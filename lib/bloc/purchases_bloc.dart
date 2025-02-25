import 'dart:async';
import 'dart:math';

// import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/models/companies_model.dart';
// import 'package:pos_wappsi/environment/environment.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/models/documents_types_model.dart';
import 'package:pos_wappsi/models/payment_methods_model.dart';
// import 'package:pos_wappsi/models/documents_types_model.dart';

// import 'package:pos_wappsi/models/payment_methods_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/purchase_model.dart';
// import 'package:pos_wappsi/models/suspended_sale_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
// import 'package:pos_wappsi/providers/suspended_sales_provider.dart';

// import 'package:pos_wappsi/utils/local_storage/local_db.dart';

import 'package:rxdart/rxdart.dart';

class PurchaseBloc {
  // to save data of user
  bool isDisposed = false;
  BehaviorSubject<Map<String, ProductModel>> _productsController =
      BehaviorSubject<Map<String, ProductModel>>();
  BehaviorSubject<Map<String, UnitsModel>> _productUnitController =
      BehaviorSubject<Map<String, UnitsModel>>();

  BehaviorSubject<Map> _printDataController = BehaviorSubject<Map>();

  BehaviorSubject<PaymentMethods?> _paymentMethodController =
      BehaviorSubject<PaymentMethods?>();

  BehaviorSubject<CompanyModel?> _supplierController =
      BehaviorSubject<CompanyModel?>();
  BehaviorSubject<double?> _discountController = BehaviorSubject<double?>();

  BehaviorSubject<CustomerAddressesModel?> _customerAddressesController =
      BehaviorSubject<CustomerAddressesModel?>();

  // final _productsViewController =
  // StreamController<Map<String, ProductModel>>.broadcast();

  StreamController<double> _subtotalCostController =
      StreamController<double>.broadcast();

  StreamController<List<ProductModel>> _productSearchController =
      StreamController<List<ProductModel>>.broadcast();

  BehaviorSubject<String> _payNoteController = BehaviorSubject<String>();

  BehaviorSubject<PurchaseModel?> _purchaseInfoController =
      BehaviorSubject<PurchaseModel?>();

  BehaviorSubject<DocumentsTypes?> _documentController =
      BehaviorSubject<DocumentsTypes?>();

  //-----------------------------------------------------------------------------
  //                                STREAMS
  //
  //-----------------------------------------------------------------------------

  Stream<Map<String, ProductModel>> get productsStream =>
      _productsController.stream.asBroadcastStream();

  Stream<double?> get discountStream =>
      _discountController.stream.asBroadcastStream();

  Stream<List<ProductModel>> get productSearchStream =>
      _productSearchController.stream;

  // Stream<Map<String, ProductModel>> get productViewStream =>
  // _productsViewController.stream;

  Stream<Map<String, UnitsModel>> get productsUnitStream =>
      _productUnitController.stream;

  Stream<double> get subTotalCostStream =>
      _subtotalCostController.stream.asBroadcastStream();

  //______________________________________
  //
  //                                       Functions
  //_____________________________________

  ///Add a producto to a Map where key is the local id of product
  ///and value is an instance of ProductModel(). Param getPrices is
  ///used to know if product prices should or not be calculated
  Future addProduct(
    Map<String, dynamic> productReq, {
    bool getPrices = true,
    bool getQttys = true,
  }) async {
    bool res = false;
    if (_productsController.hasValue) {
    } else {
      emptyProductsAdded();
    }
    res = await _addProductToProductMap(
      productReq['product'],
      unit: productReq['product_unit'],
    );
    getSubTotalCost();
    return res;
  }

  /// Add product to sale product list, if getPrices = true, calculate
  /// product prices
  Future<bool> _addProductToProductMap(
    ProductModel product, {
    UnitsModel? unit,
  }) async {
    bool res = false;
    if (dataBloc.settings!['item_addition'] == 1) {
      final key = product.id.toString() + ((unit?.id ?? '').toString());
      final p = getProductData(key);
      if (p == null) {
        // add product unit if product unit is selected
        // product.quantity = 1;
        if (unit != null) {
          addProductUnit(key, unit);
          product.unit = unit.idCloud;
        }

        final temp = {key: product};
        temp.addAll(_productsController.value);
        _productsController.value = temp;

        res = await addProductQuantity(key, product.quantity);
      } else {
        // add the incoming product initial value
        res = await addProductQuantity(key, p.quantity + product.quantity);
      }
    } else if (dataBloc.settings!['item_addition'] == 0) {
      Random random = Random();
      int randomNumber = random.nextInt(300);
      final key = product.id.toString() + '-' + randomNumber.toString();

      /// gen an unique key for each product
      if (_productsController.value.keys.contains(key)) {
        _addProductToProductMap(product, unit: unit);
      } else {
        // add product unit if product unit is selected
        if (unit != null) {
          addProductUnit(key, unit);
          product.unit = unit.idCloud;
        }

        final temp = {key: product};
        temp.addAll(_productsController.value);
        _productsController.value = temp;

        res = await addProductQuantity(key, product.quantity);
      }

      // product.quantity = 1;
    }
    reloadProductStream();
    return res;
  }

  ///Returns a Map<String,dynamic>, where the keys are the same of
  ///PurchaseModel.fromJson(), it could be useful to build an instance of
  ///PurchaseModel to send to an endpoint of API's service.
  Map<String, dynamic> getProductDetailMapLists() {
    return ProductModel.getProductDetailMapLists(
      _productsController.value,
      dataBloc.userData!.warehouseId,
      _productUnitController.valueOrNull,
      (String v) {},
    );
  }

  /// Modify quantity field of a ProductModel() given a key and a value
  Future<bool> addProductQuantity(String key, double value) async {
    bool res = false;

    // printConsole(dataBloc.settings?['overselling']??);
    // verify overselling setting to avoid overselling or not

    _productsController.value[key]!.quantity = value;
    // setProductView(_productsController.value);
    getSubTotalCost();

    res = true;

    return res;
  }

  List<Map<String, dynamic>> getProductsMap() {
    if (_productsController.hasValue) {
      List<Map<String, dynamic>> products = List.from(
        _productsController.value.values.map((value) => value.toJson()),
      );
      return products;
    } else {
      return [];
    }
  }

  /// Makes product Map empty
  emptyProductsAdded() {
    _productsController.value = {};
  }

  reloadProductStream() {
    _productsController.sink.add(_productsController.value);
  }

  /// Remove a product from products Map given a key, if product have an associate
  /// unit, remove unit too
  removeProduct(String key) {
    _productsController.value.remove(key);
    reloadProductStream();
    _subtotalCostController.sink.add(getSubTotalCost());

    if (_productUnitController.hasValue) {
      try {
        _productUnitController.value.remove(key);
      } catch (e) {
        printConsole(e);
      }
    }
  }

  /// Returns an instance of [ProductModel()] from products Map
  /// given a key
  ProductModel? getProductData(String key) {
    return _productsController.valueOrNull?[key];
  }

  /// Returns product information in [Map] format
  Future<List<Map>?> getProductsListMap() async {
    List<Map> productsMap = [];
    for (var key in _productsController.value.keys) {
      final pInfo = getProducts![key]!.toJson();
      UnitsModel? unitS = getProductUnits?[key];
      pInfo['unit'] = unitS?.toJson();
      if (unitS != null) {
        final baseUnit = await UnitsProvider.getUnitInfo(unitS.baseUnit);
        pInfo['base_unit'] = baseUnit?.toJson();
      }
      productsMap.add(pInfo);
    }

    return productsMap;
  }

  /// Returns sum of products.getPriceWithIVA() * products.quantity
  double getSubTotalCost() {
    double subTotal = getSubTotalCostWithoutDiscount();

    double total = subTotal - getDiscount;
    if (total < 0) {
      total = 0;
    }
    _subtotalCostController.sink.add(total);

    return total;
  }

  /// Returns sum of products.getPriceWithIVA() * products.quantity
  double getSubTotalCostWithoutDiscount() {
    double subTotal = 0;
    // ignore: unnecessary_null_comparison
    if (_productsController.hasValue) {
      for (var element in _productsController.value.values) {
        double temp = element.getCostWithIVA() * element.quantity;
        subTotal = subTotal + temp;
      }
    }

    return subTotal;
  }

  /// Returns total price of products without applying customer discount.
  double getTotalWithoutDiscount() {
    double total = 0;
    // ignore: unnecessary_null_comparison
    if (_productsController.hasValue) {
      for (var element in _productsController.value.values) {
        double temp = element.priceWithoutDiscount! * element.quantity;
        total = total + temp;
      }
    }

    return total;
  }

  /// Returns sum of IVA value from all products in products Map.
  double getTotalIVA() {
    double total = 0.0;
    if (_productsController.hasValue) {
      for (var element in _productsController.value.values) {
        double temp =
            (element.getPriceWithIVA() - element.getPriceWithoutIVA()) *
                element.quantity;
        total = total + temp;
      }
    }
    return total;
  }

  /// Returns sum of IVA value from all products in products Map.
  double getTotalWithNoIVA() {
    double total = 0.0;
    if (_productsController.hasValue) {
      for (var element in _productsController.value.values) {
        double temp = (element.getPriceWithoutIVA()) * element.quantity;
        total = total + temp;
      }
    }
    return total;
  }

  /// Returns total items in products Map
  int getItemsCount() {
    int count = 0;
    // ignore: unnecessary_null_comparison
    if (_productsController.hasValue) {
      for (var element in _productsController.value.values) {
        double temp = element.quantity;
        count = (count + temp).toInt();
      }
    }

    return count;
  }

  /// Return the num of unique products in products Map.
  int getProductsCount() {
    return _productsController.value.length;
  }

  Map getIVAs() {
    Map ivasMap = {};
    Map temp = {};
    for (var element in _productsController.value.values) {
      temp[element.taxRate] = (temp[element.taxRate] ?? 0.0) +
          element.getPriceWithoutIVA() * element.quantity;
      ivasMap[element.taxRate] = {
        'value': temp[element.taxRate],
        'name': element.taxRateName,
      };
      // printConsole('xd');
    }

    return ivasMap;
  }

  bool addProductUnit(String productKey, UnitsModel unit) {
    try {
      if (!_productUnitController.hasValue) {
        _productUnitController.value = {};
      }
      _productUnitController.value[productKey] = unit;
      return true;
    } catch (e) {
      return false;
    }
  }

  //-----------------------------------------------------------------------------
  //                                CUSTOMER
  //
  //-----------------------------------------------------------------------------

  String getCustomerId() {
    if (_supplierController.hasValue) {
      return _supplierController.value!.idCloud!;
    } else {
      return '0';
    }
  }

  //__________________________
  //
  //                                       GETTERS
  //_____________________________________

  CompanyModel? get getSupplier => _supplierController.valueOrNull;

  Map<String, UnitsModel>? get getProductUnits =>
      _productUnitController.valueOrNull;

  UnitsModel? getUnitDetails(String key) {
    return _productUnitController.valueOrNull?[key];
  }

  DocumentsTypes? get getDocumentType => _documentController.valueOrNull;

  // Map<String, dynamic> get settings => _settingsController.value;

  // bool get getPrintState => _printStateController.valueOrNull??false;

  Map<String, ProductModel>? get getProducts => _productsController.valueOrNull;

  Map? get getPrintData => _printDataController.valueOrNull;

  String? getDate() {
    if (!_purchaseInfoController.hasValue) {
      _purchaseInfoController.value = PurchaseModel();
    }
    return _purchaseInfoController.value?.date ?? '';
  }

  double get getDiscount => _discountController.valueOrNull ?? 0;

  double getTotalDiscount() {
    return _discountController.valueOrNull ?? 0;
  }

  PurchaseModel? get getPurchase => _purchaseInfoController.value!;

  String? get getReference => _purchaseInfoController.value?.referenceNo;
  String? get getSupplierConsecutive =>
      _purchaseInfoController.value?.consecutiveSupplier;
  String? get getPayNote => _payNoteController.valueOrNull;
  PaymentMethods? get getPaymentMethod => _paymentMethodController.valueOrNull;

  CustomerAddressesModel? get getCustomerAddresses =>
      _customerAddressesController.valueOrNull;

  Map<String, ProductModel> get productsAdded {
    if (!_productsController.hasValue) {
      emptyProductsAdded();
    }

    return _productsController.value;
  }

  //__________________________
  //
  //                                       SETTERS
  //__________________________

  setCustomer(CompanyModel? customer) {
    _supplierController.sink.add(customer);
  }

  Function(PaymentMethods?) get setPaymentMethod =>
      _paymentMethodController.sink.add;
  void setReference(String reference) {
    if (!_purchaseInfoController.hasValue) {
      _purchaseInfoController.value = PurchaseModel();
    }
    _purchaseInfoController.value?.referenceNo = reference;
  }

  void setSupplierConsecutive(String consecutive) {
    if (!_purchaseInfoController.hasValue) {
      _purchaseInfoController.value = PurchaseModel();
    }
    _purchaseInfoController.value?.consecutiveSupplier = consecutive;
  }

  void setDate(String date) {
    if (!_purchaseInfoController.hasValue) {
      _purchaseInfoController.value = PurchaseModel();
    }
    _purchaseInfoController.value?.date = date;
  }

  Function(String) get setPayNote => _payNoteController.sink.add;
  Function(double) get setDiscount => _discountController.sink.add;

  // Function(bool) get setPrintState => _printStateController.sink.add;

  Function(Map) get setPrintData => _printDataController.sink.add;

  // Function get setSettings =>
  // _settingsController.sink.add;

  Function(CustomerAddressesModel?) get setCustomerAddresses =>
      _customerAddressesController.sink.add;

  Function(DocumentsTypes?) get setDocumentType => _documentController.sink.add;

  Function(List<ProductModel>) get setProductSearchData =>
      _productSearchController.sink.add;

  // Function(Map<String, ProductModel>) get setProductView =>
  //     // _productsViewController.sink.add;

  dispose() {
    isDisposed = true;
    // _productsViewController.close();
    _productsController.close();
    _productSearchController.close();
    _subtotalCostController.close();
    _supplierController.close();
    _customerAddressesController.close();
    _paymentMethodController.close();
    _purchaseInfoController.close();
    _documentController.close();
    _payNoteController.close();
    _productUnitController.close();
    _discountController.close();
    _printDataController.close();

    // _printStateController.close();
  }

  reload({bool disposeFirst = false}) {
    if (disposeFirst) {
      dispose();
    }
    isDisposed = false;
    _productsController = BehaviorSubject<Map<String, ProductModel>>();
    _productUnitController = BehaviorSubject<Map<String, UnitsModel>>();

    _printDataController = BehaviorSubject<Map>();
    _paymentMethodController = BehaviorSubject<PaymentMethods>();
    _purchaseInfoController = BehaviorSubject<PurchaseModel?>();
    _payNoteController = BehaviorSubject<String>();
    _supplierController = BehaviorSubject<CompanyModel?>();
    _documentController = BehaviorSubject<DocumentsTypes?>();
    _customerAddressesController = BehaviorSubject<CustomerAddressesModel?>();

    _subtotalCostController = StreamController<double>.broadcast();
    _productSearchController = StreamController<List<ProductModel>>.broadcast();
    _discountController = BehaviorSubject<double?>();
  }
}

final purchaseBloc = PurchaseBloc();
