import 'dart:convert';

import 'package:pos_wappsi/providers/local_db_provider.dart';

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
          id: json["id"].toString(),
          idCloud: json["id_cloud"].toString(),
          name: json["name"].toString(),
          priceGroupBase: json["price_group_base"].toString(),
          lastUpdate: json["last_update"].toString());

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_cloud": idCloud,
        "name": name,
        "price_group_base": priceGroupBase,
        "last_update": lastUpdate,
      };

  /// Load price group given a country id
  static Future<PriceGroupsModel?> loadPriceGroup(String id) async {
    final res = await loadPriceGroupFromDB(id);
    if (res == null) {
      return null;
    } else {
      return PriceGroupsModel.fromJson(res);
    }
  }

  static Future<List<PriceGroupsModel>> loadFromDB({String? search}) async {
    List<Map<String, dynamic>>? data = [];
    if (search == null || search == '') {
      data = await allPriceGroups();
    } else {
      data = await findPriceGroup(search);
    }
    List<PriceGroupsModel> list = [];
    if (data != null) {
      Map<String, dynamic> temp = {};
      data.forEach((item) {
        for (var i = 0; i < item.keys.length; i++) {
          temp[item.keys.toList()[i]] = item.values.toList()[i];
        }
        list.add(PriceGroupsModel.fromJson(temp));
      });
    }

    return list;
  }


  /// Return all rows in sma_countries
  static Future<List<Map<String, dynamic>>?> allPriceGroups() async {
    return await DBProvider.db.sqlQuery('sma_price_groups');
  }

  /// Return all rows in sma_states
  static Future<Map<String, dynamic>?> loadPriceGroupFromDB(String id) async {
    return await DBProvider.db.sqlFirstQuery('sma_price_groups', where: 'id_cloud = $id');
  }

  /// Return a list with price_groups data wich fields name or percent LIKE
  /// param searchs
  static Future<List<Map<String, dynamic>>?> findPriceGroup(String searchs) async {
    return await DBProvider.db.sqlQuery('sma_price_groups',
        where: "name LIKE '%$searchs%'", limit: 20);
  }

  @override
  String toString() => name;
}
