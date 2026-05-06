import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_wappsi/models/local_sales_model.dart';
import 'package:pos_wappsi/providers/local_sale_items_provider.dart';
import 'package:pos_wappsi/providers/payment_provider.dart';

Future<Map<String, dynamic>> getFormatedSale(SalesModel sale) async {
  final saleData = sale.toJson();
  // debugPrint(const JsonEncoder.withIndent('  ').convert(saleData),
  //     wrapWidth: 1024);
  final saleItems = await SaleItemsProvider.loadFromDB(saleData['id']);
  final payments = await PaymentProvider.loadPayment(saleData['id']);

  final totalItems = saleItems.length;

  var dataItems = {
    'product_id': <int>[],
    'product_type': <String>[],
    'product_code': <String>[],
    'product_name': <String>[],
    'product_discount': <String?>[],
    'product_discount_val': <double?>[],
    'product_tax': <int>[],
    'product_tax_rate': <String?>[],
    'unit_product_tax': <double?>[],
    'product_tax_val': <double?>[],
    'product_tax_2': <int?>[],
    'product_tax_rate_2': <String?>[],
    'unit_product_tax_2': <double?>[],
    'product_tax_val_2': <double?>[],
    'net_price': <double?>[],
    'unit_price': <double?>[],
    'real_unit_price': <double?>[],
    'quantity': <double?>[],
    'product_unit': <int?>[],
    'product_preferences_text': <String?>[],
  };

  for (var element in saleItems) {
    dataItems['product_id']!.add(element.productId);
    dataItems['product_type']!.add(element.productType);
    dataItems['product_code']!.add(element.productCode);
    dataItems['product_name']!.add(element.productName);
    dataItems['product_discount']!
        .add(element.discount == '-Infinity%' ? null : element.discount);
    dataItems['product_discount_val']!.add(element.itemDiscount);
    dataItems['product_tax']!.add(element.taxRateId);
    dataItems['product_tax_rate']!.add(element.tax);
    dataItems['unit_product_tax']!.add(element.itemTax);
    dataItems['product_tax_val']!.add(element.itemTax);
    dataItems['product_tax_2']!.add(element.taxRate2Id);
    dataItems['product_tax_rate_2']!.add(element.tax2);
    dataItems['unit_product_tax_2']!.add(0.00);
    dataItems['product_tax_val_2']!.add(element.itemTax2);
    dataItems['net_price']!.add(element.netUnitPrice);
    dataItems['unit_price']!.add(element.unitPrice);
    dataItems['real_unit_price']!.add(element.unitPrice);
    dataItems['quantity']!.add(element.quantity);
    dataItems['product_unit']!.add(element.productUnitId);
    dataItems['product_preferences_text']!.add(element.preferences);
  }

  return {
    'type_pos': '1',
    'test': null,
    'mobile_reference_no': saleData['reference_no'],
    'mobile_date': saleData['date'],
    'posbiller': saleData['biller_id'],
    'doc_type_id': saleData['document_type_id'],
    'warehouse': saleData['warehouse_id'],
    'seller': saleData['seller_id'],
    'created_by': saleData['created_by'],
    'customer': saleData['customer_id'],
    'customer_price_group_id': 1,
    'customer_group_id': 1,
    'customer_branch': sale.addressId,
    'add_item': null,
    'verify_prices': 1,
    'product_ordered_product_id': null,
    'under_cost_authorized': null,
    'product_id': dataItems['product_id'],
    'product_type': dataItems['product_type'],
    'ignore_hide_parameters': null,
    'product_code': dataItems['product_code'],
    'product_name': dataItems['product_name'],
    'product_is_new': null,
    'product_option': null,
    'product_comment': null,
    'state_readiness': null,
    'preparation_area': null,
    'product_discount': dataItems['product_discount'],
    'product_discount_val': dataItems['product_discount_val'],
    'product_tax': dataItems['product_tax'],
    'product_tax_rate': dataItems['product_tax_rate'],
    'unit_product_tax': dataItems['unit_product_tax'],
    'product_tax_val': dataItems['product_tax_val'],
    'product_tax_2': dataItems['product_tax_2'],
    'product_tax_rate_2': dataItems['product_tax_rate_2'],
    'unit_product_tax_2': dataItems['unit_product_tax_2'],
    'product_tax_val_2': dataItems['product_tax_val_2'],
    'net_price': dataItems['net_price'],
    'unit_price': dataItems['unit_price'],
    'real_unit_price': dataItems['real_unit_price'],
    'quantity': dataItems['quantity'],
    'order_sale_origin': sale.saleOrigin,
    'product_unit': dataItems['product_unit'],
    'product_unit_id_selected': dataItems['product_unit'],
    'product_base_quantity': dataItems['quantity'],
    'product_aqty': null,
    'product_preferences_text': dataItems['product_preferences_text'],
    'biller': sale.billerId,
    'pos_note': sale.note,
    'staff_note': sale.staffNote,
    'amount': [
      payments!.posPaid,
    ],
    'balance_amount': [
      payments.posBalance,
    ],
    'due_payment': sale.dueDate != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(sale.dueDate!)
        : null,
    'paid_by': [
      payments.paidBy,
    ],
    'cc_no': payments.ccNo,
    'paying_gift_card_no': payments.ccNo,
    'cc_holder': payments.ccHolder,
    'cheque_no': payments.chequeNo,
    'cc_month': payments.ccMonth,
    'cc_year': payments.ccYear,
    'cc_type': payments.ccType,
    'cc_cvv2': null,
    'payment_note': payments.note,
    'order_tax': sale.orderTax,
    'discount': sale.totalDiscount,
    'shipping': sale.shipping,
    'table_id': sale.restobarTableId,
    'suspend_sale_id': null,
    'rpaidby': null,
    'gtotal_rete_amount': null,
    'total_items': totalItems,
    'payment_term': sale.paymentTerm,
    'document_type_id': sale.documentTypeId,
    'seller_id': sale.sellerId,
    'address_id': sale.addressId,
    'cost_center_id': sale.costCenterId,
    'sale_tip_amount': sale.tipAmount,
    'restobar_mode_module': null,
    'shipping_in_grand_total': sale.shippingInGrandTotal,
    'payment_document_type_id': payments.documentTypeId,
    'restobar_table': sale.restobarTableId,
    'mean_payment_code_fe': payments.meanPaymentCodeFe,
    'except_category_taxes': null,
    'tax_exempt_customer': null,
    'rete_fuente_account': null,
    'rete_fuente_base': null,
    'rete_fuente_id': null,
    'rete_fuente_tax': null,
    'rete_fuente_valor': null,
    'rete_iva_account': null,
    'rete_iva_base': null,
    'rete_iva_id': null,
    'rete_iva_tax': null,
    'rete_iva_valor': null,
    'rete_ica_account': null,
    'rete_ica_base': null,
    'rete_ica_id': null,
    'rete_ica_tax': null,
    'rete_ica_valor': null,
    'rete_otros_account': null,
    'rete_otros_base': null,
    'rete_otros_id': null,
    'rete_otros_tax': null,
    'rete_otros_valor': null,
    'rete_bomberil_account': null,
    'rete_bomberil_base': null,
    'rete_bomberil_id': null,
    'rete_bomberil_tax': null,
    'rete_bomberil_valor': null,
    'rete_autoaviso_account': null,
    'rete_autoaviso_base': null,
    'rete_autoaviso_id': null,
    'rete_autoaviso_tax': null,
    'rete_autoaviso_valor': null,
    'rete_applied': null,
  };
}

/****************************** Lo que se envía ********************************* */
/* {
   "type_pos": 1,
   "test": null,
   "posbiller": 3,
   "doc_type_id": 39,
   "warehouse": 1,
   "seller": 28,
   "created_by": "14",
   "customer": "1",
   "customer_price_group_id": "1",
   "customer_group_id": "1",
   "customer_branch": 6,
   "add_item": null,
   "verify_prices": 1,
   "product_ordered_product_id": null,
   "under_cost_authorized": null,
   "product_id": [
     237
   ],
   "product_type": [
     "standard"
   ],
   "ignore_hide_parameters": null,
   "product_code": [
     "37026328"
   ],
   "product_name": [
     "Aceite de Coco"
   ],
   "product_is_new": null,
   "product_option": null,
   "product_comment": null,
   "state_readiness": null,
   "preparation_area": null,
   "product_discount": [
     0
   ],
   "product_discount_val": [
     0.0
   ],
   "product_tax": [
     1
   ],
   "product_tax_rate": [
     0
   ],
   "unit_product_tax": [
     0.0
   ],
   "product_tax_val": [
     0.0
   ],
   "product_tax_2": null,
   "product_tax_rate_2": null,
   "unit_product_tax_2": null,
   "product_tax_val_2": null,
   "net_price": [
     10000.0
   ],
   "unit_price": [
     10000.0
   ],
   "real_unit_price": [
     10000.0
   ],
   "quantity": [
     1.0
   ],
   "order_sale_origin": 2,
   "product_unit": [
     13
   ],
   "product_unit_id_selected": [
     13
   ],
   "product_base_quantity": [
     1.0
   ],
   "product_aqty": null,
   "product_preferences_text": [
     ""
   ],
   "biller": 3,
   "pos_note": "",
   "staff_note": "",
   "amount": [
     10000
   ],
   "balance_amount": null,
   "due_payment": [],
   "paid_by": [
     "cash"
   ],
   "cc_no": null,
   "paying_gift_card_no": null,
   "cc_holder": null,
   "cheque_no": null,
   "cc_month": null,
   "cc_year": null,
   "cc_type": null,
   "cc_cvv2": null,
   "payment_note": null,
   "order_tax": null,
   "discount": null,
   "shipping": null,
   "table_id": null,
   "suspend_sale_id": null,
   "rpaidby": null,
   "gtotal_rete_amount": null,
   "total_items": 1,
   "payment_term": null,
   "document_type_id": 39,
   "seller_id": 28,
   "address_id": 6,
   "cost_center_id": null,
   "sale_tip_amount": null,
   "restobar_mode_module": null,
   "shipping_in_grand_total": null,
   "payment_document_type_id": "26",
   "restobar_table": null,
   "mean_payment_code_fe": "10",
   "except_category_taxes": null,
   "tax_exempt_customer": null,
   "rete_fuente_account": null,
   "rete_fuente_base": null,
   "rete_fuente_id": null,
   "rete_fuente_tax": null,
   "rete_fuente_valor": null,
   "rete_iva_account": null,
   "rete_iva_base": null,
   "rete_iva_id": null,
   "rete_iva_tax": null,
   "rete_iva_valor": null,
   "rete_ica_account": null,
   "rete_ica_base": null,
   "rete_ica_id": null,
   "rete_ica_tax": null,
   "rete_ica_valor": null,
   "rete_otros_account": null,
   "rete_otros_base": null,
   "rete_otros_id": null,
   "rete_otros_tax": null,
   "rete_otros_valor": null,
   "rete_bomberil_account": null,
   "rete_bomberil_base": null,
   "rete_bomberil_id": null,
   "rete_bomberil_tax": null,
   "rete_bomberil_valor": null,
   "rete_autoaviso_account": null,
   "rete_autoaviso_base": null,
   "rete_autoaviso_id": null,
   "rete_autoaviso_tax": null,
   "rete_autoaviso_valor": null,
   "rete_applied": null
 }*/
