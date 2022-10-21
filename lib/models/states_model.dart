// To parse this JSON data, do
//
//     final statesModel = statesModelFromJson(jsonString);

import 'dart:convert';

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
        pais: json['PAIS'],
        coddepartamento: json['CODDEPARTAMENTO'],
        departamento: json['DEPARTAMENTO'],
        desadicional: json['DESADICIONAL'],
      );

  Map<String, dynamic> toJson() => {
        'PAIS': pais,
        'CODDEPARTAMENTO': coddepartamento,
        'DEPARTAMENTO': departamento,
        'DESADICIONAL': desadicional,
      };

  @override
  String toString() => departamento ?? '';
}
