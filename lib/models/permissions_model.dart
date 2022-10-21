// To parse this JSON data, do
//
//     final permissionsModel = permissionsModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class PermissionsModel {
  PermissionsModel({
    @required this.productsIndex,
    @required this.productsAdd,
    @required this.productsEdit,
    @required this.productsPrice,
    @required this.salesIndex,
    @required this.salesAdd,
    @required this.purchasesIndex,
    @required this.purchasesAdd,
    @required this.transfersIndex,
    @required this.transfersAdd,
    @required this.customersIndex,
    @required this.customersAdd,
    @required this.customersEdit,
    @required this.suppliersAdd,
    @required this.suppliersEdit,
    @required this.suppliersIndex,
    @required this.salesDeliveries,
    @required this.salesAddDelivery,
    @required this.salesEditDelivery,
    @required this.posIndex,
    @required this.posSales,
    @required this.salesOrders,
    @required this.salesAddOrder,
    @required this.quotesIndex,
    @required this.posPosRegisterAddMovement,
    @required this.posPosRegisterMovements,
    @required this.quotesAdd,
  });

  final int? productsIndex;
  final int? productsAdd;
  final int? productsEdit;
  final int? productsPrice;
  final int? salesIndex;
  final int? salesAdd;
  final int? purchasesIndex;
  final int? purchasesAdd;
  final int? transfersIndex;
  final int? transfersAdd;
  final int? customersIndex;
  final int? customersAdd;
  final int? customersEdit;
  final int? suppliersAdd;
  final int? suppliersIndex;
  final int? suppliersEdit;
  final int? salesDeliveries;
  final int? salesAddDelivery;
  final int? salesEditDelivery;
  final int? posIndex;
  final int? posSales;
  final int? salesOrders;
  final int? salesAddOrder;
  final int? posPosRegisterMovements;
  final int? posPosRegisterAddMovement;
  final int? quotesIndex;
  final int? quotesAdd;

  factory PermissionsModel.fromRawJson(String str) =>
      PermissionsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PermissionsModel.fromJson(Map<String, dynamic> json) =>
      PermissionsModel(
        productsIndex: int.tryParse((json['products-index'] ?? '0').toString()),
        productsAdd: int.tryParse((json['products-add'] ?? '0').toString()),
        productsEdit: int.tryParse((json['products-edit'] ?? '0').toString()),
        productsPrice: int.tryParse((json['products-price'] ?? '0').toString()),
        salesIndex: int.tryParse((json['sales-index'] ?? '0').toString()),
        salesAdd: int.tryParse((json['sales-add'] ?? '0').toString()),
        purchasesIndex:
            int.tryParse((json['purchases-index'] ?? '0').toString()),
        purchasesAdd: int.tryParse((json['purchases-add'] ?? '0').toString()),
        transfersIndex:
            int.tryParse((json['transfers-index'] ?? '0').toString()),
        transfersAdd: int.tryParse((json['transfers-add'] ?? '0').toString()),
        customersIndex:
            int.tryParse((json['customers-index'] ?? '0').toString()),
        customersAdd: int.tryParse((json['customers-add'] ?? '0').toString()),
        customersEdit: int.tryParse((json['customers-edit'] ?? '0').toString()),
        suppliersAdd: int.tryParse((json['suppliers-add'] ?? '0').toString()),
        suppliersEdit: int.tryParse((json['suppliers-edit'] ?? '0').toString()),
        suppliersIndex:
            int.tryParse((json['suppliers-index'] ?? '0').toString()),
        salesDeliveries:
            int.tryParse((json['sales-deliveries'] ?? '0').toString()),
        salesAddDelivery:
            int.tryParse((json['sales-add_delivery'] ?? '0').toString()),
        salesEditDelivery:
            int.tryParse((json['sales-edit_delivery'] ?? '0').toString()),
        posIndex: int.tryParse((json['pos-index'] ?? '0').toString()),
        posSales: int.tryParse((json['pos-sales'] ?? '0').toString()),
        salesOrders: int.tryParse((json['sales-orders'] ?? '0').toString()),
        salesAddOrder:
            int.tryParse((json['sales-add_order'] ?? '0').toString()),
        quotesIndex: int.tryParse((json['quotes-index'] ?? '0').toString()),
        quotesAdd: int.tryParse((json['quotes-add'] ?? '0').toString()),
        posPosRegisterAddMovement: int.tryParse(
          (json['pos-pos_register_add_movement'] ?? '0').toString(),
        ),
        posPosRegisterMovements:
            int.tryParse((json['pos_register_movements'] ?? '0').toString()),
      );

  Map<String, dynamic> toJson() => {
        'products-index': productsIndex,
        'products-add': productsAdd,
        'products-edit': productsEdit,
        'products-price': productsPrice,
        'sales-index': salesIndex,
        'sales-add': salesAdd,
        'purchases-index': purchasesIndex,
        'purchases-add': purchasesAdd,
        'transfers-index': transfersIndex,
        'transfers-add': transfersAdd,
        'customers-index': customersIndex,
        'customers-add': customersAdd,
        'customers-edit': customersEdit,
        'suppliers-add': suppliersAdd,
        'suppliers-edit': suppliersEdit,
        'sales-deliveries': salesDeliveries,
        'sales-add_delivery': salesAddDelivery,
        'sales-edit_delivery': salesEditDelivery,
        'pos-index': posIndex,
        'pos-sales': posSales,
        'sales-orders': salesOrders,
        'sales-add_order': salesAddOrder,
        'quotes-index': quotesIndex,
        'quotes-add': quotesAdd,
        'pos-pos_register_movements': posPosRegisterMovements,
        'pos-pos_register_add_movement': posPosRegisterAddMovement
      };
}
