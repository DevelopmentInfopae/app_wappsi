// To parse this JSON data, do
//
//     final groups = groupsFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/models/price_groups_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';

Groups groupsFromJson(String str) => Groups.fromJson(json.decode(str));

String groupsToJson(Groups data) => json.encode(data.toJson());

class Groups {
  Groups({
    required this.id,
    required this.idCloud,
    required this.name,
    required this.description,
    this.relationedCompanies,
    this.groupNameRelationed,
    this.lastUpdate,
  });

  String id;
  String idCloud;
  String name;
  String description;
  String? relationedCompanies;
  String? groupNameRelationed;
  String? lastUpdate;

  factory Groups.fromJson(Map<String, dynamic> json) => Groups(
        id: json["id"].toString(),
        idCloud: json["id_cloud"].toString(),
        name: json["name"] ?? '',
        description: json["description"] ?? '',
        relationedCompanies: json["relationed_companies"].toString(),
        groupNameRelationed: json["group_name_relationed"],
        lastUpdate: json["last_update"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_cloud": idCloud,
        "name": name,
        "description": description,
        "relationed_companies": relationedCompanies,
        "group_name_relationed": groupNameRelationed,
        "last_update": lastUpdate,
      };

  /// Load group given a country id
  static Future<Groups?> loadGroup(String id) async {
    final res = await PriceGroupsModel.loadPriceGroupFromDB(id);
    if (res == null) {
      return null;
    } else {
      return Groups.fromJson(res);
    }
  }

  /// Load group given a group id
  static Future<Groups?> loadCustomerGroup({String name = 'customer'}) async {
    final res = await findGroupByName(name);
    if (res == null) {
      return null;
    } else {
      return Groups.fromJson(res);
    }
  }

  static Future<List<Groups>> loadFromDB({String? search}) async {
    List<Map<String, dynamic>>? data = [];
    if (search == null || search == '') {
      data = await allGroups();
    } else {
      data = await findGroups(search);
    }
    List<Groups> list = [];
    if (data != null) {
      Map<String, dynamic> temp = {};
      data.forEach((item) {
        for (var i = 0; i < item.keys.length; i++) {
          temp[item.keys.toList()[i]] = item.values.toList()[i];
        }
        list.add(Groups.fromJson(temp));
      });
    }

    return list;
  }


  /// Return all rows in sma_groups
  static Future<List<Map<String, dynamic>>?> allGroups() async {
    return await DBProvider.db.sqlQuery('sma_groups');
  }

  /// Return a list with price_groups data wich fields name or percent LIKE
  /// param searchs
  static Future<Map<String, dynamic>?> findGroupByName(String searchs) async {
    return await DBProvider.db.sqlFirstQuery('sma_groups', where: "name LIKE '%$searchs%'");
  }

  /// Return a list with groups data wich fields name or percent LIKE
  /// param searchs
  static Future<List<Map<String, dynamic>>?> findGroups(String searchs) async {
    return await DBProvider.db.sqlQuery('sma_groups',
        where: "name LIKE '%$searchs%'", limit: 20);
  }

  @override
  String toString() => name;
}
