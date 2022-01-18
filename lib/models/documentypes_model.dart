import 'dart:convert';

import 'package:pos_wappsi/providers/local_db_provider.dart';

DocumentypeModel documentypeModelFromJson(String str) =>
    DocumentypeModel.fromJson(json.decode(str));

String documentypeModelToJson(DocumentypeModel data) =>
    json.encode(data.toJson());

class DocumentypeModel {
  DocumentypeModel({
    required this.idCloud,
    required this.id,
    required this.nombre,
    required this.abreviacion,
    required this.codigoDoc,
  });

  int id;
  int idCloud;
  String nombre;
  String abreviacion;
  int codigoDoc;

  factory DocumentypeModel.fromJson(Map<String, dynamic> json) =>
      DocumentypeModel(
        id: json["id"],
        idCloud: json["id_cloud"],
        nombre: json["nombre"] == null ? null : json["nombre"],
        abreviacion: json["abreviacion"] == null ? null : json["abreviacion"],
        codigoDoc: json["codigo_doc"],
      );

  Map<String, dynamic> toJson() => {
        "id_cloud": idCloud,
        "nombre": nombre,
        "abreviacion": abreviacion,
        "codigo_doc": codigoDoc,
      };

  static List<DocumentypeModel> fromJsonList(List<Map> list) {
    List<DocumentypeModel> documentypes = [];
    Map<String, dynamic> temp = {};
    list.forEach((item) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      documentypes.add(DocumentypeModel.fromJson(temp));
    });

    return documentypes;

    // prString(temp);
  }

  static Future<DocumentypeModel?> defaultDocument() async {
    final res = await DBProvider.db.defaultDocument();
    return DocumentypeModel.fromJson(res!);
  }

  static Future<DocumentypeModel?> loadDocument(String id) async {
    final res = await DBProvider.db.loadDocument(id);
    return DocumentypeModel.fromJson(res!);
  }

  static Future<List<DocumentypeModel>> loadFromDB({String? search}) async {
    List<Map<String, dynamic>>? data = [];
    if (search == null) {
      data = await DBProvider.db.getAllDocumentypes();
    } else {
      data = await DBProvider.db.findDocument(search);
    }
    List<DocumentypeModel> list = [];
    if (data != null) {
      Map<String, dynamic> temp = {};
      data.forEach((item) {
        for (var i = 0; i < item.keys.length; i++) {
          temp[item.keys.toList()[i]] = item.values.toList()[i];
        }
        list.add(DocumentypeModel.fromJson(temp));
      });
    }

    return list;
  }

  @override
  String toString() => nombre;
}
