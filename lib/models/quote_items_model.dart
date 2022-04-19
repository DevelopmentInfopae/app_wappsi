// To parse this JSON data, do
//
//     final QuoteItemsModel = QuoteItemsModelFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:pos_wappsi/bloc/orders_bloc.dart';
import 'package:pos_wappsi/bloc/quotes_bloc.dart';

class QuoteItemsModel {
  QuoteItemsModel({
    this.id,
    this.idCloud,
    this.quoteId,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.productType,
    this.optionId,
    required this.netUnitPrice,
    required this.unitPrice,
    required this.quantity,
    required this.warehouseId,
    required this.itemTax,
    required this.taxRateId,
    required this.tax,
    this.itemTax2,
    this.taxRate2Id,
    this.tax2,
    this.discount,
    this.itemDiscount = 0,
    required this.subtotal,
    this.serialNo,
    this.realUnitPrice,
    this.productUnitId,
    this.productUnitCode,
    this.unitQuantity,
    this.gst,
    this.preferences,
    this.cgst,
    this.sgst,
    this.igst,
    this.priceBeforeTax = 0.0,
  });

  int? id;
  int? idCloud;
  int? quoteId;
  int productId;
  String productCode;
  String productName;
  String productType;
  int? optionId;
  double netUnitPrice;
  double unitPrice;
  double quantity;
  int? warehouseId;
  double? itemTax;
  int? taxRateId;
  String? tax;
  double? itemTax2;
  int? taxRate2Id;
  String? tax2;
  String? discount;
  double? itemDiscount;
  double subtotal;
  String? serialNo;
  double? realUnitPrice;
  int? productUnitId;
  String? productUnitCode;
  String? preferences;
  double? unitQuantity;
  String? gst;
  double? cgst;
  double? sgst;
  double? igst;
  double priceBeforeTax;

  factory QuoteItemsModel.fromRawJson(String str) =>
      QuoteItemsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory QuoteItemsModel.fromJson(Map<String, dynamic> json) =>
      QuoteItemsModel(
        id: json["id"],
        idCloud: json["id_cloud"],
        quoteId: json["quote_id"],
        productId: json["product_id"],
        productCode: json["product_code"],
        productName: json["product_name"],
        productType: json["product_type"],
        optionId: int.tryParse(json["option_id"].toString()),
        netUnitPrice:
            double.tryParse(json["net_unit_price"]?.toString() ?? '0.0') ?? 0.0,
        unitPrice: json["unit_price"] + 0.0,
        quantity: json["quantity"] + 0.0,
        warehouseId: json["warehouse_id"],
        itemTax: json["item_tax"] + 0.0,
        taxRateId: json["tax_rate_id"],
        preferences: json["preferences"],
        tax: json["tax"],
        itemTax2: double.tryParse(json["item_tax_2"].toString()),
        taxRate2Id: int.tryParse(json["tax_rate_2_id"].toString()),
        tax2: json["tax_2"],
        discount: json["discount"],
        itemDiscount: double.tryParse(json["item_discount"].toString()),
        subtotal: json["subtotal"] + 0.0,
        serialNo: json["serial_no"],
        realUnitPrice: double.tryParse(json["real_unit_price"].toString()),
        productUnitId: json["product_unit_id"],
        productUnitCode: json["product_unit_code"],
        unitQuantity: json["unit_quantity"] + 0.0,
        gst: json["gst"],
        cgst: double.tryParse(json["cgst"].toString()),
        sgst: double.tryParse(json["sgst"].toString()),
        igst: double.tryParse(json["igst"].toString()),
        priceBeforeTax:
            double.tryParse(json["price_before_tax"]?.toString() ?? '0') == 0.0
                ? (double.tryParse(
                        json["net_unit_price"]?.toString() ?? '0.0') ??
                    0.0)
                : 0.0,
      );

  Map<String, dynamic> toJson({bool withoutIds = true}) {
    if (withoutIds) {
      return {
        "quote_id": quoteId,
        "product_id": productId,
        "product_code": productCode,
        "product_name": productName,
        "product_type": productType,
        "option_id": optionId,
        "net_unit_price": netUnitPrice,
        "unit_price": unitPrice,
        "quantity": quantity,
        "warehouse_id": warehouseId,
        "item_tax": itemTax,
        "tax_rate_id": taxRateId,
        "tax": tax,
        "item_tax_2": itemTax2,
        "tax_rate_2_id": taxRate2Id,
        "tax_2": tax2,
        "preferences": preferences,
        "discount": discount,
        "item_discount": itemDiscount,
        "subtotal": subtotal,
        "serial_no": serialNo,
        "real_unit_price": realUnitPrice,
        "product_unit_id": productUnitId,
        "product_unit_code": productUnitCode,
        "unit_quantity": unitQuantity,
        "gst": gst,
        "cgst": cgst,
        "sgst": sgst,
        "igst": igst,
        "price_before_tax": priceBeforeTax,
      };
    } else {
      return {
        "id": id,
        "id_cloud": idCloud,
        "quote_id": quoteId,
        "product_id": productId,
        "product_code": productCode,
        "product_name": productName,
        "product_type": productType,
        "preferences": preferences,
        "option_id": optionId,
        "net_unit_price": netUnitPrice,
        "unit_price": unitPrice,
        "quantity": quantity,
        "warehouse_id": warehouseId,
        "item_tax": itemTax,
        "tax_rate_id": taxRateId,
        "tax": tax,
        "item_tax_2": itemTax2,
        "tax_rate_2_id": taxRate2Id,
        "tax_2": tax2,
        "discount": discount,
        "item_discount": itemDiscount,
        "subtotal": subtotal,
        "serial_no": serialNo,
        "real_unit_price": realUnitPrice,
        "product_unit_id": productUnitId,
        "product_unit_code": productUnitCode,
        "unit_quantity": unitQuantity,
        "gst": gst,
        "cgst": cgst,
        "sgst": sgst,
        "igst": igst,
        "price_before_tax": priceBeforeTax,
      };
    }
  }

  static List<QuoteItemsModel> fromJsonList(List<Map> list) {
    List<QuoteItemsModel> orders = [];
    Map<String, dynamic> temp = {};
    for (var item in list) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      orders.add(QuoteItemsModel.fromJson(temp));
    }

    return orders;

    // prString(temp);
  }

  /// Build an instance of  QuoteItemsModel given a keys set to get products and units from
  /// order bloc
  static List<Map<String, dynamic>> buildQuoteItems(List<String> keys) {
    List<Map<String, dynamic>> orderSaleItems = [];
    for (String key in keys) {
      final product = quoteBloc.getProducts![key]!;
      final unit = quoteBloc.getProductUnits?[key]!;

      final pIVA = product.getPriceWithIVA();
      final pNoIVA = product.getPriceWithoutIVA();
      final taxValue = pIVA - pNoIVA;

      final orderSaleItem = QuoteItemsModel(
          productId: product.idCloud,
          productCode: product.code,
          productName: product.name,
          productType: product.type,
          netUnitPrice: product.getPriceWithoutIVA(),
          priceBeforeTax: product.getPriceWithoutIVA(),
          unitPrice: product.getPriceWithIVA(),
          quantity: product.quantity,
          warehouseId: dataBloc.userData!.warehouseId,
          preferences: quoteBloc.getProductPrefsText(key),
          itemTax: taxValue,
          taxRateId: product.taxRateId,
          productUnitCode: unit?.code,
          realUnitPrice: product.pricePolicyPrices,
          unitQuantity: product.quantity / (unit?.operationValue ?? 1),
          productUnitId: unit?.idCloud ?? product.unit,
          tax: product.taxRateName,
          subtotal: pIVA * product.quantity);
      orderSaleItems.add(orderSaleItem.toJson(withoutIds: true));
    }
    return orderSaleItems;
  }
}
