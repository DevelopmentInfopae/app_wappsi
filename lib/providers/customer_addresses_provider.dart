import 'package:pos_wappsi/bloc/orders_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
// import 'package:pos_wappsi/environment/environment.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
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
  static selectDefaultAddrs({bool returnBool = false, bool fromOrderCreation=false}) async {
    if (posBloc.getCustomer != null && posBloc.getCustomerAddresses == null) {
      final data = await findCustomerAddresses(
          '', posBloc.getCustomer!.idCloud!.toString());
      if (data != []) {
        final defaultAddrss = data.first;
        if(fromOrderCreation){
          orderBloc.setCustomerAddresses(
            CustomerAddressesModel.fromJson(defaultAddrss));
        }else{
          posBloc.setCustomerAddresses(
            CustomerAddressesModel.fromJson(defaultAddrss));
        }
        
        if (returnBool) {
          return true;
        }
      }
    }
  }

  /// Load default customer address
  static selectDefaultAddrsToOrder({bool returnBool = false}) async {
    if (orderBloc.getCustomer != null && orderBloc.getCustomerAddresses == null) {
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

  /// Load address given an address id

  static Future<CustomerAddressesModel?> loadCustomerAddress(String id) async {
    final data = await loadCustomerAddressFromDB(id);
    if (data != null) {
      return CustomerAddressesModel.fromJson(data);
    } else {
      return null;
    }
  }

  /// To load POS sale customer addresses
  static Future<List<CustomerAddressesModel>> getDataAdrreses(filter) async {
    List<Map> data;

    String customerID = posBloc.getCustomerId();

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
  static Future<List<CustomerAddressesModel>> getDataAdrresesToOrder(filter) async {
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
}
