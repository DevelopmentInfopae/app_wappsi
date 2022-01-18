// To parse this JSON data, do
//
//     final PaymentMethods = PaymentMethodsFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';

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

  static loadDefaultPaymentMethod() async {
    final data = await findPaymentMethods(search: 'Efectivo');

    if (data != null) {
      if (data.length > 0 && posBloc.getPaymentMethod == null) {
        posBloc.setPaymentMethod(PaymentMethods.fromJson(data.first));
        return true;
      }
    }
  }

  static Future<List<PaymentMethods>> getPaymentMethods(filter) async {
    final data = await findPaymentMethods(search: filter, pos: true);

    if (data != null) {
      return PaymentMethods.fromListJson(data);
    }

    return [];
  }

  /// Returns PaymentMethod object given an payment method id
  static Future<PaymentMethods?> loadPayDoc(String idPayM) async {
    Map<String, dynamic>? data = await loadPaymentMethod(idPayM);
    if (data != null) {
      return PaymentMethods.fromJson(data);
    } else {
      return null;
    }
  }

  /// Returns PaymentMethod object given an payment method code
  static Future<PaymentMethods?> loadPayMByCode(String code) async {
    Map<String, dynamic>? data = await loadPaymentMethodByCode(code);
    if (data != null) {
      return PaymentMethods.fromJson(data);
    } else {
      return null;
    }
  }

  //-----------------------------------------------------------------------------
  //                                PAYMENT METHODS
  //
  //-----------------------------------------------------------------------------
  /// Return all rows in sma_payment_methods wich fields (name) LIKE given string
  // ignore: avoid_init_to_null
  static Future<List<Map<String, dynamic>>?> findPaymentMethods(
      {String? search = '', pos: true}) async {
    String where = '';
    if (pos) {
      where = "name LIKE '%$search%' AND state_sale = 1 AND code!='deposit'";
    } else {
      where = "name LIKE '%$search%'";
    }
    return await DBProvider.db.sqlQuery('sma_payment_methods', where: where);
  }

  /// Return payMethod info given a pay method id
  static Future<Map<String, dynamic>?> loadPaymentMethod(String idPayM) async {
    return await DBProvider.db
        .sqlFirstQuery('sma_payment_methods', where: 'id_cloud = $idPayM');
  }

  /// Return payMethod info given a pay method id
  static Future<Map<String, dynamic>?> loadPaymentMethodByCode(
      String code) async {
    return await DBProvider.db
        .sqlFirstQuery('sma_payment_methods', where: 'code="$code"');
  }

  @override
  String toString() => name;
}
