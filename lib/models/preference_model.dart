// To parse this JSON data, do
//
//     final PreferenceModel = PreferenceModelFromJson(jsonString);

import 'dart:convert';

class PreferenceModel {
  PreferenceModel({
    this.idCloud,
    this.productId,
    this.name,
    this.preferenceId,
    this.preferenceCategoryId,
  });

  String? idCloud;
  String? productId;
  String? name;
  String? preferenceId;
  String? preferenceCategoryId;

  factory PreferenceModel.fromRawJson(String str) =>
      PreferenceModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PreferenceModel.fromJson(Map<String, dynamic> json) =>
      PreferenceModel(
        idCloud: (json["id_cloud"] ?? '').toString(),
        productId: (json["product_id"] ?? '').toString(),
        name: (json["name"] ?? '').toString(),
        preferenceId: (json["preference_id"] ?? '').toString(),
        preferenceCategoryId: (json["preference_category_id"] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        "id_cloud": idCloud,
        "product_id": productId,
        "name": name,
        "preference_id": preferenceId,
        "preference_category_id": preferenceCategoryId,
      };

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
