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
  int quantity;
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
  int unitQuantity;
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
        id: json["id"] ?? null,
        saleId: saleId ?? json["sale_id"],
        productId: json["product_id"],
        productCode: json["product_code"],
        productName: json["product_name"],
        productType: json["product_type"],
        optionId: json["option_id"] ?? null,
        netUnitPrice: json["net_unit_price"].toDouble(),
        unitPrice: json["unit_price"].toDouble(),
        quantity: json["quantity"],
        warehouseId: json["warehouse_id"],
        itemTax: json["item_tax"].toDouble(),
        taxRateId: json["tax_rate_id"],
        tax: json["tax"],
        itemTax2: json["item_tax_2"] ?? null,
        taxRate2Id: json["tax_rate_2_id"] ?? null,
        tax2: json["tax_2"] ?? null,
        discount: json["discount"] ?? null,
        itemDiscount: json["item_discount"] ?? null,
        subtotal: json["subtotal"].toDouble() ?? null,
        serialNo: json["serial_no"] ?? null,
        realUnitPrice: json["real_unit_price"] ?? null,
        saleItemId: json["sale_item_id"] ?? null,
        productUnitId: json["product_unit_id"] ?? null,
        productUnitCode: json["product_unit_code"] ?? null,
        unitQuantity: json["unit_quantity"],
        comment: json["comment"] ?? null,
        gst: json["gst"] ?? null,
        cgst: json["cgst"] ?? null,
        sgst: json["sgst"] ?? null,
        igst: json["igst"] ?? null,
        unitOrderDiscount: json["unit_order_discount"] ?? null,
        avgNetUnitCost: json["avg_net_unit_cost"] ?? null,
        stateReadiness: json["state_readiness"] ?? 1,
        preferences: json["preferences"] ?? null,
        priceBeforeTax: json["price_before_tax"].toDouble(),
        productUnitIdSelected: json["product_unit_id_selected"] ?? null,
        consumptionSales: json["consumption_sales"] ?? null,
        consumptionSalesCosting: json["consumption_sales_costing"] ?? null,
        returnedQuantity: json["returned_quantity"] ?? null,
        priceBeforePromo: json["price_before_promo"] ?? null,
        registrationDate: json["registration_date"] ?? null,
        underCostAuthorized: json["under_cost_authorized"] ?? null,
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
    list.forEach((item) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      items.add(LocalSaleItems.fromJson(temp));
    });

    return items;

    // prString(temp);
  }

  Future<bool> saveIntoDB(int saleId) async {
    return await DBProvider.db.insertQuery('sma_sale_items', toJson());
  }

  static Future<List<LocalSaleItems>> loadFromDB(int saleId) async {
    final res = await DBProvider.db
        .sqlQuery('sma_sale_items', where: 'sale_id=$saleId');
    if (res != null) {
      return LocalSaleItems.fromJsonList(res);
    } else {
      return [];
    }
  }

  static Future<bool> saveAllIntoDB(
      List<Map<String, dynamic>> productsDetails, int saleId) async {
    List<Map<String, dynamic>> productsD = [];
    productsDetails.forEach((pD) {
      productsD.add(LocalSaleItems.fromJson(pD, saleId: saleId).toJson());
    });
    return await DBProvider.db.insertQuerys('sma_sale_items', productsD);
  }
}
