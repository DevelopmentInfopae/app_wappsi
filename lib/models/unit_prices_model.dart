// To parse this JSON data, do
//
//     final unitPricesModel = unitPricesModelFromJson(jsonString);

import 'dart:convert';

UnitPricesModel unitPricesModelFromJson(String str) =>
    UnitPricesModel.fromJson(json.decode(str));

String unitPricesModelToJson(UnitPricesModel data) =>
    json.encode(data.toJson());

class UnitPricesModel {
  UnitPricesModel({
    required this.id,
    required this.idCloud,
    required this.code,
    required this.valorUnitario,
    required this.label,
    required this.unidad,
    required this.cantidad,
    required this.unitId,
    this.idProduct,
    this.priceGroupId,
    this.unitPriceId,
    required this.lastUpdate,
  });

  int id;
  int idCloud;
  String code;
  double valorUnitario;
  String label;
  String unidad;
  double cantidad;
  int unitId;
  int? idProduct;
  int? priceGroupId;
  int? unitPriceId;
  String lastUpdate;

  factory UnitPricesModel.fromJson(Map<String, dynamic> json) =>
      UnitPricesModel(
          id: json["id"],
          idCloud: json["id_cloud"],
          code: json["code"],
          valorUnitario: json["valor_unitario"].toDouble(),
          label: json["label"],
          unidad: json["unidad"],
          cantidad: json["cantidad"].toDouble(),
          unitId: json["unit_id"],
          idProduct: json["id_product"],
          priceGroupId: json["price_group_id"],
          lastUpdate: json["last_update"],
          unitPriceId: json["unit_price_id"] ?? 0);

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_cloud": idCloud,
        "code": code,
        "valor_unitario": valorUnitario,
        "label": label,
        "unidad": unidad,
        "cantidad": cantidad,
        "unit_id": unitId,
        "id_product": idProduct,
        "price_group_id": priceGroupId,
        "unit_price_id": unitPriceId,
        "last_update": lastUpdate,
      };
  factory UnitPricesModel.fromRawJson(String str) =>
      UnitPricesModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  static List<UnitPricesModel> fromJsonList(List<Map> list) {
    List<UnitPricesModel> unitPrices = [];
    Map<String, dynamic> temp = {};
    list.forEach((item) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      unitPrices.add(UnitPricesModel.fromJson(temp));
    });

    return unitPrices;

    // prString(temp);
  }
}
