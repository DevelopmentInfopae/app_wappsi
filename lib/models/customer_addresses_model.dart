// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/utils/text_formating/functions.dart';

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

  @override
  String toString() => capitalizeText(sucursal);
}
