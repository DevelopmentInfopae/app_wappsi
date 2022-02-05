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
        pais: json["PAIS"],
        coddepartamento:
            json["CODDEPARTAMENTO"],
        departamento:
            json["DEPARTAMENTO"],
        codigo: json["CODIGO"],
        descripcion: json["DESCRIPCION"],
      );

  Map<String, dynamic> toJson() => {
        "PAIS": pais,
        "CODDEPARTAMENTO": coddepartamento,
        "DEPARTAMENTO": departamento,
        "CODIGO": codigo,
        "DESCRIPCION": descripcion,
      };

  @override
  String toString() => descripcion ?? '';
}
