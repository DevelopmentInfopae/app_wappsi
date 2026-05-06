import 'dart:async';
import 'dart:math';

// import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/models/companies_model.dart';
// import 'package:pos_wappsi/environment/environment.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/models/documents_types_model.dart';
import 'package:pos_wappsi/models/payment_methods_model.dart';
import 'package:pos_wappsi/models/preference_category_model.dart';
import 'package:pos_wappsi/models/preference_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
// import 'package:pos_wappsi/models/suspended_sale_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/providers/price_policy_provider.dart';
import 'package:pos_wappsi/providers/products_provider.dart';
import 'package:pos_wappsi/providers/suspended_sales_provider.dart';
import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/screens/components/alerts/product_changes_alert.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
// import 'package:pos_wappsi/utils/local_storage/local_db.dart';

import 'package:rxdart/rxdart.dart';
import '../models/user_model.dart';

class POSBloc {
  // to save data of user
  bool isDisposed = false;

  ///
  String? suspendedSaleId;

  BehaviorSubject<Map<String, ProductModel>> _productsController =
      BehaviorSubject<Map<String, ProductModel>>();
  BehaviorSubject<Map<String, UnitsModel>> _productUnitController =
      BehaviorSubject<Map<String, UnitsModel>>();

  BehaviorSubject<PaymentMethods?> _paymentMethodController =
      BehaviorSubject<PaymentMethods?>();

  BehaviorSubject<DocumentsTypes?> _paymentDocumentController =
      BehaviorSubject<DocumentsTypes?>();
  BehaviorSubject<int?> _paymentTermController = BehaviorSubject<int?>();

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
  Future addProduct(
    Map<String, dynamic> productReq, {
    bool getPrices = true,
    bool getQttys = true,
  }) async {
    bool res = false;
    if (!_productsController.hasValue) {
      emptyProductsAdded();
    }
    res = await _addProductToProductPOSMap(
      productReq['product'],
      getPrices,
      getQttys,
      unit: productReq['product_unit'],
      prefs: productReq['product_prefs'],
    );
    setSubTotal(getSubTotal());
    return res;
  }

  Future<bool> updateProductPrice(String productKey, double newPrice) async{
    bool res = false;
    if (_productsController.hasValue) {
      final products = Map<String, ProductModel>.from(_productsController.value);
      if (products.containsKey(productKey)) {
        products[productKey]!.price = newPrice;
        _productsController.add(products);
        setSubTotal(getSubTotal());
        res = true;
      }
    }
    return res;
  }

  /// Add product to sale product list, if getPrices = true, calculate
  /// product prices
  Future<bool> _addProductToProductPOSMap(
    ProductModel product,
    bool getPrices,
    bool getQttys, {
    UnitsModel? unit,
    Map<PreferenceCategoryModel, List<PreferenceModel>>? prefs,
  }) async {
    bool res = false;
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
        _addProductToProductPOSMap(
          product,
          getPrices,
          getQttys,
          unit: unit,
          prefs: prefs,
        );
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

  String _prefsKey(
    Map<PreferenceCategoryModel, List<PreferenceModel>> prefs,
    String prefsKey,
  ) {
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
  ///SaleModel.fromJson(), it could be useful to build an instance of
  ///SaleModel to send to an endpoint of API's service.
  Map<String, dynamic> getProductDetailMapLists() {
    return ProductModel.getProductDetailMapLists(
      _productsController.value,
      dataBloc.userData!.warehouseId,
      _productUnitController.valueOrNull,
      getProductPrefsText,
    );
  }

  /// Modify quantity field of a ProductModel() given a key and a value
  Future<bool> addProductQuantity(String key, double value) async {
    bool res = false;
    if (dataBloc.settings?.isNotEmpty ?? false) {
      // printConsole(dataBloc.settings?['overselling']??);
      // verify overselling setting to avoid overselling or not
      if (dataBloc.settings!['overselling'] == 0) {
        final p = await ProductsProvider.getProductDetails(
          _productsController.value[key]!.id.toString(),
          true,
        );
        _productsController.value[key]!.inventory =
            p?.inventory ?? _productsController.value[key]!.inventory;
        if (_productsController.value[key]!.inventory < value) {
          if (_productsController.value[key]!.inventory > 0) {
            _productsController.value[key]!.quantity =
                _productsController.value[key]!.inventory.toDouble();
          } else {
            _productsController.value.remove(key);
            res = false;
          }
        } else {
          _productsController.value[key]!.quantity = value;

          res = true;
        }
      } else {
        _productsController.value[key]!.quantity = value;

        res = true;
      }
      setSubTotal(getSubTotal());

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
        _productsController.value.values.map((value) => value.toJson()),
      );
      return products;
    } else {
      return [];
    }
  }

  /// Function to reload product data, costumer data and customer addresses data
  Future<bool> reloadPOSData(BuildContext context) async {
    final customer = await CompanyModel.getCompanyDetails(
      _customerController.value!.idCloud!,
    );
    if (customer != null) {
      setCustomer(customer);
      return await findChanges(context);
    } else {
      return false;
    }
  }

  /// When parameters of product price calculation change, it's
  /// necessary to recalculate product prices, this function make
  /// current product list empty and then introduce all products
  /// again recalculating prices for parameters.
  Future<bool> reloadAllProducts() async {
    bool result = false;
    if (_productsController.hasValue) {
      try {
        await Future.forEach((getProducts ?? {}).keys, (String key) async {
          result = await reloadProduct(key);
        });
      } catch (e) {
        // printConsole(e);
        await logError(e, from: 'Reload pos products');
      }
    }
    return result;
  }

  Future<bool> reloadProduct(String key, {bool getQttys = false}) async {
    bool result = false;
    Map<String, dynamic>? pInfo = await ProductsProvider.findProductDetails(
      getProducts?[key]?.idCloud ?? 0,
    );
    final u = await UnitsProvider.getUnitInfo(getProductUnits?[key]?.idCloud);
    if (pInfo != null) {
      final p = ProductModel.fromJson(pInfo);

      // remove product first, then add
      removeProduct(key);
      result =
          await addProduct({'product': p, 'product_unit': u}, getQttys: false);
    }
    return result;
  }

  Future<bool> reloadOnlyProductPrice(String key, ProductModel product) async {
    bool result = false;

    getProducts?[key] = product;
    reloadProductStream();
    setSubTotal(getSubTotal());

    return result;
  }

  /// When parameters of product price calculation change, it's
  /// necessary to find diffs in their or them units.
  /// Returns a map with two list, price_diffs is a list of products
  /// who have changes in its price, and quantity_diffs for products who
  /// don't have enough inventory.
  Future<bool> findChanges(BuildContext context) async {
    bool result = false;
    if (_productsController.hasValue) {
      try {
        // String keyInitialQtty = 'initial_qtty';
        final Map<String, ProductModel> temp = _productsController.value;
        Map<String, UnitsModel> pUnits = {};
        if (_productUnitController.hasValue) {
          pUnits = getProductUnits!;
        }

        await Future.forEach(temp.keys, (String key) async {
          Map<String, dynamic>? pInfo =
              await ProductsProvider.findProductDetails(temp[key]!.idCloud);
          final u = await UnitsProvider.getUnitInfo(pUnits[key]?.idCloud);
          if (pInfo != null) {
            final p = ProductModel.fromJson(pInfo);
            if (dataBloc.settings != null) {
              final pWithPrices = await PricePoliciesProvider.policyCases(
                p,
                dataBloc.settings!['prioridad_precios_producto'],
                posBloc.getCustomer,
                unit: u,
              );
              if (dataBloc.settings!['overselling'] == 0) {
                if ((temp[key]?.quantity ?? 1) > p.inventory) {
                  await showCupertinoDialog<Map<String, dynamic>?>(
                    barrierDismissible: false,
                    // useRootNavigator: false,
                    context: context,
                    builder: (context) {
                      return ProductChangesAlert(
                        productKey: key,
                        product: pWithPrices,
                        qttyDiff: true,
                      );
                    },
                  );
                }
              }
              if (temp[key]?.price != pWithPrices.price) {
                await showCupertinoDialog<Map<String, dynamic>?>(
                  barrierDismissible: false,
                  // useRootNavigator: false,
                  context: context,
                  builder: (context) {
                    return ProductChangesAlert(
                      productKey: key,
                      product: pWithPrices,
                      priceDiff: true,
                    );
                  },
                );
              }
            } else {
              await dataBloc.getSettings();
              return await findChanges(context);
            }
          }
        });
        result = true;
      } catch (e) {
        // printConsole(e);
        await logError(e, from: 'Reload pos products');
      }
    } else {
      _productsController.value = {};
      return await findChanges(context);
    }
    return result;
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
  removeProduct(String key, {bool removeUnit = true}) {
    _productsController.value.remove(key);
    reloadProductStream();
    setSubTotal(getSubTotal());
    if (_productUnitController.hasValue && removeUnit) {
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
      pInfo['preferences'] = getProductPrefsText(key);

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
        'name': element.taxRateName,
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
    suspendedSaleId = id;
    return res;
  }

  /// Load suspended sale with suspended sale product prices
  Future<List<Map<String, dynamic>>> loadSuspSaleWPrices(String id) async {
    _emptyPosData();
    _verifyPricesController.value = 0;
    final res = await SuspendedSalesProvider.loadSale(id, getPrices: false);
    suspendedSaleId = id;
    return res;
  }

  _emptyPosData() {
    emptyProductsAdded();
    _paymentTermController.value = null;
    _customerAddressesController.value = null;
    _customerController.value = null;
    _paymentMethodController.value = null;
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

  addProductPrefs(
    String productKey,
    Map<PreferenceCategoryModel, List<PreferenceModel>> prefs,
  ) {
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
                prefsText += ' / ' + text;
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
                  prefsText += ' / ' + text;
                } else {
                  prefsText += text;
                }
              }
            }
          }
        }
      }
      return prefsText;
    } catch (e) {
      printConsole(e);
    }
    return prefsText;
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

  Map<String, Map<PreferenceCategoryModel, List<PreferenceModel>>>?
      get getProductPrefs => _productPrefsController.value;

  // Map<String, dynamic> get settings => _settingsController.value;

  // bool get getPrintState => _printStateController.valueOrNull??false;

  Map<String, ProductModel>? get getProducts => _productsController.valueOrNull;

  Map? get getPrintData => _printDataController.valueOrNull;

  PaymentMethods? get getPaymentMethod => _paymentMethodController.valueOrNull;

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

  int? get getPaymentTerm => _paymentTermController.valueOrNull;

  int? get getPaymentValue => _paymentValueController.valueOrNull;

  int? get getVerifyPrices => _verifyPricesController.valueOrNull;

  //__________________________
  //
  //                                       SETTERS
  //__________________________

  setCustomer(CompanyModel? customer) {
    _customerController.sink.add(customer);
  }

  BehaviorSubject<bool> _isElectronicController = BehaviorSubject<bool>.seeded(true);
  Stream<bool> get isElectronicStream => _isElectronicController.stream;
  bool get isElectronicValue => _isElectronicController.value;
  setDocumentType(bool value) {
    // Si por alguna razón está cerrado (no debería si la página está activa), lo recreamos
    if (_isElectronicController.isClosed) {
      _isElectronicController = BehaviorSubject<bool>.seeded(value);
    } else {
      _isElectronicController.sink.add(value);
    }
  }

  int getDocumentTypeId(UserModel user) {
    int documentTypeId = user.documentTypeId ?? 0;
    int posId = user.pos_document_type_id ?? 0;
    int feId = user.fe_pos_document_type_id ?? 0;

    if (posBloc.isElectronicValue && feId != 0) {
      documentTypeId = feId;
    } else if (!posBloc.isElectronicValue && posId != 0) {
      documentTypeId = posId;
    }
    return documentTypeId;
  }

  // Function(bool) get setPrintState => _printStateController.sink.add;

  Function(Map) get setPrintData => _printDataController.sink.add;

  Function(PaymentMethods?) get setPaymentMethod =>
      _paymentMethodController.sink.add;

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

  Function(int?) get setPaymentTerm => _paymentTermController.sink.add;

  Function(double) get setSubTotal => _subtotalController.sink.add;

  Function(int) get setVerifyPrices => _verifyPricesController.sink.add;

  Function(int) get setPaymentValue => _paymentValueController.sink.add;

  dispose() async {
    isDisposed = true;
    _productsController.close();
    _productSearchController.close();
    _isElectronicController.close();
    // _productsViewController.close();
    _subtotalController.close();
    _paymentValueController.close();
    _invoiceNoteController.close();
    _dispatchNoteController.close();
    _verifyPricesController.close();
    _customerController.close();
    _customerAddressesController.close();
    _paymentMethodController.close();
    _productUnitController.close();
    // _settingsController.close();
    _paymentDocumentController.close();
    _printDataController.close();
    _productPrefsController.close();

    _paymentTermController.close();
    // _printStateController.close();
    if (suspendedSaleId != null) {
      try {
        await SuspendedSalesProvider.deleteSuspSale(
          suspendedSaleId ?? '',
        );
      } catch (e) {
        logError(e);
      }
      suspendedSaleId = null;
    }
  }

  reload({bool disposeFirst = false}) async {
    if (disposeFirst) {
      dispose();
    }
    isDisposed = false;
    _productsController = BehaviorSubject<Map<String, ProductModel>>();
    _productUnitController = BehaviorSubject<Map<String, UnitsModel>>();

    _paymentMethodController = BehaviorSubject<PaymentMethods?>();
    _paymentDocumentController = BehaviorSubject<DocumentsTypes?>();
    _paymentTermController = BehaviorSubject<int?>();
    _printDataController = BehaviorSubject<Map>();

    _productPrefsController = BehaviorSubject<
        Map<String, Map<PreferenceCategoryModel, List<PreferenceModel>>>?>();

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
