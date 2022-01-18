// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/models/biller_data_model.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/providers/API_provider.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/local_db.dart';
import 'package:pos_wappsi/utils/manage_server_resp.dart';
import 'package:pos_wappsi/utils/product_price_functions.dart';

ProductModel productModelFromJson(Map<String, dynamic> str) =>
    ProductModel.fromJson(str);

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
  final formatCurrency = new NumberFormat.simpleCurrency();
  ProductModel(
      {required this.name,
      required this.id,
      required this.idCloud,
      required this.slug,
      required this.code,
      required this.image,
      required this.price,
      this.priceWithoutDiscount,
      this.pricePolicyPrices,
      required this.promoStart,
      required this.promoEnd,
      this.promoPrice = 0.0,
      this.quantity = 1,
      required this.inventory,
      required this.taxMethod,
      required this.brand,
      required this.taxRateId,
      required this.taxRate,
      required this.categoryId,
      required this.subCategoryId,
      required this.unit,
      required this.type,
      required this.taxRateName,
      this.discount = 0.0});
  String type;
  String slug;
  int id;
  int idCloud;
  String image;
  double price;
  double? pricePolicyPrices;
  double? priceWithoutDiscount;
  String name;
  String categoryId;
  String subCategoryId;
  dynamic code;
  String promoStart;
  String promoEnd;
  int taxMethod;
  double? promoPrice;
  int quantity;
  int brand;
  int taxRateId;
  String taxRateName;
  int unit;
  double discount;
  int inventory;

  // other data
  // ignore: avoid_init_to_null
  double? taxRate;

  static List get _productColumns => [
        'name',
        'slug',
        'id',
        'id_cloud',
        'image',
        'price',
        'code',
        'start_date',
        'type',
        'end_date',
        'tax_method',
        'promo_price',
        'brand',
        'tax_rate',
        'tax_method',
        'product_details',
        'unit',
        'category_id',
        'subcategory_id',
      ];

  factory ProductModel.fromJson(Map<dynamic, dynamic> json,
          {bool loadInitialQtty = false, String? qtyKey}) =>
      ProductModel(
          idCloud: json["id_cloud"],
          id: json["id"],
          slug: json["slug"] ?? json["name"],
          image: json["image"] ?? '',
          name: json["name"] ?? json["slug"],
          code: json["code"],
          price: double.tryParse(json["price"].toString()) ?? 0.0,
          pricePolicyPrices:
              double.tryParse(json["price_policy"].toString()) ?? 0.0,
          priceWithoutDiscount:
              double.tryParse(json["price_without_discount"].toString()) ?? 0.0,
          discount: double.tryParse(json["discount"].toString()) ?? 0.0,
          promoStart: json["start_date"] ?? '',
          promoEnd: json["end_date"] ?? '',
          taxMethod: json["tax_method"],
          promoPrice: _promoPrice(json),
          inventory: int.tryParse(json["quantity"].toString()) ?? 0,
          brand: json["brand"],
          unit: int.tryParse(json['unit'].toString()) ?? 0,
          taxRateId: json["tax_rate"],
          taxRate: double.tryParse(json['rate'].toString()) ?? 0.0,
          type: json['type'],
          categoryId: json['category_id'].toString(),
          subCategoryId: json['subcategory_id'].toString(),
          taxRateName: json['tax_rate_name'],
          quantity: loadInitialQtty ? (json[qtyKey]) : 1);

  /// Load ProductModel instances of a given list of product data
  static List<ProductModel> fromJsonList(List<Map> list,
      {bool loadInitialQtty = false,
      String qttyKey = 'initial_qtty',
      bool initalPrice = false,
      String inititalPriceKey = ''}) {
    List<ProductModel> products = [];
    // to check product promo

    Map temp = {};

    list.forEach((item) {
      for (var i = 0; i < item.keys.length; i++) {
        // print(item.values.toList()[i]);
        // print(item.keys.toList()[i]);
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      try {
        temp['promo_price'] = _promoPrice(temp);
      } catch (e) {
        print(e);

        temp['promo_price'] = null;
      }
      if (initalPrice) {
        try {
          temp['price'] = temp[inititalPriceKey];
        } catch (e) {
          print(e);
        }
      }

      products.add(ProductModel.fromJson(temp,
          loadInitialQtty: loadInitialQtty, qtyKey: qttyKey));
    });

    return products;

    // print(temp);
  }

  static double? _promoPrice(Map<dynamic, dynamic> temp) {
    if (temp['start_date'] == '' || temp['end_date'] == '') {
      return null;
    } else {
      final start = DateTime.parse(temp['start_date']);
      final end = DateTime.parse(temp['end_date']);
      double? promoPrice;
      var now = new DateTime.now();
      // print(temp['name'] + start.toString() +end.toString());
      if (!(now.isAfter(start) && now.isBefore(end)) ||
          !(start.difference(now).inDays <= 0 ||
              end.difference(now).inDays >= 0)) {
        promoPrice = null;
      } else {
        try {
          promoPrice = double.parse(temp['promo_price'].toString());
        } catch (e) {
          print(e);
          promoPrice = null;
        }
      }
      return promoPrice;
    }
  }

  static Future<bool> saveProductsSpSale(int suspSaleId) async {
    bool result = false;
    if (suspSaleId != 0) {
      List<Map<String, dynamic>> productsMap = [];
      posBloc.getProducts!.values.forEach((element) {
        productsMap.add({
          'id_suspended_sale': suspSaleId,
          'id_product': element.idCloud,
          'quantity': element.quantity,
          'price': element.price,
          'price_policy': element.pricePolicyPrices,
          'price_without_discount': element.priceWithoutDiscount,
          'discount': element.discount,
        });
      });
      result = await saveSuspSaleProducts(productsMap);
    }
    return result;
  }

  /// Load products of given suspended sale id
  static Future<Map<String, dynamic>> loadSuspSaleProducts(
      String suspSaleId) async {
    final res = await loadSuspendedSProducts(suspSaleId);

    List<Map<String, dynamic>> dif = [];
    if (res != null) {
      dif = await _checkSuspPriceDif(res);
    }

    List<ProductModel> products = [];

    if (res != null) {
      // Load prices saved on suspended_sale_products
      products = fromJsonList(res,
          loadInitialQtty: true,
          qttyKey: 'initial_qtty',
          initalPrice: true,
          inititalPriceKey: 'sp_price');
    }
    return {'products': products, 'dif': dif};
  }

  double getPriceWithoutIVA() {
    double pwoutIVA = price;

    if (taxMethod == 0) {
      pwoutIVA = price / ((100 + taxRate!) / 100);
    } else {
      pwoutIVA = price;
    }

    return pwoutIVA;
  }

  String getFormatedPriceIVA() {
    return formatCurrency.format(getPriceWithIVA());
  }

  String getFormatedPriceNoIva() {
    return formatCurrency.format(getPriceWithoutIVA());
  }

  double getPriceWithIVA() {
    double pwithIVA = price;

    if (taxMethod == 0) {
      pwithIVA = price;
    } else {
      pwithIVA = price * (100 + taxRate!) / 100;
    }

    return pwithIVA;
  }

  double getIVA() {
    return getPriceWithIVA() - getPriceWithoutIVA();
  }

  Map<String, dynamic> toJson() => {
        "slug": slug,
        "id": id,
        "id_cloud": idCloud,
        "image": image,
        "price": getPriceWithIVA(),
        "name": name,
        "code": code,
        "start_date": promoStart,
        "end_date": promoEnd,
        'price_without_discount': priceWithoutDiscount,
        "tax_method": taxMethod,
        "promo_price": promoPrice,
        "quantity": quantity,
        "brand": brand,
        "inventory": inventory,
        "tax_rate": taxRateId,
        "rate": taxRate,
        "tax_rate_name": taxRateName
      };

  /// Customer's price for a product
  Future<double> customerPrice(
      CompanyModel customer, Future<double> function) async {
    final productPrice =
        await findProductPrice(idCloud.toString(), customer.priceGroupId!);
    return double.tryParse(productPrice!['price'].toString()) ?? await function;
  }

  @override
  String toString() => name;

  Future<double> billerPrice(Future<double> functionAfter) async {
    if (dataBloc.getBIllerData == null) {
      final billerData = await DBProvider.db.getBillerData();
      if (billerData == null) {
        return await functionAfter;
      } else {
        dataBloc.setBillerData(BillerDataModel.fromJson(billerData));
        return await billerPrice(getPrice());
      }
    } else {
      if (dataBloc.getBIllerData!.defaultPriceGroup != null) {
        final productPrice = await findProductPrice(
            idCloud.toString(), dataBloc.getBIllerData!.defaultPriceGroup!);
        if (productPrice != null) {
          return double.tryParse(productPrice['price'].toString()) ??
              priceWithoutDiscount!;
        } else {
          return priceWithoutDiscount!;
        }
      } else {
        return priceWithoutDiscount!;
      }
    }
  }

  ///Returns a Map<String,dynamic>, where the keys are the same of
  ///SaleModel.fromJson(), it could be usefull to build an instance of
  ///SaleModel to send to an endpoint of API's service. It also returns
  ///key product_detail_list wich contains a list of product details
  static Map<String, dynamic> getProductDetailMapLists(
      Map<String, ProductModel>? products, int warehouseId) {
    List<int> _quantitys = [];
    List<int> _units = [];
    List<int> _ids = [];
    List<String> _types = [];
    List<String> _codes = [];
    List<String> _names = [];
    List<int> _discounts = [];
    List<double> _discountValues = [];
    List<int> _taxRates = [];
    List<double> _taxValues = [];
    List<double> _prices = [];
    List<double?> _pricePPolicy = [];
    List<double> _pricesIVA = [];
    List<double> _realPrices = [];
    List<int> _taxRateIds = [];

    /// To save product details to save into local db
    List<Map<String, dynamic>> productsDetails = [];

    if (products != null && products != {}) {
      products.values.forEach((value) {
        final pIVA = value.getPriceWithIVA();
        final pNoIVA = value.getPriceWithoutIVA();
        final taxValue = pIVA - pNoIVA;
        _ids.add(value.idCloud);
        _codes.add(value.code);
        _quantitys.add(value.quantity);
        _units.add(value.unit);
        _types.add(value.type);
        _names.add(value.name);
        _discounts.add(value.discount.toInt());
        _discountValues.add(value.priceWithoutDiscount! - value.price);
        _taxRates.add(value.taxRate!.toInt());
        _taxValues.add(taxValue);
        _prices.add(pNoIVA);
        _pricePPolicy.add(value.pricePolicyPrices);
        _pricesIVA.add(pIVA);
        _realPrices.add(value.priceWithoutDiscount!);
        _taxRateIds.add(value.taxRateId);

        double discountPercent =
            1 - (value.price / (value.priceWithoutDiscount ?? value.price));
        discountPercent = discountPercent * 100;

        productsDetails.add({
          "product_id": value.idCloud,
          "product_type": value.type,
          "product_code": value.code,
          "product_name": value.name,
          "quantity": value.quantity,
          "warehouse_id": warehouseId,
          "tax_rate_id": value.taxRateId,
          "tax": value.taxRateName,
          "unit_price": pIVA,
          "net_unit_price": pNoIVA,
          "discount": discountPercent.toString() + '%',
          "item_tax": taxValue,
          "subtotal": value.getPriceWithIVA() * value.quantity,
          "price_before_tax": value.getPriceWithoutIVA(),
          "unit_quantity": value.quantity
        });
      });
    }
    return {
      'product_id': _ids,
      'product_type': _types,
      'product_code': _codes,
      'product_name': _names,
      'product_discount': _discounts,
      'product_discount_val': _discountValues,
      'product_tax': _taxRateIds,
      'product_tax_rate': _taxRates,
      'unit_product_tax': _taxValues,
      'product_tax_val': _taxValues,
      'net_price': _prices,
      'unit_price': _pricesIVA,
      'real_unit_price': _pricePPolicy,
      'quantity': _quantitys,
      'product_unit': _units,
      'product_unit_id_selected': _units,
      'product_base_quantity': _quantitys,
      "product_detail_list": productsDetails
    };
  }

  Future<double> getPrice() async {
    return priceWithoutDiscount!;
  }

  /// Check if suspendedSaleProducts's prices are different of current
  /// product's prices and return the price diff betwen them
  static Future<List<Map<String, dynamic>>> _checkSuspPriceDif(
      List<Map> res) async {
    List<Map<String, dynamic>> dif = [];
    Future.forEach(res, (Map p) async {
      final temp = ProductModel.fromJsonList([p]);
      final prodP = await posBloc.getProductPrices(temp.first);
      if (prodP.price != p['sp_price']) {
        dif.add({
          'product_name': p['name'],
          'price': prodP.price,
          'sp_price': p['sp_price']
        });
      }
    });
    return dif;
  }

  /// Return all rows in sma_products taking product quantities from warehouse
  /// asigned to current user
  static Future<List<Map>?> getAllProducts(
      {bool overselling = true,
      bool limit = true,
      bool offset = false,
      int offsetValue = 2}) async {
    String sql = '';
    if (offset) limit = false;
    if (limit) offset = false;
    if (overselling) {
      sql = '''
        SELECT p.${_productColumns.join(',p.')},wp.quantity, tr.rate,tr.name as tax_rate_name FROM 
        sma_products p INNER JOIN sma_warehouses_products wp ON (wp.product_id = p.id_cloud AND 
        wp.warehouse_id = ${dataBloc.userData!.warehouseId}) INNER JOIN sma_tax_rates tr ON tr.id_cloud = 
        p.tax_rate WHERE p.discontinued = 0 ORDER BY p.name ${limit ? "LIMIT 30" : ""}
        ${offset ? "LIMIT 30 offset " + offsetValue.toString() : ""}
    ''';
    } else {
      sql = '''
              SELECT p.${_productColumns.join(',p.')},wp.quantity, tr.rate,tr.name as tax_rate_name FROM 
              sma_products p INNER JOIN sma_warehouses_products wp ON (wp.product_id = p.id_cloud AND 
              wp.warehouse_id = ${dataBloc.userData!.warehouseId}) INNER JOIN sma_tax_rates tr ON 
              tr.id_cloud = p.tax_rate WHERE p.discontinued = 0 AND wp.quantity>0 ORDER BY p.name ${limit ? "LIMIT 30" : ""}
              ${offset ? "LIMIT 30 offset " + offsetValue.toString() : ""}
          ''';
    }

    return await DBProvider.db.sqlRawQuery(sql);
  }

  //______________________________________________________________________________________________________________
  //
  //                                       WISHLIST
  //_______________________________________________________________________________________________________________

  /// given a list of product ids, load them into
  static Future<List<ProductModel>> loadCustomerFavorites(
      CompanyModel customer) async {
    final products = await getCustomerFavFromDB(customer.id.toString());
    if (products == []) {
      return [];
    } else {
      final temp = ProductModel.fromJsonList(products!);
      List<ProductModel> pM = [];
      await Future.forEach(temp, (ProductModel p) async {
        pM.add(await policyCases(
            p, dataBloc.settings!['prioridad_precios_producto'], customer));
      });

      return pM;
    }
  }

  static Future<List<Map<String, dynamic>>?> getCustomerFavFromDB(
      String customerId) async {
    // String sql = '''
    //     SELECT p.${_productColumns.join(',p.')},wp.quantity, tr.rate, tr.name as tax_rate_name
    //     FROM sma_products p INNER JOIN sma_warehouses_products wp ON (wp.product_id = p.id_cloud AND
    //     wp.warehouse_id = ${dataBloc.userData!.warehouseId}) INNER JOIN sma_tax_rates tr ON
    //     tr.id_cloud = p.tax_rate INNER JOIN sma_wishlist wl ON wl.customer_id = $customerId
    //     WHERE p.discontinued = 0
    //     ''';movil

    String sql = '''
    SELECT DISTINCT p.${_productColumns.join(',p.')},wp.quantity, tr.rate, tr.name as tax_rate_name 
    FROM sma_wishlist wl INNER JOIN sma_products p ON (p.id_cloud =wl.product_id 
    AND p.discontinued = 0) INNER JOIN sma_warehouses_products wp ON (wp.product_id = wl.product_id AND 
    wp.warehouse_id = ${dataBloc.userData!.warehouseId}) INNER JOIN sma_tax_rates tr ON tr.id = p.tax_rate 
    WHERE wl.customer_id=$customerId;''';

    final res = await DBProvider.db.sqlRawQuery(sql);

    if (res == []) {
      return [];
    } else {
      return queryResultToMapList(res!);
    }
  }

   static Future<bool> reloadCustomerFavs(BuildContext context,CompanyModel customer) async {
    // get favorites from Cloud(
    final fav = await getCustomerFav(customer,context);

    return await saveCustomerFav(customer, fav);
  }

  static Future<List<Map>> getCustomerFav(
      CompanyModel customer, BuildContext context) async {
    var dataProvider = DataProvider();
    Map<String, String> headers = {
      'content-Type': 'application/json',
      'Authorization': dataBloc.getToken()
    };

    final res = await dataProvider.postPetition(
        getCustomerWishListEndP, {'company_id': customer.idCloud}, headers);

    manageResponseAlerts(res, context);
    try {
      final List<Map> fav = List<Map>.from(res['body']['data']);
      if(fav.length > 0) {

        return fav;
      }else{
        confirmDialog(context, res['body']['message'], 'assets/images/alert.png');
        return [{}];
      }
    } catch (e) {
      print(e);
      confirmDialog(context, res['body']['message'], 'assets/images/alert.png');
      return [];
    }
  }

 

  static Future<bool> saveCustomerFav(
      CompanyModel customer, List<Map> favorites) async {
    if (favorites.length > 0) {
      final res = await loadCustomerFavorites(customer);
      if (res.length > 0) {
        await deleteCustomerFavs(customer);
      } else {
        if(favorites.length>0){
          final query = [];
          favorites.forEach((Map e) {
            query.add({
              'user_id': e['user_id'],
              'id_cloud': e['id_cloud'],
              'product_id': e['product_id'],
              'customer_id': customer.id,
            });
          });
          return await DBProvider.db.insertQuerys('sma_wishlist', query);
        }else{
          return true;
        }

      }
    } else {
      // whithout favorites to save
      // delete current favorites from local

      return true;
    }
    return false;
  }

  static Future<bool> deleteCustomerFavs(CompanyModel customer) async {
    String where = '''
        customer_id=${customer.id} 
        ''';

    return await DBProvider.db.sqlDelete('sma_wishlist', where);
  }

  ///Function used to get products info based on a list of products IDs,
  ///with innerjoint to sma_tax_rates to get value of tax
  Future<List<Map>?> findProductsByIds(List<int> ids) async {
    String sql = '''
        SELECT p.${_productColumns.join(',p.')},wp.quantity, tr.rate, tr.name as tax_rate_name 
        FROM sma_products p INNER JOIN sma_warehouses_products wp ON (wp.product_id = p.id_cloud AND 
        wp.warehouse_id = ${dataBloc.userData!.warehouseId}) INNER JOIN sma_tax_rates tr ON 
        tr.id_cloud = p.tax_rate WHERE p.discontinued = 0 AND p.id_cloud IN (${ids.join(',')}) 
        ''';

    return await DBProvider.db.sqlRawQuery(sql);
  }

  ///Function used to get products info based on a list of products IDs,
  ///with innerjoint to sma_tax_rates to get value of tax
  Future<List<Map>?> findCustomerProductsByIds(
      List<int> ids, String customerId) async {
    String sql = '''
        SELECT p.${_productColumns.join(',p.')},wp.quantity, tr.rate, tr.name as tax_rate_name 
        FROM sma_products p INNER JOIN sma_warehouses_products wp ON (wp.product_id = p.id_cloud AND 
        wp.warehouse_id = ${dataBloc.userData!.warehouseId}) INNER JOIN sma_tax_rates tr ON 
        tr.id_cloud = p.tax_rate WHERE p.discontinued = 0 AND p.id_cloud IN (${ids.join(',')}) 
        ''';

    return await DBProvider.db.sqlRawQuery(sql);
  }

  ///Function used to get products given a suspendedSale id
  static Future<List<Map>?> loadSuspendedSProducts(String suspSaleId) async {
    String sql2 = '''
        SELECT p.${_productColumns.join(',p.')},wp.quantity,ssp.price AS sp_price,ssp.price_policy,
        ssp.price_without_discount,ssp.discount ,tr.rate, tr.name as tax_rate_name, 
        ssp.quantity as initial_qtty FROM suspended_sales_product ssp INNER JOIN sma_warehouses_products
         wp ON (wp.product_id = p.id_cloud AND wp.warehouse_id = ${dataBloc.userData!.warehouseId}) 
        INNER JOIN sma_tax_rates tr ON tr.id_cloud = p.tax_rate INNER JOIN sma_products p
        ON (ssp.id_product = p.id_cloud AND p.discontinued = 0) WHERE ssp.id_suspended_sale=$suspSaleId ORDER BY p.name
        ''';

    // return await sqlRawQuery(sql);
    return await DBProvider.db.sqlRawQuery(sql2);
  }

  /// To find products from sma_products, with and whitout search params
  static Future<List<Map>?> findProducts(String? searchs,
      {bool overselling = true,
      bool limit = true,
      bool offset = false,
      int offsetValue = 2}) async {
    if (searchs == null || searchs == '') {
      return await ProductModel.getAllProducts(
          limit: limit,
          offset: offset,
          offsetValue: offsetValue,
          overselling: overselling);
    } else {
      return await findProductsBySearch(searchs,
          limit: limit,
          offset: offset,
          offsetValue: offsetValue,
          overselling: overselling);
    }
  }

  /// Given a string, search in sma_products fields (name,slug,code) LIKE string.
  static Future<List<Map>?> findProductsBySearch(String searchs,
      {bool overselling = true,
      bool limit = true,
      bool offset = false,
      int offsetValue = 2}) async {
    String sql = '';
    if (offset) limit = false;
    if (limit) offset = false;
    if (overselling) {
      sql = '''
              SELECT p.${_productColumns.join(',p.')},wp.quantity, tr.rate, tr.name as tax_rate_name 
              FROM sma_products p INNER JOIN sma_warehouses_products wp ON (wp.product_id = p.id_cloud 
              AND wp.warehouse_id = ${dataBloc.userData!.warehouseId}) INNER JOIN sma_tax_rates tr 
              ON tr.id_cloud = p.tax_rate WHERE p.discontinued = 0 AND (p.name LIKE '%$searchs%' OR 
              p.slug LIKE '%$searchs%' OR p.code LIKE '%$searchs%') ${limit ? "LIMIT 30" : ""}
              ${offset ? "LIMIT 30 offset " + offsetValue.toString() : ""}
          ''';
    } else {
      sql = '''
          SELECT p.${_productColumns.join(',p.')},wp.quantity, tr.rate,tr.name as tax_rate_name 
          FROM sma_products p INNER JOIN sma_warehouses_products wp ON (wp.product_id = p.id_cloud AND 
          wp.warehouse_id = ${dataBloc.userData!.warehouseId}) INNER JOIN sma_tax_rates tr ON tr.id_cloud 
          = p.tax_rate WHERE p.discontinued = 0 AND wp.quantity > 0 AND (p.name LIKE '%$searchs%' OR 
          p.slug LIKE '%$searchs%' OR p.code LIKE '%$searchs%') ${limit ? "LIMIT 30" : ""}
          ${offset ? "LIMIT 30 offset " + offsetValue.toString() : ""}
      ''';
    }

    return await DBProvider.db.sqlRawQuery(sql);
  }

  static Future<List<Map>?> findProductVariants(int id) async {
    return await DBProvider.db
        .sqlQuery('sma_product_variants', where: 'product_id = $id');
  }

  static Future<List<Map>?> findProductPrices(String id) async {
    return await DBProvider.db.sqlRawQuery('''
      SELECT pg.name,pp.price FROM sma_product_prices pp INNER JOIN sma_price_groups pg
      ON pg.id_cloud = pp.price_group_id where pp.product_id = $id
    ''');
  }

  static Future<List<Map>?> findProductQuantities(String id) async {
    return await DBProvider.db.sqlRawQuery('''
      SELECT w.name,wp.quantity FROM sma_warehouses_products wp INNER JOIN sma_warehouses w
      ON wp.warehouse_id = w.id_cloud where wp.product_id = $id
    ''');
  }

  static Future<Map?> findProductCategory(String id) async {
    return await DBProvider.db
        .sqlFirstQuery('sma_categories', where: 'id_cloud = $id');
  }

  static Future<Map?> findProductUnit(String id) async {
    return await DBProvider.db
        .sqlFirstQuery('sma_units', where: 'id_cloud = $id');
  }

  /// Given an id returns all data form id in sma_products
  static Future<Map<String, dynamic>?> findProductDetails(int id) async {
    String sql = '''
        SELECT p.${_productColumns.join(',p.')},wp.quantity, tr.rate, tr.name as tax_rate_name 
        FROM sma_products p INNER JOIN sma_warehouses_products wp ON (wp.product_id = p.id_cloud AND 
        wp.warehouse_id = ${dataBloc.userData!.warehouseId}) INNER JOIN sma_tax_rates tr ON 
        tr.id_cloud = p.tax_rate WHERE p.discontinued = 0 AND p.id_cloud = $id
        ''';

    return await DBProvider.db.sqlFirstRawQuery(sql);
  }

  /// Get price of a product for a given priceGroupId
  Future<Map?> findProductPrice(String id, String idPriceGroup) async {
    return await DBProvider.db.sqlFirstQuery('sma_product_prices',
        where: 'product_id = $id AND price_group_id = $idPriceGroup');
  }

  /// Insert sale products data into DB
  static Future<bool> saveSuspSaleProducts(List<dynamic> query) async {
    return await DBProvider.db.insertQuerys('suspended_sales_product', query);
  }

  /// Insert sale data into DB and returns id of new Row
  static Future<List<Map<String, dynamic>>?> loadSuspSaleProductsFromDB(
      List<dynamic> idSSale) async {
    return await DBProvider.db.sqlQuery('suspended_sales_product',
        where: 'id_suspended_sale=$idSSale');
  }
}
