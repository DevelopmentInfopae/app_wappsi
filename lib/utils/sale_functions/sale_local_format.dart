import 'package:intl/intl.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';

double _calculateDiscount({String? discount, dynamic amount}) {
  if (discount != null && discount.isNotEmpty) {
    if (discount.contains('%')) {
      final parts = discount.split('%');
      final percentage = double.tryParse(parts[0]) ?? 0;
      final parsedAmount = double.tryParse(amount.toString()) ?? 0;
      return _formatDecimal((parsedAmount * percentage) / 100);
    } else {
      return _formatDecimal(double.tryParse(discount) ?? 0);
    }
  }
  return 0;
}

double _formatDecimal(double value, {int decimals = 2}) {
  return double.parse(value.toStringAsFixed(decimals));
}

Map<String, dynamic> _getTotalFromItems (sale) {
  var total = 0.0;
  var productDiscount = 0.0;
  var productTax = 0.0;
  var totalItems = 0;

  final netUnitPrices = sale['net_price'];
  final quantitys = sale['product_base_quantity'];
  final productsDiscount = sale['product_discount_val'];
  final unitProductsTax = sale['unit_product_tax'];
  final List? unitProductsTax2 = sale['unit_product_tax_2'];

  for (var i = 0; i < netUnitPrices.length; i++) {
    final netUnitPrice = netUnitPrices[i];
    final quantity = quantitys[i];
    final tax1 = unitProductsTax[i];
    final tax2 = unitProductsTax2 != null ? unitProductsTax2[i] : 0;

    total += (netUnitPrice * quantity);
    productDiscount += productsDiscount[i];
    productTax += (tax1 * quantity);
    productTax += tax2 * quantity;
    totalItems ++;
  }

  return {
    'total'           : total,
    'productDiscount' : productDiscount,
    'productTax'      : productTax,
    'totalItems'      : totalItems,
  };
}

Future<Map<String, dynamic>> formatedSale (sale) async {
  final now = DateTime.now();
  final formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  final totales = _getTotalFromItems(sale);
  final discount = sale['discount'];
  final orderDiscount = _calculateDiscount(discount: discount, amount: totales['total']);
  final totalDiscount = orderDiscount + totales['productDiscount'];
  final granTotal = totales['total'] + totales['productTax'] - totalDiscount;
  final customer = posBloc.getCustomer!.toJson();
  final billerName =  dataBloc.getBillerCompany;
  
  return {
    'status'  : '1',
    'error'   : false,
    'body'    : {
      'sync_status'         : 0,    // Cuando entra en este metodo si o si es local el estado de la sincronización es 0
      'status'              : 201,
      'error'               : false,
      'current_server_date' : formatted,
      'sync'                : false,
      'message'             : 'sale added',
      'data'                : {
        'date'                        : formatted,
        'customer_id'                 : sale['customer'],
        'customer'                    : customer['name'],
        'address_id'                  : sale['address_id'],
        'biller_id'                   : sale['biller'],
        'biller'                      : billerName ?? '',
        'seller_id'                   : sale['seller_id'],
        'warehouse_id'                : sale['warehouse'],
        'note'                        : sale['pos_note'],
        'staff_note'                  : sale['staff_note'],
        'total'                       : totales['total'],
        'product_discount'            : totales['productDiscount'],
        'order_discount_id'           : discount,
        'order_discount'              : orderDiscount,
        'total_discount'              : totalDiscount,
        'product_tax'                 : totales['product_tax'],
        'order_tax_id'                : sale['order_tax'],
        'order_tax'                   : 0, // El servidor lo calcula, no se muestra en el formato
        'total_tax'                   : totales['product_tax'],
        'shipping'                    : sale['shipping'] ?? 0,
        'grand_total'                 : granTotal,
        'payment_term'                : 0,
        'total_items'                 : totales['totalItems'],
        'sale_status'                 : 'completed',
        'payment_status'              : 'due',
        'rounding'                    : 0,
        'suspend_note'                : '',
        'pos'                         : 1,
        'paid'                        : sale['amount'][0],
        'created_by'                  : sale['created_by'],
        'hash'                        : '', // El servidor lo calcula
        'resolucion'                  : '',
        'document_type_id'            : sale['document_type_id'],
        'tip_amount'                  : sale['sale_tip_amount'],
        'shipping_in_grand_total'     : sale['shipping_in_grand_total'],
        'restobar_table_id'           : sale['restobar_table'], 
        'self_withholding_amount'     : 0, // El servidor lo calcula, no se muestra en el formato
        'self_withholding_percentage' : 0, // El servidor lo calcula, no se muestra en el formato
        'sale_origin_reference_no'    : sale['sale_origin_reference_no'],
        'sale_origin'                 : sale['suspend_sale'],
        'sale_currency'               : 'COP',
        'payment_method'              : sale['paid_by'][0],
        'payment_method_fe'           : sale['amount'][0] > 0 ? 1 : 2,
        'payment_mean_fe'             : sale['mean_payment_code_fe'],
        'error'                       : false,
        'message'                     : 'sale added',
        'reference_no'                : sale['mobile_reference_no'],
        'sale_id'                     : 0, 
        'fe_xml'                      : null,
        'cufe'                        : null,
        'fe_aceptado'                 : 0,
        'fe_mensaje'                  : null,
        'fe_mensaje_soporte_tecnico'  : null,
        'fe_validation_dian'          : null,
        'codigo_qr'                   : null,
        'fe_print_footer'             : {
          'technology_provider'         : null,
          'print_footer'                : 'Impreso por Wappsi © 2023  \\n Web Apps Innovation SAS NIT 901.090.070-9  \\n www.wappsi.com'
        }
      } 
    }
  };
}

/****************************** Lo que se espera ******************************** */  
/* 
   "status": 1,
   "error": false,
   "body": {
     "status": 201,
     "error": false,
     "current_server_date": "2026-04-24 08:32:35",
     "sync": false,
     "message": "sale added",
     "data": {
       "date": "2026-04-24 08:32:34",
       "customer_id": "1",
       "customer": "Consumidor Final",
       "address_id": "6",
       "biller_id": "3",
       "biller": "Lacteos Lilianita SUC",
       "seller_id": "28",
       "warehouse_id": "1",
       "note": "",
       "staff_note": "",
       "total": 10000,
       "product_discount": 0,
       "order_discount_id": null,
       "order_discount": 0,
       "total_discount": "0.0000",
       "product_tax": 0,
       "order_tax_id": null,
       "order_tax": 0,
       "total_tax": "0.0000",
       "shipping": "0.0000",
       "grand_total": "10000.00",
       "payment_term": null,
       "total_items": "1",
       "sale_status": "completed",
       "payment_status": "due",
       "rounding": 0,
       "suspend_note": null,
       "pos": 1,
       "paid": 0,
       "created_by": "14",
       "hash": "435002b00e3ccbfea79b5e66f523086f766f221595394c7e785e5c4c6c881d81",
       "resolucion": "",
       "document_type_id": "39",
       "tip_amount": null,
       "shipping_in_grand_total": null,
       "restobar_table_id": null,
       "self_withholding_amount": 0,
       "self_withholding_percentage": 0,
       "sale_origin_reference_no": null,
       "sale_origin": "suspend_sale",
       "sale_currency": "COP",
       "payment_method": "cash",
       "payment_method_fe": 2,
       "payment_mean_fe": "10",
       "error": false,
       "message": "sale added",
       "reference_no": "OP-29",
       "sale_id": 79769,
       "fe_xml": null,
       "cufe": null,
       "fe_aceptado": "0",
       "fe_mensaje": null,
       "fe_mensaje_soporte_tecnico": null,
       "fe_validation_dian": null,
       "codigo_qr": null,
       "fe_print_footer": {
         "technology_provider": null,
         "print_footer": "Impreso por Wappsi © 2023  \\n Web Apps Innovation SAS NIT 901.090.070-9  \\n www.wappsi.com"
       }
     }
   }
 }
*/


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
 }
 */
