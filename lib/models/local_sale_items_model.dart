// To parse this JSON data, do
//
//     final localSaleitems = localSaleitemsFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/providers/local_db_provider.dart';

LocalSaleItems localSaleitemsFromJson(String str) =>
    LocalSaleItems.fromJson(json.decode(str));

String localSaleItemsToJson(LocalSaleItems data) => json.encode(data.toJson());

class LocalSaleItems {
  LocalSaleItems({
    this.id,
    required this.saleId,
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

    /// value of tax, not its percent
    required this.tax,
    this.itemTax2,
    this.taxRate2Id,
    this.tax2,
    this.discount,
    this.itemDiscount,
    required this.subtotal,
    this.serialNo,
    this.realUnitPrice,
    this.saleItemId,
    this.productUnitId,
    this.productUnitCode,
    required this.unitQuantity,
    this.comment,
    this.gst,
    this.cgst,
    this.sgst,
    this.igst,
    this.unitOrderDiscount,
    this.avgNetUnitCost,
    required this.stateReadiness,
    this.preferences,
    required this.priceBeforeTax,
    this.productUnitIdSelected,
    this.consumptionSales,
    this.consumptionSalesCosting,
    this.returnedQuantity,
    this.priceBeforePromo,
    this.registrationDate,
    this.underCostAuthorized,
  });

  int? id;
  int saleId;
  int productId;
  String productCode;
  String productName;
  String productType;
  int? optionId;
  double netUnitPrice;
  double unitPrice;
  double quantity;
  int warehouseId;
  double itemTax;
  int taxRateId;
  String tax;
  int? itemTax2;
  int? taxRate2Id;
  int? tax2;
  String? discount;
  double? itemDiscount;
  double subtotal;
  String? serialNo;
  double? realUnitPrice;
  double? saleItemId;
  int? productUnitId;
  int? productUnitCode;
  double unitQuantity;
  String? comment;
  double? gst;
  double? cgst;
  double? sgst;
  double? igst;
  double? unitOrderDiscount;
  double? avgNetUnitCost;
  int stateReadiness;
  String? preferences;
  double priceBeforeTax;
  int? productUnitIdSelected;
  int? consumptionSales;
  double? consumptionSalesCosting;
  double? returnedQuantity;
  double? priceBeforePromo;
  String? registrationDate;
  int? underCostAuthorized;

  factory LocalSaleItems.fromJson(Map<String, dynamic> json, {int? saleId}) =>
      LocalSaleItems(
        id: json["id"],
        saleId: saleId ?? json["sale_id"],
        productId: json["product_id"],
        productCode: json["product_code"],
        productName: json["product_name"],
        productType: json["product_type"],
        optionId: int.tryParse(json["option_id"].toString()),
        netUnitPrice: double.tryParse(json["net_unit_price"].toString()) ?? 0.0,
        unitPrice: double.tryParse(json["unit_price"].toString()) ?? 0.0,
        quantity: double.tryParse(json["quantity"].toString()) ?? 0.0,
        warehouseId: json["warehouse_id"],
        itemTax: double.tryParse(json["item_tax"].toString()) ?? 0.0,
        taxRateId: json["tax_rate_id"],
        tax: json["tax"],
        itemTax2: json["item_tax_2"],
        taxRate2Id: int.tryParse(json["tax_rate_2_id"].toString()),
        tax2: int.tryParse(json["tax_2"].toString()),
        discount: json["discount"],
        itemDiscount: double.tryParse(json["item_discount"].toString()),
        subtotal: double.tryParse(json["subtotal"].toString()) ?? 0.0,
        serialNo: json["serial_no"],
        realUnitPrice: double.tryParse(json["real_unit_price"].toString()),
        saleItemId: double.tryParse(json["sale_item_id"].toString()),
        productUnitId: int.tryParse(json["product_unit_id"].toString()),
        productUnitCode: int.tryParse(json["product_unit_code"].toString()),
        unitQuantity: double.tryParse(json["unit_quantity"].toString()) ?? 0.0,
        comment: json["comment"],
        gst: double.tryParse(json["gst"].toString()),
        cgst: double.tryParse(json["cgst"].toString()),
        sgst: double.tryParse(json["sgst"].toString()),
        igst: double.tryParse(json["igst"].toString()),
        unitOrderDiscount:
            double.tryParse(json["unit_order_discount"].toString()),
        avgNetUnitCost: double.tryParse(json["avg_net_unit_cost"].toString()),
        stateReadiness: int.tryParse(json["state_readiness"].toString()) ?? 1,
        preferences: json["preferences"],
        priceBeforeTax:
            double.tryParse(json["price_before_tax"].toString()) ?? 0.0,
        productUnitIdSelected:
            int.tryParse(json["product_unit_id_selected"].toString()),
        consumptionSales: int.tryParse(json["consumption_sales"].toString()),
        consumptionSalesCosting:
            double.tryParse(json["consumption_sales_costing"].toString()),
        returnedQuantity: double.tryParse(json["returned_quantity"].toString()),
        priceBeforePromo:
            double.tryParse(json["price_before_promo"].toString()),
        registrationDate: json["registration_date"],
        underCostAuthorized:
            int.tryParse(json["under_cost_authorized"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "sale_id": saleId,
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
        "avg_net_unit_cost": avgNetUnitCost,
        "state_readiness": stateReadiness,
        "preferences": preferences,
        "price_before_tax": priceBeforeTax,
        "product_unit_id_selected": productUnitIdSelected,
        "consumption_sales": consumptionSales,
        "consumption_sales_costing": consumptionSalesCosting,
        "returned_quantity": returnedQuantity,
        "price_before_promo": priceBeforePromo,
        "registration_date": registrationDate ?? '',
        "under_cost_authorized": underCostAuthorized,
      };

  static List<LocalSaleItems> fromJsonList(List<Map> list) {
    List<LocalSaleItems> items = [];
    Map<String, dynamic> temp = {};
    for (var item in list) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      items.add(LocalSaleItems.fromJson(temp));
    }

    return items;

    // prString(temp);
  }

  Future<bool> saveIntoDB(int saleId) async {
    return await DBProvider.db.insertQuery('sma_sale_items', toJson());
  }
}
