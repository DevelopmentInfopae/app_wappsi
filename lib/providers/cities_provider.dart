import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pos_wappsi/models/cities_model.dart';

import 'local_db_provider.dart';

class CitiesProvider {
  static List<CitiesModel> fromJsonFileList(List<Map<String, dynamic>> list) {
    List<CitiesModel> _list = [];
    list.forEach((element) {
      _list.add(CitiesModel.fromJson(element));
    });
    return _list;
  }

  static Future<List<CitiesModel>> loadFromJson() async {
    final String response =
        await rootBundle.loadString('assets/json-files/cities.json');
    List<Map<String, dynamic>> data = [];
    try {
      final List temp = await json.decode(response);
      data = temp.map((e) => CitiesModel.fromJson(e).toJson()).toList();
    } catch (e) {
      print(e);
    }

    return fromJsonFileList(data);
  }

  static writeToDBfromJson() async {
    final String response =
        await rootBundle.loadString('assets/json-files/cities.json');
    List<Map<String, dynamic>> data = [];
    try {
      final List temp = await json.decode(response);
      // data = queryResultToMapList(temp);
      data = temp.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print(e);
    }

    return await DBProvider.db.insertOrUpdateQuerys('sma_cities', data);
  }

  static Future<List<CitiesModel>> loadFromDB(
      {String? search, String? departament}) async {
    List<Map<String, dynamic>>? data = [];
    if (departament != null) {
      data = await findCity(departament, searchs: search);
    } else {
      return [];
    }
    List<CitiesModel> list = [];
    if (data != null) {
      Map<String, dynamic> temp = {};
      data.forEach((item) {
        for (var i = 0; i < item.keys.length; i++) {
          temp[item.keys.toList()[i]] = item.values.toList()[i];
        }
        list.add(CitiesModel.fromJson(temp));
      });
    }

    return list;
  }

  /// Load default city
  static Future<CitiesModel?> defaultCity() async {
    final res = await DBProvider.db.sqlFirstRawQuery('''
        SELECT * FROM sma_cities c INNER JOIN sma_settings s
        ON c.DESCRIPCION = s.ciudad
        ''');
    if (res == null) {
      return null;
    } else {
      return CitiesModel.fromJson(res);
    }
  }

  /// Load city of a given city description
  static Future<CitiesModel?> loadCity(String description) async {
    final res = await DBProvider.db
        .sqlFirstQuery('sma_cities', where: "DESCRIPCION = '$description'");
    if (res == null) {
      return null;
    } else {
      return CitiesModel.fromJson(res);
    }
  }

  /// Return all rows in sma_cities
  static Future<List<Map<String, dynamic>>?> allCities() async {
    return await DBProvider.db.sqlQuery('sma_cities', limit: 20);
  }

  static Future<List<Map<String, dynamic>>?> findCity(String departament,
      {String? searchs = ''}) async {
    return await DBProvider.db.sqlQuery('sma_cities',
        where: "CODDEPARTAMENTO=$departament AND DESCRIPCION LIKE '%$searchs%'",
        limit: 20);
  }
}
