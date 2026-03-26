import 'dart:convert';

import 'package:flutter/services.dart';
// import 'package:pos_wappsi/environment/environment.dart';
import 'package:pos_wappsi/models/countries_dart.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

class CountriesProvider {
  static List<CountriesModel> fromJsonFileList(
    List<Map<String, dynamic>> list,
  ) {
    List<CountriesModel> _list = [];
    for (var element in list) {
      _list.add(CountriesModel.fromJson(element));
    }
    return _list;
  }

  static Future<List<CountriesModel>> loadFromJsonFile() async {
    final String response =
        await rootBundle.loadString('assets/json-files/countries.json');
    final List temp = await json.decode(response);
    List<Map<String, dynamic>> data = [];
    try {
      data = temp.map((e) => CountriesModel.fromJson(e).toJson()).toList();
    } catch (e) {
      printConsole(e);
    }

    return fromJsonFileList(data);
  }

  static Future<List<CountriesModel>> loadFromDB({String? search}) async {
    List<Map<String, dynamic>>? data = [];
    if (search == null || search == '') {
      data = await allCountries();
    } else {
      data = await DBProvider.db.sqlQuery(
        'sma_countries',
        where:
            "NOMBRE LIKE '%$search%' OR INDICATIVO LIKE '%$search%' OR codigo_iso LIKE '%$search%'",
        limit: 20,
      );
    }
    List<CountriesModel> list = [];
    if (data != null) {
      print('***************************** countries ***');
      print(data);
      print('***************************** countries ***');
      Map<String, dynamic> temp = {};
      for (var item in data) {
        for (var i = 0; i < item.keys.length; i++) {
          temp[item.keys.toList()[i]] = item.values.toList()[i];
        }
        list.add(CountriesModel.fromJson(temp));
      }
    }

    return list;
  }

  /// Load default country
  static Future<CountriesModel?> defaultCountry() async {
    final res = await DBProvider.db.sqlFirstRawQuery('''
        SELECT c.NOMBRE,c.CODIGO,c.INDICATIVO,c.MONEDA,c.codigo_iso FROM sma_countries c INNER JOIN sma_settings s
        ON c.NOMBRE = s.pais
        ''');
    if (res == null) {
      return null;
    } else {
      return CountriesModel.fromJson(res);
    }
  }

  /// Load country given a country name
  static Future<CountriesModel?> loadCountry(String name) async {
    final res = await DBProvider.db
        .sqlFirstQuery('sma_countries', where: "NOMBRE = '$name'");
    if (res == null) {
      return null;
    } else {
      return CountriesModel.fromJson(res);
    }
  }

  static Future<bool> writeToDBfromJsonFile() async {
    final String response =
        await rootBundle.loadString('assets/json-files/countries.json');
    final List temp = await json.decode(response);
    List<Map<String, dynamic>> data = [];
    try {
      data = temp.map((e) => CountriesModel.fromJson(e).toJson()).toList();
    } catch (e) {
      await logError(e, from: 'Writing countries from JSON file to DB');

      // printConsole(e);
    }

    return await DBProvider.db.insertOrUpdateQuery('sma_countries', data);
  }

  /// Return all rows in sma_countries
  static Future<List<Map<String, dynamic>>?> allCountries() async {
    return await DBProvider.db.sqlQuery('sma_countries', limit: 20);
  }
}
