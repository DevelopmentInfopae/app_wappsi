// To parse this JSON data, do
//
//     final PreferenceModel = PreferenceModelFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/utils/parsing/to_double.dart';

class PreferenceModel {
  PreferenceModel({required this.id, this.categoryId, this.name});

  int id;
  String? categoryId;
  String? name;

  factory PreferenceModel.fromRawJson(String str) =>
      PreferenceModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PreferenceModel.fromJson(Map<String, dynamic> json) =>
      PreferenceModel(
        id: parsingToInt(json['id'] ?? ''),
        categoryId: (json['category_id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'category_id': categoryId, 'name': name};

  static List<PreferenceModel> fromJsonList(List<Map> list) {
    List<PreferenceModel> prefs = [];
    Map<String, dynamic> temp = {};
    for (var item in list) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      prefs.add(PreferenceModel.fromJson(temp));
    }

    return prefs;

    // prString(temp);
  }
}
