// To parse this JSON data, do
//
//     final SalePosTicketModel = SalePosTicketModelFromJson(jsonString);
import 'dart:convert';

class SalePosTicketModel {
    SalePosTicketModel({
        required this.saleId,
        required this.message,
        required this.referenceNo,
        required this.resolucion,
        required this.date,
    });

    int saleId;
    String message;
    String referenceNo;
    String resolucion;
    DateTime date;

    factory SalePosTicketModel.fromRawJson(String str) => SalePosTicketModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory SalePosTicketModel.fromJson(Map<String, dynamic> json) => SalePosTicketModel(
        saleId: json["sale_id"],
        message: json["message"],
        referenceNo: json["reference_no"],
        resolucion: json["resolucion"],
        date: DateTime.parse(json["date"]),
    );

    Map<String, dynamic> toJson() => {
        "sale_id": saleId,
        "message": message,
        "reference_no": referenceNo,
        "resolucion": resolucion,
        "date": date.toIso8601String(),
    };

    
}
