// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/utils/functions.dart';

CustomerAddressesModel customerAddressesModelFromJson(
        Map<String, dynamic> str) =>
    CustomerAddressesModel.fromJson(str);

String customerAddressesModelToJson(CustomerAddressesModel data) =>
    json.encode(data.toJson());

class CustomerAddressesModel {
  CustomerAddressesModel({
    required this.id,
    required this.idCloud,
    required this.companyId,
    required this.sucursal,
    required this.direccion,
    required this.country,
    required this.state,
    required this.city,
    required this.priceGroupId,
    required this.customerGroupId,
    required this.vatNo,
    required this.code,
  });
  String id;
  int idCloud;
  String sucursal;
  String companyId;
  String? country;
  String? state;
  String? direccion;
  String? city;
  String? vatNo;

  String? code;
  String customerGroupId;
  String priceGroupId;

  static List<String> get _addressesColumns =>[
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

  factory CustomerAddressesModel.fromJson(Map<dynamic, dynamic> json) =>
      CustomerAddressesModel(
        id: json["id"].toString(),
        idCloud: json["id_cloud"],
        sucursal: json["sucursal"] ?? '',
        companyId: json["companyId"] ?? '',
        country: json["tipo_documento"].toString(),
        state: json['vat_no'].toString(),
        direccion: json["direccion"] ?? '',
        city: json["city"] ?? '',
        vatNo: json["invoice_footer"] ?? '',
        code: json["group_id"].toString(),
        customerGroupId: json["customer_group_id"].toString(),
        priceGroupId: json["price_group_id"].toString(),
      );

  static List<CustomerAddressesModel> fromJsonList(List<Map> list) {
    List<CustomerAddressesModel> products = [];
    Map temp = {};
    list.forEach((item) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      products.add(CustomerAddressesModel.fromJson(temp));
    });

    return products;

    // prString(temp);
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_cloud": idCloud,
        "sucursal": sucursal,
        "company_id": companyId,
        "country": country,
        "state": state,
        "direccion": direccion,
        "city": city,
        "vat_no": vatNo,
        "code": code,
        "customer_group_id": customerGroupId,
        "price_group_id": priceGroupId,
      };

  /// Load default customer address
  static selectDefaultAddrs({bool returnBool = false}) async {
    if (posBloc.getCustomer != null && posBloc.getCustomerAddresses == null) {
      final data = await findCustomerAddresses('', posBloc.getCustomer!.idCloud!.toString());
      if (data != []) {
        final defaultAddrss = data.first;

        posBloc.setCustomerAddresses(
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
      return res??[];
    } catch (e) {
      print(e);
      return [];
    }
  }

  /// Returns customer address info given an address id
  static Future<Map<String, dynamic>?> loadCustomerAddressFromDB(String addressId) async {
    return await DBProvider.db.sqlFirstQuery('sma_addresses', where: "id_cloud = $addressId");
  }

  @override
  String toString() => capitalizeText(sucursal);
}
