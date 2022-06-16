// To parse this JSON data, do
//
//     final subzoneModel = subzoneModelFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/utils/text_formating/functions.dart';

class SubzoneModel {
  SubzoneModel({
    required this.zoneCode,
    required this.subzoneName,
    required this.subzoneCode,
  });

  final String zoneCode;
  final String subzoneName;
  final String subzoneCode;

  factory SubzoneModel.fromRawJson(String str) =>
      SubzoneModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SubzoneModel.fromJson(Map json) => SubzoneModel(
        zoneCode: json["zone_code"],
        subzoneName: json["subzone_name"],
        subzoneCode: json["subzone_code"],
      );

  Map<String, dynamic> toJson() => {
        "zone_code": zoneCode,
        "subzone_name": subzoneName,
        "subzone_code": subzoneCode,
      };

  static List<SubzoneModel> fromJsonList(List data) {
    List<SubzoneModel> list = [];
    Map<String, dynamic> temp = {};
    for (var item in data) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      list.add(SubzoneModel.fromJson(temp));
    }

    return list;

    // prString(temp);
  }

  @override
  String toString() {
    return capitalizeText(subzoneName);
  }
}
