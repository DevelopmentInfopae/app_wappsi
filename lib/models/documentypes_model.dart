import 'dart:convert';

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
        nombre: json["nombre"],
        abreviacion: json["abreviacion"],
        codigoDoc: json["codigo_doc"],
      );

  Map<String, dynamic> toJson() => {
        "id_cloud": idCloud,
        "nombre": nombre,
        "abreviacion": abreviacion,
        "codigo_doc": codigoDoc,
      };

  @override
  String toString() => nombre;
}
