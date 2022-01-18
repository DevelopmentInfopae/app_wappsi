// To parse this JSON data, do
//
//     final statesModel = statesModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';

StatesModel statesModelFromJson(String str) =>
    StatesModel.fromJson(json.decode(str));

String statesModelToJson(StatesModel data) => json.encode(data.toJson());

class StatesModel {
  StatesModel({
    required this.pais,
    required this.coddepartamento,
    required this.departamento,
    required this.desadicional,
  });

  String? pais;
  String? coddepartamento;
  String? departamento;
  String? desadicional;

  factory StatesModel.fromJson(Map<String, dynamic> json) => StatesModel(
        pais: json["PAIS"],
        coddepartamento: json["CODDEPARTAMENTO"],
        departamento: json["DEPARTAMENTO"],
        desadicional: json["DESADICIONAL"],
      );

  Map<String, dynamic> toJson() => {
        "PAIS": pais == null ? null : pais,
        "CODDEPARTAMENTO": coddepartamento == null ? null : coddepartamento,
        "DEPARTAMENTO": departamento == null ? null : departamento,
        "DESADICIONAL": desadicional == null ? null : desadicional,
      };

  static List<StatesModel> fromJsonFileList(List<Map<String, dynamic>> list) {
    List<StatesModel> _list = [];
    list.forEach((element) {
      _list.add(StatesModel.fromJson(element));
    });
    return _list;
  }

  static Future<List<StatesModel>> loadFromJson() async {
    final String response =
        await rootBundle.loadString('assets/json-files/states.json');
    final List<Map<String, dynamic>> data = await json.decode(response);

    return fromJsonFileList(data);
  }

  static writeToDBfromJson() async {
    final String response =
        await rootBundle.loadString('assets/json-files/states.json');
    List<Map<String, dynamic>> data = [];
    try {
      final List temp = await json.decode(response);
      data = temp.map((e) => StatesModel.fromJson(e).toJson()).toList();
    } catch (e) {
      // print(e);
    }

    return await DBProvider.db.insertOrUpdateQuerys('sma_states', data);
  }

  static Future<List<StatesModel>> loadFromDB(
      {String? search, String? country}) async {
    List<Map<String, dynamic>>? data = [];
    if (country != null) {
      data = await DBProvider.db.sqlQuery('sma_states',
          where:
              "PAIS=$country AND (DEPARTAMENTO LIKE '%$search%' OR DESADICIONAL LIKE '%$search%')",
          limit: 20);
    } else {
      return [];
    }
    List<StatesModel> list = [];
    if (data != null) {
      Map<String, dynamic> temp = {};
      data.forEach((item) {
        for (var i = 0; i < item.keys.length; i++) {
          temp[item.keys.toList()[i]] = item.values.toList()[i];
        }
        list.add(StatesModel.fromJson(temp));
      });
    }

    return list;
  }

  /// Load default state
  static Future<StatesModel?> defaultState() async {
    final res = await DBProvider.db.sqlFirstRawQuery('''
        SELECT * FROM sma_states st INNER JOIN sma_settings s
        ON st.DEPARTAMENTO = s.departamento
        ''');
    if (res == null) {
      return null;
    } else {
      return StatesModel.fromJson(res);
    }
  }

  /// Load state given a state departamento
  static Future<StatesModel?> loadState(String detartamento) async {
    final res = await DBProvider.db
        .sqlFirstQuery('sma_states', where: "DEPARTAMENTO = '$detartamento'");
    if (res == null) {
      return null;
    } else {
      return StatesModel.fromJson(res);
    }
  }

     /// Return all rows in sma_states
  static Future<List<Map<String, dynamic>>?> allStates() async {
    return await DBProvider.db.sqlQuery('sma_states', limit: 20);
  }

  @override
  String toString() => departamento ?? '';
}
