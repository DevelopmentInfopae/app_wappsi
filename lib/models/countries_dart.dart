import 'dart:convert';

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

  @override
  String toString() => nombre ?? '';
}
