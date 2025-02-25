import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/api_provider.dart';
import 'package:pos_wappsi/providers/biller_data_provider.dart';
import 'package:pos_wappsi/providers/companies_provider.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
// import 'package:pos_wappsi/providers/price_policy_provider.dart';
import 'package:pos_wappsi/providers/products_provider.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/manage_server_resp.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

class WishlistProvider {
  /// given a list of product ids, load them into
  static Future<List<ProductModel>> loadCustomerFavorites(
    CompanyModel customer,
  ) async {
    final products = await getCustomerFavFromDB(customer.id.toString());
    if (products?.isEmpty ?? true) {
      return [];
    } else {
      final temp = ProductModel.fromJsonList(products!);
      // List<ProductModel> pM = [];
      // await Future.forEach(temp, (ProductModel p) async {
      //   // here we can get price policy prices if it's necessary
      //   pM.add(p);
      // });

      return temp;
    }
  }

  static Future<List<Map<String, dynamic>>?> getCustomerFavFromDB(
    String customerId,
  ) async {
    // String sql = '''
    //     SELECT p.${_productColumns.join(',p.')},wp.quantity, tr.rate, tr.name as tax_rate_name
    //     FROM sma_products p INNER JOIN sma_warehouses_products wp ON (wp.product_id = p.id_cloud AND
    //     wp.warehouse_id = ${dataBloc.userData!.warehouseId}) INNER JOIN sma_tax_rates tr ON
    //     tr.id_cloud = p.tax_rate INNER JOIN sma_wishlist wl ON wl.customer_id = $customerId
    //     WHERE p.discontinued = 0
    //     ''';movil

    String sql = '''
    SELECT DISTINCT p.${ProductsProvider.productColumns.join(',p.')},wp.quantity, tr.rate, tr.name as tax_rate_name 
    FROM sma_wishlist wl INNER JOIN sma_products p ON (p.id_cloud =wl.product_id 
    AND p.discontinued = 0) INNER JOIN sma_warehouses_products wp ON (wp.product_id = wl.product_id AND 
    wp.warehouse_id = ${dataBloc.userData!.warehouseId}) INNER JOIN sma_tax_rates tr ON tr.id = p.tax_rate 
    WHERE wl.customer_id=$customerId;''';

    final res = await DBProvider.db.sqlRawQuery(sql);

    if (res == [] || res == null) {
      return [];
    } else {
      return res;
    }
  }

  static Future<bool> reloadCustomerFavorites(
    BuildContext context,
    CompanyModel customer,
  ) async {
    // get favorites from Cloud(
    final fav = await getCustomerFav(customer, context);
    bool result = false;
    if (fav.isNotEmpty) {
      result = await saveCustomerFav(customer, fav);
    } else {
      result = true;
    }
    return result;
  }

  static Future<List<Map>> getCustomerFav(
    CompanyModel customer,
    BuildContext context,
  ) async {
    var dataProvider = DataProvider();

    final res = await dataProvider.postPetition(
      getCustomerWishListEndP,
      {'company_id': customer.idCloud},
      dataBloc.getHeaders(),
    );

    manageResponseAlerts(res, context);
    try {
      final List<Map> fav = List<Map>.from(res['body']['data']);
      if (fav.isNotEmpty) {
        return fav;
      } else {
        confirmDialog(
          context,
          res['body']['message'],
          'assets/images/alert.png',
        );
        return [{}];
      }
    } catch (e) {
      printConsole(e);
      confirmDialog(context, res['body']['message'], 'assets/images/alert.png');
      return [];
    }
  }

  static Future<bool> saveCustomerFav(
    CompanyModel customer,
    List<Map> favorites,
  ) async {
    if (favorites.isNotEmpty) {
      await deleteLocalCustomerFavorites(customer);

      if (favorites.isNotEmpty) {
        final query = [];
        for (var e in favorites) {
          query.add({
            'user_id': e['user_id'],
            'id_cloud': e['id_cloud'],
            'product_id': e['product_id'],
            'customer_id': customer.id,
          });
        }
        return await DBProvider.db.insertOrUpdateQuery('sma_wishlist', query);
      } else {
        return true;
      }
    } else {
      // without favorites to save
      // delete current favorites from local

      return true;
    }
  }

  static Future<bool> saveCustomerFavFromLocal(
    String customerId,
    List<int> favorites,
  ) async {
    if (favorites.isNotEmpty) {
      final List<Map> query = [];
      for (var p in favorites) {
        query.add({
          'user_id': null,
          'id_cloud': null,
          'product_id': p.toString(),
          'customer_id': customerId,
        });
      }
      return await DBProvider.db.insertQueryJsonList('sma_wishlist', query);
    } else {
      // without favorites to save
      // delete current favorites from local

      return true;
    }
  }

  static Future<List<Map>> getFavoritesId(
    CompanyModel customer,
    List<ProductModel> products,
  ) async {
    if (products.isNotEmpty) {
      String pIds = '(';
      for (var p in products) {
        pIds += p.idCloud.toString();
        if (p != products.last) {
          pIds += ',';
        } else {
          pIds += ')';
        }
      }

      final res = await DBProvider.db.sqlQuery(
        'sma_wishlist',
        where: 'customer_id=${customer.id} AND product_id IN $pIds',
        columns: ['id', 'id_cloud'],
      );
      return res ?? [];
    } else {
      return [];
    }
  }

  /// Delete local favorites in List of favorites, and return a list of favorites id
  /// who are also stored in cloud db
  static Future<List> deleteLocalFav(
    CompanyModel customer,
    List<Map> favorites,
  ) async {
    if (favorites.isNotEmpty) {
      // delete all selected favorites from local db
      final temp1 = getKeyValuesOfListMap(favorites, 'id');
      final res = await deleteLocalSelectedCustomerFavorites(customer, temp1);
      if (res) {
        printConsole('Favorites deleted successfully');
      }

      return getKeyValuesOfListMap(favorites, 'id_cloud');
    } else {
      return [];
    }
  }

  static Future<Map<String, dynamic>> deleteCustomerFavoritesOnServer(
    String customerId,
    List favorites,
  ) async {
    final data = {'company_id': customerId, 'favorites': favorites};
    var dataProvider = DataProvider();

    final res = dataProvider.postPetition(
      deleteCompanyFavEndP,
      data,
      dataBloc.getHeaders(),
    );
    return res;
  }

  static Future<Map<String, dynamic>> addCustomerFavoritesToServer(
    String customerId,
    List favorites,
  ) async {
    final data = {'company_id': customerId, 'favorites': favorites};
    var dataProvider = DataProvider();

    final res = dataProvider.postPetition(
      deleteCompanyFavEndP,
      data,
      dataBloc.getHeaders(),
    );
    return res;
  }

  static Future<bool> deleteLocalCustomerFavorites(
    CompanyModel customer,
  ) async {
    String where = '''
        customer_id=${customer.id} 
        ''';

    return await DBProvider.db.sqlDelete('sma_wishlist', where);
  }

  /// Delete all favorites i List favorites for a given customer
  static Future<bool> deleteLocalSelectedCustomerFavorites(
    CompanyModel customer,
    List favoritesIds,
  ) async {
    String where =
        "customer_id=${customer.id} AND id IN (${favoritesIds.join(',')})";

    return await DBProvider.db.sqlDelete('sma_wishlist', where);
  }

  static Future<Map> buildPrintDataMap(
    CompanyModel customer,
    List<ProductModel> products,
  ) async {
    final billerId = dataBloc.userData!.billerId.toString();
    final biller = await CompaniesProvider.getCompanyById(billerId);
    final billerData = await BillerDataProvider.loadBillerDataId(billerId);
    // final customerAddress = await CustomerAddressesProvider.loadCustomerAddress(
    //     addressId.toString());
    // Load only first sale payment

    final settings = dataBloc.settings;

    final productsInfo = products.map((p) {
      return p.toJson();
    }).toList();

    return {
      'products': productsInfo,
      'customer': customer.toJson(),
      // "customer_address": customerAddress?.toJson() ?? {},
      'company_data': biller,
      'biller_data': billerData,
      'settings': settings,
    };
  }
}
