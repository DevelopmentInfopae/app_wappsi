// To parse this JSON data, do
//
//     final PaymentMethods = PaymentMethodsFromJson(jsonString);

import 'dart:convert';

PaymentMethods paymentMethodsFromJson(String str) =>
    PaymentMethods.fromJson(json.decode(str));

String paymentMethodsToJson(PaymentMethods data) => json.encode(data.toJson());

class PaymentMethods {
  PaymentMethods({
    required this.id,
    required this.idCloud,
    required this.name,
    required this.code,
    this.stateSale,
    this.statePurchase,
    this.codeFe,
    this.cashPayment,
    this.duePayment,
    this.commisionValue,
    this.commisionLedgerId,
    this.retefuenteValue,
    this.retefuenteLedgerId,
    this.reteivaValue,
    this.reteivaLedgerId,
    this.reteicaValue,
    this.reteicaLedgerId,
    this.supplierId,
    this.icon,
    this.billerAccountantParametrization,
    this.billers,
    required this.lastUpdate,
  });

  String id;
  String idCloud;
  String name;
  String code;
  String? stateSale;
  String? statePurchase;
  int? codeFe;
  String? cashPayment;
  String? duePayment;
  String? commisionValue;
  String? commisionLedgerId;
  String? retefuenteValue;
  String? retefuenteLedgerId;
  String? reteivaValue;
  String? reteivaLedgerId;
  String? reteicaValue;
  String? reteicaLedgerId;
  String? supplierId;
  String? icon;
  String? billerAccountantParametrization;
  String? billers;
  String lastUpdate;

  factory PaymentMethods.fromJson(Map<String, dynamic> json) => PaymentMethods(
        id: json["id"]?.toString() ?? '',
        idCloud: json["id_cloud"]?.toString() ?? '',
        name: json["name"]?.toString() ?? '',
        code: json["code"]?.toString() ?? '',
        stateSale: json["state_sale"]?.toString() ?? '',
        statePurchase: json["state_purchase"]?.toString() ?? '',
        codeFe: int.tryParse(json["code_fe"] ?? "0"),
        cashPayment: json["cash_payment"]?.toString() ?? '',
        duePayment: json["due_payment"]?.toString() ?? '',
        commisionValue: json["commision_value"]?.toString() ?? '',
        commisionLedgerId: json["commision_ledger_id"]?.toString() ?? '',
        retefuenteValue: json["retefuente_value"]?.toString() ?? '',
        retefuenteLedgerId: json["retefuente_ledger_id"]?.toString() ?? '',
        reteivaValue: json["reteiva_value"]?.toString() ?? '',
        reteivaLedgerId: json["reteiva_ledger_id"]?.toString() ?? '',
        reteicaValue: json["reteica_value"]?.toString() ?? '',
        reteicaLedgerId: json["reteica_ledger_id"]?.toString() ?? '',
        supplierId: json["supplier_id"]?.toString() ?? '',
        icon: json["icon"]?.toString() ?? '',
        billerAccountantParametrization:
            json["biller_accountant_parametrization"]?.toString() ?? '',
        billers: json["billers"]?.toString() ?? '',
        lastUpdate: json["last_update"],
      );

  static List<PaymentMethods> fromListJson(List<Map<String, dynamic>> data) {
    return data.map((e) => PaymentMethods.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_cloud": idCloud,
        "name": name,
        "code": code,
        "state_sale": stateSale,
        "state_purchase": statePurchase,
        "code_fe": codeFe,
        "cash_payment": cashPayment,
        "due_payment": duePayment,
        "commision_value": commisionValue,
        "commision_ledger_id": commisionLedgerId,
        "retefuente_value": retefuenteValue,
        "retefuente_ledger_id": retefuenteLedgerId,
        "reteiva_value": reteivaValue,
        "reteiva_ledger_id": reteivaLedgerId,
        "reteica_value": reteicaValue,
        "reteica_ledger_id": reteicaLedgerId,
        "supplier_id": supplierId,
        "icon": icon,
        "biller_accountant_parametrization": billerAccountantParametrization,
        "billers": billers,
        "last_update": lastUpdate,
      };

  @override
  String toString() => name;
}
