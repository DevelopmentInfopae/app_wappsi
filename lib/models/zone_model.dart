// To parse this JSON data, do
//
//     final zoneModel = zoneModelFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/utils/text_formating/functions.dart';

class ZoneModel {
  ZoneModel({
    required this.codigoCiudad,
    required this.zoneName,
    required this.zoneCode,
  });

  final String codigoCiudad;
  final String zoneName;
  final String zoneCode;

  factory ZoneModel.fromRawJson(String str) =>
      ZoneModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ZoneModel.fromJson(Map json) => ZoneModel(
        codigoCiudad: json["codigo_ciudad"],
        zoneName: json["zone_name"],
        zoneCode: json["zone_code"],
      );

  Map<String, dynamic> toJson() => {
        "codigo_ciudad": codigoCiudad,
        "zone_name": zoneName,
        "zone_code": zoneCode,
      };
  static List<ZoneModel> fromJsonList(List data) {
    List<ZoneModel> list = [];
    Map<String, dynamic> temp = {};
    for (var item in data) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      list.add(ZoneModel.fromJson(temp));
    }

    return list;

    // prString(temp);
  }

  @override
  String toString() {
    return capitalizeText(zoneName);
  }
}
