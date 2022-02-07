// To parse this JSON data, do
//
//     final OrderSaleItemsModel = OrderSaleItemsModelFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/orders_bloc.dart';

class OrderSaleItemsModel {
  OrderSaleItemsModel({
    this.id,
    this.idCloud,
    this.saleId,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.productType,
    this.optionId,
    required this.netUnitPrice,
    required this.unitPrice,
    required this.quantity,
    this.quantityToBill = 0,
    this.quantityDelivered = 0,
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
    this.saleItemId,
    this.productUnitId,
    this.productUnitCode,
    this.unitQuantity,
    this.comment,
    this.gst,
    this.cgst,
    this.sgst,
    this.igst,
    this.unitOrderDiscount,
    this.priceBeforeTax = 0.0,
    this.preferences,
    this.registrationDate,
  });

  int? id;
  int? idCloud;
  int? saleId;
  int productId;
  String productCode;
  String productName;
  String productType;
  int? optionId;
  double netUnitPrice;
  double unitPrice;
  double quantity;
  double quantityToBill;
  double quantityDelivered;
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
  int? saleItemId;
  int? productUnitId;
  String? productUnitCode;
  double? unitQuantity;
  String? comment;
  String? gst;
  double? cgst;
  double? sgst;
  double? igst;
  double? unitOrderDiscount;
  double priceBeforeTax;
  String? preferences;
  String? registrationDate;

  factory OrderSaleItemsModel.fromRawJson(String str) =>
      OrderSaleItemsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrderSaleItemsModel.fromJson(Map<String, dynamic> json) =>
      OrderSaleItemsModel(
        id: json["id"],
        idCloud: json["id_cloud"],
        saleId: json["sale_id"],
        productId: json["product_id"],
        productCode: json["product_code"],
        productName: json["product_name"],
        productType: json["product_type"],
        optionId: json["option_id"],
        netUnitPrice: json["net_unit_price"],
        unitPrice: json["unit_price"],
        quantity: json["quantity"],
        quantityToBill: json["quantity_to_bill"],
        quantityDelivered: json["quantity_delivered"],
        warehouseId: json["warehouse_id"],
        itemTax: json["item_tax"],
        taxRateId: json["tax_rate_id"],
        tax: json["tax"],
        itemTax2: json["item_tax_2"],
        taxRate2Id: json["tax_rate_2_id"],
        tax2: json["tax_2"],
        discount: json["discount"],
        itemDiscount: json["item_discount"],
        subtotal: json["subtotal"],
        serialNo: json["serial_no"],
        realUnitPrice: json["real_unit_price"],
        saleItemId: json["sale_item_id"],
        productUnitId: json["product_unit_id"],
        productUnitCode: json["product_unit_code"],
        unitQuantity: json["unit_quantity"],
        comment: json["comment"],
        gst: json["gst"],
        cgst: json["cgst"],
        sgst: json["sgst"],
        igst: json["igst"],
        unitOrderDiscount: json["unit_order_discount"],
        priceBeforeTax: json["price_before_tax"],
        preferences: json["preferences"],
        registrationDate: json["registration_date"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_cloud": idCloud,
        "sale_id": saleId,
        "product_id": productId,
        "product_code": productCode,
        "product_name": productName,
        "product_type": productType,
        "option_id": optionId,
        "net_unit_price": netUnitPrice,
        "unit_price": unitPrice,
        "quantity": quantity,
        "quantity_to_bill": quantityToBill,
        "quantity_delivered": quantityDelivered,
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
        "sale_item_id": saleItemId,
        "product_unit_id": productUnitId,
        "product_unit_code": productUnitCode,
        "unit_quantity": unitQuantity,
        "comment": comment,
        "gst": gst,
        "cgst": cgst,
        "sgst": sgst,
        "igst": igst,
        "unit_order_discount": unitOrderDiscount,
        "price_before_tax": priceBeforeTax,
        "preferences": preferences,
        "registration_date": registrationDate,
      };

  /// Build an instance of  OrderSaleItemsModel given a keys set to get products and units from
  /// order bloc
  static List<Map<String, dynamic>> buildOderSaleItems(List<String> keys) {
    List<Map<String, dynamic>> orderSaleItems = [];
    for (String key in keys) {
      final product = orderBloc.getProducts![key]!;
      final unit = orderBloc.getProductUnits?[key]!;

      final pIVA = product.getPriceWithIVA();
      final pNoIVA = product.getPriceWithoutIVA();
      final taxValue = pIVA - pNoIVA;

      final orderSaleItem = OrderSaleItemsModel(
          productId: product.idCloud,
          productCode: product.code,
          productName: product.name,
          productType: product.type,
          netUnitPrice: product.getPriceWithoutIVA(),
          unitPrice: product.getPriceWithIVA(),
          quantity: product.quantity,
          warehouseId: dataBloc.userData!.warehouseId,
          itemTax: taxValue,
          taxRateId: product.taxRateId,
          productUnitCode: unit?.code,
          realUnitPrice: product.pricePolicyPrices,
          unitQuantity: product.quantity / (unit?.operationValue ?? 1),
          productUnitId: product.unit,
          tax: product.taxRateName,
          subtotal: pIVA * product.quantity);
      orderSaleItems.add(orderSaleItem.toJson());
    }
    return orderSaleItems;
  }
}
