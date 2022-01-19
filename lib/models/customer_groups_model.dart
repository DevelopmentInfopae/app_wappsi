import 'dart:convert';

CustomerGroupsModel customerGroupsModelFromJson(String str) =>
    CustomerGroupsModel.fromJson(json.decode(str));

String customerGroupsModelToJson(CustomerGroupsModel data) =>
    json.encode(data.toJson());

class CustomerGroupsModel {
  CustomerGroupsModel({
    required this.id,
    required this.idCloud,
    required this.name,
    required this.percent,
    required this.lastUpdate,
  });

  String id;
  String idCloud;
  String name;
  String percent;
  String lastUpdate;

  factory CustomerGroupsModel.fromJson(Map<String, dynamic> json) =>
      CustomerGroupsModel(
        id: json["id"].toString(),
        idCloud: json["id_cloud"].toString(),
        name: json["name"].toString(),
        percent: json["percent"].toString(),
        lastUpdate: json["last_update"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id_cloud": idCloud,
        "name": name,
        "percent": percent,
        "last_update": lastUpdate,
      };

  @override
  String toString() => name;
}
