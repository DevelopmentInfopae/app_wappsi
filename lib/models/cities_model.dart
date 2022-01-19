// To parse this JSON data, do
//
//     final citiesModel = citiesModelFromJson(jsonString);

import 'dart:convert';

CitiesModel citiesModelFromJson(String str) =>
    CitiesModel.fromJson(json.decode(str));

String citiesModelToJson(CitiesModel data) => json.encode(data.toJson());

class CitiesModel {
  CitiesModel({
    required this.pais,
    required this.coddepartamento,
    required this.departamento,
    required this.codigo,
    required this.descripcion,
  });

  String? pais;
  String? coddepartamento;
  String? departamento;
  String? codigo;
  String? descripcion;

  factory CitiesModel.fromJson(Map<String, dynamic> json) => CitiesModel(
        pais: json["PAIS"] == null ? null : json["PAIS"],
        coddepartamento:
            json["CODDEPARTAMENTO"] == null ? null : json["CODDEPARTAMENTO"],
        departamento:
            json["DEPARTAMENTO"] == null ? null : json["DEPARTAMENTO"],
        codigo: json["CODIGO"] == null ? null : json["CODIGO"],
        descripcion: json["DESCRIPCION"] == null ? null : json["DESCRIPCION"],
      );

  Map<String, dynamic> toJson() => {
        "PAIS": pais == null ? null : pais,
        "CODDEPARTAMENTO": coddepartamento == null ? null : coddepartamento,
        "DEPARTAMENTO": departamento == null ? null : departamento,
        "CODIGO": codigo == null ? null : codigo,
        "DESCRIPCION": descripcion == null ? null : descripcion,
      };

  @override
  String toString() => descripcion ?? '';
}
