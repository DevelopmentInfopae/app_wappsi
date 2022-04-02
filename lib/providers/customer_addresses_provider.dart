import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/customer_bloc.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/orders_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/bloc/quotes_bloc.dart';
import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/models/companies_model.dart';
// import 'package:pos_wappsi/environment/environment.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/providers/api_provider.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

class CustomerAddressesProvider {
  static List<String> get _addressesColumns => [
        "id",
        "id_cloud",
        "sucursal",
        "company_id",
        "country",
        "state",
        "direccion",
        "city",
        "vat_no",
        "code",
        "customer_group_id",
        "price_group_id",
      ];

  /// Load default customer address
  static Future<CustomerAddressesModel?> selectDefaultAddrs(
      String? customerId) async {
    if (customerId == null) {
      return null;
    } else {
      final data = await findCustomerAddresses('', customerId);
      if (data != []) {
        final defaultAddrss = data.first;

        return CustomerAddressesModel.fromJson(defaultAddrss);
      } else {
        return null;
      }
    }
  }

  /// Load default customer address
  static selectDefaultAddrsToOrder({bool returnBool = false}) async {
    if (orderBloc.getCustomer != null &&
        orderBloc.getCustomerAddresses == null) {
      final data = await findCustomerAddresses(
          '', orderBloc.getCustomer!.idCloud!.toString());
      if (data != []) {
        final defaultAddrss = data.first;

        orderBloc.setCustomerAddresses(
            CustomerAddressesModel.fromJson(defaultAddrss));
        if (returnBool) {
          return true;
        }
      }
    }
  }

  /// Load default customer address
  static selectDefaultAddrsToQuote({bool returnBool = false}) async {
    if (quoteBloc.getCustomer != null &&
        quoteBloc.getCustomerAddresses == null) {
      final data = await findCustomerAddresses(
          '', quoteBloc.getCustomer!.idCloud!.toString());
      if (data != []) {
        final defaultAddrss = data.first;

        quoteBloc.setCustomerAddresses(
            CustomerAddressesModel.fromJson(defaultAddrss));
        if (returnBool) {
          return true;
        }
      }
    }
  }

  /// Load address given an address id

  static Future<CustomerAddressesModel?> loadCustomerAddress(String id) async {
    final data = await loadCustomerAddressFromDB(id);
    if (data != null) {
      return CustomerAddressesModel.fromJson(data);
    } else {
      return null;
    }
  }

  /// Load address given an address id

  static Future<List<CustomerAddressesModel>> loadCustomerAddresses(
      String id) async {
    final data = await loadCustomerAddressesFromDB(id);
    if (data != null) {
      try {
        return CustomerAddressesModel.fromJsonList(data);
      } catch (e) {
        // printConsole(e);
        await logError(e, from: 'Loading customer addresses');

        return [];
      }
    } else {
      return [];
    }
  }

  /// To load POS sale customer addresses
  static Future<List<CustomerAddressesModel>> getDataAdrreses(filter) async {
    List<Map> data;

    String? customerID = posBloc.getCustomerId();

    if (customerID == '0') {
      data = [];
    } else {
      if (customerID != null) {
        data = await findCustomerAddresses(filter, customerID);
      } else {
        data = [];
      }
    }

    // ignore: unnecessary_null_comparison
    if (data != null) {
      return CustomerAddressesModel.fromJsonList(data);
    }

    return [];
  }

  /// To load POS sale customer addresses
  static Future<List<CustomerAddressesModel>> getDataAdrresesToOrder(
      filter) async {
    List<Map> data;

    String customerID = orderBloc.getCustomerId();

    if (customerID == '0') {
      data = [];
    } else {
      data = await findCustomerAddresses(filter, customerID);
    }

    // ignore: unnecessary_null_comparison
    if (data != null) {
      return CustomerAddressesModel.fromJsonList(data);
    }

    return [];
  }

  /// To load POS sale customer addresses
  static Future<List<CustomerAddressesModel>> getDataAdrresesToQuote(
      filter) async {
    List<Map> data;

    String customerID = quoteBloc.getCustomerId();

    if (customerID == '0') {
      data = [];
    } else {
      data = await findCustomerAddresses(filter, customerID);
    }

    // ignore: unnecessary_null_comparison
    if (data != null) {
      return CustomerAddressesModel.fromJsonList(data);
    }

    return [];
  }

  /// Write customer and his address created locally into local DB with ids comming from cloud
  /// DB
  static Future<bool> writeAddressOnDB(Map<String, dynamic> body) async {
    bool dbUpdated = false;

    dbUpdated = await DBProvider.db.insertQuery('sma_addresses', body);

    return dbUpdated;
  }

  //-----------------------------------------------------------------------------
  //                              CUSTOMER ADDRESSES
  //
  //-----------------------------------------------------------------------------

  /// Returns all rows in sma_addresses with company_id = csutomerID and fields
  /// (sucursal,state,city,country) LIKE given string searchs
  static Future<List<Map>> findCustomerAddresses(
      String searchs, String customerID) async {
    try {
      final res = await DBProvider.db.sqlQuery('sma_addresses',
          columns: _addressesColumns,
          where: '''
          company_id = $customerID AND (sucursal LIKE '%$searchs%' OR state 
          LIKE '%$searchs%' OR city LIKE '%$searchs%' OR country LIKE '%$searchs%')
        ''',
          limit: 20);
      return res ?? [];
    } catch (e) {
      printConsole(e);
      return [];
    }
  }

  /// Returns customer address info given an address id
  static Future<Map<String, dynamic>?> loadCustomerAddressFromDB(
      String addressId) async {
    return await DBProvider.db
        .sqlFirstQuery('sma_addresses', where: "id_cloud = $addressId");
  }

  /// Returns customer address info given an address id
  static Future<List<Map<String, dynamic>>?> loadCustomerAddressesFromDB(
      String customerId) async {
    return await DBProvider.db.sqlQuery('sma_addresses',
        where: "company_id = $customerId", orderBy: "last_update DESC");
  }

  static createAddress(BuildContext context, CompanyModel customer) async {
    final apiProvider = DataProvider();

    customerBloc.getAddress.customerGroupId = customer.customerGroupId!;
    customerBloc.getAddress.customerGroupName = customer.customerGroupName!;
    customerBloc.getAddress.companyId = customer.idCloud!;
    customerBloc.getAddress.vatNo = customer.vatNo ?? '';
    customerBloc.getAddress.customerAddressSellerIdAssigned =
        customer.customerSellerIdAssigned;
    customerBloc.getAddress.priceGroupId = customer.priceGroupId!;
    customerBloc.getAddress.priceGroupName = customer.priceGroupName!;
    customerBloc.getAddress.customerAddressSellerIdAssigned =
        customer.customerSellerIdAssigned!;

    final customerAddresses =
        await CustomerAddressesProvider.findCustomerAddresses(
            '', customer.idCloud!);
    String nAddress = '';
    if (customerAddresses.isNotEmpty) {
      final addLen = customerAddresses.length;
      if (addLen >= 9) {
        nAddress = (addLen + 1).toString();
      } else {
        nAddress = '0' + (addLen + 1).toString();
      }
    }

    customerBloc.getAddress.code = (customer.vatNo ?? '') + '-' + nAddress;

    final body = customerBloc.getAddress.toJson();

    scaffoldAlert(context, 'Creando sucursal', const Duration(seconds: 10),
        key: UniqueKey());
    final res = await apiProvider.postPetition(
        addAddressEnd, body, dataBloc.getHeaders());

    hideCurrentScaffoldAlert(context);
    if (res['status'] == -1) {
      await reloadDialog(
          context, res['body']['message'], 'assets/images/dizzy-robot.png');
    } else if (res['error']) {
      confirmDialog(
          context, res['body']['message'], 'assets/images/dizzy-robot.png');
    } else {
      // // update local DB with company info
      // body['id_cloud'] = res['body']['address_id'];
      // body.remove('id');
      // bool dbUpdated = await CustomerAddressesProvider.writeAddressOnDB(body);

      // // if fails we force DB sync
      // if (!dbUpdated) {
        customerBloc.clearAdressCreationData();
        // goHome(context);
        Navigator.pop(context, true);
        // DBSyncElements(
        //   options: {'Terceros': true, 'Sucursales': true},
        // ).launch(context);
        await dataBloc.syncElements(['Sucursales'], context);
        confirmDialog(
            context, res['body']['message'], 'assets/images/success.png');
      // } else {
      //   customerBloc.clearAdressCreationData();
      //   Navigator.pop(context, true);
      //   // dataBloc.homeKey?.currentState?.selectTab(TabItem.clients);
      //   confirmDialog(
      //       context, res['body']['message'], 'assets/images/success.png');
      // }

      // Navigator.pop(context);
    }
  }
}
