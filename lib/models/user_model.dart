// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/config/host_params.dart';

UserModel userModelFromJson(Map<String, dynamic> str) =>
    UserModel.fromJson(str);

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  UserModel(
      {required this.id,
      required this.token,
      required this.gender,
      required this.hostUrl,
      required this.lastName,
      required this.sellerId,
      required this.firstName,
      required this.companyName,
      required this.userName,
      required this.email,
      required this.warehouseId,
      required this.warehouseName,
      required this.billerId,
      required this.billerName,
      required this.sellerName,
      required this.documentTypeId,
      required this.companyFolder});
  String id;
  String token;
  String firstName;
  String lastName;
  String userName;
  String email;
  String gender;

  String companyFolder;
  String hostUrl;
  int warehouseId;
  int sellerId;
  String companyName;
  String warehouseName;
  int billerId;
  String sellerName;
  String billerName;
  int? documentTypeId;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
      id: json["id"],
      token: json["token"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      gender: json["gender"],
      email: json["email"],
      userName: json["username"],
      hostUrl:
          json['host_url'] == 'default_host' ? HOST : json['host_url'] ?? HOST,
      warehouseId: int.parse(json["warehouse_id"]),
      sellerId: int.parse(json["seller_id"]),
      companyName: json["company_name"],
      warehouseName: json["warehouse_name"],
      sellerName: json['seller_name'],
      billerId: int.parse(json['biller_id']),
      billerName: json['biller_name'],
      companyFolder: json['companyFolder'] ?? '/forbabys_prueba/',
      documentTypeId:
          int.tryParse(json['document_type_id'].toString()) ?? null);

  Map<String, dynamic> toJson() => {
        "token": token,
        "id": id,
        "gender": gender,
        "host_url": hostUrl,
        "last_name": lastName,
        "biller_id": billerId,
        "seller_id": sellerId,
        "first_name": firstName,
        "company_folder": companyFolder,
        "seller_name": sellerName,
        "biller_name": billerName,
        "username": userName,
        "email": email,
        "warehouse_id": warehouseId,
        "company_name": companyName,
        "warehouse_name": warehouseName,
        "document_type_id": documentTypeId
      };
}
