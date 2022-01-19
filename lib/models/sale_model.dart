// To parse this JSON data, do
//
//     final saleModel = saleModelFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/models/user_model.dart';

SaleModel saleModelFromJson(String str) => SaleModel.fromJson(json.decode(str));

String saleModelToJson(SaleModel data) => json.encode(data.toJson());

class SaleModel {
  SaleModel(
      {required this.typePos,
      this.test,
      required this.posbiller,
      required this.docTypeId,
      required this.customerGroup,
      required this.customerPrices,
      required this.warehouse,
      required this.seller,
      required this.customer,
      required this.customerBranch,
      this.addItem,
      this.productOrderedProductId,
      this.underCostAuthorized,
      required this.productId,
      this.ignoreHideParameters,
      required this.productType,
      required this.productCode,
      required this.productName,
      this.productIsNew,
      this.productOption,
      this.productComment,
      this.stateReadiness,
      this.preparationArea,
      required this.productDiscount,
      required this.productDiscountVal,
      required this.productTax,
      required this.productTaxRate,
      required this.unitProductTax,
      required this.productTaxVal,
      this.productTax2,
      this.productTaxRate2,
      this.unitProductTax2,
      this.productTaxVal2,
      required this.netPrice,
      required this.unitPrice,
      required this.realUnitPrice,
      required this.quantity,
      required this.productUnit,
      required this.productUnitIdSelected,
      required this.productBaseQuantity,
      this.productAqty,
      this.productPreferencesText,
      required this.biller,
      this.posNote = ' ',
      this.staffNote = ' ',
      required this.amount,
      this.balanceAmount,
      this.duePayment,
      required this.paidBy,
      this.ccNo,
      this.payingGiftCardNo,
      this.ccHolder,
      this.chequeNo,
      this.ccMonth,
      this.ccYear,
      this.ccType,
      this.ccCvv2,
      this.paymentNote,
      this.orderTax,
      this.discount,
      this.shipping,
      this.tableId,
      this.suspendSaleId,
      this.rpaidby,
      this.gtotalReteAmount,
      required this.totalItems,
      required this.paymentTerm,
      required this.documentTypeId,
      required this.sellerId,
      required this.addressId,
      required this.costCenterId,
      this.saleTipAmount,
      this.restobarModeModule,
      this.shippingInGrandTotal,
      this.paymentDocumentTypeId,
      this.restobarTable,
      required this.meanPaymentCodeFe,
      this.exceptCategoryTaxes,
      this.taxExemptCustomer,
      this.reteFuenteAccount,
      this.reteFuenteBase,
      this.reteFuenteId,
      this.reteFuenteTax,
      this.reteFuenteValor,
      this.reteIvaAccount,
      this.reteIvaBase,
      this.reteIvaId,
      this.reteIvaTax,
      this.reteIvaValor,
      this.reteIcaAccount,
      this.reteIcaBase,
      this.reteIcaId,
      this.reteIcaTax,
      this.reteIcaValor,
      this.reteOtrosAccount,
      this.reteOtrosBase,
      this.reteOtrosId,
      this.reteOtrosTax,
      this.reteOtrosValor,
      this.reteBomberilAccount,
      this.reteBomberilBase,
      this.reteBomberilId,
      this.reteBomberilTax,
      this.reteBomberilValor,
      this.reteAutoavisoAccount,
      this.reteAutoavisoBase,
      this.reteAutoavisoId,
      this.reteAutoavisoTax,
      this.reteAutoavisoValor,
      this.reteApplied,
      this.verifyPrices});

  int typePos;
  dynamic test;
  int posbiller;
  String? customerGroup;
  String? customerPrices;
  int docTypeId;
  int warehouse;
  int seller;
  String customer;
  int customerBranch;
  dynamic addItem;
  List<int>? productOrderedProductId;
  List<int>? underCostAuthorized;
  List<int> productId;
  List<int>? ignoreHideParameters;
  List<String> productType;
  List<String> productCode;
  List<String> productName;
  List<bool>? productIsNew;
  List<bool>? productOption;
  List<dynamic>? productComment;
  List<dynamic>? stateReadiness;
  List<dynamic>? preparationArea;
  List<dynamic> productDiscount;
  List<double> productDiscountVal;
  List<int> productTax;
  List<int> productTaxRate;
  List<double> unitProductTax;
  List<double> productTaxVal;
  List<int>? productTax2;
  List<int>? productTaxRate2;
  List<double>? unitProductTax2;
  List<double>? productTaxVal2;
  List<double> netPrice;
  List<double> unitPrice;
  List<double?> realUnitPrice;
  List<int> quantity;
  List<int> productUnit;
  List<int> productUnitIdSelected;
  List<int> productBaseQuantity;
  List<double>? productAqty;
  List<String>? productPreferencesText;
  int biller;
  String posNote;
  String staffNote;
  List<int> amount;
  List<int>? balanceAmount;
  List<String>? duePayment;
  List<String>? paidBy;
  List<String>? ccNo;
  List<String>? payingGiftCardNo;
  List<dynamic>? ccHolder;
  List<dynamic>? chequeNo;
  List<dynamic>? ccMonth;
  List<dynamic>? ccYear;
  List<dynamic>? ccType;
  List<dynamic>? ccCvv2;
  List<dynamic>? paymentNote;
  double? orderTax;
  int? discount;
  int? shipping;
  int? tableId;
  dynamic suspendSaleId;
  String? rpaidby;
  int? gtotalReteAmount;
  int totalItems;
  int? paymentTerm;
  int? documentTypeId;
  int sellerId;
  int addressId;
  dynamic costCenterId;
  int? saleTipAmount;
  int? verifyPrices;
  bool? restobarModeModule;
  int? shippingInGrandTotal;
  String? paymentDocumentTypeId;
  dynamic restobarTable;
  String? meanPaymentCodeFe;
  dynamic exceptCategoryTaxes;
  dynamic taxExemptCustomer;
  dynamic reteFuenteAccount;
  dynamic reteFuenteBase;
  dynamic reteFuenteId;
  dynamic reteFuenteTax;
  dynamic reteFuenteValor;
  dynamic reteIvaAccount;
  dynamic reteIvaBase;
  dynamic reteIvaId;
  dynamic reteIvaTax;
  dynamic reteIvaValor;
  dynamic reteIcaAccount;
  dynamic reteIcaBase;
  dynamic reteIcaId;
  dynamic reteIcaTax;
  dynamic reteIcaValor;
  dynamic reteOtrosAccount;
  dynamic reteOtrosBase;
  dynamic reteOtrosId;
  dynamic reteOtrosTax;
  dynamic reteOtrosValor;
  dynamic reteBomberilAccount;
  dynamic reteBomberilBase;
  dynamic reteBomberilId;
  dynamic reteBomberilTax;
  dynamic reteBomberilValor;
  dynamic reteAutoavisoAccount;
  dynamic reteAutoavisoBase;
  dynamic reteAutoavisoId;
  dynamic reteAutoavisoTax;
  dynamic reteAutoavisoValor;
  dynamic reteApplied;

  factory SaleModel.fromJson(Map<String, dynamic> json) => SaleModel(
        typePos: json["type_pos"],
        test: json["test"],
        customerGroup: '0',
        customerPrices: '0',
        posbiller: json["posbiller"],
        docTypeId: json["doc_type_id"],
        warehouse: json["warehouse"],
        seller: json["seller"],
        customer: json["customer"],
        customerBranch: json["customer_branch"],
        addItem: json["add_item"],
        verifyPrices: json["verify_prices"] ?? 1,
        productOrderedProductId:
            List<int>.from(json["product_ordered_product_id"].map((x) => x)),
        underCostAuthorized:
            List<int>.from(json["under_cost_authorized"].map((x) => x)),
        productId: List<int>.from(json["product_id"].map((x) => x)),
        ignoreHideParameters:
            List<int>.from(json["ignore_hide_parameters"].map((x) => x)),
        productType: List<String>.from(json["product_type"].map((x) => x)),
        productCode: List<String>.from(json["product_code"].map((x) => x)),
        productName: List<String>.from(json["product_name"].map((x) => x)),
        productIsNew: List<bool>.from(json["product_is_new"].map((x) => x)),
        productOption: List<bool>.from(json["product_option"].map((x) => x)),
        productComment:
            List<dynamic>.from(json["product_comment"].map((x) => x)),
        stateReadiness:
            List<dynamic>.from(json["state_readiness"].map((x) => x)),
        preparationArea:
            List<dynamic>.from(json["preparation_area"].map((x) => x)),
        productDiscount:
            List<dynamic>.from(json["product_discount"].map((x) => x)),
        productDiscountVal:
            List<double>.from(json["product_discount_val"].map((x) => x)),
        productTax: List<int>.from(json["product_tax"].map((x) => x)),
        productTaxRate: List<int>.from(json["product_tax_rate"].map((x) => x)),
        unitProductTax: List<double>.from(
            json["unit_product_tax"].map((x) => x.toDouble())),
        productTaxVal:
            List<double>.from(json["product_tax_val"].map((x) => x.toDouble())),
        productTax2: List<int>.from(json["product_tax_2"].map((x) => x)),
        productTaxRate2:
            List<int>.from(json["product_tax_rate_2"].map((x) => x)),
        unitProductTax2:
            List<double>.from(json["unit_product_tax_2"].map((x) => x)),
        productTaxVal2:
            List<double>.from(json["product_tax_val_2"].map((x) => x)),
        netPrice: List<double>.from(json["net_price"].map((x) => x)),
        unitPrice:
            List<double>.from(json["unit_price"].map((x) => x.toDouble())),
        realUnitPrice: List<double>.from(json["real_unit_price"].map((x) => x)),
        quantity: List<int>.from(json["quantity"].map((x) => x)),
        productUnit: List<int>.from(json["product_unit"].map((x) => x)),
        productUnitIdSelected:
            List<int>.from(json["product_unit_id_selected"].map((x) => x)),
        productBaseQuantity:
            List<int>.from(json["product_base_quantity"].map((x) => x)),
        productAqty: List<double>.from(json["product_aqty"].map((x) => x)),
        productPreferencesText:
            List<String>.from(json["product_preferences_text"].map((x) => x)),
        biller: json["biller"],
        posNote: json["pos_note"],
        staffNote: json["staff_note"],
        amount: List<int>.from(json["amount"].map((x) => x)),
        balanceAmount: List<int>.from(json["balance_amount"].map((x) => x)),
        duePayment: json["due_payment"] ?? '',
        paidBy: List<String>.from(json["paid_by"].map((x) => x)),
        ccNo: List<String>.from(json["cc_no"].map((x) => x)),
        payingGiftCardNo:
            List<String>.from(json["paying_gift_card_no"].map((x) => x)),
        ccHolder: List<dynamic>.from(json["cc_holder"].map((x) => x)),
        chequeNo: List<dynamic>.from(json["cheque_no"].map((x) => x)),
        ccMonth: List<dynamic>.from(json["cc_month"].map((x) => x)),
        ccYear: List<dynamic>.from(json["cc_year"].map((x) => x)),
        ccType: List<dynamic>.from(json["cc_type"].map((x) => x)),
        ccCvv2: List<dynamic>.from(json["cc_cvv2"].map((x) => x)),
        paymentNote: List<dynamic>.from(json["payment_note"].map((x) => x)),
        orderTax: json["order_tax"],
        discount: json["discount"],
        shipping: json["shipping"],
        tableId: json["table_id"],
        suspendSaleId: json["suspend_sale_id"],
        rpaidby: json["rpaidby"],
        gtotalReteAmount: json["gtotal_rete_amount"],
        totalItems: json["total_items"],
        paymentTerm: json["payment_term"],
        documentTypeId: json["document_type_id"],
        sellerId: json["seller_id"],
        addressId: json["address_id"],
        costCenterId: json["cost_center_id"],
        saleTipAmount: json["sale_tip_amount"],
        restobarModeModule: json["restobar_mode_module"],
        shippingInGrandTotal: json["shipping_in_grand_total"],
        paymentDocumentTypeId: json["payment_document_type_id"],
        restobarTable: json["restobar_table"],
        meanPaymentCodeFe: json["mean_payment_code_fe"],
        exceptCategoryTaxes: json["except_category_taxes"],
        taxExemptCustomer: json["tax_exempt_customer"],
        reteFuenteAccount: json["rete_fuente_account"],
        reteFuenteBase: json["rete_fuente_base"],
        reteFuenteId: json["rete_fuente_id"],
        reteFuenteTax: json["rete_fuente_tax"],
        reteFuenteValor: json["rete_fuente_valor"],
        reteIvaAccount: json["rete_iva_account"],
        reteIvaBase: json["rete_iva_base"],
        reteIvaId: json["rete_iva_id"],
        reteIvaTax: json["rete_iva_tax"],
        reteIvaValor: json["rete_iva_valor"],
        reteIcaAccount: json["rete_ica_account"],
        reteIcaBase: json["rete_ica_base"],
        reteIcaId: json["rete_ica_id"],
        reteIcaTax: json["rete_ica_tax"],
        reteIcaValor: json["rete_ica_valor"],
        reteOtrosAccount: json["rete_otros_account"],
        reteOtrosBase: json["rete_otros_base"],
        reteOtrosId: json["rete_otros_id"],
        reteOtrosTax: json["rete_otros_tax"],
        reteOtrosValor: json["rete_otros_valor"],
        reteBomberilAccount: json["rete_bomberil_account"],
        reteBomberilBase: json["rete_bomberil_base"],
        reteBomberilId: json["rete_bomberil_id"],
        reteBomberilTax: json["rete_bomberil_tax"],
        reteBomberilValor: json["rete_bomberil_valor"],
        reteAutoavisoAccount: json["rete_autoaviso_account"],
        reteAutoavisoBase: json["rete_autoaviso_base"],
        reteAutoavisoId: json["rete_autoaviso_id"],
        reteAutoavisoTax: json["rete_autoaviso_tax"],
        reteAutoavisoValor: json["rete_autoaviso_valor"],
        reteApplied: json["rete_applied"],
      );

  Map<String, dynamic> toJson() => {
        "type_pos": typePos,
        "test": test,
        "posbiller": posbiller,
        "doc_type_id": docTypeId,
        "warehouse": warehouse,
        "seller": seller,
        "created_by": dataBloc.userData!.id,
        "customer": customer,
        "customer_price_group_id": customerPrices,
        "customer_group_id": customerGroup,
        "customer_branch": customerBranch,
        "add_item": addItem,
        "verify_prices": verifyPrices,
        "product_ordered_product_id": productOrderedProductId,
        "under_cost_authorized": underCostAuthorized,
        "product_id": productId,
        "product_type": productType,
        "ignore_hide_parameters": ignoreHideParameters,
        "product_code": productCode,
        "product_name": productName,
        "product_is_new": productIsNew,
        "product_option": productOption,
        "product_comment": productComment,
        "state_readiness": stateReadiness,
        "preparation_area": preparationArea,
        "product_discount": productDiscount,
        "product_discount_val": productDiscountVal,
        "product_tax": productTax,
        "product_tax_rate": productTaxRate,
        "unit_product_tax": unitProductTax,
        "product_tax_val": productTaxVal,
        "product_tax_2": productTax2,
        "product_tax_rate_2": productTaxRate2,
        "unit_product_tax_2": unitProductTax2,
        "product_tax_val_2": productTaxVal2,
        "net_price": netPrice,
        "unit_price": unitPrice,
        "real_unit_price": realUnitPrice,
        "quantity": quantity,
        "product_unit": productUnit,
        "product_unit_id_selected": productUnitIdSelected,
        "product_base_quantity": productBaseQuantity,
        "product_aqty": productAqty,
        "product_preferences_text": productPreferencesText,
        "biller": biller,
        "pos_note": posNote,
        "staff_note": staffNote,
        "amount": amount,
        "balance_amount": balanceAmount,
        "due_payment": duePayment,
        "paid_by": paidBy,
        "cc_no": ccNo,
        "paying_gift_card_no": payingGiftCardNo,
        "cc_holder": ccHolder,
        "cheque_no": chequeNo,
        "cc_month": ccMonth,
        "cc_year": ccYear,
        "cc_type": ccType,
        "cc_cvv2": ccCvv2,
        "payment_note": paymentNote,
        "order_tax": orderTax,
        "discount": discount,
        "shipping": shipping,
        "table_id": tableId,
        "suspend_sale_id": suspendSaleId,
        "rpaidby": rpaidby,
        "gtotal_rete_amount": gtotalReteAmount,
        "total_items": totalItems,
        "payment_term": paymentTerm,
        "document_type_id": documentTypeId,
        "seller_id": sellerId,
        "address_id": addressId,
        "cost_center_id": costCenterId,
        "sale_tip_amount": saleTipAmount,
        "restobar_mode_module": restobarModeModule,
        "shipping_in_grand_total": shippingInGrandTotal,
        "payment_document_type_id": paymentDocumentTypeId,
        "restobar_table": restobarTable,
        "mean_payment_code_fe": meanPaymentCodeFe,
        "except_category_taxes": exceptCategoryTaxes,
        "tax_exempt_customer": taxExemptCustomer,
        "rete_fuente_account": reteFuenteAccount,
        "rete_fuente_base": reteFuenteBase,
        "rete_fuente_id": reteFuenteId,
        "rete_fuente_tax": reteFuenteTax,
        "rete_fuente_valor": reteFuenteValor,
        "rete_iva_account": reteIvaAccount,
        "rete_iva_base": reteIvaBase,
        "rete_iva_id": reteIvaId,
        "rete_iva_tax": reteIvaTax,
        "rete_iva_valor": reteIvaValor,
        "rete_ica_account": reteIcaAccount,
        "rete_ica_base": reteIcaBase,
        "rete_ica_id": reteIcaId,
        "rete_ica_tax": reteIcaTax,
        "rete_ica_valor": reteIcaValor,
        "rete_otros_account": reteOtrosAccount,
        "rete_otros_base": reteOtrosBase,
        "rete_otros_id": reteOtrosId,
        "rete_otros_tax": reteOtrosTax,
        "rete_otros_valor": reteOtrosValor,
        "rete_bomberil_account": reteBomberilAccount,
        "rete_bomberil_base": reteBomberilBase,
        "rete_bomberil_id": reteBomberilId,
        "rete_bomberil_tax": reteBomberilTax,
        "rete_bomberil_valor": reteBomberilValor,
        "rete_autoaviso_account": reteAutoavisoAccount,
        "rete_autoaviso_base": reteAutoavisoBase,
        "rete_autoaviso_id": reteAutoavisoId,
        "rete_autoaviso_tax": reteAutoavisoTax,
        "rete_autoaviso_valor": reteAutoavisoValor,
        "rete_applied": reteApplied,
      };

  /// Build an instance of SaleModel given productDetails, user, customer and
  /// customerAddress
  static SaleModel buildSale(
      UserModel user, Map<String, dynamic> productsDetails) {
    final customer = posBloc.getCustomer!;
    final customerAddress = posBloc.getCustomerAddresses!;
    final payment = posBloc.getPaymentMethod!;

    final today = DateTime.now();
    DateTime? dueDate;
    if (posBloc.getPaymentTerm != null) {
      dueDate = today.add(Duration(days: posBloc.getPaymentTerm!));
    }
    return SaleModel(
        typePos: 1,
        amount: [posBloc.getSubTotal().toInt()],
        customerGroup: posBloc.getCustomer!.customerGroupId,
        customerPrices: posBloc.getCustomer!.priceGroupId,
        biller: user.billerId,
        paidBy: [payment.code],
        posNote: posBloc.getInvoiceNote ?? '',
        verifyPrices: posBloc.getVerifyPrices ?? 1,
        sellerId: user.sellerId,
        netPrice: productsDetails['net_price'],
        quantity: productsDetails['quantity'],
        unitPrice: productsDetails['unit_price'],
        meanPaymentCodeFe: posBloc.getPaymentMethod?.codeFe.toString(),
        posbiller: user.billerId,
        docTypeId: user.documentTypeId ?? 0,
        warehouse: user.warehouseId,
        seller: user.sellerId,
        customer: customer.idCloud!,
        productId: productsDetails['product_id'],
        staffNote: posBloc.getDispatchNote ?? '',
        addressId: customerAddress.idCloud,
        totalItems: posBloc.getItemsCount(),
        productTax: productsDetails['product_tax'],
        paymentTerm: null,
        duePayment: dueDate == null ? [] : [dueDate.toIso8601String()],
        productUnit: productsDetails['product_unit'],
        productType: productsDetails['product_type'],
        productCode: productsDetails['product_code'],
        productName: productsDetails['product_name'],
        costCenterId: null,
        productTaxVal: productsDetails['product_tax_val'],
        realUnitPrice: productsDetails['real_unit_price'],
        unitProductTax: productsDetails['unit_product_tax'],
        customerBranch: customerAddress.idCloud,
        documentTypeId: user.documentTypeId ?? null,
        productTaxRate: productsDetails['product_tax_rate'],
        productDiscount: productsDetails['product_discount'],
        productDiscountVal: productsDetails['product_discount_val'],
        productBaseQuantity: productsDetails['product_base_quantity'],
        productUnitIdSelected: productsDetails['product_unit_id_selected'],
        paymentDocumentTypeId: posBloc.getPaymentDocument!.idCloud.toString());
  }
}
