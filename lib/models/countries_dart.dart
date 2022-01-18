import 'package:flutter/services.dart';

import 'dart:convert';

import 'package:pos_wappsi/providers/local_db_provider.dart';

CountriesModel countriesModelFromJson(String str) =>
    CountriesModel.fromJson(json.decode(str));

String countriesModelToJson(CountriesModel data) => json.encode(data.toJson());

class CountriesModel {
  CountriesModel({
    required this.codigo,
    required this.nombre,
    required this.indicativo,
    required this.moneda,
    required this.codigoIso,
  });

  String? codigo;
  String? nombre;
  String? indicativo;
  int? moneda;
  String? codigoIso;

  factory CountriesModel.fromJson(Map<String, dynamic> json) => CountriesModel(
        codigo: json["CODIGO"],
        nombre: json["NOMBRE"],
        indicativo: json["INDICATIVO"],
        moneda: int.parse(json["MONEDA"].toString()),
        codigoIso: json["codigo_iso"],
      );

  Map<String, dynamic> toJson() => {
        "CODIGO": codigo == null ? null : codigo,
        "NOMBRE": nombre == null ? null : nombre,
        "INDICATIVO": indicativo == null ? null : indicativo,
        "MONEDA": moneda == null ? null : moneda,
        "codigo_iso": codigoIso == null ? null : codigoIso,
      };
  static List<CountriesModel> fromJsonFileList(
      List<Map<String, dynamic>> list) {
    List<CountriesModel> _list = [];
    list.forEach((element) {
      _list.add(CountriesModel.fromJson(element));
    });
    return _list;
  }

  static Future<List<CountriesModel>> loadFromJsonFile() async {
    final String response =
        await rootBundle.loadString('assets/json-files/countries.json');
    final List temp = await json.decode(response);
    List<Map<String, dynamic>> data = [];
    try {
      data = temp.map((e) => CountriesModel.fromJson(e).toJson()).toList();
    } catch (e) {}

    return fromJsonFileList(data);
  }

  static Future<List<CountriesModel>> loadFromDB({String? search}) async {
    List<Map<String, dynamic>>? data = [];
    if (search == null || search == '') {
      data = await allCountries();
    } else {
      data = await DBProvider.db.sqlQuery('sma_countries',
          where:
              "NOMBRE LIKE '%$search%' OR INDICATIVO LIKE '%$search%' OR codigo_iso LIKE '%$search%'",
          limit: 20);
    }
    List<CountriesModel> list = [];
    if (data != null) {
      Map<String, dynamic> temp = {};
      data.forEach((item) {
        for (var i = 0; i < item.keys.length; i++) {
          temp[item.keys.toList()[i]] = item.values.toList()[i];
        }
        list.add(CountriesModel.fromJson(temp));
      });
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
      print(e);
    }

    return await DBProvider.db.insertOrUpdateQuerys('sma_countries', data);
  }

  /// Return all rows in sma_countries
  static Future<List<Map<String, dynamic>>?> allCountries() async {
    return await DBProvider.db.sqlQuery('sma_countries', limit: 20);
  }


  @override
  String toString() => nombre ?? '';
}
