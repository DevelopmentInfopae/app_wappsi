// To parse this JSON data, do
//
//     final salesModel = salesModelFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/models/local_sale_items_model.dart';

import 'package:pos_wappsi/models/user_model.dart';
import 'package:pos_wappsi/providers/biller_data_provider.dart';
import 'package:pos_wappsi/providers/companies_provider.dart';
import 'package:pos_wappsi/providers/customer_addresses_provider.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/local_sale_items_provider.dart';
import 'package:pos_wappsi/providers/payment_methods_provider.dart';
import 'package:pos_wappsi/providers/payment_provider.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

class SalesModel {
  SalesModel(
      {this.id,
      this.idCloud,
      this.date,
      this.referenceNo,
      required this.customerId,
      required this.customer,
      required this.billerId,
      required this.biller,
      required this.warehouseId,
      this.note,
      this.staffNote,
      required this.total,
      required this.productDiscount,
      this.orderDiscountId,
      required this.totalDiscount,
      this.orderDiscount,
      required this.productTax,
      this.orderTaxId,
      required this.orderTax,
      required this.totalTax,
      this.shipping,
      required this.grandTotal,
      this.saleStatus,
      this.paymentStatus,
      this.paymentTerm,
      this.dueDate,
      required this.createdBy,
      this.updatedBy,
      this.updatedAt,
      required this.totalItems,
      required this.pos,
      required this.paid,
      this.returnId,
      this.surcharge,
      this.attachment,
      this.returnSaleRef,
      this.saleId,
      this.returnSaleTotal,
      this.rounding,
      this.suspendNote,
      this.api = 0,
      this.shop = 0,
      required this.addressId,
      required this.sellerId,
      this.reserveId,
      this.hash,
      this.manualPayment,
      this.cgst,
      this.sgst,
      this.igst,
      this.paymentMethod,
      this.payPartner = 0,
      this.reteFuentePercentage,
      this.reteFuenteTotal,
      this.reteFuenteAccount,
      this.reteFuenteBase,
      this.reteIvaPercentage,
      this.reteIvaTotal,
      this.reteIvaAccount,
      this.reteIvaBase,
      this.reteIcaPercentage,
      this.reteIcaTotal,
      this.reteIcaAccount,
      this.reteIcaBase,
      this.reteOtherPercentage,
      this.reteOtherTotal,
      this.reteOtherAccount,
      this.reteOtherBase,
      this.resolucion,
      this.feCorreoEnviado,
      this.feAceptado,
      this.feRecibido,
      this.cufe,
      this.codigoQr,
      this.feIdTransaccion,
      this.feMensaje,
      this.feMensajeSoporteTecnico,
      this.feXml,
      this.feDebitCreditNoteConceptDianCode,
      required this.saleCurrency,
      this.saleCurrencyTrm,
      this.costCenterId,
      required this.documentTypeId,
      this.paymentMethodFe,
      this.paymentMeanFe,
      this.tipAmount,
      this.shippingInGrandTotal,
      this.saleOrigin,
      this.saleOriginReferenceNo,
      this.reteFuenteId,
      this.reteIvaId,
      this.reteIcaId,
      this.reteOtherId,
      this.saleCommPerc,
      this.collectionCommPerc,
      this.saleCommAmount,
      this.saleCommPaymentStatus,
      this.debitNoteId,
      this.referenceDebitNote,
      this.referenceInvoiceId,
      this.restobarTableId,
      this.consumptionSales,
      this.selfWithholdingAmount,
      this.selfWithholdingPercentage,
      this.printed = 0,
      this.duePaymentMethodId,
      this.registrationDate,
      this.returnOtherConcepts,
      this.reteBomberilPercentage,
      this.reteBomberilTotal,
      this.reteBomberilAccount,
      this.reteBomberilBase,
      this.reteAutoavisoPercentage,
      this.reteAutoavisoTotal,
      this.reteAutoavisoAccount,
      this.reteAutoavisoBase,
      this.reteAutoicaPercentage,
      this.reteAutoicaTotal,
      this.reteAutoicaAccount,
      this.reteAutoicaBase,
      this.reteAutoicaAccountCounterpart,
      this.reteAutoavisoAccountCounterpart,
      this.reteBomberilAccountCounterpart,
      this.reteBomberilId,
      this.reteAutoavisoId});

  int? id;
  int? idCloud;
  String? date;
  String? referenceNo;
  int customerId;
  String customer;
  int billerId;
  String biller;
  int warehouseId;
  String? note;
  String? staffNote;
  double total;
  double productDiscount;
  dynamic orderDiscountId;
  double totalDiscount;
  double? orderDiscount;
  double productTax;
  int? orderTaxId;
  double orderTax;
  double totalTax;
  double? shipping;
  double grandTotal;
  String? saleStatus;
  String? paymentStatus;
  int? paymentTerm;
  DateTime? dueDate;
  int createdBy;
  dynamic updatedBy;
  dynamic updatedAt;
  int totalItems;
  int pos;
  double paid;
  dynamic returnId;
  int? surcharge;
  dynamic attachment;
  dynamic returnSaleRef;
  dynamic saleId;
  double? returnSaleTotal;
  dynamic rounding;
  dynamic suspendNote;
  int api;
  int shop;
  int addressId;
  int sellerId;
  dynamic reserveId;
  String? hash;
  dynamic manualPayment;
  dynamic cgst;
  dynamic sgst;
  dynamic igst;
  String? paymentMethod;
  int payPartner;
  double? reteFuentePercentage;
  double? reteFuenteTotal;
  int? reteFuenteAccount;
  double? reteFuenteBase;
  double? reteIvaPercentage;
  dynamic reteIvaTotal;
  int? reteIvaAccount;
  double? reteIvaBase;
  double? reteIcaPercentage;
  dynamic reteIcaTotal;
  int? reteIcaAccount;
  double? reteIcaBase;
  double? reteOtherPercentage;
  dynamic reteOtherTotal;
  int? reteOtherAccount;
  double? reteOtherBase;
  String? resolucion;
  int? feCorreoEnviado;
  int? feAceptado;
  int? feRecibido;
  dynamic cufe;
  dynamic codigoQr;
  dynamic feIdTransaccion;
  dynamic feMensaje;
  dynamic feMensajeSoporteTecnico;
  dynamic feXml;
  dynamic feDebitCreditNoteConceptDianCode;
  String saleCurrency;
  dynamic saleCurrencyTrm;
  dynamic costCenterId;
  int documentTypeId;
  int? paymentMethodFe;
  String? paymentMeanFe;
  int? tipAmount;
  String? shippingInGrandTotal;
  String? saleOrigin;
  String? saleOriginReferenceNo;
  dynamic reteFuenteId;
  dynamic reteIvaId;
  dynamic reteIcaId;
  dynamic reteOtherId;
  int? saleCommPerc;
  int? collectionCommPerc;
  int? saleCommAmount;
  int? saleCommPaymentStatus;
  dynamic debitNoteId;
  dynamic referenceDebitNote;
  dynamic referenceInvoiceId;
  dynamic restobarTableId;
  dynamic consumptionSales;
  int? selfWithholdingAmount;
  int? selfWithholdingPercentage;
  int printed;
  dynamic duePaymentMethodId;
  String? registrationDate;
  int? returnOtherConcepts;
  double? reteBomberilPercentage;
  double? reteBomberilTotal;
  double? reteBomberilAccount;
  dynamic reteBomberilBase;
  double? reteAutoavisoPercentage;
  double? reteAutoavisoTotal;
  int? reteAutoavisoAccount;
  dynamic reteAutoavisoBase;
  double? reteAutoicaPercentage;
  double? reteAutoicaTotal;
  int? reteAutoicaAccount;
  dynamic reteAutoicaBase;
  int? reteAutoicaAccountCounterpart;
  int? reteAutoavisoAccountCounterpart;
  int? reteBomberilAccountCounterpart;
  dynamic reteBomberilId;
  dynamic reteAutoavisoId;

  factory SalesModel.fromRawJson(String str) =>
      SalesModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SalesModel.fromJson(Map<String, dynamic> json) => SalesModel(
        id: json["id"],
        idCloud: json["id_cloud"],
        date: json["date"] ?? '',
        referenceNo: json["reference_no"],
        customerId: json["customer_id"],
        customer: json["customer"],
        billerId: json["biller_id"],
        biller: json["biller"],
        warehouseId: json["warehouse_id"],
        note: json["note"],
        staffNote: json["staff_note"],
        total: json["total"].toDouble(),
        productDiscount: json["product_discount"].toDouble(),
        orderDiscountId: json["order_discount_id"],
        totalDiscount: json["total_discount"].toDouble(),
        orderDiscount: json["order_discount"].toDouble(),
        productTax: json["product_tax"].toDouble(),
        orderTaxId: json["order_tax_id"],
        orderTax: json["order_tax"].toDouble(),
        totalTax: json["total_tax"].toDouble(),
        shipping: (json["shipping"] ?? 0).toDouble(),
        grandTotal: json["grand_total"].toDouble(),
        saleStatus: json["sale_status"],
        paymentStatus: json["payment_status"],
        paymentTerm: json["payment_term"] ?? 0,
        dueDate: DateTime.parse(json["due_date"]),
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        updatedAt: json["updated_at"],
        totalItems: json["total_items"],
        pos: json["pos"],
        paid: json["paid"].toDouble(),
        returnId: json["return_id"],
        surcharge: json["surcharge"],
        attachment: json["attachment"],
        returnSaleRef: json["return_sale_ref"],
        saleId: json["sale_id"],
        returnSaleTotal: (json["return_sale_total"] ?? 0).toDouble(),
        rounding: json["rounding"],
        suspendNote: json["suspend_note"],
        api: json["api"],
        shop: json["shop"],
        addressId: json["address_id"],
        sellerId: json["seller_id"],
        reserveId: json["reserve_id"],
        hash: json["hash"],
        manualPayment: json["manual_payment"],
        cgst: json["cgst"],
        sgst: json["sgst"],
        igst: json["igst"],
        paymentMethod: json["payment_method"],
        payPartner: json["pay_partner"],
        reteFuentePercentage: (json["rete_fuente_percentage"] ?? 0).toDouble(),
        reteFuenteTotal: (json["rete_fuente_total"] ?? 0).toDouble(),
        reteFuenteAccount: json["rete_fuente_account"],
        reteFuenteBase: (json["rete_fuente_base"] ?? 0).toDouble(),
        reteIvaPercentage: (json["rete_iva_percentage"] ?? 0).toDouble(),
        reteIvaTotal: (json["rete_iva_total"] ?? 0).toDouble(),
        reteIvaAccount: json["rete_iva_account"],
        reteIvaBase: (json["rete_iva_base"] ?? 0).toDouble(),
        reteIcaPercentage: (json["rete_ica_percentage"] ?? 0).toDouble(),
        reteIcaTotal: (json["rete_ica_total"] ?? 0).toDouble(),
        reteIcaAccount: json["rete_ica_account"],
        reteIcaBase: (json["rete_ica_base"] ?? 0).toDouble(),
        reteOtherPercentage: (json["rete_other_percentage"] ?? 0).toDouble(),
        reteOtherTotal: (json["rete_other_total"] ?? 0).toDouble(),
        reteOtherAccount: json["rete_other_account"],
        reteOtherBase: (json["rete_other_base"] ?? 0).toDouble(),
        resolucion: json["resolucion"],
        feCorreoEnviado: json["fe_correo_enviado"],
        feAceptado: json["fe_aceptado"],
        feRecibido: json["fe_recibido"],
        cufe: json["cufe"],
        codigoQr: json["codigo_qr"],
        feIdTransaccion: json["fe_id_transaccion"],
        feMensaje: json["fe_mensaje"],
        feMensajeSoporteTecnico: json["fe_mensaje_soporte_tecnico"],
        feXml: json["fe_xml"],
        feDebitCreditNoteConceptDianCode:
            json["fe_debit_credit_note_concept_dian_code"],
        saleCurrency: json["sale_currency"],
        saleCurrencyTrm: json["sale_currency_trm"],
        costCenterId: json["cost_center_id"],
        documentTypeId: json["document_type_id"],
        paymentMethodFe: json["payment_method_fe"],
        paymentMeanFe: json["payment_mean_fe"],
        tipAmount: json["tip_amount"],
        shippingInGrandTotal: json["shipping_in_grand_total"],
        saleOrigin: json["sale_origin"],
        saleOriginReferenceNo: json["sale_origin_reference_no"],
        reteFuenteId: json["rete_fuente_id"],
        reteIvaId: json["rete_iva_id"],
        reteIcaId: json["rete_ica_id"],
        reteOtherId: json["rete_other_id"],
        saleCommPerc: json["sale_comm_perc"],
        collectionCommPerc: json["collection_comm_perc"],
        saleCommAmount: json["sale_comm_amount"],
        saleCommPaymentStatus: json["sale_comm_payment_status"],
        debitNoteId: json["debit_note_id"],
        referenceDebitNote: json["reference_debit_note"],
        referenceInvoiceId: json["reference_invoice_id"],
        restobarTableId: json["restobar_table_id"],
        consumptionSales: json["consumption_sales"],
        selfWithholdingAmount: json["self_withholding_amount"],
        selfWithholdingPercentage: json["self_withholding_percentage"],
        printed: json["printed"],
        duePaymentMethodId: json["due_payment_method_id"],
        registrationDate: json["registration_date"],
        returnOtherConcepts: json["return_other_concepts"],
        reteBomberilPercentage:
            (json["rete_bomberil_percentage"] ?? 0).toDouble(),
        reteBomberilTotal: (json["rete_bomberil_total"] ?? 0).toDouble(),
        reteBomberilAccount: json["rete_bomberil_account"],
        reteBomberilBase: (json["rete_bomberil_base"] ?? 0).toDouble(),
        reteAutoavisoPercentage:
            (json["rete_autoaviso_percentage"] ?? 0).toDouble(),
        reteAutoavisoTotal: (json["rete_autoaviso_total"] ?? 0).toDouble(),
        reteAutoavisoAccount: json["rete_autoaviso_account"],
        reteAutoavisoBase: (json["rete_autoaviso_base"] ?? 0).toDouble(),
        reteAutoicaPercentage:
            (json["rete_autoica_percentage"] ?? 0).toDouble(),
        reteAutoicaTotal: (json["rete_autoica_total"] ?? 0).toDouble(),
        reteAutoicaAccount: json["rete_autoica_account"],
        reteAutoicaBase: json["rete_autoica_base"],
        reteAutoicaAccountCounterpart: json["rete_autoica_account_counterpart"],
        reteAutoavisoAccountCounterpart:
            json["rete_autoaviso_account_counterpart"],
        reteBomberilAccountCounterpart:
            json["rete_bomberil_account_counterpart"],
        reteBomberilId: json["rete_bomberil_id"],
        reteAutoavisoId: json["rete_autoaviso_id"],
      );

  factory SalesModel.fromPosBloc(Map<String, dynamic> productsDetails,
      {int? idCld,
      double orderTax = 0,
      Map<String, dynamic>? salePrintData,
      int pos = 1,
      String saleStatus = "completed",
      String saleCurrency = 'COP',
      paymentMeanFe: 'ZZZ'}) {
    final UserModel userData = dataBloc.userData!;
    final customer = posBloc.getCustomer!;
    final customerAddress = posBloc.getCustomerAddresses!;
    final payment = posBloc.getPaymentMethod!;
    final total = posBloc.getSubTotal();
    String paymentStatus = '';
    double pDiscount = 0;
    double orderDiscount = 0;
    double totalTax = 0;
    if (productsDetails['product_discount'].length > 0) {
      productsDetails['product_discount'].forEach((d) {
        pDiscount += d;
      });
    }
    if (productsDetails['product_tax_val'].length > 0) {
      productsDetails['product_tax_val'].forEach((d) {
        totalTax += d;
      });
    }
    double paid = 0;
    if (posBloc.getPaymentMethod!.code == 'Credito' ||
        posBloc.getPaymentMethod!.code == 'credito') {
      paid = 0;
      paymentStatus = 'due';
    } else {
      paid = total;
      paymentStatus = 'paid';
    }

    return SalesModel(
      idCloud: salePrintData?["id"] ?? idCld,
      referenceNo: salePrintData?['reference_no'] ?? '',
      customerId: int.tryParse(customer.idCloud ?? '0') ?? 0,
      customer: customer.name ?? customer.company ?? '',
      billerId: userData.billerId,
      biller: userData.billerName,
      warehouseId: userData.warehouseId,
      note: posBloc.getInvoiceNote,
      staffNote: posBloc.getDispatchNote,
      total: total - totalTax,
      productDiscount: pDiscount,
      orderDiscountId: null,
      totalDiscount: pDiscount + orderDiscount,
      orderDiscount: orderDiscount,
      productTax: totalTax,
      orderTaxId: null,
      orderTax: orderTax,
      totalTax: totalTax + orderTax,
      saleCurrency: saleCurrency,
      // shipping: json["shipping"],
      grandTotal: total,
      saleStatus: saleStatus,
      paymentStatus: paymentStatus,
      dueDate: DateTime.now().add(Duration(days: posBloc.getPaymentTerm ?? 0)),
      paymentTerm: posBloc.getPaymentTerm,
      createdBy: int.parse(userData.id),
      totalItems: posBloc.getItemsCount(),
      pos: pos,
      paid: paid,
      // returnId: json["return_id"],
      // surcharge: json["surcharge"],
      // attachment: json["attachment"],
      // returnSaleRef: json["return_sale_ref"],
      // saleId: json["sale_id"],
      // returnSaleTotal: json["return_sale_total"],
      // rounding: json["rounding"],
      // suspendNote: '',
      // api: json["api"],
      // shop: json["shop"],
      addressId: customerAddress.idCloud,
      sellerId: userData.sellerId,
      // reserveId: json["reserve_id"],
      // hash: json["hash"],
      // manualPayment: json["manual_payment"],
      // cgst: json["cgst"],
      // sgst: json["sgst"],
      // igst: json["igst"],
      paymentMethod: '',
      // payPartner: json["pay_partner"],
      // reteFuentePercentage: json["rete_fuente_percentage"].toDouble(),
      // reteFuenteTotal: json["rete_fuente_total"],
      // reteFuenteAccount: json["rete_fuente_account"],
      // reteFuenteBase: json["rete_fuente_base"],
      // reteIvaPercentage: json["rete_iva_percentage"],
      // reteIvaTotal: json["rete_iva_total"],
      // reteIvaAccount: json["rete_iva_account"],
      // reteIvaBase: json["rete_iva_base"],
      // reteIcaPercentage: json["rete_ica_percentage"],
      // reteIcaTotal: json["rete_ica_total"],
      // reteIcaAccount: json["rete_ica_account"],
      // reteIcaBase: json["rete_ica_base"],
      // reteOtherPercentage: json["rete_other_percentage"],
      // reteOtherTotal: json["rete_other_total"],
      // reteOtherAccount: json["rete_other_account"],
      // reteOtherBase: json["rete_other_base"],
      resolucion: salePrintData?["resolucion"] ?? '',
      // feCorreoEnviado: json["fe_correo_enviado"],
      // feAceptado: json["fe_aceptado"],
      // feRecibido: json["fe_recibido"],
      // cufe: json["cufe"],
      // codigoQr: json["codigo_qr"],
      // feIdTransaccion: json["fe_id_transaccion"],
      // feMensaje: json["fe_mensaje"],
      // feMensajeSoporteTecnico: json["fe_mensaje_soporte_tecnico"],
      // feXml: json["fe_xml"],
      // feDebitCreditNoteConceptDianCode:
      //     json["fe_debit_credit_note_concept_dian_code"],
      // saleCurrency: json["sale_currency"],
      // saleCurrencyTrm: json["sale_currency_trm"],
      // costCenterId: json["cost_center_id"],
      documentTypeId: userData.documentTypeId!,
      paymentMethodFe: (payment.codeFe),
      paymentMeanFe: paymentMeanFe,
      // tipAmount: json["tip_amount"],
      // shippingInGrandTotal: json["shipping_in_grand_total"],
      // saleOrigin: json["sale_origin"],
      // saleOriginReferenceNo: json["sale_origin_reference_no"],
      // reteFuenteId: json["rete_fuente_id"],
      // reteIvaId: json["rete_iva_id"],
      // reteIcaId: json["rete_ica_id"],
      // reteOtherId: json["rete_other_id"],
      // saleCommPerc: json["sale_comm_perc"],
      // collectionCommPerc: json["collection_comm_perc"],
      // saleCommAmount: json["sale_comm_amount"],
      // saleCommPaymentStatus: json["sale_comm_payment_status"],
      // debitNoteId: json["debit_note_id"],
      // referenceDebitNote: json["reference_debit_note"],
      // referenceInvoiceId: json["reference_invoice_id"],
      // restobarTableId: json["restobar_table_id"],
      // consumptionSales: json["consumption_sales"],
      // selfWithholdingAmount: json["self_withholding_amount"],
      // selfWithholdingPercentage: json["self_withholding_percentage"],
      // printed: json["printed"],
      // duePaymentMethodId: json["due_payment_method_id"],
      registrationDate: salePrintData?["date"] ?? '',
      // returnOtherConcepts: json["return_other_concepts"],
      // reteBomberilPercentage: json["rete_bomberil_percentage"],
      // reteBomberilTotal: json["rete_bomberil_total"],
      // reteBomberilAccount: json["rete_bomberil_account"],
      // reteBomberilBase: json["rete_bomberil_base"],
      // reteAutoavisoPercentage: json["rete_autoaviso_percentage"],
      // reteAutoavisoTotal: json["rete_autoaviso_total"],
      // reteAutoavisoAccount: json["rete_autoaviso_account"],
      // reteAutoavisoBase: json["rete_autoaviso_base"],
      // reteAutoicaPercentage: json["rete_autoica_percentage"],
      // reteAutoicaTotal: json["rete_autoica_total"],
      // reteAutoicaAccount: json["rete_autoica_account"],
      // reteAutoicaBase: json["rete_autoica_base"],
      // reteAutoicaAccountCounterpart: json["rete_autoica_account_counterpart"],
      // reteAutoavisoAccountCounterpart:
      //     json["rete_autoaviso_account_counterpart"],
      // reteBomberilAccountCounterpart:
      //     json["rete_bomberil_account_counterpart"],
      // reteBomberilId: json["rete_bomberil_id"],
      // reteAutoavisoId: json["rete_autoaviso_id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date ?? '',
        "reference_no": referenceNo,
        "customer_id": customerId,
        "customer": customer,
        "biller_id": billerId,
        "biller": biller,
        "warehouse_id": warehouseId,
        "note": note,
        "staff_note": staffNote,
        "total": total,
        "product_discount": productDiscount,
        "order_discount_id": orderDiscountId,
        "total_discount": totalDiscount,
        "order_discount": orderDiscount,
        "product_tax": productTax,
        "order_tax_id": orderTaxId,
        "order_tax": orderTax,
        "total_tax": totalTax,
        "shipping": shipping,
        "grand_total": grandTotal,
        "sale_status": saleStatus,
        "payment_status": paymentStatus,
        "payment_term": paymentTerm,
        "due_date":
            "${(dueDate?.year ?? 0).toString().padLeft(4, '0')}-${(dueDate?.month ?? 0).toString().padLeft(2, '0')}-${(dueDate?.day ?? 0).toString().padLeft(2, '0')}",
        "created_by": createdBy,
        "updated_by": updatedBy,
        "updated_at": updatedAt,
        "total_items": totalItems,
        "pos": pos,
        "paid": paid,
        "return_id": returnId,
        "surcharge": surcharge,
        "attachment": attachment,
        "return_sale_ref": returnSaleRef,
        "sale_id": saleId,
        "return_sale_total": returnSaleTotal,
        "rounding": rounding,
        "suspend_note": suspendNote,
        "api": api,
        "shop": shop,
        "address_id": addressId,
        "seller_id": sellerId,
        "reserve_id": reserveId,
        "hash": hash,
        "manual_payment": manualPayment,
        "cgst": cgst,
        "sgst": sgst,
        "igst": igst,
        "payment_method": paymentMethod,
        "pay_partner": payPartner,
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
        "resolucion": resolucion,
        "fe_correo_enviado": feCorreoEnviado,
        "fe_aceptado": feAceptado,
        "fe_recibido": feRecibido,
        "cufe": cufe,
        "codigo_qr": codigoQr,
        "fe_id_transaccion": feIdTransaccion,
        "fe_mensaje": feMensaje,
        "fe_mensaje_soporte_tecnico": feMensajeSoporteTecnico,
        "fe_xml": feXml,
        "fe_debit_credit_note_concept_dian_code":
            feDebitCreditNoteConceptDianCode,
        "sale_currency": saleCurrency,
        "sale_currency_trm": saleCurrencyTrm,
        "cost_center_id": costCenterId,
        "document_type_id": documentTypeId,
        "payment_method_fe": paymentMethodFe,
        "payment_mean_fe": paymentMeanFe,
        "tip_amount": tipAmount,
        "shipping_in_grand_total": shippingInGrandTotal,
        "sale_origin": saleOrigin,
        "sale_origin_reference_no": saleOriginReferenceNo,
        "rete_fuente_id": reteFuenteId,
        "rete_iva_id": reteIvaId,
        "rete_ica_id": reteIcaId,
        "rete_other_id": reteOtherId,
        "sale_comm_perc": saleCommPerc,
        "collection_comm_perc": collectionCommPerc,
        "sale_comm_amount": saleCommAmount,
        "sale_comm_payment_status": saleCommPaymentStatus,
        "debit_note_id": debitNoteId,
        "reference_debit_note": referenceDebitNote,
        "reference_invoice_id": referenceInvoiceId,
        "restobar_table_id": restobarTableId,
        "consumption_sales": consumptionSales,
        "self_withholding_amount": selfWithholdingAmount,
        "self_withholding_percentage": selfWithholdingPercentage,
        "printed": printed,
        "due_payment_method_id": duePaymentMethodId,
        "registration_date": registrationDate ?? '',
        "return_other_concepts": returnOtherConcepts,
        "rete_bomberil_percentage": reteBomberilPercentage,
        "rete_bomberil_total": reteBomberilTotal,
        "rete_bomberil_account": reteBomberilAccount,
        "rete_bomberil_base": reteBomberilBase,
        "rete_autoaviso_percentage": reteAutoavisoPercentage,
        "rete_autoaviso_total": reteAutoavisoTotal,
        "rete_autoaviso_account": reteAutoavisoAccount,
        "rete_autoaviso_base": reteAutoavisoBase,
        "rete_autoica_percentage": reteAutoicaPercentage,
        "rete_autoica_total": reteAutoicaTotal,
        "rete_autoica_account": reteAutoicaAccount,
        "rete_autoica_base": reteAutoicaBase,
        "rete_autoica_account_counterpart": reteAutoicaAccountCounterpart,
        "rete_autoaviso_account_counterpart": reteAutoavisoAccountCounterpart,
        "rete_bomberil_account_counterpart": reteBomberilAccountCounterpart,
        "rete_bomberil_id": reteBomberilId,
        "rete_autoaviso_id": reteAutoavisoId,
      };
  Future<int?> saveSaleData() async {
    return await DBProvider.db
        .insertQuery('sma_sales', toJson(), returnId: true);
  }

  static Future<List<SalesModel>?> listSales(
      {String search = '',
      int? limit,
      String orderBy = 'name',
      bool offset = false,
      int offsetValue = 1}) async {
    final pagination = offset ? " LIMIT 30 OFFSET $offsetValue" : "";
    final currentBiller = dataBloc.userData!.billerId;
    final sql = '''select * from sma_sales s 
        WHERE (s.customer LIKE "%$search%" OR s.note LIKE "%$search%" OR s.staff_note LIKE "%$search%" 
        OR s.reference_no LIKE "%$search%") 
        AND s.biller_id=$currentBiller$pagination ORDER BY registration_date DESC;
    ''';
    final res = await DBProvider.db.sqlRawQuery(sql);
    if (res != null) {
      List<SalesModel> sales = [];
      try {
        sales = fromJsonList(res);
      } catch (e) {
        print(e);
      }
      return sales;
    } else {
      return [];
    }
  }

  static List<SalesModel> fromJsonList(List<Map> list) {
    List<SalesModel> sales = [];
    Map<String, dynamic> temp = {};
    list.forEach((item) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      sales.add(SalesModel.fromJson(temp));
    });

    return sales;

    // prString(temp);
  }

  Future<Map> buildPrintDataMap() async {
    final customer =
        await CompaniesProvider.getCompanyById(customerId.toString());
    final biller = await CompaniesProvider.getCompanyById(billerId.toString());
    final billerData =
        await BillerDataProvider.loadBillerDataId(billerId.toString());
    final customerAddress = await CustomerAddressesProvider.loadCustomerAddress(
        addressId.toString());
    // Load only first sale payment
    final payment = await PaymentProvider.loadPayment(id!);
    final paymentMethod =
        await PaymentMethodsProvider.loadPayMByCode(payment!.paidBy);

    final settings = (await DBProvider.db.getSettings())!;
    final docDetails =
        await DBProvider.db.getDocumentDetails(documentTypeId.toString());
    final temp = removeRareSpaceChr(docDetails?['invoice_footer'] ?? '');

    final productsInfo = await _productsMap(id!);

    return {
      "products": productsInfo['products'],
      "customer": customer?.toJson() ?? {},
      "customer_address": customerAddress?.toJson() ?? {},
      "payment_method": paymentMethod?.toJson(),
      "sale_data": {
        'reference_no': referenceNo,
        'resolucion': resolucion,
        'date': registrationDate
      },
      "pos_note": note ?? '',
      "payment": payment.posPaid,
      "total": payment.amount,
      "iva": productsInfo['iva'],
      "company_data": biller,
      "biller_data": billerData,
      "settings": settings,
      "footer": temp
    };
  }

  static Future<Map<String, dynamic>> _productsMap(int saleId) async {
    final saleItems = await SaleItemsProvider.loadFromDB(saleId);

    List<Map<String, dynamic>> productsMap = [];
    Map<double, dynamic> ivasMap = {};
    try {
      saleItems.forEach((LocalSaleItems item) {
        final tItempMap = {
          'quantity': item.quantity,
          'price': item.unitPrice,
          'name': item.productName,
        };
        productsMap.add(tItempMap);
        final taxRate = (item.unitPrice / item.netUnitPrice) - 1;
        if (ivasMap.containsKey(taxRate)) {
          ivasMap[taxRate]['value'] =
              ivasMap[taxRate]['value'] + (item.priceBeforeTax * item.quantity);
        } else {
          ivasMap[taxRate] = {
            'value': (item.priceBeforeTax * item.quantity),
            'name': item.tax
          };
        }
      });
    } catch (e) {
      print(e);
      return {};
    }
    return {
      'iva': ivasMap,
      'products': productsMap,
    };
  }
}
