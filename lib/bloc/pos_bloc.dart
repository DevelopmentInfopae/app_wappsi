import 'dart:async';

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/documents_types_model.dart';
import 'package:pos_wappsi/models/local_sale_items_model.dart';
import 'package:pos_wappsi/models/local_sales_model.dart';
import 'package:pos_wappsi/models/payment_methods_model.dart';
import 'package:pos_wappsi/models/payment_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/sale_model.dart';
import 'package:pos_wappsi/models/suspended_sale_model.dart';
import 'package:pos_wappsi/providers/API_provider.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/functions.dart';
import 'package:pos_wappsi/utils/local_db.dart';
import 'package:pos_wappsi/utils/manage_server_resp.dart';
import 'package:pos_wappsi/utils/product_price_functions.dart';
import 'package:rxdart/rxdart.dart';

class POSBloc {
  // to save data of user
  final _productsController = BehaviorSubject<Map<String, ProductModel>>();

  final _paymentMthdController = BehaviorSubject<PaymentMethods?>();

  final _paymentDocumentController = BehaviorSubject<DocumentsTypes?>();
  final _paymenttermController = BehaviorSubject<int?>();

  final _printDataController = BehaviorSubject<Map>();

  final _searchController = BehaviorSubject<FloatingSearchBarController>();

  final _customerController = BehaviorSubject<CompanyModel?>();

  final _customerAddressesController =
      BehaviorSubject<CustomerAddressesModel?>();

  final _productsViewController =
      StreamController<Map<String, ProductModel>>.broadcast();

  final _subtotalController = StreamController<double>.broadcast();

  final _paymentValueController = BehaviorSubject<int>();

  /// To know if sale is loaded from suspended sale and verify or not prices
  final _verifyPricesController = BehaviorSubject<int>();

  final _invoiceNoteController = BehaviorSubject<String>();

  final _dispatchNoteController = BehaviorSubject<String>();

  final StreamController<List<ProductModel>> _productSearchController =
      StreamController<List<ProductModel>>.broadcast();

  //-----------------------------------------------------------------------------
  //                                STREAMS
  //
  //-----------------------------------------------------------------------------

  Stream<Map<String, ProductModel>> get productsStream =>
      _productsController.stream;

  Stream<List<ProductModel>> get productSearchStream =>
      _productSearchController.stream;

  Stream<Map<String, ProductModel>> get productViewStream =>
      _productsViewController.stream;

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
  Future<bool> addProduct(ProductModel product, {bool getPrices = true}) async {
    bool res = false;
    if (_productsController.hasValue) {
      res = await _addProductToProductMap(product, getPrices);
    } else {
      emptyProductsAdded();
      res = await _addProductToProductMap(product, getPrices);
    }
    setProductView(_productsController.value);
    setSubTotal(getSubTotal());
    return res;
  }

  /// Add product to sale product list, if getPrices = true, calculate
  /// product prices
  Future<bool> _addProductToProductMap(
      ProductModel product, bool getPrices) async {
    bool res = false;
    if (dataBloc.settings!['item_addition'] == 1) {
      final p = getProductData(product.id.toString());
      if (p == null) {
        final p2 = getPrices ? await getProductPrices(product) : product;
        product = p2;
        // product.quantity = 1;
        final temp = {product.id.toString(): product};
        temp.addAll(_productsController.value);
        _productsController.value = temp;
        res = await addProductQuantity(product.id.toString(), product.quantity);
      } else {
        res = await addProductQuantity(product.id.toString(), p.quantity + 1);
      }
    } else if (dataBloc.settings!['item_addition'] == 0) {
      final p2 = getPrices ? await getProductPrices(product) : product;
      product = p2;
      // product.quantity = 1;
      Random random = new Random();
      int randomNumber = random.nextInt(300);

      /// gen an unique key for each product
      final key = product.id.toString() + '-' + randomNumber.toString();
      if (_productsController.value.keys.contains(key)) {
        _addProductToProductMap(product, getPrices);
      } else {
        final temp = {key: product};
        temp.addAll(_productsController.value);
        _productsController.value = temp;
        res = await addProductQuantity(key, product.quantity);
      }
    }
    return res;
  }

  ///Returns a Map<String,dynamic>, where the keys are the same of
  ///SaleModel.fromJson(), it could be usefull to build an instance of
  ///SaleModel to send to an endpoint of API's service.
  Map<String, dynamic> getProductDetailMapLists() {
    return ProductModel.getProductDetailMapLists(
        _productsController.value, dataBloc.userData!.warehouseId);
  }

  /// Modify quantity field of a ProductModel() given a key and a value
  Future<bool> addProductQuantity(String key, int value) async {
    bool res = false;
    if (dataBloc.settings?.isNotEmpty ?? false) {
      // print(dataBloc.settings?['overselling']??);
      // verify overselling setting to avoid overselling or not
      if (dataBloc.settings!['overselling'] == 0) {
        if (_productsController.value[key]!.inventory < value) {
          if (_productsController.value[key]!.inventory > 0) {
            _productsController.value[key]!.quantity =
                _productsController.value[key]!.inventory;
            // setProductView(_productsController.value);
            setSubTotal(getSubTotal());
          } else {
            _productsController.value.remove(key);
            res = false;
          }
        } else {
          _productsController.value[key]!.quantity = value;
          // setProductView(_productsController.value);
          setSubTotal(getSubTotal());
          res = true;
        }
      } else {
        _productsController.value[key]!.quantity = value;
        // setProductView(_productsController.value);
        setSubTotal(getSubTotal());
        res = true;
      }
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

  /// Returns ProductModel object with it's respective prices
  Future<ProductModel> getProductPrices(ProductModel product,
      {String? customerId}) async {
    if (product.promoPrice != null) {
      product.price = product.promoPrice!;
      product.discount = 0;
      product.priceWithoutDiscount = product.promoPrice!;
      return product;
    } else {
      if (dataBloc.settings != null) {
        final product2 = await policyCases(
            product,
            dataBloc.settings!['prioridad_precios_producto'],
            _customerController.valueOrNull);

        return product2;
        //aply discount

      } else {
        await dataBloc.getSettings();
        return getProductPrices(product);
      }
    }
  }

  /// Function to reload product data, costumer data and customer addresses data
  Future<bool> reloadPOSData() async {
    final customer = await DBProvider.db.findTableFieldsById(
        'sma_companies', _customerController.value!.idCloud!);
    if (customer != null) {
      setCustomer(CompanyModel.fromJson(customer));
      final res = await reloadProducts();
      setProductView(_productsController.value);
      return res;
    } else {
      return false;
    }
  }

  /// When parameters of product price calculation change, it's
  /// neccesary to recalculate product prices, this function make
  /// current product list empty and then introduce all products
  /// again recalculating prices for new parameters.
  Future<bool> reloadProducts() async {
    if (_productsController.hasValue) {
      try {
        String keyInitialQtty = 'initial_qtty';
        final Map<String, ProductModel> temp = _productsController.value;

        /// Empty current product list
        emptyProductsAdded();
        await Future.forEach(temp.values, (ProductModel element) async {
          Map<String, dynamic>? temp2 =
              await ProductModel.findProductDetails(element.idCloud);
          if (temp2 != null) {
            Map<String, dynamic> pData = queryResultToMap(temp2);
            pData[keyInitialQtty] = element.quantity;
            final product = ProductModel.fromJson(pData,
                loadInitialQtty: true, qtyKey: keyInitialQtty);
            await addProduct(product);
          }
        });

        return true;
      } catch (e) {
        print(e);
        return false;
      }
    } else {
      return false;
    }
  }

  /// Makes product Map empty
  emptyProductsAdded() {
    setProductView({});
    _productsController.value = {};
  }

  /// Remove a product from products Map given a key
  removeProduct(String key) {
    setProductView(_productsController.value);
    _productsController.value.remove(key);
    setSubTotal(getSubTotal());
  }

  /// Returns an instance of [ProductModel()] from products Map
  /// given a key
  ProductModel? getProductData(String key) {
    return _productsController.value[key];
  }

  /// Returns product information in [Map] format
  List<Map>? getProductsListMap() {
    List<Map> productsMap = [];
    _productsController.value.values.forEach((element) {
      productsMap.add(element.toJson());
    });

    return productsMap;
  }

  /// Returns sum of products.getPriceWithIVA() * products.quantity
  double getSubTotal() {
    double subTotal = 0;
    // ignore: unnecessary_null_comparison
    if (_productsController.hasValue) {
      _productsController.value.values.forEach((element) {
        double temp = element.getPriceWithIVA() * element.quantity;
        subTotal = subTotal + temp;
      });
    }

    return subTotal;
  }

  /// Returns total price of products without aplying customer discount.
  double getTotalWithoutDiscount() {
    double total = 0;
    // ignore: unnecessary_null_comparison
    if (_productsController.hasValue) {
      _productsController.value.values.forEach((element) {
        double temp = element.priceWithoutDiscount! * element.quantity;
        total = total + temp;
      });
    }

    return total;
  }

  /// Returns sum of IVA value from all products in products Map.
  double getTotalIVA() {
    double total = 0.0;
    if (_productsController.hasValue) {
      _productsController.value.values.forEach((element) {
        double temp =
            (element.getPriceWithIVA() - element.getPriceWithoutIVA()) *
                element.quantity;
        total = total + temp;
      });
    }
    return total;
  }

  /// Returns total items in products Map
  int getItemsCount() {
    int count = 0;
    // ignore: unnecessary_null_comparison
    if (_productsController.hasValue) {
      _productsController.value.values.forEach((element) {
        int temp = element.quantity;
        count = count + temp;
      });
    }

    return count;
  }

  /// Return the num of unique products in products Map.
  int getProductsCount() {
    return _productsController.value.length;
  }

  /// Send current pos data to server, if there is any changes between local db and server,
  /// server response will contain those changes and they'll be writen into local db, then
  /// reload POS data
  ///
  Future<bool> sendPosData(BuildContext context) async {
    bool result = false;
    final productsDetails = getProductDetailMapLists();
    final sale =
        SaleModel.buildSale(dataBloc.userData!, productsDetails).toJson();
    // final debug = sale.toString();
    final api = new DataProvider();
    Map<String, String> headers = {
      'content-Type': 'application/json',
      'Authorization': dataBloc.getToken()
    };
    try {
      final res = await api.postPetition(newSaleEndP, sale, headers);
      if (res['status'] == -1) {
        reloadDialog(
            context,
            res['body']['error_message'] ?? res['body']['message'],
            'assets/images/dizzy-robot.png');
      } else {
        if (res['error'] ?? true) {
          if (res['body']['data'] != [] &&
              res['body']['data'] != null &&
              res['body']['sync']) {
            hideCurrentScaffoldAlert(context);
            scaffoldAlert(
                context,
                res['body']['error_message'] ?? res['body']['message'],
                Duration(seconds: 2));
            final Map<String, dynamic> changes = res['body']['data'];
            // to show changes in costumer or products
            // String chText = _getChangesString(changes);
            await Future.forEach(changes.keys.toList(), (String key) async {
              // ignore: unnecessary_null_comparison
              if (key != null) {
                await DBProvider.db
                    .insertOrUpdateQuerys(key.toString(), changes[key] ?? []);
              }
            });
            final reload = await posBloc.reloadPOSData();

            if (!reload) {
              confirmDialog(context, 'Error al recargar datos de venta POS',
                  'assets/images/browser.png');
            } else {
              hideCurrentScaffoldAlert(context);

              Navigator.pop(context);
              confirmDialog(context, 'Datos de venta POS recargados',
                  'assets/images/success.png');
            }
          } else {
            confirmDialog(context, res['body']['message'] ?? res['message'],
                'assets/images/browser.png');
          }
        } else {
          try {
            //Load data into SalesModel instance to work with it
            final printData = await _buildPrintDataMap(res['body']);
            final salesModel = SalesModel.fromPosBloc(
              productsDetails,
              salePrintData: res['body'],
            );
            // Save sale data into local DB
            final saleId = await salesModel.saveSaleData();

            // Verify if sale was saved successfully
            if (saleId != null) {
              // Save sale items into dbUpdated
              final saleItemsStatus = await LocalSaleItems.saveAllIntoDB(
                  productsDetails['product_detail_list'], saleId);

              final paymentsStatus = await PaymentsModel.saveAllIntoDB(saleId);
              // Verify if sale items were saved successfully
              if (saleItemsStatus && paymentsStatus) {
                posBloc.setPrintData(printData);
                _emptyPosData();
                scaffoldAlert(context, 'Venta creada', Duration(seconds: 1));
                result = true;
              }
            }
          } catch (e) {
            hideCurrentScaffoldAlert(context);
            confirmDialog(context, e.toString(), 'assets/images/browser.png');
          }
          hideCurrentScaffoldAlert(context);
        }
      }
    } catch (e) {
      print(e);
      hideCurrentScaffoldAlert(context);
      confirmDialog(context, e.toString(), 'assets/images/browser.png');
    }
    return result;
  }

  Future<Map> _buildPrintDataMap(Map saleData) async {
    final settings = (await DBProvider.db.getSettings())!;
    final docDetails = await DBProvider.db
        .getDocumentDetails(dataBloc.userData!.documentTypeId.toString());
    final temp = removeRareSpaceChr(docDetails?['invoice_footer'] ?? '');
    return {
      "products": getProductsListMap(),
      "customer": _customerController.value!.toJson(),
      "customer_address": _customerAddressesController.value!.toJson(),
      "payment_method": _paymentMthdController.value!.toJson(),
      "sale_data": saleData,
      "pos_note": _invoiceNoteController.valueOrNull ?? '',
      "payment": _paymentValueController.value.toDouble(),
      "total": getSubTotal(),
      "iva": getIVAs(),
      "company_data": dataBloc.getBillerCompany,
      "biller_data": dataBloc.getBIllerData,
      "settings": settings,
      "footer": temp
    };
  }

  Map getIVAs() {
    Map ivasMap = {};
    Map temp = {};
    _productsController.value.values.forEach((element) {
      temp[element.taxRate] = (temp[element.taxRate] ?? 0.0) +
          element.getPriceWithoutIVA() * element.quantity;
      ivasMap[element.taxRate] = {
        'value': temp[element.taxRate],
        'name': element.taxRateName
      };
      // print('xd');
    });

    return ivasMap;
  }

  Future<bool> suspendSale({String keyWord = ''}) async {
    final res = await SuspendedSales.suspendSale(keyWord: keyWord);
    if (res == true) {
      _emptyPosData();
    }

    return res;
  }

  /// Load suspended sale recalculating product prices
  Future<List<Map<String, dynamic>>> loadSuspendedSale(String id) async {
    _emptyPosData();
    final res = await SuspendedSales.loadSale(id);

    return res;
  }

  /// Load suspended sale with suspended sale product prices
  Future loadSuspSaleWPrices(String id) async {
    _emptyPosData();
    _verifyPricesController.value = 0;
    final res = await SuspendedSales.loadSale(id, getPrices: false);

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

  FloatingSearchBarController get getSearchBarController =>
      _searchController.value;

  //__________________________
  //
  //                                       SETTERS
  //__________________________

  setCustomer(CompanyModel? customer) {
    // if(customer==null){
    //   _customerController.value = null;
    // }else{

    _customerController.sink.add(customer);
    // }

    // OR recalculate prices
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

  Function(Map<String, ProductModel>) get setProductView =>
      _productsViewController.sink.add;

  Function(String) get setInvoiceNote => _invoiceNoteController.sink.add;

  Function(String) get setDispatchNote => _dispatchNoteController.sink.add;

  Function(int?) get setPaymentTerm => _paymenttermController.sink.add;

  Function(double) get setSubTotal => _subtotalController.sink.add;

  Function(int) get setVerifyPrices => _verifyPricesController.sink.add;

  Function(int) get setPaymentValue => _paymentValueController.sink.add;
  Function(FloatingSearchBarController) get setSearchController =>
      _searchController.sink.add;

  dispose() {
    _productsController.close();
    _productSearchController.close();
    _productsViewController.close();
    _subtotalController.close();
    _paymentValueController.close();
    _invoiceNoteController.close();
    _dispatchNoteController.close();
    _verifyPricesController.close();
    _customerController.close();
    _customerAddressesController.close();
    _paymentMthdController.close();
    // _settingsController.close();
    _paymentDocumentController.close();
    _printDataController.close();
    _searchController.close();
    _paymenttermController.close();
    // _printStateController.close();
  }

  disposeSearchController() {
    _searchController.value.dispose();
  }
}

final posBloc = POSBloc();
