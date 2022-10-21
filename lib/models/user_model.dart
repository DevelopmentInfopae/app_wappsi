// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/environment/environment.dart';

UserModel userModelFromJson(Map<String, dynamic> str) =>
    UserModel.fromJson(str);

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  UserModel({
    required this.id,
    required this.token,
    this.gender,
    this.allowDiscount = 0,
    required this.hostUrl,
    required this.lastName,
    required this.viewRight,
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
    required this.companyFolder,
  });
  String id;
  String token;
  String firstName;
  String lastName;
  int allowDiscount;
  String userName;
  String email;
  String? gender;
  int viewRight;

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
        id: json['id'],
        allowDiscount: int.parse(json['allow_discount'] ?? '0'),
        token: json['token'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        gender: json['gender'] ?? '',
        email: json['email'],
        userName: json['username'],
        hostUrl: json['host_url'] == 'default_host'
            ? Environment().config.apiHost
            : json['host_url'] ?? Environment().config.apiHost,
        warehouseId: int.parse(json['warehouse_id']),
        viewRight: int.parse(json['view_right'] ?? '0'),
        sellerId: int.parse(json['seller_id']),
        companyName: json['company_name'],
        warehouseName: json['warehouse_name'],
        sellerName: json['seller_name'],
        billerId: int.parse(json['biller_id']),
        billerName: json['biller_name'],
        companyFolder: json['company_folder'] ?? Environment().config.cFolder,
        documentTypeId: int.tryParse(json['document_type_id'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'id': id,
        'gender': gender,
        'host_url': hostUrl,
        'allow_discount': allowDiscount,
        'last_name': lastName,
        'biller_id': billerId,
        'seller_id': sellerId,
        'view_right': viewRight,
        'first_name': firstName,
        'company_folder': companyFolder,
        'seller_name': sellerName,
        'biller_name': billerName,
        'username': userName,
        'email': email,
        'warehouse_id': warehouseId,
        'company_name': companyName,
        'warehouse_name': warehouseName,
        'document_type_id': documentTypeId
      };
}
