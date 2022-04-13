// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/utils/parsing/to_double.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';
// import 'package:pos_wappsi/utils/text_formating/json_parsing.dart';

CustomerAddressesModel customerAddressesModelFromJson(
        Map<String, dynamic> str) =>
    CustomerAddressesModel.fromJson(str);

String customerAddressesModelToJson(CustomerAddressesModel data) =>
    json.encode(data.toJson());

class CustomerAddressesModel {
  CustomerAddressesModel(
      {required this.id,
      required this.idCloud,
      required this.companyId,
      required this.sucursal,
      required this.direccion,
      this.country,
      this.state,
      this.email,
      this.customerAddressSellerIdAssigned,
      this.phone,
      this.line1,
      this.line2,
      this.postalCode,
      this.city,
      required this.priceGroupId,
      required this.customerGroupId,
      required this.vatNo,
      this.latitude,
      this.longitude,
      this.cityCode,
      this.customerGroupName,
      this.priceGroupName,
      this.code});
  String id;
  int idCloud;
  String? sucursal;
  String companyId;
  String? country;
  String? state;
  String? email;
  int? customerAddressSellerIdAssigned;
  String? phone;
  double? latitude;
  double? longitude;
  String? direccion;
  String? city;
  String? vatNo;

  String? code;
  String? line1;
  String? postalCode;
  String? line2;
  String? cityCode;
  String? customerGroupId;
  String? customerGroupName;
  String? priceGroupName;
  String priceGroupId;

  factory CustomerAddressesModel.fromJson(Map<dynamic, dynamic> json) =>
      CustomerAddressesModel(
        id: json["id"].toString(),
        idCloud: json["id_cloud"],
        customerAddressSellerIdAssigned: int.tryParse(
            json["customer_address_seller_id_assigned"]?.toString() ?? ''),
        sucursal: json["sucursal"] ?? '',
        companyId: json["companyId"] ?? '',
        country: json["country"].toString(),
        state: json['state'].toString(),
        email: json['email'].toString(),
        phone: json['phone'].toString(),
        priceGroupName: json['price_group_name'].toString(),
        direccion: json["direccion"] ?? '',
        latitude: parsingToDoubleNullAble(json["latitude"]),
        longitude: parsingToDoubleNullAble(json["longitude"]),
        city: json["city"] ?? '',
        line1: json["line1"] ?? '',
        line2: json["line2"] ?? '',
        postalCode: json["postal_code"] ?? '',
        vatNo: json["vat_no"] ?? '',
        code: json["code"].toString(),
        cityCode: json["city_code"].toString(),
        customerGroupId: json["customer_group_id"].toString(),
        customerGroupName: json["customer_group_name"].toString(),
        priceGroupId: json["price_group_id"].toString(),
      );

  static List<CustomerAddressesModel> fromJsonList(List<Map> list) {
    List<CustomerAddressesModel> products = [];
    Map temp = {};
    for (var item in list) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      products.add(CustomerAddressesModel.fromJson(temp));
    }

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
        "latitude": latitude,
        "longitude": longitude,
        "city": city,
        "vat_no": vatNo,
        "email": email ?? '',
        "phone": phone ?? '',
        "code": code,
        "city_code": cityCode,
        "customer_group_id": customerGroupId,
        "customer_group_name": customerGroupName,
        "price_group_name": priceGroupName,
        "price_group_id": priceGroupId,
        "postal_code": postalCode,
        "line1": line1,
        "line2": line2,
        "customer_address_seller_id_assigned": customerAddressSellerIdAssigned
      };

  @override
  String toString() => capitalizeText(sucursal ?? '');
}
