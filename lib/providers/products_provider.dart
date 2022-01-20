import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';

import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';

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
  static Future<List<Map<String, dynamic>>> checkSuspPriceDif(
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

  /// Insert sale data into DB and returns id of new Row
  static Future<List<Map<String, dynamic>>?> loadSuspSaleProductsFromDB(
      List<dynamic> idSSale) async {
    return await DBProvider.db.sqlQuery('suspended_sales_product',
        where: 'id_suspended_sale=$idSSale');
  }
}
