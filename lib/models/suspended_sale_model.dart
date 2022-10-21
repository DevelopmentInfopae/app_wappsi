// To parse this JSON data, do
//
//     final SuspendedSales = SuspendedSalesFromJson(jsonString);

import 'dart:convert';

SuspendedSales suspendedSalesFromJson(String str) =>
    SuspendedSales.fromJson(json.decode(str));

String suspendedSalesToJson(SuspendedSales data) => json.encode(data.toJson());

class SuspendedSales {
  SuspendedSales({
    required this.id,
    required this.idCustomer,
    required this.idAddress,
    required this.idPayDocument,
    required this.idPayMethod,
    required this.sellerName,
    required this.payValue,
    required this.invoiceNote,
    required this.dispatchNote,
    required this.customerName,
    required this.createdDate,
    required this.keyWord,
    required this.totalValue,
    required this.items,
  });

  int id;
  int idCustomer;
  int idAddress;
  int? idPayDocument;
  int? idPayMethod;
  int? payValue;
  int items;
  double totalValue;
  String? invoiceNote;
  String? sellerName;
  String? keyWord;
  String customerName;
  String? dispatchNote;
  String createdDate;

  factory SuspendedSales.fromJson(Map<String, dynamic> json) => SuspendedSales(
        id: json['id'],
        idCustomer: json['id_customer'],
        idAddress: json['id_address'],
        sellerName: json['seller_name'],
        idPayDocument:
            json['id_pay_document'] == '' ? null : json['id_pay_document'],
        idPayMethod: json['id_pay_method'] == '' ? null : json['id_pay_method'],
        payValue: json['pay_value'] == '' ? null : json['pay_value'],
        dispatchNote: json['invoice_note'] ?? '',
        invoiceNote: json['dispatch_note'] ?? '',
        customerName: json['customer_name'] ?? '',
        createdDate: json['created_date'] ?? '',
        items: json['items'] ?? 1,
        keyWord: json['key_word'] ?? '',
        totalValue: (json['total_value'] ?? 0.0) + 0.0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_customer': idCustomer,
        'id_address': idAddress,
        'id_pay_document': idPayDocument,
        'id_ay_method': idPayMethod,
        'pay_value': payValue,
        'invoice_note': invoiceNote,
        'dispatch_note': dispatchNote,
        'customer_name': customerName,
        'items': items,
        'total_value': totalValue,
        'key_word': keyWord,
        'created_date': items,
        'seller_name': sellerName
      };
  static List<SuspendedSales> fromJsonList(List<Map> list) {
    List<SuspendedSales> suspSales = [];
    Map<String, dynamic> temp = {};
    for (var item in list) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      suspSales.add(SuspendedSales.fromJson(temp));
    }

    return suspSales;

    // prString(temp);
  }
}
