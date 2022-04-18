// To parse this JSON data, do
//
//     final preferenceCategoryModel = preferenceCategoryModelFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/utils/parsing/to_double.dart';

class PreferenceCategoryModel {
  PreferenceCategoryModel(
      {this.id, this.name, this.selectionLimit, this.required});

  int? id;
  int? selectionLimit;
  int? required;
  String? name;

  factory PreferenceCategoryModel.fromRawJson(String str) =>
      PreferenceCategoryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PreferenceCategoryModel.fromJson(Map<String, dynamic> json) =>
      PreferenceCategoryModel(
        id: parsingToInt(json["id"]),
        name: (json["name"] ?? '').toString(),
        selectionLimit: parsingToInt(json["selection_limit"]),
        required: parsingToInt(json["required"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "selection_limit": selectionLimit,
        "required": required
      };

  static List<PreferenceCategoryModel> fromJsonList(List<Map> list) {
    List<PreferenceCategoryModel> prefsCat = [];
    Map<String, dynamic> temp = {};
    for (var item in list) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      prefsCat.add(PreferenceCategoryModel.fromJson(temp));
    }

    return prefsCat;

    // prString(temp);
  }
}
