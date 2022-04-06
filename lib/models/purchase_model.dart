// To parse this JSON data, do
//
//     final purchaseModel = purchaseModelFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/bloc/purchases_bloc.dart';
import 'package:pos_wappsi/models/user_model.dart';
import 'package:pos_wappsi/utils/parsing/to_double.dart';

class PurchaseModel {
  PurchaseModel({
    this.id,
    this.idCloud,
    this.referenceNo,
    this.date,
    this.supplierId,
    this.supplier,
    this.warehouseId,
    this.note,
    this.total,
    this.productDiscount = 0,
    this.orderDiscountId,
    this.orderDiscount = 0,
    this.totalDiscount = 0,
    this.productTax = 0.0,
    this.orderTaxId,
    this.orderTax = 0.0,
    this.totalTax = 0.0,
    this.shipping = 0.0,
    this.grandTotal,
    this.paid = 0.0,
    this.status = '',
    this.paymentStatus = 'pending',
    this.createdBy,
    this.updatedBy,
    this.updatedAt,
    this.attachment,
    this.paymentTerm,
    this.dueDate,
    this.returnId,
    this.surcharge = 0.0,
    this.returnPurchaseRef,
    this.purchaseId,
    this.returnPurchaseTotal = 0.0,
    this.cgst,
    this.sgst,
    this.igst,
    this.closedYear = 0,
    this.reteFuentePercentage = 0.0,
    this.reteFuenteTotal = 0.0,
    this.reteFuenteAccount = 0,
    this.reteFuenteBase,
    this.reteIvaPercentage = 0.0,
    this.reteIvaTotal = 0.0,
    this.reteIvaAccount = 0,
    this.reteIvaBase,
    this.reteIcaPercentage = 0.0,
    this.reteIcaTotal = 0.0,
    this.reteIcaAccount = 0,
    this.reteIcaBase,
    this.reteOtherPercentage = 0.0,
    this.reteOtherTotal = 0.0,
    this.reteOtherAccount = 0,
    this.reteOtherBase,
    this.orderDiscountMethod = 2,
    this.purchaseCurrency = 'COP',
    this.purchaseCurrencyTrm,
    this.purchaseType = 1,
    this.creditLedgerId,
    this.paymentAffectsRegister = 0,
    this.costCenterId,
    this.billerId,
    this.consecutiveSupplier,
    this.documentTypeId,
    this.reteFuenteId,
    this.reteIvaId,
    this.reteIcaId,
    this.reteOtherId,
    this.purchaseOrigin,
    this.purchaseOriginReferenceNo,
    this.proratedShippingCost = 0.0,
    this.consumptionPurchase = 0.0,
    this.resolucion,
    this.duePaymentMethodId,
    this.registrationDate,
    this.expenseCausation,
    this.returnOtherConcepts = 0,
    this.reteFuenteAssumed,
    this.reteIvaAssumed,
    this.reteIcaAssumed,
    this.reteOtherAssumed,
    this.reteFuenteAssumedAccount,
    this.reteIvaAssumedAccount,
    this.reteIcaAssumedAccount,
    this.reteOtherAssumedAccount,
    this.reteBomberilPercentage = 0.0,
    this.reteBomberilTotal = 0.0,
    this.reteBomberilAccount = 0,
    this.reteBomberilBase,
    this.reteAutoavisoPercentage = 0.0,
    this.reteAutoavisoTotal = 0.0,
    this.reteAutoavisoAccount = 0,
    this.reteAutoavisoBase,
    this.reteBomberilId,
    this.reteAutoavisoId,
    this.reteBomberilAssumedAccount,
    this.reteAutoavisoAssumedAccount,
  });

  int? id;
  int? idCloud;
  String? referenceNo;
  String? date;
  int? supplierId;
  String? supplier;
  int? warehouseId;
  String? note;
  double? total;
  double? productDiscount;
  String? orderDiscountId;
  double? orderDiscount;
  double? totalDiscount;
  double? productTax;
  dynamic orderTaxId;
  double? orderTax;
  double? totalTax;
  double? shipping;
  double? grandTotal;
  double? paid;
  String? status;
  String? paymentStatus;
  int? createdBy;
  dynamic updatedBy;
  dynamic updatedAt;
  dynamic attachment;
  int? paymentTerm;
  String? dueDate;
  dynamic returnId;
  double? surcharge;
  dynamic returnPurchaseRef;
  dynamic purchaseId;
  double? returnPurchaseTotal;
  dynamic cgst;
  dynamic sgst;
  dynamic igst;
  int? closedYear;
  double? reteFuentePercentage;
  double? reteFuenteTotal;
  int? reteFuenteAccount;
  dynamic reteFuenteBase;
  double? reteIvaPercentage;
  double? reteIvaTotal;
  int? reteIvaAccount;
  dynamic reteIvaBase;
  double? reteIcaPercentage;
  double? reteIcaTotal;
  int? reteIcaAccount;
  dynamic reteIcaBase;
  double? reteOtherPercentage;
  double? reteOtherTotal;
  int? reteOtherAccount;
  dynamic reteOtherBase;
  int? orderDiscountMethod;
  String? purchaseCurrency;
  dynamic purchaseCurrencyTrm;
  int? purchaseType;
  dynamic creditLedgerId;
  int? paymentAffectsRegister;
  dynamic costCenterId;
  int? billerId;
  dynamic consecutiveSupplier;
  String? documentTypeId;
  dynamic reteFuenteId;
  dynamic reteIvaId;
  dynamic reteIcaId;
  dynamic reteOtherId;
  dynamic purchaseOrigin;
  dynamic purchaseOriginReferenceNo;
  double? proratedShippingCost;
  double? consumptionPurchase;
  dynamic resolucion;
  dynamic duePaymentMethodId;
  String? registrationDate;
  dynamic expenseCausation;
  int? returnOtherConcepts;
  dynamic reteFuenteAssumed;
  dynamic reteIvaAssumed;
  dynamic reteIcaAssumed;
  dynamic reteOtherAssumed;
  dynamic reteFuenteAssumedAccount;
  dynamic reteIvaAssumedAccount;
  dynamic reteIcaAssumedAccount;
  dynamic reteOtherAssumedAccount;
  double? reteBomberilPercentage;
  double? reteBomberilTotal;
  int? reteBomberilAccount;
  dynamic reteBomberilBase;
  double? reteAutoavisoPercentage;
  double? reteAutoavisoTotal;
  int? reteAutoavisoAccount;
  dynamic reteAutoavisoBase;
  dynamic reteBomberilId;
  dynamic reteAutoavisoId;
  dynamic reteBomberilAssumedAccount;
  dynamic reteAutoavisoAssumedAccount;

  factory PurchaseModel.fromRawJson(String str) =>
      PurchaseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PurchaseModel.fromJson(Map<String, dynamic> json) => PurchaseModel(
        id: json["id"],
        idCloud: json["id_cloud"],
        referenceNo: json["reference_no"],
        date: json["date"],
        supplierId: json["supplier_id"],
        supplier: json["supplier"],
        warehouseId: json["warehouse_id"],
        note: json["note"],
        total: parsingToDouble(json["total"].toString()),
        productDiscount: parsingToDouble(json["product_discount"].toString()),
        orderDiscountId: (json["order_discount_id"] ?? '').toString(),
        orderDiscount: parsingToDouble(json["order_discount"].toString()),
        totalDiscount: parsingToDouble(json["total_discount"].toString()),
        productTax: parsingToDouble(json["product_tax"].toString()),
        orderTaxId: json["order_tax_id"],
        orderTax: parsingToDouble(json["order_tax"]),
        totalTax: parsingToDouble(json["total_tax"]),
        shipping: parsingToDouble(json["shipping"]),
        grandTotal: parsingToDouble(json["grand_total"]),
        paid: parsingToDouble(json["paid"]),
        status: json["status"],
        paymentStatus: json["payment_status"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        updatedAt: json["updated_at"],
        attachment: json["attachment"],
        paymentTerm: json["payment_term"],
        dueDate: json["due_date"],
        returnId: json["return_id"],
        surcharge: parsingToDouble(json["surcharge"]),
        returnPurchaseRef: json["return_purchase_ref"],
        purchaseId: json["purchase_id"],
        returnPurchaseTotal: parsingToDouble(json["return_purchase_total"]),
        cgst: json["cgst"],
        sgst: json["sgst"],
        igst: json["igst"],
        closedYear: json["closed_year"],
        reteFuentePercentage: parsingToDouble(json["rete_fuente_percentage"]),
        reteFuenteTotal: parsingToDouble(json["rete_fuente_total"]),
        reteFuenteAccount: json["rete_fuente_account"],
        reteFuenteBase: json["rete_fuente_base"],
        reteIvaPercentage: parsingToDouble(json["rete_iva_percentage"]),
        reteIvaTotal: parsingToDouble(json["rete_iva_total"]),
        reteIvaAccount: json["rete_iva_account"],
        reteIvaBase: json["rete_iva_base"],
        reteIcaPercentage: parsingToDouble(json["rete_ica_percentage"]),
        reteIcaTotal: parsingToDouble(json["rete_ica_total"]),
        reteIcaAccount: json["rete_ica_account"],
        reteIcaBase: json["rete_ica_base"],
        reteOtherPercentage: parsingToDouble(json["rete_other_percentage"]),
        reteOtherTotal: parsingToDouble(json["rete_other_total"]),
        reteOtherAccount: json["rete_other_account"],
        reteOtherBase: json["rete_other_base"],
        orderDiscountMethod: json["order_discount_method"],
        purchaseCurrency: json["purchase_currency"],
        purchaseCurrencyTrm: json["purchase_currency_trm"],
        purchaseType: json["purchase_type"],
        creditLedgerId: json["credit_ledger_id"],
        paymentAffectsRegister: json["payment_affects_register"],
        costCenterId: json["cost_center_id"],
        billerId: json["biller_id"],
        consecutiveSupplier: json["consecutive_supplier"],
        documentTypeId: (json["document_type_id"] ?? '').toString(),
        reteFuenteId: json["rete_fuente_id"],
        reteIvaId: json["rete_iva_id"],
        reteIcaId: json["rete_ica_id"],
        reteOtherId: json["rete_other_id"],
        purchaseOrigin: json["purchase_origin"],
        purchaseOriginReferenceNo: json["purchase_origin_reference_no"],
        proratedShippingCost: parsingToDouble(json["prorated_shipping_cost"]),
        consumptionPurchase: parsingToDouble(json["consumption_purchase"]),
        resolucion: json["resolucion"],
        duePaymentMethodId: json["due_payment_method_id"],
        registrationDate: json["registration_date"],
        expenseCausation: json["expense_causation"],
        returnOtherConcepts: json["return_other_concepts"],
        reteFuenteAssumed: json["rete_fuente_assumed"],
        reteIvaAssumed: json["rete_iva_assumed"],
        reteIcaAssumed: json["rete_ica_assumed"],
        reteOtherAssumed: json["rete_other_assumed"],
        reteFuenteAssumedAccount: json["rete_fuente_assumed_account"],
        reteIvaAssumedAccount: json["rete_iva_assumed_account"],
        reteIcaAssumedAccount: json["rete_ica_assumed_account"],
        reteOtherAssumedAccount: json["rete_other_assumed_account"],
        reteBomberilPercentage:
            parsingToDouble(json["rete_bomberil_percentage"]),
        reteBomberilTotal: parsingToDouble(json["rete_bomberil_total"]),
        reteBomberilAccount: json["rete_bomberil_account"],
        reteBomberilBase: json["rete_bomberil_base"],
        reteAutoavisoPercentage:
            parsingToDouble(json["rete_autoaviso_percentage"]),
        reteAutoavisoTotal: parsingToDouble(json["rete_autoaviso_total"]),
        reteAutoavisoAccount: json["rete_autoaviso_account"],
        reteAutoavisoBase: json["rete_autoaviso_base"],
        reteBomberilId: json["rete_bomberil_id"],
        reteAutoavisoId: json["rete_autoaviso_id"],
        reteBomberilAssumedAccount: json["rete_bomberil_assumed_account"],
        reteAutoavisoAssumedAccount: json["rete_autoaviso_assumed_account"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "reference_no": referenceNo,
        "date": date,
        "supplier_id": supplierId,
        "supplier": supplier,
        "warehouse_id": warehouseId,
        "note": note,
        "total": total,
        "product_discount": productDiscount,
        "order_discount_id": orderDiscountId,
        "order_discount": orderDiscount,
        "total_discount": totalDiscount,
        "product_tax": productTax,
        "order_tax_id": orderTaxId,
        "order_tax": orderTax,
        "total_tax": totalTax,
        "shipping": shipping,
        "grand_total": grandTotal,
        "paid": paid,
        "status": status,
        "payment_status": paymentStatus,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "updated_at": updatedAt,
        "attachment": attachment,
        "payment_term": paymentTerm,
        "due_date": dueDate,
        "return_id": returnId,
        "surcharge": surcharge,
        "return_purchase_ref": returnPurchaseRef,
        "purchase_id": purchaseId,
        "return_purchase_total": returnPurchaseTotal,
        "cgst": cgst,
        "sgst": sgst,
        "igst": igst,
        "closed_year": closedYear,
        "rete_fuente_percentage": reteFuentePercentage,
        "rete_fuente_total": reteFuenteTotal,
        "rete_fuente_account": reteFuenteAccount,
        "rete_fuente_base": reteFuenteBase,
        "rete_iva_percentage": reteIvaPercentage,
        "rete_iva_total": reteIvaTotal,
        "rete_iva_account": reteIvaAccount,
        "rete_iva_base": reteIvaBase,
        "rete_ica_percentage": reteIcaPercentage,
        "rete_ica_total": reteIcaTotal,
        "rete_ica_account": reteIcaAccount,
        "rete_ica_base": reteIcaBase,
        "rete_other_percentage": reteOtherPercentage,
        "rete_other_total": reteOtherTotal,
        "rete_other_account": reteOtherAccount,
        "rete_other_base": reteOtherBase,
        "order_discount_method": orderDiscountMethod,
        "purchase_currency": purchaseCurrency,
        "purchase_currency_trm": purchaseCurrencyTrm,
        "purchase_type": purchaseType,
        "credit_ledger_id": creditLedgerId,
        "payment_affects_register": paymentAffectsRegister,
        "cost_center_id": costCenterId,
        "biller_id": billerId,
        "consecutive_supplier": consecutiveSupplier,
        "document_type_id": documentTypeId,
        "rete_fuente_id": reteFuenteId,
        "rete_iva_id": reteIvaId,
        "rete_ica_id": reteIcaId,
        "rete_other_id": reteOtherId,
        "purchase_origin": purchaseOrigin,
        "purchase_origin_reference_no": purchaseOriginReferenceNo,
        "prorated_shipping_cost": proratedShippingCost,
        "consumption_purchase": consumptionPurchase,
        "resolucion": resolucion,
        "due_payment_method_id": duePaymentMethodId,
        "registration_date": registrationDate,
        "expense_causation": expenseCausation,
        "return_other_concepts": returnOtherConcepts,
        "rete_fuente_assumed": reteFuenteAssumed,
        "rete_iva_assumed": reteIvaAssumed,
        "rete_ica_assumed": reteIcaAssumed,
        "rete_other_assumed": reteOtherAssumed,
        "rete_fuente_assumed_account": reteFuenteAssumedAccount,
        "rete_iva_assumed_account": reteIvaAssumedAccount,
        "rete_ica_assumed_account": reteIcaAssumedAccount,
        "rete_other_assumed_account": reteOtherAssumedAccount,
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
      };

  Map<String, dynamic> toJsonToSend() => {
        "reference_no": referenceNo,
        "date": date,
        "supplier_id": supplierId,
        "supplier": supplier,
        "warehouse_id": warehouseId,
        "note": note,
        "total": total,
        "product_discount": productDiscount,
        "order_discount_id": orderDiscountId,
        "order_discount": orderDiscount,
        "total_discount": totalDiscount,
        "product_tax": productTax,
        "order_tax_id": orderTaxId,
        "order_tax": orderTax,
        "total_tax": totalTax,
        "shipping": shipping,
        "grand_total": grandTotal,
        "paid": paid,
        "status": status,
        "payment_status": paymentStatus,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "updated_at": updatedAt,
        "attachment": attachment,
        "payment_term": paymentTerm,
        "due_date": dueDate,
        "return_id": returnId,
        "surcharge": surcharge,
        "return_purchase_ref": returnPurchaseRef,
        "purchase_id": purchaseId,
        "return_purchase_total": returnPurchaseTotal,
        "cgst": cgst,
        "sgst": sgst,
        "igst": igst,
        "closed_year": closedYear,
        "rete_fuente_percentage": reteFuentePercentage,
        "rete_fuente_total": reteFuenteTotal,
        "rete_fuente_account": reteFuenteAccount,
        "rete_fuente_base": reteFuenteBase,
        "rete_iva_percentage": reteIvaPercentage,
        "rete_iva_total": reteIvaTotal,
        "rete_iva_account": reteIvaAccount,
        "rete_iva_base": reteIvaBase,
        "rete_ica_percentage": reteIcaPercentage,
        "rete_ica_total": reteIcaTotal,
        "rete_ica_account": reteIcaAccount,
        "rete_ica_base": reteIcaBase,
        "rete_other_percentage": reteOtherPercentage,
        "rete_other_total": reteOtherTotal,
        "rete_other_account": reteOtherAccount,
        "rete_other_base": reteOtherBase,
        "order_discount_method": orderDiscountMethod,
        "purchase_currency": purchaseCurrency,
        "purchase_currency_trm": purchaseCurrencyTrm,
        "purchase_type": purchaseType,
        "credit_ledger_id": creditLedgerId,
        "payment_affects_register": paymentAffectsRegister,
        "cost_center_id": costCenterId,
        "biller_id": billerId,
        "consecutive_supplier": consecutiveSupplier,
        "document_type_id": documentTypeId,
        "rete_fuente_id": reteFuenteId,
        "rete_iva_id": reteIvaId,
        "rete_ica_id": reteIcaId,
        "rete_other_id": reteOtherId,
        "purchase_origin": purchaseOrigin,
        "purchase_origin_reference_no": purchaseOriginReferenceNo,
        "prorated_shipping_cost": proratedShippingCost,
        "consumption_purchase": consumptionPurchase,
        "resolucion": resolucion,
        "due_payment_method_id": duePaymentMethodId,
        "registration_date": registrationDate,
        "expense_causation": expenseCausation,
        "return_other_concepts": returnOtherConcepts,
        "rete_fuente_assumed": reteFuenteAssumed,
        "rete_iva_assumed": reteIvaAssumed,
        "rete_ica_assumed": reteIcaAssumed,
        "rete_other_assumed": reteOtherAssumed,
        "rete_fuente_assumed_account": reteFuenteAssumedAccount,
        "rete_iva_assumed_account": reteIvaAssumedAccount,
        "rete_ica_assumed_account": reteIcaAssumedAccount,
        "rete_other_assumed_account": reteOtherAssumedAccount,
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
      };

  static List<PurchaseModel> fromJsonList(List<Map> list) {
    List<PurchaseModel> purchases = [];
    Map<String, dynamic> temp = {};
    for (var item in list) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      purchases.add(PurchaseModel.fromJson(temp));
    }

    return purchases;

    // prString(temp);
  }

  /// Build an instance of PurchaseModel given productDetails, user, customer
  Map<String, dynamic> buildPurchase(
      UserModel user, Map<String, dynamic> productsDetails) {
    final supp = purchaseBloc.getSupplier!;
    // referenceNo: purchaseBloc.get;
    totalTax = productsDetails['product_total_tax'];
    status = 'pending';
    orderTax = 0;
    total = purchaseBloc.getSubTotalCostWithoutDiscount();
    grandTotal = purchaseBloc.getSubTotalCost();
    // orderDiscount= purchaseBloc.getDiscount;
    supplier = supp.name ?? supp.company ?? '';
    supplierId = int.parse(supp.idCloud ?? '0');
    billerId = user.billerId;
    note = purchaseBloc.getPayNote ?? '';
    warehouseId = user.warehouseId;
    paymentTerm = 0;
    createdBy = int.parse(user.id);
    productTax = productsDetails['product_total_tax'];
    documentTypeId = purchaseBloc.getDocumentType?.idCloud ?? '';
    productDiscount = productsDetails['product_total_discount'];
    // to manage discounts
    // totalDiscount= productsDetails['product_total_discount'] + purchaseBloc.getTotalDiscount();

    return toJsonToSend();
    // here we add order tax if needed
  }
}
