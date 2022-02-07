import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/models/companies_model.dart';

import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/price_policy_provider.dart';
import 'package:pos_wappsi/providers/units_provider.dart';

class ProductsProvider {
  static List get productColumns => [
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

  /// Check if suspendedSaleProducts's prices are different of current
  /// product's prices and return the price diff betwen them
  static Future<Map<String, dynamic>> checkSuspPriceDif(
      Map res, CompanyModel customer,
      {UnitsModel? unit}) async {
    Map<String, dynamic> dif = {};

    final temp = ProductModel.fromJsonList([res]);
    final prodP =
        await getProductPrices(temp.first, customer: customer, unit: unit);
    if (prodP.price != res['sp_price']) {
      dif = {
        'product_name': res['name'],
        'price': prodP.price,
        'sp_price': res['sp_price']
      };
    }

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
        SELECT p.${productColumns.join(',p.')},wp.quantity, tr.rate,tr.name as tax_rate_name FROM 
        sma_products p INNER JOIN sma_warehouses_products wp ON (wp.product_id = p.id_cloud AND 
        wp.warehouse_id = ${dataBloc.userData!.warehouseId}) INNER JOIN sma_tax_rates tr ON tr.id_cloud = 
        p.tax_rate WHERE p.discontinued = 0 ORDER BY p.name ${limit ? "LIMIT 30" : ""}
        ${offset ? "LIMIT 30 offset " + offsetValue.toString() : ""}
    ''';
    } else {
      sql = '''
              SELECT p.${productColumns.join(',p.')},wp.quantity, tr.rate,tr.name as tax_rate_name FROM 
              sma_products p INNER JOIN sma_warehouses_products wp ON (wp.product_id = p.id_cloud AND 
              wp.warehouse_id = ${dataBloc.userData!.warehouseId}) INNER JOIN sma_tax_rates tr ON 
              tr.id_cloud = p.tax_rate WHERE p.discontinued = 0 AND wp.quantity>0 ORDER BY p.name ${limit ? "LIMIT 30" : ""}
              ${offset ? "LIMIT 30 offset " + offsetValue.toString() : ""}
          ''';
    }

    return await DBProvider.db.sqlRawQuery(sql);
  }

  ///Function used to get products info based on a list of products IDs,
  ///with innerjoint to sma_tax_rates to get value of tax
  Future<List<Map>?> findProductsByIds(List<int> ids) async {
    String sql = '''
        SELECT p.${productColumns.join(',p.')},wp.quantity, tr.rate, tr.name as tax_rate_name 
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
        SELECT p.${productColumns.join(',p.')},wp.quantity, tr.rate, tr.name as tax_rate_name 
        FROM sma_products p INNER JOIN sma_warehouses_products wp ON (wp.product_id = p.id_cloud AND 
        wp.warehouse_id = ${dataBloc.userData!.warehouseId}) INNER JOIN sma_tax_rates tr ON 
        tr.id_cloud = p.tax_rate WHERE p.discontinued = 0 AND p.id_cloud IN (${ids.join(',')}) 
        ''';

    return await DBProvider.db.sqlRawQuery(sql);
  }

  ///Function used to get products given a suspendedSale id
  static Future<List<Map>?> loadSuspendedSProducts(String suspSaleId) async {
    String sql2 = '''
        SELECT p.${productColumns.join(',p.')},wp.quantity,ssp.price AS sp_price,ssp.price_policy,
        ssp.price_without_discount,ssp.discount ,tr.rate, tr.name as tax_rate_name, 
        ssp.quantity as initial_qtty,ssp.unit_id as unit_id FROM suspended_sales_product ssp INNER JOIN sma_warehouses_products
         wp ON (wp.product_id = p.id_cloud AND wp.warehouse_id = ${dataBloc.userData!.warehouseId}) 
        INNER JOIN sma_tax_rates tr ON tr.id_cloud = p.tax_rate INNER JOIN sma_products p
        ON (ssp.id_product = p.id_cloud AND p.discontinued = 0) WHERE ssp.id_suspended_sale=$suspSaleId ORDER BY p.name
        ''';

    // return await sqlRawQuery(sql);
    return await DBProvider.db.sqlRawQuery(sql2);
  }

  /// Load products of given suspended sale id
  static Future<Map<String, dynamic>> loadSuspSaleProducts(
      String suspSaleId, CompanyModel customer) async {
    final res = await loadSuspendedSProducts(suspSaleId);
    List<Map<String, dynamic>> dif = [];
    List<ProductModel> products = [];
    List<UnitsModel> units = [];
    if (res != null) {
      await Future.forEach(res, (Map p) async {
        products.add(ProductModel.fromJsonList([p],
                loadInitialQtty: true,
                qttyKey: 'initial_qtty',
                initalPrice: true,
                inititalPriceKey: 'sp_price')
            .first);
        UnitsModel? unit;
        if (p['unit_id'] != null && p['unit_id'] != '') {
          unit = await UnitsProvider.getPUnitSuspended(p['id_cloud'].toString(),
              customer.priceGroupId!, p['unit_id'].toString());
          if (unit != null) {
            units.add(unit);
          }
        }
        final tdif = await checkSuspPriceDif(p, customer, unit: unit);
        if (tdif.isNotEmpty) {
          dif.add(tdif);
        }
      });
    }
    return {'products': products, 'dif': dif, 'products_unit': units};
  }

  static Future<bool> saveProductsSpSale(int suspSaleId) async {
    bool result = false;
    if (suspSaleId != 0) {
      List<Map<String, dynamic>> productsMap = [];
      for (var k in posBloc.getProducts!.keys) {
        final product = posBloc.getProducts![k]!;
        productsMap.add({
          'id_suspended_sale': suspSaleId,
          'id_product': product.idCloud,
          'quantity': product.quantity,
          'price': product.price,
          'price_policy': product.pricePolicyPrices,
          'price_without_discount': product.priceWithoutDiscount,
          'discount': product.discount,
          'unit_id': posBloc.getProductUnits?[k]?.idCloud,
        });
      }
      result = await saveSuspSaleProducts(productsMap);
    }
    return result;
  }

  /// To find products from sma_products, with and whitout search params
  static Future<List<Map>?> findProducts(String? searchs,
      {bool overselling = true,
      bool limit = true,
      bool offset = false,
      int offsetValue = 2}) async {
    if (searchs == null || searchs == '') {
      return await getAllProducts(
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
              SELECT p.${productColumns.join(',p.')},wp.quantity, tr.rate, tr.name as tax_rate_name 
              FROM sma_products p INNER JOIN sma_warehouses_products wp ON (wp.product_id = p.id_cloud 
              AND wp.warehouse_id = ${dataBloc.userData!.warehouseId}) INNER JOIN sma_tax_rates tr 
              ON tr.id_cloud = p.tax_rate WHERE p.discontinued = 0 AND (p.name LIKE '%$searchs%' OR 
              p.slug LIKE '%$searchs%' OR p.code LIKE '%$searchs%') ${limit ? "LIMIT 30" : ""}
              ${offset ? "LIMIT 30 offset " + offsetValue.toString() : ""}
          ''';
    } else {
      sql = '''
          SELECT p.${productColumns.join(',p.')},wp.quantity, tr.rate,tr.name as tax_rate_name 
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
        SELECT p.${productColumns.join(',p.')},wp.quantity, tr.rate, tr.name as tax_rate_name 
        FROM sma_products p INNER JOIN sma_warehouses_products wp ON (wp.product_id = p.id_cloud AND 
        wp.warehouse_id = ${dataBloc.userData!.warehouseId}) INNER JOIN sma_tax_rates tr ON 
        tr.id_cloud = p.tax_rate WHERE p.discontinued = 0 AND p.id_cloud = $id
        ''';

    return await DBProvider.db.sqlFirstRawQuery(sql);
  }

  /// Get price of a product for a given priceGroupId
  static Future<Map?> findProductPrice(String id, String idPriceGroup) async {
    return await DBProvider.db.sqlFirstQuery('sma_product_prices',
        where: 'product_id = $id AND price_group_id = $idPriceGroup');
  }

  /// Insert sale products data into DB
  static Future<bool> saveSuspSaleProducts(List<dynamic> query) async {
    return await DBProvider.db.insertQuerys('suspended_sales_product', query);
  }

  /// Insert sale data into DB and returns id of Row
  static Future<List<Map<String, dynamic>>?> loadSuspSaleProductsFromDB(
      List<dynamic> idSSale) async {
    return await DBProvider.db.sqlQuery('suspended_sales_product',
        where: 'id_suspended_sale=$idSSale');
  }

  /// Returns map with product and its requirementes based on pricePolicy
  static Future<Map<String, dynamic>> getProductRequirements(
      BuildContext context, ProductModel product) async {
    final policyReq = PricePoliciesProvider.checkProductSelectionRequirements();
    Map<String, dynamic> req = {"product": product, "product_unit": null};
    Map<String, dynamic>? unitInfo;
    if (policyReq['product_unit']) {
      unitInfo = await UnitsProvider.getProductUnit(
          context, product, posBloc.getCustomer!.priceGroupId!);
      if (unitInfo != null) {
        final unit = unitInfo['unit'];
        req['product_unit'] = unitInfo['unit'];
        req['product'].quantity =
            (unit.operationValue ?? 1) * (unitInfo['quantity'] ?? 1);
      } else {
        req = {};
      }
    }
    return req;
  }

  /// Return ProductModel product with all it's prices in it
  static Future<ProductModel> getProductPrices(ProductModel product,
      {String? productKey,
      String? customerId,
      bool defaultPrice = false,
      CompanyModel? customer,
      UnitsModel? unit}) async {
    if (dataBloc.settings != null) {
      final product2 = await PricePoliciesProvider.policyCases(product,
          dataBloc.settings!['prioridad_precios_producto'], posBloc.getCustomer,
          defaultPrice: defaultPrice, unit: unit);

      return product2;
      //aply discount

    } else {
      await dataBloc.getSettings();
      return getProductPrices(product);
    }
  }

  /// Return ProductModel product with all it's prices in it
  static Future<bool> getPOSProductPrices(String productKey,
      {String? customerId,
      bool defaultPrice = false,
      bool toOrder = false}) async {
    if (dataBloc.settings != null) {
      final result = await PricePoliciesProvider.policyCasesFromPos(productKey,
          dataBloc.settings!['prioridad_precios_producto'], posBloc.getCustomer,
          defaultPrice: defaultPrice, toOrder: toOrder);

      return result;
      //aply discount

    } else {
      await dataBloc.getSettings();
      return getPOSProductPrices(productKey);
    }
  }

  /// Return ProductModel product with all it's prices in it
  static Future<bool> getPOSOrderProductPrices(String productKey,
      {String? customerId, bool defaultPrice = false}) async {
    if (dataBloc.settings != null) {
      final result = await PricePoliciesProvider.policyCasesFromPosOrder(
          productKey,
          dataBloc.settings!['prioridad_precios_producto'],
          posBloc.getCustomer,
          defaultPrice: defaultPrice);

      return result;
      //aply discount

    } else {
      await dataBloc.getSettings();
      return getPOSProductPrices(productKey);
    }
  }
}
