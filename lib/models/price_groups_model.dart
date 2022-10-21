import 'dart:convert';

PriceGroupsModel priceGroupsModelFromJson(String str) =>
    PriceGroupsModel.fromJson(json.decode(str));

String priceGroupsModelToJson(PriceGroupsModel data) =>
    json.encode(data.toJson());

class PriceGroupsModel {
  PriceGroupsModel({
    required this.id,
    required this.idCloud,
    required this.name,
    required this.priceGroupBase,
    required this.lastUpdate,
  });

  String id;
  String idCloud;
  String name;
  String priceGroupBase;
  String lastUpdate;

  factory PriceGroupsModel.fromJson(Map<String, dynamic> json) =>
      PriceGroupsModel(
        id: json['id'].toString(),
        idCloud: json['id_cloud'].toString(),
        name: json['name'].toString(),
        priceGroupBase: json['price_group_base'].toString(),
        lastUpdate: json['last_update'].toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_cloud': idCloud,
        'name': name,
        'price_group_base': priceGroupBase,
        'last_update': lastUpdate,
      };

  @override
  String toString() => name;
}
