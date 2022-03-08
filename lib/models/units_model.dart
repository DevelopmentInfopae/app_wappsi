// To parse this JSON data, do
//
//     final unitsModel = unitsModelFromJson(jsonString);

import 'dart:convert';

UnitsModel unitsModelFromJson(String str) =>
    UnitsModel.fromJson(json.decode(str));

String unitsModelToJson(UnitsModel data) => json.encode(data.toJson());

class UnitsModel {
  UnitsModel({
    required this.id,
    required this.idCloud,
    required this.code,
    required this.name,
    this.baseUnit,
    this.operator,
    required this.unitValue,
    this.operationValue = 1,
    this.priceGroupId,
    required this.lastUpdate,
  });

  int id;
  int idCloud;
  String code;
  String name;
  int? baseUnit;
  String? operator;
  double unitValue;
  double operationValue;
  int? priceGroupId;
  String lastUpdate;

  factory UnitsModel.fromJson(Map<String, dynamic> json) => UnitsModel(
        id: json["id"],
        idCloud: json["id_cloud"],
        code: json["code"],
        name: json["name"],
        baseUnit: int.tryParse(json["base_unit"].toString()),
        operator: json["operator"]??'',
        unitValue: double.tryParse(
            (json['valor_unitario'] ?? json["unit_value"]??'').toString()) ?? 1.0,
        operationValue:double.tryParse((json["operation_value"]??'').toString())??1.0,
           
        priceGroupId:
            json["price_group_id"] == '' ? null : json["price_group_id"],
        lastUpdate: json["last_update"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_cloud": idCloud,
        "code": code,
        "base_unit": baseUnit,
        "operator": operator,
        "unit_value": unitValue,
        "operation_value": operationValue,
        "price_group_id": priceGroupId,
        "last_update": lastUpdate,
      };
  factory UnitsModel.fromRawJson(String str) =>
      UnitsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  static List<UnitsModel> fromJsonList(List<Map> list) {
    List<UnitsModel> units = [];
    Map<String, dynamic> temp = {};
    for (var item in list) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      units.add(UnitsModel.fromJson(temp));
    }

    return units;

    // prString(temp);
  }
}
