// To parse this JSON data, do
//
//     final payment = paymentFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/providers/local_db_provider.dart';

PaymentsModel paymentFromJson(String str) =>
    PaymentsModel.fromJson(json.decode(str));

String paymentToJson(PaymentsModel data) => json.encode(data.toJson());

class PaymentsModel {
  PaymentsModel({
    this.id,
    this.date,
    required this.saleId,
    this.returnId,
    this.purchaseId,
    this.expenseId,
    this.referenceNo,
    this.transactionId,
    required this.paidBy,
    this.chequeNo,
    this.ccNo,
    this.ccHolder,
    this.ccMonth,
    this.ccYear,
    this.ccType,
    required this.amount,
    this.currency,
    required this.createdBy,
    this.attachment,
    required this.type,
    this.note,
    this.posPaid,
    this.posBalance,
    this.approvalCode,
    this.affect,
    this.trmDifference,
    this.trmDifferenceLedgerId,
    this.taxRateTraslate,
    this.taxRateTraslateLedgerId,
    this.costCenterId,
    this.reteFuenteTotal,
    this.reteIvaTotal,
    this.reteIcaTotal,
    this.reteOtherTotal,
    this.multiPayment,
    required this.meanPaymentCodeFe,
    this.paymentDate,
    this.consecutivePayment,
    this.documentTypeId,
    this.reteFuentePercentage,
    this.reteFuenteAccount,
    this.reteFuenteBase,
    this.reteIvaPercentage,
    this.reteIvaAccount,
    this.reteIvaBase,
    this.reteIcaPercentage,
    this.reteIcaAccount,
    this.reteIcaBase,
    this.reteOtherPercentage,
    this.reteOtherAccount,
    this.reteOtherBase,
    this.reteFuenteId,
    this.reteIvaId,
    this.reteIcaId,
    this.reteOtherId,
    this.discountLedgerId,
    this.commPerc,
    this.commBase,
    this.commAmount,
    this.sellerId,
    this.commPaymentStatus,
    this.commPaymentDate,
    this.commPaymentReferenceNo,
    this.conceptLedgerId,
    this.affectedDepositId,
    this.returnReferenceNo,
    this.pmCommisionValue,
    this.pmRetefuenteValue,
    this.pmReteivaValue,
    this.pmReteicaValue,
    this.companyId,
    this.reteFuenteAssumed,
    this.reteIvaAssumed,
    this.reteIcaAssumed,
    this.reteOtherAssumed,
    this.reteFuenteAssumedAccount,
    this.reteIvaAssumedAccount,
    this.reteIcaAssumedAccount,
    this.reteOtherAssumedAccount,
    this.conceptBase,
    this.conceptCompanyId,
    this.reteBomberilPercentage,
    this.reteBomberilTotal,
    this.reteBomberilAccount,
    this.reteBomberilBase,
    this.reteAutoavisoPercentage,
    this.reteAutoavisoTotal,
    this.reteAutoavisoAccount,
    this.reteAutoavisoBase,
    this.reteBomberilId,
    this.reteAutoavisoId,
    this.reteBomberilAssumedAccount,
    this.reteAutoavisoAssumedAccount,
    this.commPaidPaymentsIds,
    this.commPaidSaleReference,
  });

  int? id;
  String? date;
  int saleId;
  int? returnId;
  int? purchaseId;
  int? expenseId;
  String? referenceNo;
  String? transactionId;
  String paidBy;
  String? chequeNo;
  String? ccNo;
  String? ccHolder;
  String? ccMonth;
  String? ccYear;
  String? ccType;
  double amount;
  String? currency;
  int createdBy;
  String? attachment;
  String type;
  String? note;
  double? posPaid;
  double? posBalance;
  String? approvalCode;
  int? affect;
  double? trmDifference;
  int? trmDifferenceLedgerId;
  double? taxRateTraslate;
  int? taxRateTraslateLedgerId;
  int? costCenterId;
  double? reteFuenteTotal;
  double? reteIvaTotal;
  double? reteIcaTotal;
  double? reteOtherTotal;
  int? multiPayment;
  String meanPaymentCodeFe;
  String? paymentDate;
  String? consecutivePayment;
  int? documentTypeId;
  int? reteFuentePercentage;
  int? reteFuenteAccount;
  int? reteFuenteBase;
  int? reteIvaPercentage;
  int? reteIvaAccount;
  int? reteIvaBase;
  int? reteIcaPercentage;
  int? reteIcaAccount;
  int? reteIcaBase;
  int? reteOtherPercentage;
  int? reteOtherAccount;
  int? reteOtherBase;
  int? reteFuenteId;
  int? reteIvaId;
  int? reteIcaId;
  int? reteOtherId;
  int? discountLedgerId;
  int? commPerc;
  int? commBase;
  int? commAmount;
  int? sellerId;
  int? commPaymentStatus;
  String? commPaymentDate;
  String? commPaymentReferenceNo;
  int? conceptLedgerId;
  int? affectedDepositId;
  String? returnReferenceNo;
  String? pmCommisionValue;
  String? pmRetefuenteValue;
  String? pmReteivaValue;
  String? pmReteicaValue;
  int? companyId;
  int? reteFuenteAssumed;
  int? reteIvaAssumed;
  int? reteIcaAssumed;
  int? reteOtherAssumed;
  int? reteFuenteAssumedAccount;
  int? reteIvaAssumedAccount;
  int? reteIcaAssumedAccount;
  int? reteOtherAssumedAccount;
  double? conceptBase;
  double? conceptCompanyId;
  double? reteBomberilPercentage;
  double? reteBomberilTotal;
  int? reteBomberilAccount;
  double? reteBomberilBase;
  double? reteAutoavisoPercentage;
  double? reteAutoavisoTotal;
  int? reteAutoavisoAccount;
  double? reteAutoavisoBase;
  int? reteBomberilId;
  int? reteAutoavisoId;
  int? reteBomberilAssumedAccount;
  int? reteAutoavisoAssumedAccount;
  int? commPaidPaymentsIds;
  String? commPaidSaleReference;

  factory PaymentsModel.fromJson(Map<String, dynamic> json) => PaymentsModel(
        id: json["id"],
        date: json["date"],
        saleId: json["sale_id"],
        returnId: int.tryParse(json["return_id"].toString()),
        purchaseId: int.tryParse(json["purchase_id"].toString()),
        expenseId: int.tryParse(json["expense_id"].toString()),
        referenceNo: json["reference_no"],
        transactionId: json["transaction_id"],
        paidBy: json["paid_by"],
        chequeNo: json["cheque_no"],
        ccNo: json["cc_no"],
        ccHolder: json["cc_holder"],
        ccMonth: json["cc_month"],
        ccYear: json["cc_year"],
        ccType: json["cc_type"],
        amount: json["amount"].toDouble(),
        currency: json["currency"],
        createdBy: json["created_by"],
        attachment: json["attachment"],
        type: json["type"],
        note: json["note"],
        posPaid: json["pos_paid"].toDouble(),
        posBalance: json["pos_balance"].toDouble(),
        approvalCode: json["approval_code"],
        affect: json["affect"],
        trmDifference: double.tryParse(json["trm_difference"].toString()),
        trmDifferenceLedgerId:
            int.tryParse(json["trm_difference_ledger_id"].toString()),
        taxRateTraslate: double.tryParse(json["tax_rate_traslate"].toString()),
        taxRateTraslateLedgerId:
            int.tryParse(json["tax_rate_traslate_ledger_id"].toString()),
        costCenterId: int.tryParse(json["cost_center_id"].toString()),
        reteFuenteTotal: double.tryParse(json["rete_fuente_total"].toString()),
        reteIvaTotal: double.tryParse(json["rete_iva_total"].toString()),
        reteIcaTotal: double.tryParse(json["rete_ica_total"].toString()),
        reteOtherTotal: double.tryParse(json["rete_other_total"].toString()),
        multiPayment: int.tryParse(json["multi_payment"].toString()),
        meanPaymentCodeFe: json["mean_payment_code_fe"],
        paymentDate: json["payment_date"],
        consecutivePayment: json["consecutive_payment"],
        documentTypeId: int.tryParse(json["document_type_id"].toString()),
        reteFuentePercentage: json["rete_fuente_percentage"],
        reteFuenteAccount: json["rete_fuente_account"],
        reteFuenteBase: int.tryParse(json["rete_fuente_base"].toString()),
        reteIvaPercentage: int.tryParse(json["rete_iva_percentage"].toString()),
        reteIvaAccount: int.tryParse(json["rete_iva_account"].toString()),
        reteIvaBase: int.tryParse(json["rete_iva_base"].toString()),
        reteIcaPercentage: int.tryParse(json["rete_ica_percentage"].toString()),
        reteIcaAccount: int.tryParse(json["rete_ica_account"].toString()),
        reteIcaBase: int.tryParse(json["rete_ica_base"].toString()),
        reteOtherPercentage:
            int.tryParse(json["rete_other_percentage"].toString()),
        reteOtherAccount: int.tryParse(json["rete_other_account"].toString()),
        reteOtherBase: int.tryParse(json["rete_other_base"].toString()),
        reteFuenteId: int.tryParse(json["rete_fuente_id"].toString()),
        reteIvaId: int.tryParse(json["rete_iva_id"].toString()),
        reteIcaId: int.tryParse(json["rete_ica_id"].toString()),
        reteOtherId: int.tryParse(json["rete_other_id"].toString()),
        discountLedgerId: int.tryParse(json["discount_ledger_id"].toString()),
        commPerc: int.tryParse(json["comm_perc"].toString()),
        commBase: int.tryParse(json["comm_base"].toString()),
        commAmount: int.tryParse(json["comm_amount"].toString()),
        sellerId: int.tryParse(json["seller_id"].toString()),
        commPaymentStatus: int.tryParse(json["comm_payment_status"].toString()),
        commPaymentDate: json["comm_payment_date"],
        commPaymentReferenceNo: json["comm_payment_reference_no"],
        conceptLedgerId: int.tryParse(json["concept_ledger_id"].toString()),
        affectedDepositId: int.tryParse(json["affected_deposit_id"].toString()),
        returnReferenceNo: json["return_reference_no"],
        pmCommisionValue: json["pm_commision_value"],
        pmRetefuenteValue: json["pm_retefuente_value"],
        pmReteivaValue: json["pm_reteiva_value"],
        pmReteicaValue: json["pm_reteica_value"],
        companyId: int.tryParse(json["company_id"].toString()),
        reteFuenteAssumed: int.tryParse(json["rete_fuente_assumed"].toString()),
        reteIvaAssumed: int.tryParse(json["rete_iva_assumed"].toString()),
        reteIcaAssumed: int.tryParse(json["rete_ica_assumed"].toString()),
        reteOtherAssumed: int.tryParse(json["rete_other_assumed"].toString()),
        reteFuenteAssumedAccount:
            int.tryParse(json["rete_fuente_assumed_account"].toString()),
        reteIvaAssumedAccount:
            int.tryParse(json["rete_iva_assumed_account"].toString()),
        reteIcaAssumedAccount:
            int.tryParse(json["rete_ica_assumed_account"].toString()),
        reteOtherAssumedAccount:
            int.tryParse(json["rete_other_assumed_account"].toString()),
        conceptBase: double.tryParse(json["concept_base"].toString()),
        conceptCompanyId:
            double.tryParse(json["concept_company_id"].toString()),
        reteBomberilPercentage:
            double.tryParse(json["rete_bomberil_percentage"].toString()),
        reteBomberilTotal:
            double.tryParse(json["rete_bomberil_total"].toString()),
        reteBomberilAccount:
            int.tryParse(json["rete_bomberil_account"].toString()),
        reteBomberilBase:
            double.tryParse(json["rete_bomberil_base"].toString()),
        reteAutoavisoPercentage:
            double.tryParse(json["rete_autoaviso_percentage"].toString()),
        reteAutoavisoTotal:
            double.tryParse(json["rete_autoaviso_total"].toString()),
        reteAutoavisoAccount:
            int.tryParse(json["rete_autoaviso_account"].toString()),
        reteAutoavisoBase:
            double.tryParse(json["rete_autoaviso_base"].toString()),
        reteBomberilId: int.tryParse(json["rete_bomberil_id"].toString()),
        reteAutoavisoId: int.tryParse(json["rete_autoaviso_id"].toString()),
        reteBomberilAssumedAccount:
            int.tryParse(json["rete_bomberil_assumed_account"].toString()),
        reteAutoavisoAssumedAccount:
            int.tryParse(json["rete_autoaviso_assumed_account"].toString()),
        commPaidPaymentsIds:
            int.tryParse(json["comm_paid_payments_ids"].toString()),
        commPaidSaleReference: json["comm_paid_sale_reference"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date,
        "sale_id": saleId,
        "return_id": returnId,
        "purchase_id": purchaseId,
        "expense_id": expenseId,
        "reference_no": referenceNo,
        "transaction_id": transactionId,
        "paid_by": paidBy,
        "cheque_no": chequeNo,
        "cc_no": ccNo,
        "cc_holder": ccHolder,
        "cc_month": ccMonth,
        "cc_year": ccYear,
        "cc_type": ccType,
        "amount": amount,
        "currency": currency,
        "created_by": createdBy,
        "attachment": attachment,
        "type": type,
        "note": note,
        "pos_paid": posPaid,
        "pos_balance": posBalance,
        "approval_code": approvalCode,
        "affect": affect,
        "trm_difference": trmDifference,
        "trm_difference_ledger_id": trmDifferenceLedgerId,
        "tax_rate_traslate": taxRateTraslate,
        "tax_rate_traslate_ledger_id": taxRateTraslateLedgerId,
        "cost_center_id": costCenterId,
        "rete_fuente_total": reteFuenteTotal,
        "rete_iva_total": reteIvaTotal,
        "rete_ica_total": reteIcaTotal,
        "rete_other_total": reteOtherTotal,
        "multi_payment": multiPayment,
        "mean_payment_code_fe": meanPaymentCodeFe,
        "payment_date": paymentDate,
        "consecutive_payment": consecutivePayment,
        "document_type_id": documentTypeId,
        "rete_fuente_percentage": reteFuentePercentage,
        "rete_fuente_account": reteFuenteAccount,
        "rete_fuente_base": reteFuenteBase,
        "rete_iva_percentage": reteIvaPercentage,
        "rete_iva_account": reteIvaAccount,
        "rete_iva_base": reteIvaBase,
        "rete_ica_percentage": reteIcaPercentage,
        "rete_ica_account": reteIcaAccount,
        "rete_ica_base": reteIcaBase,
        "rete_other_percentage": reteOtherPercentage,
        "rete_other_account": reteOtherAccount,
        "rete_other_base": reteOtherBase,
        "rete_fuente_id": reteFuenteId,
        "rete_iva_id": reteIvaId,
        "rete_ica_id": reteIcaId,
        "rete_other_id": reteOtherId,
        "discount_ledger_id": discountLedgerId,
        "comm_perc": commPerc,
        "comm_base": commBase,
        "comm_amount": commAmount,
        "seller_id": sellerId,
        "comm_payment_status": commPaymentStatus,
        "comm_payment_date": commPaymentDate,
        "comm_payment_reference_no": commPaymentReferenceNo,
        "concept_ledger_id": conceptLedgerId,
        "affected_deposit_id": affectedDepositId,
        "return_reference_no": returnReferenceNo,
        "pm_commision_value": pmCommisionValue,
        "pm_retefuente_value": pmRetefuenteValue,
        "pm_reteiva_value": pmReteivaValue,
        "pm_reteica_value": pmReteicaValue,
        "company_id": companyId,
        "rete_fuente_assumed": reteFuenteAssumed,
        "rete_iva_assumed": reteIvaAssumed,
        "rete_ica_assumed": reteIcaAssumed,
        "rete_other_assumed": reteOtherAssumed,
        "rete_fuente_assumed_account": reteFuenteAssumedAccount,
        "rete_iva_assumed_account": reteIvaAssumedAccount,
        "rete_ica_assumed_account": reteIcaAssumedAccount,
        "rete_other_assumed_account": reteOtherAssumedAccount,
        "concept_base": conceptBase,
        "concept_company_id": conceptCompanyId,
        "rete_bomberil_percentage": reteBomberilPercentage,
        "rete_bomberil_total": reteBomberilTotal,
        "rete_bomberil_account": reteBomberilAccount,
        "rete_bomberil_base": reteBomberilBase,
        "rete_autoaviso_percentage": reteAutoavisoPercentage,
        "rete_autoaviso_total": reteAutoavisoTotal,
        "rete_autoaviso_account": reteAutoavisoAccount,
        "rete_autoaviso_base": reteAutoavisoBase,
        "rete_bomberil_id": reteBomberilId,
        "rete_autoaviso_id": reteAutoavisoId,
        "rete_bomberil_assumed_account": reteBomberilAssumedAccount,
        "rete_autoaviso_assumed_account": reteAutoavisoAssumedAccount,
        "comm_paid_payments_ids": commPaidPaymentsIds,
        "comm_paid_sale_reference": commPaidSaleReference,
      };
  Future<bool> savePayments() async {
    return await DBProvider.db.insertQuery('sma_payments', toJson());
  }

  static List<PaymentsModel> fromJsonList(List<Map> list) {
    List<PaymentsModel> payments = [];
    Map<String, dynamic> temp = {};
    for (var item in list) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      payments.add(PaymentsModel.fromJson(temp));
    }

    return payments;

    // prString(temp);
  }
}
