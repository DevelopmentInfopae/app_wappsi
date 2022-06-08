import 'dart:async';

import 'dart:math';

// import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:pos_wappsi/environment/environment.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/documents_types_model.dart';
import 'package:pos_wappsi/models/payment_methods_model.dart';
import 'package:pos_wappsi/models/preference_category_model.dart';
import 'package:pos_wappsi/models/preference_model.dart';
// import 'package:pos_wappsi/models/documents_types_model.dart';

// import 'package:pos_wappsi/models/payment_methods_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
// import 'package:pos_wappsi/models/suspended_sale_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';

import 'package:pos_wappsi/providers/products_provider.dart';
import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
// import 'package:pos_wappsi/providers/suspended_sales_provider.dart';

// import 'package:pos_wappsi/utils/local_storage/local_db.dart';

import 'package:rxdart/rxdart.dart';

class QuoteBloc {
  // to save data of user
  bool isDisposed = false;
  BehaviorSubject<Map<String, ProductModel>> _productsController =
      BehaviorSubject<Map<String, ProductModel>>();
  BehaviorSubject<Map<String, UnitsModel>> _productUnitController =
      BehaviorSubject<Map<String, UnitsModel>>();

  BehaviorSubject<Map> _printDataController = BehaviorSubject<Map>();

  BehaviorSubject<PaymentMethods?> _paymentMthdController =
      BehaviorSubject<PaymentMethods?>();

  BehaviorSubject<CompanyModel?> _customerController =
      BehaviorSubject<CompanyModel?>();
  BehaviorSubject<double?> _discountController = BehaviorSubject<double?>();

  BehaviorSubject<CustomerAddressesModel?> _customerAddressesController =
      BehaviorSubject<CustomerAddressesModel?>();

  // final _productsViewController =
  // StreamController<Map<String, ProductModel>>.broadcast();

  StreamController<double> _subtotalController =
      StreamController<double>.broadcast();

  StreamController<List<ProductModel>> _productSearchController =
      StreamController<List<ProductModel>>.broadcast();

  BehaviorSubject<String> _quoteNoteController = BehaviorSubject<String>();

  BehaviorSubject<String> _internalNoteController = BehaviorSubject<String>();

  BehaviorSubject<DocumentsTypes?> _quoteDocumentController =
      BehaviorSubject<DocumentsTypes?>();

  BehaviorSubject<
          Map<String, Map<PreferenceCategoryModel, List<PreferenceModel>>>?>
      _productPrefsController = BehaviorSubject<
          Map<String, Map<PreferenceCategoryModel, List<PreferenceModel>>>?>();

  //-----------------------------------------------------------------------------
  //                                STREAMS
  //
  //-----------------------------------------------------------------------------

  Stream<Map<String, ProductModel>> get productsStream =>
      _productsController.stream.asBroadcastStream();

  Stream<double?> get quoteDiscountStream =>
      _discountController.stream.asBroadcastStream();

  Stream<List<ProductModel>> get productSearchStream =>
      _productSearchController.stream;

  // Stream<Map<String, ProductModel>> get productViewStream =>
  // _productsViewController.stream;

  Stream<Map<String, UnitsModel>> get productsUnitStream =>
      _productUnitController.stream;

  Stream<double> get subTotalStream =>
      _subtotalController.stream.asBroadcastStream();

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
    if (!_productsController.hasValue) {
      emptyProductsAdded();
    }
    res = await _addProductToProductQuoteMap(
        productReq['product'], getPrices, getQttys,
        unit: productReq['product_unit'], prefs: productReq['product_prefs']);
    getSubTotal();
    return res;
  }

  /// Add product to sale product list, if getPrices = true, calculate
  /// product prices
  Future<bool> _addProductToProductQuoteMap(
      ProductModel product, bool getPrices, bool getQttys,
      {UnitsModel? unit,
      Map<PreferenceCategoryModel, List<PreferenceModel>>? prefs}) async {
    bool res = false;
    try {
      if (dataBloc.settings!['item_addition'] == 1) {
        String prefsKey = '';
        String pUnitKey = '';
        if (prefs == null) {
          pUnitKey = product.id.toString() + ((unit?.id ?? '').toString());
        } else {
          prefsKey = _prefsKey(prefs, prefsKey);
        }
        String key = pUnitKey + prefsKey;
        if (prefs?.isNotEmpty ?? false) {
          addProductPrefs(key, prefs!);
        }
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
          // if get prices = true, then we calculate prices based on price policy
          res = getPrices
              ? await ProductsProvider.getPOSProductPrices(key, toQuote: true)
              : false;
          res;
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
          _addProductToProductQuoteMap(product, getPrices, getQttys,
              unit: unit, prefs: prefs);
        } else {
          // add product unit if product unit is selected
          if (unit != null) {
            addProductUnit(key, unit);
            product.unit = unit.idCloud;
          }
          if (prefs?.isNotEmpty ?? false) {
            addProductPrefs(key, prefs!);
          }

          final temp = {key: product};
          temp.addAll(_productsController.value);
          _productsController.value = temp;
          res = getPrices
              ? await ProductsProvider.getPOSProductPrices(key, toQuote: true)
              : false;
          if (res) {
            if (getQttys) {
              res = await addProductQuantity(key, product.quantity);
            }
          }
        }

        // product.quantity = 1;

      }
    } on Exception catch (e) {
      await logError(e, from: 'Adding product to quote');
    }
    reloadProductStream();
    return res;
  }

  String _prefsKey(Map<PreferenceCategoryModel, List<PreferenceModel>> prefs,
      String prefsKey) {
    final List<int> prefsId = [];
    if (prefs.isNotEmpty) {
      for (var prefCat in prefs.keys) {
        prefs[prefCat]?.forEach((pref) {
          prefsId.add(pref.id);
          // prefsKey += pref.id ?? '';
        });
      }
    }
    prefsId.sort();
    prefsKey = prefsId.join();
    return prefsKey;
  }

  ///Returns a Map<String,dynamic>, where the keys are the same of
  ///SaleModel.fromJson(), it could be usefull to build an instance of
  ///SaleModel to send to an endpoint of API's service.
  Map<String, dynamic> getProductDetailMapLists() {
    return ProductModel.getProductDetailMapLists(
        _productsController.value,
        dataBloc.userData!.warehouseId,
        _productUnitController.valueOrNull,
        getProductPrefsText);
  }

  /// Modify quantity field of a ProductModel() given a key and a value
  Future<bool> addProductQuantity(String key, double value) async {
    bool res = false;
    if (dataBloc.settings?.isNotEmpty ?? false) {
      // verify overselling setting to avoid overselling or not
      if (dataBloc.settings!['overselling'] == 0) {
        final p = await ProductsProvider.getProductDetails(
            _productsController.value[key]!.id.toString(), true);
        _productsController.value[key]!.inventory =
            p?.inventory ?? _productsController.value[key]!.inventory;
        if (_productsController.value[key]!.inventory < value) {
          if (_productsController.value[key]!.inventory > 0) {
            _productsController.value[key]!.quantity =
                _productsController.value[key]!.inventory.toDouble();
            // setProductView(_productsController.value);
          } else {
            _productsController.value.remove(key);
            res = false;
          }
        } else {
          _productsController.value[key]!.quantity = value;
          // setProductView(_productsController.value);
          res = true;
        }
        // reloadProductStream();
      } else {
        _productsController.value[key]!.quantity = value;
        // setProductView(_productsController.value);
        res = true;
      }
      // reloadProductStream();
      // _updateProductViewQuantity(key,value);
    } else {
      await dataBloc.getSettings();
      res = await addProductQuantity(key, value);
    }
    getSubTotal();

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
    final customer = await DBProvider.db.findTableFieldsById(
        'sma_companies', _customerController.value!.idCloud!);
    if (customer != null) {
      setCustomer(CompanyModel.fromJson(customer));
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
        await logError(e, from: 'Reloading quote products');

        printConsole(e);
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
    getSubTotal();
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
      pInfo['preferences'] = getProductPrefsText(key);
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
    double subTotal = getSubTotalWithoutDiscount();

    double total = subTotal - getQuoteDiscount;
    if (total < 0) {
      total = 0;
    }
    _subtotalController.sink.add(total);

    return total;
  }

  /// Returns sum of products.getPriceWithIVA() * products.quantity
  double getSubTotalWithoutDiscount() {
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
        'name': element.taxRateName
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

  addProductPrefs(String productKey,
      Map<PreferenceCategoryModel, List<PreferenceModel>> prefs) {
    try {
      if (!_productPrefsController.hasValue) {
        _productPrefsController.value = {};
      }
      _productPrefsController.value?[productKey] = prefs;
    } catch (e) {
      printConsole(e);
    }
  }

  String prefsText(String productKey) {
    String prefsText = '';

    if (_productPrefsController.hasValue) {
      final temp = _productPrefsController.value![productKey];
      if (temp != null) {
        if ((temp).isNotEmpty) {
          for (var prefCat in temp.keys) {
            String text = '';

            for (PreferenceModel element in (temp[prefCat] ?? [])) {
              if (element == temp[prefCat]?.last) {
                text += '' + element.name!;
              } else {
                text += '' + element.name! + ', ';
              }
            }
            if (text.isNotEmpty) {
              if (prefsText.isNotEmpty) {
                prefsText += " / " + text;
              } else {
                prefsText += text;
              }
            }
          }
        }
      }
    }
    return prefsText;
  }

  String getProductPrefsText(String productKey) {
    String prefsText = '';
    try {
      for (PreferenceCategoryModel prefCat
          in (getProductPrefs?[productKey]?.keys ?? [])) {
        if (prefCat.name != null) {
          prefsText += prefCat.name! + ': ';
        } else {
          prefsText += '';
        }

        for (PreferenceModel pref
            in getProductPrefs![productKey]?[prefCat] ?? []) {
          prefsText += pref != getProductPrefs![productKey]?[prefCat]?.last
              ? ((pref.name ?? '') + ', ')
              : (pref.name ?? '');
        }
      }
    } catch (e) {
      printConsole(e);
    }
    return prefsText;
  }

  //-----------------------------------------------------------------------------
  //                                CUSTOMER
  //
  //-----------------------------------------------------------------------------

  String getCustomerId() {
    if (_customerController.hasValue) {
      return _customerController.value!.idCloud!;
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

  DocumentsTypes? get getQuoteDocumentType =>
      _quoteDocumentController.valueOrNull;

  Map<String, Map<PreferenceCategoryModel, List<PreferenceModel>>>?
      get getProductPrefs => _productPrefsController.value;

  // Map<String, dynamic> get settings => _settingsController.value;

  // bool get getPrintState => _printStateController.valueOrNull??false;

  Map<String, ProductModel>? get getProducts => _productsController.valueOrNull;

  Map? get getPrintData => _printDataController.valueOrNull;

  double get getQuoteDiscount => _discountController.valueOrNull ?? 0;
  double getTotalDiscount() {
    return _discountController.valueOrNull ?? 0;
  }

  String? get getInternalNote => _internalNoteController.valueOrNull;
  String? get getNote => _quoteNoteController.valueOrNull;
  PaymentMethods? get getPaymentMethod => _paymentMthdController.valueOrNull;

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
    _customerController.sink.add(customer);
  }

  Function(PaymentMethods?) get setPaymentMethod =>
      _paymentMthdController.sink.add;
  Function(String) get setInternalNote => _internalNoteController.sink.add;
  Function(String) get setNote => _quoteNoteController.sink.add;
  Function(double) get setQuoteDiscount => _discountController.sink.add;

  // Function(bool) get setPrintState => _printStateController.sink.add;

  Function(Map) get setPrintData => _printDataController.sink.add;

  // Function get setSettings =>
  // _settingsController.sink.add;

  Function(CustomerAddressesModel?) get setCustomerAddresses =>
      _customerAddressesController.sink.add;

  Function(DocumentsTypes?) get setQuoteDocumentType =>
      _quoteDocumentController.sink.add;

  Function(List<ProductModel>) get setProductSearchData =>
      _productSearchController.sink.add;

  // Function(Map<String, ProductModel>) get setProductView =>
  //     // _productsViewController.sink.add;

  dispose() {
    isDisposed = true;
    // _productsViewController.close();
    _productsController.close();
    _productSearchController.close();
    _subtotalController.close();
    _customerController.close();
    _customerAddressesController.close();
    _paymentMthdController.close();
    _internalNoteController.close();
    _quoteDocumentController.close();
    _quoteNoteController.close();
    _productUnitController.close();
    _discountController.close();
    _printDataController.close();

    _productPrefsController.close();

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
    _paymentMthdController = BehaviorSubject<PaymentMethods>();
    _internalNoteController = BehaviorSubject<String>();
    _quoteNoteController = BehaviorSubject<String>();
    _customerController = BehaviorSubject<CompanyModel?>();
    _quoteDocumentController = BehaviorSubject<DocumentsTypes?>();

    _customerAddressesController = BehaviorSubject<CustomerAddressesModel?>();

    _subtotalController = StreamController<double>.broadcast();
    _productSearchController = StreamController<List<ProductModel>>.broadcast();
    _discountController = BehaviorSubject<double?>();

    _productPrefsController = BehaviorSubject<
        Map<String, Map<PreferenceCategoryModel, List<PreferenceModel>>>?>();
  }
}

final quoteBloc = QuoteBloc();
