// To parse this JSON data, do
//
//     final purchaseItemsModel = purchaseItemsModelFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/bloc/purchases_bloc.dart';
import 'package:pos_wappsi/models/user_model.dart';

class PurchaseItemsModel {
  PurchaseItemsModel({
    this.id,
    this.idCloud,
    this.purchaseId,
    this.transferId,
    this.productId,
    this.productCode,
    this.productName,
    this.optionId,
    this.netUnitCost,
    this.quantity,
    this.warehouseId,
    this.itemTax,
    this.taxRateId,
    this.tax,
    this.itemTax2 = 0,
    this.taxRate2Id = 0,
    this.tax2,
    this.discount = 0,
    this.itemDiscount = 0,
    this.expiry,
    this.subtotal,
    this.quantityBalance = 0.0,
    this.date,
    this.status = 'pending',
    this.unitCost,
    this.realUnitCost,
    this.quantityReceived,
    this.supplierPartNo,
    this.purchaseItemId,
    this.productUnitId,
    this.productUnitCode,
    this.unitQuantity,
    this.serialNo,
    this.gst,
    this.cgst,
    this.sgst,
    this.igst,
    this.productUnitIdSelected,
    this.shippingUnitCost = 0.0,
    this.profitabilityMargin = 0.0,
    this.consumptionPurchase = 0,
    this.returnedQuantity = 0.0,
    this.registrationDate,
    this.expenseCategoryCreditorLedgerId,
    // this.calculatedAvgCost,
  });

  int? id;
  int? idCloud;
  dynamic purchaseId;
  dynamic transferId;
  int? productId;
  String? productCode;
  String? productName;
  dynamic optionId;
  double? netUnitCost;
  double? quantity;
  int? warehouseId;
  double? itemTax;
  dynamic taxRateId;
  dynamic tax;
  dynamic itemTax2;
  dynamic taxRate2Id;
  dynamic tax2;
  dynamic discount;
  dynamic itemDiscount;
  dynamic expiry;
  double? subtotal;
  double? quantityBalance;
  String? date;
  String? status;
  dynamic unitCost;
  dynamic realUnitCost;
  dynamic quantityReceived;
  dynamic supplierPartNo;
  dynamic purchaseItemId;
  dynamic productUnitId;
  dynamic productUnitCode;
  double? unitQuantity;
  dynamic serialNo;
  dynamic gst;
  dynamic cgst;
  dynamic sgst;
  dynamic igst;
  dynamic productUnitIdSelected;
  double? shippingUnitCost;
  double? profitabilityMargin;
  dynamic consumptionPurchase;
  double? returnedQuantity;
  String? registrationDate;
  dynamic expenseCategoryCreditorLedgerId;
  // dynamic calculatedAvgCost;

  factory PurchaseItemsModel.fromRawJson(String str) =>
      PurchaseItemsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PurchaseItemsModel.fromJson(Map<String, dynamic> json) =>
      PurchaseItemsModel(
        id: json['id'],
        purchaseId: json['purchase_id'],
        transferId: json['transfer_id'],
        productId: json['product_id'],
        productCode: json['product_code'],
        productName: json['product_name'],
        optionId: json['option_id'],
        netUnitCost: json['net_unit_cost'],
        quantity: json['quantity'],
        warehouseId: json['warehouse_id'],
        itemTax: json['item_tax'],
        taxRateId: json['tax_rate_id'],
        tax: json['tax'],
        itemTax2: json['item_tax_2'],
        taxRate2Id: json['tax_rate_2_id'],
        tax2: json['tax_2'],
        discount: json['discount'],
        itemDiscount: json['item_discount'],
        expiry: json['expiry'],
        subtotal: json['subtotal'],
        quantityBalance: json['quantity_balance'],
        date: json['date'],
        status: json['status'],
        unitCost: json['unit_cost'],
        realUnitCost: json['real_unit_cost'],
        quantityReceived: json['quantity_received'],
        supplierPartNo: json['supplier_part_no'],
        purchaseItemId: json['purchase_item_id'],
        productUnitId: json['product_unit_id'],
        productUnitCode: json['product_unit_code'],
        unitQuantity: json['unit_quantity'],
        serialNo: json['serial_no'],
        gst: json['gst'],
        cgst: json['cgst'],
        sgst: json['sgst'],
        igst: json['igst'],
        productUnitIdSelected: json['product_unit_id_selected'],
        shippingUnitCost: json['shipping_unit_cost'],
        profitabilityMargin: json['profitability_margin'],
        consumptionPurchase: json['consumption_purchase'],
        returnedQuantity: json['returned_quantity'],
        registrationDate: json['registration_date'],
        expenseCategoryCreditorLedgerId:
            json['expense_category_creditor_ledger_id'],
        // calculatedAvgCost: json["calculated_avg_cost"],
      );

  Map<String, dynamic> toJson({bool toSend = false}) {
    if (toSend) {
      return {
        'product_id': productId,
        'product_code': productCode,
        'product_name': productName,
        'option_id': optionId,
        'net_unit_cost': netUnitCost,
        'quantity': quantity,
        'warehouse_id': warehouseId,
        'item_tax': itemTax,
        'tax_rate_id': taxRateId,
        'tax': tax,
        'item_tax_2': itemTax2,
        'tax_rate_2_id': taxRate2Id,
        'tax_2': tax2,
        'discount': discount,
        'item_discount': itemDiscount,
        'expiry': expiry,
        'subtotal': subtotal,
        'quantity_balance': quantityBalance,
        'date': date,
        'status': status,
        'unit_cost': unitCost,
        'real_unit_cost': realUnitCost,
        'quantity_received': quantityReceived,
        'supplier_part_no': supplierPartNo,
        'purchase_item_id': purchaseItemId,
        'product_unit_id': productUnitId,
        'product_unit_code': productUnitCode,
        'unit_quantity': unitQuantity,
        'serial_no': serialNo,
        'gst': gst,
        'cgst': cgst,
        'sgst': sgst,
        'igst': igst,
        'product_unit_id_selected': productUnitIdSelected,
        'shipping_unit_cost': shippingUnitCost,
        'profitability_margin': profitabilityMargin,
        'consumption_purchase': consumptionPurchase,
        'returned_quantity': returnedQuantity,
        'registration_date': registrationDate,
        'expense_category_creditor_ledger_id': expenseCategoryCreditorLedgerId,
        // "calculated_avg_cost": calculatedAvgCost,
      };
    } else {
      return {
        'id': id,
        'id_cloud': idCloud,
        'purchase_id': purchaseId,
        'transfer_id': transferId,
        'product_id': productId,
        'product_code': productCode,
        'product_name': productName,
        'option_id': optionId,
        'net_unit_cost': netUnitCost,
        'quantity': quantity,
        'warehouse_id': warehouseId,
        'item_tax': itemTax,
        'tax_rate_id': taxRateId,
        'tax': tax,
        'item_tax_2': itemTax2,
        'tax_rate_2_id': taxRate2Id,
        'tax_2': tax2,
        'discount': discount,
        'item_discount': itemDiscount,
        'expiry': expiry,
        'subtotal': subtotal,
        'quantity_balance': quantityBalance,
        'date': date,
        'status': status,
        'unit_cost': unitCost,
        'real_unit_cost': realUnitCost,
        'quantity_received': quantityReceived,
        'supplier_part_no': supplierPartNo,
        'purchase_item_id': purchaseItemId,
        'product_unit_id': productUnitId,
        'product_unit_code': productUnitCode,
        'unit_quantity': unitQuantity,
        'serial_no': serialNo,
        'gst': gst,
        'cgst': cgst,
        'sgst': sgst,
        'igst': igst,
        'product_unit_id_selected': productUnitIdSelected,
        'shipping_unit_cost': shippingUnitCost,
        'profitability_margin': profitabilityMargin,
        'consumption_purchase': consumptionPurchase,
        'returned_quantity': returnedQuantity,
        'registration_date': registrationDate,
        'expense_category_creditor_ledger_id': expenseCategoryCreditorLedgerId,
        // "calculated_avg_cost": calculatedAvgCost,
      };
    }
  }

  static List<PurchaseItemsModel> fromJsonList(List<Map> list) {
    List<PurchaseItemsModel> purchases = [];
    Map<String, dynamic> temp = {};
    for (var item in list) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      purchases.add(PurchaseItemsModel.fromJson(temp));
    }

    return purchases;

    // prString(temp);
  }

  /// Build a list of PurchaseItemsModel given a keys set to get products and units from
  /// purchase bloc and returns a List of Mapped PurchaseItemsModel
  static List<Map<String, dynamic>> buildPurchaseSaleItems(
    List<String> keys,
    UserModel user,
    String date,
  ) {
    List<Map<String, dynamic>> orderSaleItems = [];
    for (String key in keys) {
      final product = purchaseBloc.getProducts![key]!;
      final unit = purchaseBloc.getProductUnits?[key]!;

      final pIVA = product.getCostWithIVA();
      final pNoIVA = product.getCOstWithoutIVA();
      final taxValue = pIVA - pNoIVA;

      final orderSaleItem = PurchaseItemsModel(
        productId: product.idCloud,
        productCode: product.code,
        productName: product.name,
        date: date,
        quantity: product.quantity,
        quantityBalance: product.quantity,
        quantityReceived: product.quantity,
        warehouseId: user.warehouseId,
        unitCost: pIVA,
        realUnitCost: pIVA,
        netUnitCost: pNoIVA,
        itemTax: taxValue,
        taxRateId: product.taxRateId,
        productUnitCode: unit?.code,
        unitQuantity: product.quantity / (unit?.operationValue ?? 1),
        productUnitId: unit?.idCloud ?? product.unit,
        productUnitIdSelected: unit?.idCloud ?? product.unit,
        tax: product.taxRateName,
        subtotal: pIVA * product.quantity,
      );
      orderSaleItems.add(orderSaleItem.toJson(toSend: true));
    }
    return orderSaleItems;
  }
}
