// To parse this JSON data, do
//
//     final preferenceCategoryModel = preferenceCategoryModelFromJson(jsonString);

import 'dart:convert';

class PreferenceCategoryModel {
  PreferenceCategoryModel({
    this.id,
    this.name,
  });

  String? id;
  String? name;

  factory PreferenceCategoryModel.fromRawJson(String str) =>
      PreferenceCategoryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PreferenceCategoryModel.fromJson(Map<String, dynamic> json) =>
      PreferenceCategoryModel(
        id: (json["id"] ?? '').toString(),
        name: (json["name"] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {"id": id, "name": name};

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
