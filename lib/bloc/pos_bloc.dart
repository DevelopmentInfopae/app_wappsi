import 'dart:async';

import 'dart:math';

// import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:pos_wappsi/environment/environment.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/documents_types_model.dart';

import 'package:pos_wappsi/models/payment_methods_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
// import 'package:pos_wappsi/models/suspended_sale_model.dart';
import 'package:pos_wappsi/models/units_model.dart';

import 'package:pos_wappsi/providers/products_provider.dart';
import 'package:pos_wappsi/providers/suspended_sales_provider.dart';
import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

// import 'package:pos_wappsi/utils/local_storage/local_db.dart';

import 'package:rxdart/rxdart.dart';

class POSBloc {
  // to save data of user
  bool isDisposed = false;
  BehaviorSubject<Map<String, ProductModel>> _productsController =
      BehaviorSubject<Map<String, ProductModel>>();
  BehaviorSubject<Map<String, UnitsModel>> _productUnitController =
      BehaviorSubject<Map<String, UnitsModel>>();

  BehaviorSubject<PaymentMethods?> _paymentMthdController =
      BehaviorSubject<PaymentMethods?>();

  BehaviorSubject<DocumentsTypes?> _paymentDocumentController =
      BehaviorSubject<DocumentsTypes?>();
  BehaviorSubject<int?> _paymenttermController = BehaviorSubject<int?>();

  BehaviorSubject<Map> _printDataController = BehaviorSubject<Map>();

  BehaviorSubject<CompanyModel?> _customerController =
      BehaviorSubject<CompanyModel?>();

  BehaviorSubject<CustomerAddressesModel?> _customerAddressesController =
      BehaviorSubject<CustomerAddressesModel?>();

  // final _productsViewController =
  // StreamController<Map<String, ProductModel>>.broadcast();

  StreamController<double> _subtotalController =
      StreamController<double>.broadcast();

  BehaviorSubject<int> _paymentValueController = BehaviorSubject<int>();

  /// To know if sale is loaded from suspended sale and verify or not prices
  BehaviorSubject<int> _verifyPricesController = BehaviorSubject<int>();

  BehaviorSubject<String> _invoiceNoteController = BehaviorSubject<String>();

  BehaviorSubject<String> _dispatchNoteController = BehaviorSubject<String>();

  StreamController<List<ProductModel>> _productSearchController =
      StreamController<List<ProductModel>>.broadcast();

  //-----------------------------------------------------------------------------
  //                                STREAMS
  //
  //-----------------------------------------------------------------------------

  Stream<Map<String, ProductModel>> get productsStream =>
      _productsController.stream.asBroadcastStream();

  Stream<List<ProductModel>> get productSearchStream =>
      _productSearchController.stream;

  // Stream<Map<String, ProductModel>> get productViewStream =>
  // _productsViewController.stream;

  Stream<Map<String, UnitsModel>> get productsUnitStream =>
      _productUnitController.stream;

  Stream<double> get subTotalStream => _subtotalController.stream;

  Stream<int> get paymentValueStream => _paymentValueController.stream;

  Stream<String> get invoiceNoteStream => _invoiceNoteController.stream;

  Stream<String> get dispatchNoteStream => _dispatchNoteController.stream;

  //______________________________________
  //
  //                                       Functions
  //_____________________________________

  ///Add a producto to a Map where key is the local id of product
  ///and value is an instance of ProductModel(). Param getPrices is
  ///used to know if product prices should or not be calculated
  Future addProduct(Map<String, dynamic> productReq,
      {bool getPrices = true, bool getQttys = true}) async {
    bool res = false;
    if (_productsController.hasValue) {
      res = await _addProductToProductPOSMap(
          productReq['product'], getPrices, getQttys,
          unit: productReq['product_unit']);
    } else {
      emptyProductsAdded();
      res = await _addProductToProductPOSMap(
          productReq['product'], getPrices, getQttys,
          unit: productReq['product_unit']);
    }
    setSubTotal(getSubTotal());
    return res;
  }

  /// Add product to sale product list, if getPrices = true, calculate
  /// product prices
  Future<bool> _addProductToProductPOSMap(
      ProductModel product, bool getPrices, bool getQttys,
      {UnitsModel? unit}) async {
    bool res = false;
    if (dataBloc.settings!['item_addition'] == 1) {
      final key = product.id.toString() + ((unit?.id ?? '').toString());
      final p = getProductData(key);
      if (p == null) {
        // add product unit if product unit is selected
        // product.quantity = 1;
        if (unit != null) {
          addProductUnit(key, unit);
          // product.unit = unit.idCloud;
        }

        final temp = {key: product};
        temp.addAll(_productsController.value);
        _productsController.value = temp;
        // if get prices = true, then we calculate prices based on price policy
        res =
            getPrices ? await ProductsProvider.getPOSProductPrices(key) : false;

        if (res) {
          if (getQttys) {
            res = await addProductQuantity(key, product.quantity);
          }
        }
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
        _addProductToProductPOSMap(product, getPrices, getQttys, unit: unit);
      } else {
        // add product unit if product unit is selected
        if (unit != null) {
          addProductUnit(key, unit);
          product.unit = unit.idCloud;
        }

        final temp = {key: product};
        temp.addAll(_productsController.value);
        _productsController.value = temp;
        res =
            getPrices ? await ProductsProvider.getPOSProductPrices(key) : false;
        if (res) {
          if (getQttys) {
            res = await addProductQuantity(key, product.quantity);
          }
        }
      }

      // product.quantity = 1;

    }
    reloadProductStream();
    return res;
  }

  ///Returns a Map<String,dynamic>, where the keys are the same of
  ///SaleModel.fromJson(), it could be usefull to build an instance of
  ///SaleModel to send to an endpoint of API's service.
  Map<String, dynamic> getProductDetailMapLists() {
    return ProductModel.getProductDetailMapLists(_productsController.value,
        dataBloc.userData!.warehouseId, _productUnitController.valueOrNull);
  }

  /// Modify quantity field of a ProductModel() given a key and a value
  Future<bool> addProductQuantity(String key, double value) async {
    bool res = false;
    if (dataBloc.settings?.isNotEmpty ?? false) {
      // printConsole(dataBloc.settings?['overselling']??);
      // verify overselling setting to avoid overselling or not
      if (dataBloc.settings!['overselling'] == 0) {
        if (_productsController.value[key]!.inventory < value) {
          if (_productsController.value[key]!.inventory > 0) {
            _productsController.value[key]!.quantity =
                _productsController.value[key]!.inventory.toDouble();

            setSubTotal(getSubTotal());
          } else {
            _productsController.value.remove(key);
            res = false;
          }
        } else {
          _productsController.value[key]!.quantity = value;

          setSubTotal(getSubTotal());
          res = true;
        }
      } else {
        _productsController.value[key]!.quantity = value;

        setSubTotal(getSubTotal());
        res = true;
      }
      // reloadProductStream();
      // _updateProductViewQuantity(key,value);
    } else {
      await dataBloc.getSettings();
      res = await addProductQuantity(key, value);
    }
    return res;
  }

  List<Map<String, dynamic>> getProductsMap() {
    if (_productsController.hasValue) {
      List<Map<String, dynamic>> products = List.from(
          _productsController.value.values.map((value) => value.toJson()));
      return products;
    } else {
      return [];
    }
  }

  /// Function to reload product data, costumer data and customer addresses data
  Future<bool> reloadPOSData() async {
    final customer = await CompanyModel.getCompanyDetails(
        _customerController.value!.idCloud!);
    if (customer != null) {
      setCustomer(customer);
      final res = await reloadProducts();
      return res;
    } else {
      return false;
    }
  }

  /// When parameters of product price calculation change, it's
  /// neccesary to recalculate product prices, this function make
  /// current product list empty and then introduce all products
  /// again recalculating prices for parameters.
  Future<bool> reloadProducts() async {
    if (_productsController.hasValue) {
      try {
        // String keyInitialQtty = 'initial_qtty';
        final Map<String, ProductModel> temp = _productsController.value;
        Map<String, UnitsModel> pUnits = {};
        if (_productUnitController.hasValue) {
          pUnits = getProductUnits!;
        }

        /// Empty current product list
        emptyProductsAdded();
        await Future.forEach(temp.keys, (String key) async {
          // Map<String, dynamic>? temp2 =
          //     await ProductsProvider.findProductDetails(temp[key]!.idCloud);
          // if (temp2 != null) {
          // Map<String, dynamic> pData = queryResultToMap(temp2);
          // pData[keyInitialQtty] = temp[key]!.quantity;
          // final product = ProductModel.fromJson(pData,
          //     loadInitialQtty: true, qtyKey: keyInitialQtty);
          await addProduct({'product': temp[key], 'product_unit': pUnits[key]},
              getQttys: false);
          // }
        });

        return true;
      } catch (e) {
        // printConsole(e);
        await logError(e, from: 'Reload pos products');
        return false;
      }
    } else {
      return false;
    }
  }

  /// Makes product Map empty
  emptyProductsAdded() {
    _productsController.value = {};
  }

  reloadProductStream() {
    _productsController.sink.add(_productsController.value);
  }

  /// Remove a product from products Map given a key, if product have an asosiate
  /// unit, remove unit too
  removeProduct(String key) {
    _productsController.value.remove(key);
    reloadProductStream();
    setSubTotal(getSubTotal());
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
    return _productsController.value[key];
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
  double getSubTotal() {
    double subTotal = 0;
    // ignore: unnecessary_null_comparison
    if (_productsController.hasValue) {
      for (var element in _productsController.value.values) {
        double temp = element.getPriceWithIVA() * element.quantity;
        subTotal = subTotal + temp;
      }
    }

    return subTotal;
  }

  /// Returns total price of products without aplying customer discount.
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

  /// Returns total items in products Map
  int getItemsCount() {
    double count = 0;
    // ignore: unnecessary_null_comparison
    if (_productsController.hasValue) {
      for (var element in _productsController.value.values) {
        double temp = element.quantity;
        count = (count + temp);
      }
    }

    return count.toInt();
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
        'name': element.taxRateName
      };
      // printConsole('xd');
    }

    return ivasMap;
  }

  Future<bool> suspendSale({String keyWord = ''}) async {
    final res = await SuspendedSalesProvider.suspendSale(keyWord: keyWord);
    if (res == true) {
      _emptyPosData();
    }

    return res;
  }

  /// Load suspended sale recalculating product prices
  Future<List<Map<String, dynamic>>> loadSuspendedSale(String id) async {
    _emptyPosData();
    final res = await SuspendedSalesProvider.loadSale(id);

    return res;
  }

  /// Load suspended sale with suspended sale product prices
  Future<List<Map<String, dynamic>>> loadSuspSaleWPrices(String id) async {
    _emptyPosData();
    _verifyPricesController.value = 0;
    final res = await SuspendedSalesProvider.loadSale(id, getPrices: false);

    return res;
  }

  _emptyPosData() {
    emptyProductsAdded();
    _paymenttermController.value = null;
    _customerAddressesController.value = null;
    _customerController.value = null;
    _paymentMthdController.value = null;
    _paymentDocumentController.value = null;
    _paymentValueController.value = 0;
    _dispatchNoteController.value = '';
    _invoiceNoteController.value = '';
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

  String? getCustomerId() {
    if (_customerController.hasValue) {
      return _customerController.value?.idCloud;
    } else {
      return '0';
    }
  }

  //__________________________
  //
  //                                       GETTERS
  //_____________________________________

  CompanyModel? get getCustomer => _customerController.valueOrNull;

  Map<String, UnitsModel>? get getProductUnits =>
      _productUnitController.valueOrNull;

  // Map<String, dynamic> get settings => _settingsController.value;

  // bool get getPrintState => _printStateController.valueOrNull??false;

  Map<String, ProductModel>? get getProducts => _productsController.valueOrNull;

  Map? get getPrintData => _printDataController.valueOrNull;

  PaymentMethods? get getPaymentMethod => _paymentMthdController.valueOrNull;

  DocumentsTypes? get getPaymentDocument =>
      _paymentDocumentController.valueOrNull;

  CustomerAddressesModel? get getCustomerAddresses =>
      _customerAddressesController.valueOrNull;

  Map<String, ProductModel> get productsAdded {
    if (!_productsController.hasValue) {
      emptyProductsAdded();
    }

    return _productsController.value;
  }

  String? get getInvoiceNote => _invoiceNoteController.valueOrNull;

  String? get getDispatchNote => _dispatchNoteController.valueOrNull;

  int? get getPaymentTerm => _paymenttermController.valueOrNull;

  int? get getPaymentValue => _paymentValueController.valueOrNull;

  int? get getVerifyPrices => _verifyPricesController.valueOrNull;

  //__________________________
  //
  //                                       SETTERS
  //__________________________

  setCustomer(CompanyModel? customer) {
    _customerController.sink.add(customer);
  }

  // Function(bool) get setPrintState => _printStateController.sink.add;

  Function(Map) get setPrintData => _printDataController.sink.add;

  Function(PaymentMethods?) get setPaymentMethod =>
      _paymentMthdController.sink.add;

  Function(DocumentsTypes?) get setPaymentDocument =>
      _paymentDocumentController.sink.add;

  // Function get setSettings =>
  // _settingsController.sink.add;

  Function(CustomerAddressesModel?) get setCustomerAddresses =>
      _customerAddressesController.sink.add;

  Function(List<ProductModel>) get setProductSearchData =>
      _productSearchController.sink.add;

  // Function(Map<String, ProductModel>) get setProductView =>
  //     // _productsViewController.sink.add;

  Function(String) get setInvoiceNote => _invoiceNoteController.sink.add;

  Function(String) get setDispatchNote => _dispatchNoteController.sink.add;

  Function(int?) get setPaymentTerm => _paymenttermController.sink.add;

  Function(double) get setSubTotal => _subtotalController.sink.add;

  Function(int) get setVerifyPrices => _verifyPricesController.sink.add;

  Function(int) get setPaymentValue => _paymentValueController.sink.add;

  dispose() {
    isDisposed = true;
    _productsController.close();
    _productSearchController.close();
    // _productsViewController.close();
    _subtotalController.close();
    _paymentValueController.close();
    _invoiceNoteController.close();
    _dispatchNoteController.close();
    _verifyPricesController.close();
    _customerController.close();
    _customerAddressesController.close();
    _paymentMthdController.close();
    _productUnitController.close();
    // _settingsController.close();
    _paymentDocumentController.close();
    _printDataController.close();

    _paymenttermController.close();
    // _printStateController.close();
  }

  reload({bool disposeFirst = false}) {
    if (disposeFirst) {
      dispose();
    }
    isDisposed = false;
    _productsController = BehaviorSubject<Map<String, ProductModel>>();
    _productUnitController = BehaviorSubject<Map<String, UnitsModel>>();

    _paymentMthdController = BehaviorSubject<PaymentMethods?>();
    _paymentDocumentController = BehaviorSubject<DocumentsTypes?>();
    _paymenttermController = BehaviorSubject<int?>();
    _printDataController = BehaviorSubject<Map>();

    _customerController = BehaviorSubject<CompanyModel?>();

    _customerAddressesController = BehaviorSubject<CustomerAddressesModel?>();

    // final _productsViewController =
    // StreamController<Map<String, ProductModel>>.broadcast();

    _subtotalController = StreamController<double>.broadcast();

    _paymentValueController = BehaviorSubject<int>();

    /// To know if sale is loaded from suspended sale and verify or not prices
    _verifyPricesController = BehaviorSubject<int>();

    _invoiceNoteController = BehaviorSubject<String>();

    _dispatchNoteController = BehaviorSubject<String>();

    _productSearchController = StreamController<List<ProductModel>>.broadcast();
  }
}

final posBloc = POSBloc();
