import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/customer_bloc.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/orders_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/models/biller_data_model.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/providers/api_provider.dart';
import 'package:pos_wappsi/providers/groups_providers.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/price_groups_provider.dart';
import 'package:pos_wappsi/providers/wishlist_provider.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
import 'package:pos_wappsi/utils/validation_encoding/encode_pass.dart';
import 'package:pos_wappsi/utils/nav_utils.dart';

class CompaniesProvider {
  /// Load default customer from db to posBloc
  static selectDefaultCustomer(
      {bool returnBool = false, bool fromOrderCreation = false}) async {
    if (dataBloc.getBIllerData == null) {
      final billerData = await DBProvider.db.getBillerData();
      if (billerData != null) {
        dataBloc.setBillerData(BillerDataModel.fromJson(billerData));
      }
    }
    if (fromOrderCreation) {
      if (orderBloc.getCustomer == null) {
        String? idCustomer = dataBloc.getBIllerData!.defaultCustomerId;
        if (idCustomer != null) {
          Map<String, dynamic>? customer = await findCompanyById(idCustomer);
          if (customer != null) {
            orderBloc.setCustomer(CompanyModel.fromJson(customer));
            if (returnBool) {
              return true;
            }
          }
        }
      }
    } else {
      if (posBloc.getCustomer == null) {
        String? idCustomer = dataBloc.getBIllerData!.defaultCustomerId;
        if (idCustomer != null) {
          Map<String, dynamic>? customer = await findCompanyById(idCustomer);
          if (customer != null) {
            posBloc.setCustomer(CompanyModel.fromJson(customer));
            if (returnBool) {
              return true;
            }
          }
        }
      }
    }
  }

  static Future<List<CompanyModel>> getCustomers(filter) async {
    List<Map<String, dynamic>>? data;

    if (filter == '' || filter == null) {
      data = await getAllCustomers(limit: 20);
    } else {
      data = await findCustomer(filter, limit: 20);
    }

    // ignore: unnecessary_null_comparison
    if (data != null) {
      return CompanyModel.fromJsonList(data);
    }

    return [];
  }

  /// Write customer and his address created locally into local DB with ids comming from cloud
  /// DB
  static Future<bool> writeCustomerInLDB(
      Map<String, dynamic> body, Map<String, dynamic> res) async {
    // ignore: prefer_typing_uninitialized_variables
    var customerId;
    bool result = false;
    final List<int> favorites = body['favorites'] ?? [];
    final geoLoc = body['geo_location'];
    try {
      // to remove data for user and favorites creation
      body.remove('user_data');
      body.remove('image');
      body.remove('geo_location');
      body.remove('favorites');
    } catch (e) {
      printConsole(e);
    }

    body['id_cloud'] = res['body']['company_id'];
    body['customer_profile_photo'] = res['body']['customer_profile_photo'];

    customerId =
        await DBProvider.db.insertQuery('sma_companies', body, returnId: true);
    if (customerId != 0) {
      // result = true;
      final address = {
        'id_cloud': res['body']['address_id'],
        'company_id': body['id_cloud'],
        'direccion': body['address'],
        'sucursal': body['name'],
        'city': body['city'],
        'state': body['state'],
        'country': body['country'],
        'phone': body['phone'],
        'city_code': body['city_code'],
        'customer_group_id': body['customer_group_id'],
        'customer_group_name': body['customer_group_name'],
        'price_group_name': body['price_group_name'],
        'price_group_id': body['price_group_id'],
        'email': body['email'],
        'geo_location': jsonEncode(geoLoc??{}),
        'code': body['vat_no'] + '-01',
      };
      result = await DBProvider.db.insertQuery('sma_addresses', address);
      printConsole(result);
      try {
        // if (favorites != []) {
          final favRes = await WishlistProvider.saveCustomerFavFromLocal(
              customerId.toString(), favorites);
          printConsole(favRes);
        // }
      } catch (e) {
        printConsole(e);
      }
    }

    return result;
  }

  //-----------------------------------------------------------------------------
  //                                CUSTOMERS
  //
  //-----------------------------------------------------------------------------

  /// Return all rows in sma_companies with group_id=3 (customers) and status = 1
  static Future<List<Map<String, dynamic>>?> getAllCustomers(
      {int? limit,
      String orderBy = 'name',
      bool offset = false,
      int? offsetValue}) async {
    if (offset) {
      limit = 50;
    }
    return await DBProvider.db.sqlQuery(
      'sma_companies',
      where: 'group_id = 3 AND status=1',
      limit: limit,
      orderBy: orderBy,
      offset: offsetValue,
    );
  }

  /// Find costumers from sma_companies, with and withoud search params.
  static Future<List<Map<String, dynamic>>?> findCustomer(String? searchs,
      {int? limit,
      String orderBy = 'name',
      bool offset = false,
      int offsetValue = 1}) async {
    if (searchs == null || searchs == '') {
      return await getAllCustomers(
          limit: limit,
          orderBy: orderBy,
          offset: true,
          offsetValue: offsetValue);
    } else {
      return (await findCustomerBySearch(searchs,
          limit: limit,
          orderBy: orderBy,
          offset: offset,
          offsetValue: offsetValue)) ??[];
    }
  }

  /// Return all rows in sma_companies with group_id=3 (customers) and fields
  /// (name,company,vat_no ) LIKE given string
  static Future<List<Map<String, dynamic>>?> findCustomerBySearch(
      String searchs,
      {int? limit,
      String orderBy = 'name',
      bool offset = false,
      int offsetValue = 1}) async {
    return await DBProvider.db.sqlQuery('sma_companies',
        where:
            '''group_id = 3 AND status=1 AND (name LIKE "%$searchs%" OR company 
            LIKE "%$searchs%" OR vat_no LIKE "%$searchs%" OR first_name LIKE "%$searchs%" 
            OR second_name LIKE "%$searchs%" OR first_lastname LIKE "%$searchs%"
            OR second_lastname LIKE "%$searchs%") ${offset ? "LIMIT 50 offset " + offsetValue.toString() : ""}''',
        limit: limit,
        orderBy: orderBy);
  }

  /// Return a row of sma_companies given an id
  static Future<Map<String, dynamic>?> findCompanyById(String id) async {
    return await DBProvider.db.sqlFirstQuery('sma_companies',
        // columns: _customerColumns,
        where: "id_cloud = $id");
  }

  /// Return a CompanyModel object given a company ID
  static Future<CompanyModel?> getCompanyById(String id) async {
    final res = await DBProvider.db.sqlFirstQuery('sma_companies',
        // columns: _customerColumns,
        where: "id_cloud = $id");
    if (res != null) {
      return CompanyModel.fromJson(res);
    } else {
      return null;
    }
  }

  /// Return id of current default customer of system
  static Future<int?> findDefaultCustomer(String billerId) async {
    try {
      final res = await DBProvider.db.sqlFirstQuery(
        'sma_biller_data',
        columns: ['default_customer_id'],
        where: "biller_id=$billerId",
      );
      int? customerId;
      if (res != null) {
        customerId = int.tryParse(res['sma_biller_data'].toString());
      }

      if (customerId != null) {
        return customerId;
      }

      final res2 = await DBProvider.db
          .sqlFirstQuery('sma_pos_settings', columns: ['default_customer_id']);
      if (res2 != null) {
        customerId = int.tryParse(res2['sma_biller_data'].toString());
      }

      if (customerId != null) {
        return customerId;
      }
    } catch (e) {
      printConsole(e);
      return null;
    }
    return null;
  }

  /// Return all data in sma_customer_groups of a given id
  static Future<Map<String, dynamic>?> findCustomerDiscount(String id) async {
    return await DBProvider.db
        .sqlFirstQuery('sma_customer_groups', where: "id_cloud = $id");
  }

  static sendCustomerInfo(BuildContext context) async {
    final customerGroup = await GroupsProvider.loadCustomerGroup();
    // bool closeLoading = false;

    final apiProvider = DataProvider();
    if (customerGroup == null) {
      return {
        'error': true,
        'body': {'message': 'No fue posible seleccionar grupo de company'}
      };
    } else {
      customerBloc.getCustomer.groupId = customerGroup.idCloud.toString();
      customerBloc.getCustomer.groupName = customerGroup.name;
    }
    if (customerBloc.getCustomer.priceGroupId == null ||
        customerBloc.getCustomer.priceGroupId == '') {
      final defPriceGroup = await PriceGroupsProvider.loadDefaultPriceGroup();
      customerBloc.getCustomer.priceGroupId = (defPriceGroup!.idCloud);
      customerBloc.getCustomer.priceGroupName = defPriceGroup.name;
    }

    final body = customerBloc.getCustomer.customerToJson();

    if (customerBloc.getUserName != null && customerBloc.getPassword != null) {
      final temp = {};
      temp['username'] = customerBloc.getUserName;
      temp['password'] = encodePass(customerBloc.getPassword!);
      body['user_data'] = temp;
    }

    // ignore: unnecessary_null_comparison
    if (customerBloc.getProducts() != null) {
      List<int> favorites = [];
      customerBloc.getProducts()!.forEach((key, value) {
        favorites.add(value.idCloud);
      });
      body['favorites'] = favorites;
    }

    if (customerBloc.getImagePath != null) {
      final bytes = File(customerBloc.getImagePath!).readAsBytesSync();
      String img64 = base64Encode(bytes);
      body['image'] = img64;
    }
    if (customerBloc.getLocation != null) {
      body['geo_location'] = customerBloc.getLocation!.toMap();
    }

    try {
      scaffoldAlert(context, 'Registrando cliente', const Duration(seconds: 10),
        key: UniqueKey());
    } catch (e) {
      printConsole(e);
      // closeLoading = true;
      // loading(context);
    }

    final res = await apiProvider.postPetition(
        addCompanyEndP, body, dataBloc.getHeaders());

    hideCurrentScaffoldAlert(context);
    // if(closeLoading){
    //     Navigator.pop(context);
    //   }
    if (res['status'] == -1) {
      await reloadDialog(
          context, res['body']['message'], 'assets/images/dizzy-robot.png');
    } else if (res['error']) {
      confirmDialog(
          context, res['body']['message'], 'assets/images/dizzy-robot.png');
    } else {
      // update local DB with company info

      bool dbUpdated = await CompaniesProvider.writeCustomerInLDB(body, res);

      

      // if fails we force DB sync
      if (!dbUpdated) {
        goHomeAndEmptyCustomerBloc(context);
        // DBSyncElements(
        //   options: {'Terceros': true, 'Sucursales': true},
        // ).launch(context);
        await dataBloc.syncElements(['Terceros', 'Sucursales'], context);
        confirmDialog(
            context, res['body']['message'], 'assets/images/success.png');
      } else {
        // if local db update success, go to home
        goHomeAndEmptyCustomerBloc(context);
        // dataBloc.homeKey.currentState?.selectTab(TabItem.clients);
        confirmDialog(
            context, res['body']['message'], 'assets/images/success.png');
      }

      // Navigator.pop(context);
    }
  }

  static addCompanyFavs(BuildContext context, CompanyModel customer) async {
    final Map<String, dynamic> body = {};

    if (customerBloc.getUserName != null && customerBloc.getPassword != null) {
      final temp = {};
      temp['username'] = customerBloc.getUserName;
      temp['password'] = encodePass(customerBloc.getPassword!);
      temp['first_name'] = customer.firstName;
      temp['last_name'] = customer.firstLastname;
      temp['company'] = customer.company;
      temp['company_id'] = customer.idCloud;
      temp['phone'] = customer.phone;
      temp['email'] = customer.email;
      temp['group_id'] = customer.groupId;
      temp['avtive'] = 1;

      body['user_data'] = temp;
    }

    // ignore: unnecessary_null_comparison
    if (customerBloc.getProducts() != null) {
      List<int> favorites = [];
      customerBloc.getProducts()!.forEach((key, value) {
        favorites.add(value.idCloud);
      });
      body['favorites'] = favorites;
    }

    // add customer id
    body['company_id'] = customer.idCloud;

    scaffoldAlert(context, 'Añadiendo favoritos', const Duration(seconds: 10),
        key: UniqueKey());
    final apiProvider = DataProvider();
    final res = await apiProvider.postPetition(
        addCompanyFavEndP, body, dataBloc.getHeaders());

    hideCurrentScaffoldAlert(context);
    if (res['status'] == -1) {
      await reloadDialog(
          context, res['body']['message'], 'assets/images/dizzy-robot.png');
    } else if (res['error']) {
      confirmDialog(
          context, res['body']['message'], 'assets/images/dizzy-robot.png');
    } else {
      // update local DB with company info
      bool dbUpdated =
          await WishlistProvider.reloadCustomerFavs(context, customer);

      // if fails we force DB sync
      if (!dbUpdated) {
        customerBloc.clear();
        // DBSyncElements(
        //   options: {'Terceros': true, 'Sucursales': true},
        // ).launch(context);
        await dataBloc.syncElements(['Terceros', 'Sucursales'], context);
        confirmDialog(
            context, res['body']['message'], 'assets/images/success.png');
      } else {
        // if local db update success, go to home

        customerBloc.clear();
        // dataBloc.homeKey.currentState?.selectTab(TabItem.clients);
        confirmDialog(
            context, res['body']['message'], 'assets/images/success.png');
      }

      // Navigator.pop(context);
    }
  }
}
