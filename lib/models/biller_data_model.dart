// To parse this JSON data, do
//
//     final billerDataModel = billerDataModelFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/utils/parsing/to_double.dart';

List<BillerDataModel> billerDataModelFromJson(String str) =>
    List<BillerDataModel>.from(
      json.decode(str).map((x) => BillerDataModel.fromJson(x)),
    );

String billerDataModelToJson(List<BillerDataModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BillerDataModel {
  BillerDataModel({
    required this.idCloud,
    required this.id,
    required this.billerId,
    this.posDocumentTypeDefault,
    this.detalDocumentTypeDefault,
    this.defaultPriceGroup,
    this.defaultWarehouseId,
    this.defaultCustomerId,
    this.defaultSellerId,
    this.keyLog,
    required this.productOrder,
    this.purchasesDocumentTypeDefault,
    this.pinCode,
    this.branchType,
    this.coverageCountry,
    this.coverageState,
    this.coverageCity,
    this.coverageZone,
    this.prioridadPreciosProducto,
    this.language,
    this.currency,
    this.chargeShippingCost,
    this.shippingCost,
    this.maxTotalShippingCost,
    this.concessionStatus,
    this.defaultPosSection,
    this.preparationAdjustmentDocumentTypeId,
    this.defaultCostCenterId,
    this.reteBomberilPercentage,
    this.reteBomberilAccount,
    this.reteBomberilAccountCounterpart,
    this.reteAutoavisoPercentage,
    this.reteAutoavisoAccount,
    this.reteAutoavisoAccountCounterpart,
    this.reteAutoicaPercentage,
    this.reteAutoicaAccount,
    this.reteAutoicaAccountCounterpart,
    this.cashPaymentMethodAccount,
    this.pinCodeRequest,
    this.pinCodeMethod,
    this.randomPinCode,
    this.randomPinCodeDate,
    required this.lastUpdate,
    this.minSaleAmount,
    this.orderSalesDocumentTypeDefault = 0,
  });

  String id;
  String idCloud;
  String billerId;
  String? posDocumentTypeDefault;
  String? detalDocumentTypeDefault;
  String? defaultPriceGroup;
  String? defaultWarehouseId;
  String? defaultCustomerId;
  String? defaultSellerId;
  String? keyLog;
  String productOrder;
  String? purchasesDocumentTypeDefault;
  String? pinCode;
  String? branchType;
  String? coverageCountry;
  String? coverageState;
  String? coverageCity;
  String? coverageZone;
  String? prioridadPreciosProducto;
  String? language;
  String? currency;
  String? chargeShippingCost;
  String? shippingCost;
  String? maxTotalShippingCost;
  String? concessionStatus;
  String? defaultPosSection;
  String? preparationAdjustmentDocumentTypeId;
  dynamic defaultCostCenterId;
  String? reteBomberilPercentage;
  String? reteBomberilAccount;
  String? reteBomberilAccountCounterpart;
  String? reteAutoavisoPercentage;
  String? reteAutoavisoAccount;
  String? reteAutoavisoAccountCounterpart;
  String? reteAutoicaPercentage;
  String? reteAutoicaAccount;
  String? reteAutoicaAccountCounterpart;
  String? cashPaymentMethodAccount;
  String? pinCodeRequest;
  String? pinCodeMethod;
  String? randomPinCode;
  dynamic randomPinCodeDate;
  String lastUpdate;
  int orderSalesDocumentTypeDefault;
  double? minSaleAmount;

  factory BillerDataModel.fromJson(Map<String, dynamic> json) =>
      BillerDataModel(
        id: json['id']?.toString() ?? '',
        idCloud: json['id_cloud']?.toString() ?? '',
        billerId: json['biller_id']?.toString() ?? '',
        posDocumentTypeDefault:
            json['pos_document_type_default']?.toString() ?? '',
        detalDocumentTypeDefault:
            json['detal_document_type_default']?.toString() ?? '',
        defaultPriceGroup: json['default_price_group']?.toString() ?? '',
        defaultWarehouseId: json['default_warehouse_id']?.toString() ?? '',
        defaultCustomerId: json['default_customer_id']?.toString() ?? '',
        defaultSellerId: json['default_seller_id']?.toString() ?? '',
        keyLog: json['key_log']?.toString() ?? '',
        productOrder: json['product_order']?.toString() ?? '',
        purchasesDocumentTypeDefault:
            json['purchases_document_type_default']?.toString() ?? '',
        pinCode: json['pin_code'],
        branchType: json['branch_type']?.toString() ?? '',
        coverageCountry: json['coverage_country'],
        coverageState: json['coverage_state'],
        coverageCity: json['coverage_city'],
        coverageZone: json['coverage_zone'],
        prioridadPreciosProducto:
            json['prioridad_precios_producto']?.toString() ?? '',
        language: json['language'],
        currency: json['currency'],
        chargeShippingCost: json['charge_shipping_cost']?.toString() ?? '',
        shippingCost: json['shipping_cost']?.toString() ?? '',
        maxTotalShippingCost: json['max_total_shipping_cost']?.toString() ?? '',
        concessionStatus: json['concession_status']?.toString() ?? '',
        defaultPosSection: json['default_pos_section']?.toString() ?? '',
        preparationAdjustmentDocumentTypeId:
            json['preparation_adjustment_document_type_id']?.toString() ?? '',
        defaultCostCenterId: json['default_cost_center_id']?.toString() ?? '',
        reteBomberilPercentage:
            json['rete_bomberil_percentage']?.toString() ?? '',
        reteBomberilAccount: json['rete_bomberil_account']?.toString() ?? '',
        reteBomberilAccountCounterpart:
            json['rete_bomberil_account_counterpart']?.toString() ?? '',
        reteAutoavisoPercentage:
            json['rete_autoaviso_percentage']?.toString() ?? '',
        reteAutoavisoAccount: json['rete_autoaviso_account']?.toString() ?? '',
        reteAutoavisoAccountCounterpart:
            json['rete_autoaviso_account_counterpart']?.toString() ?? '',
        reteAutoicaPercentage:
            json['rete_autoica_percentage']?.toString() ?? '',
        reteAutoicaAccount: json['rete_autoica_account']?.toString() ?? '',
        reteAutoicaAccountCounterpart:
            json['rete_autoica_account_counterpart']?.toString() ?? '',
        cashPaymentMethodAccount:
            json['cash_payment_method_account']?.toString() ?? '',
        pinCodeRequest: json['pin_code_request']?.toString() ?? '',
        pinCodeMethod: json['pin_code_method']?.toString() ?? '',
        randomPinCode: json['random_pin_code']?.toString() ?? '',
        randomPinCodeDate: json['random_pin_code_date']?.toString() ?? '',
        lastUpdate: json['last_update']?.toString() ?? '',
        minSaleAmount: parsingToDoubleNullAble(json['min_sale_amount']),
        orderSalesDocumentTypeDefault:
            parsingToInt(json['order_sales_document_type_default']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_cloud': idCloud,
        'biller_id': billerId,
        'pos_document_type_default': posDocumentTypeDefault,
        'detal_document_type_default': detalDocumentTypeDefault,
        'default_price_group': defaultPriceGroup,
        'default_warehouse_id': defaultWarehouseId,
        'default_customer_id': defaultCustomerId,
        'default_seller_id': defaultSellerId,
        'key_log': keyLog,
        'product_order': productOrder,
        'purchases_document_type_default': purchasesDocumentTypeDefault,
        'pin_code': pinCode,
        'branch_type': branchType,
        'coverage_country': coverageCountry,
        'coverage_state': coverageState,
        'coverage_city': coverageCity,
        'coverage_zone': coverageZone,
        'prioridad_precios_producto': prioridadPreciosProducto,
        'language': language,
        'currency': currency,
        'charge_shipping_cost': chargeShippingCost,
        'shipping_cost': shippingCost,
        'max_total_shipping_cost': maxTotalShippingCost,
        'concession_status': concessionStatus,
        'default_pos_section': defaultPosSection,
        'preparation_adjustment_document_type_id':
            preparationAdjustmentDocumentTypeId,
        'default_cost_center_id': defaultCostCenterId,
        'rete_bomberil_percentage': reteBomberilPercentage,
        'rete_bomberil_account': reteBomberilAccount,
        'rete_bomberil_account_counterpart': reteBomberilAccountCounterpart,
        'rete_autoaviso_percentage': reteAutoavisoPercentage,
        'rete_autoaviso_account': reteAutoavisoAccount,
        'rete_autoaviso_account_counterpart': reteAutoavisoAccountCounterpart,
        'rete_autoica_percentage': reteAutoicaPercentage,
        'rete_autoica_account': reteAutoicaAccount,
        'rete_autoica_account_counterpart': reteAutoicaAccountCounterpart,
        'cash_payment_method_account': cashPaymentMethodAccount,
        'pin_code_request': pinCodeRequest,
        'pin_code_method': pinCodeMethod,
        'random_pin_code': randomPinCode,
        'random_pin_code_date': randomPinCodeDate,
        'last_update': lastUpdate,
      };
}
