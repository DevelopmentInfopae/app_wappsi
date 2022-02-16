// To parse this JSON data, do
//
//     final orderModel = orderModelFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/orders_bloc.dart';
import 'package:pos_wappsi/models/user_model.dart';
import 'package:pos_wappsi/providers/biller_data_provider.dart';
import 'package:pos_wappsi/providers/companies_provider.dart';
import 'package:pos_wappsi/providers/customer_addresses_provider.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/order_sale_items_provider.dart';
import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

// import 'package:pos_wappsi/bloc/orders_bloc.dart';
// import 'package:pos_wappsi/models/user_model.dart';

class OrderModel {
  OrderModel({
    this.idCloud,
    this.id,
    this.date,
    required this.referenceNo,
    required this.customerId,
    required this.customer,
    required this.billerId,
    required this.biller,
    required this.warehouseId,
    this.note,
    this.staffNote,
    required this.total,
    required this.productDiscount,
    this.orderDiscountId,
    required this.totalDiscount,
    required this.orderDiscount,
    required this.productTax,
    this.orderTaxId,
    required this.orderTax,
    required this.totalTax,
    this.shipping,
    required this.grandTotal,
    required this.saleStatus,
    this.paymentStatus,
    this.paymentTerm,
    required this.dueDate,
    required this.createdBy,
    this.updatedBy,
    this.updatedAt,
    required this.totalItems,
    this.pos,
    this.paid = 0,
    this.returnId,
    this.surcharge,
    this.attachment,
    this.returnSaleRef,
    this.saleId,
    this.returnSaleTotal = 0,
    this.rounding,
    this.suspendNote,
    this.api,
    required this.shop,
    required this.sellerId,
    required this.addressId,
    this.reserveId,
    this.hash,
    this.manualPayment,
    this.cgst,
    this.sgst,
    this.igst,
    this.paymentMethod,
    required this.payPartner,
    this.reteFuentePercentage,
    this.reteFuenteTotal,
    this.reteFuenteAccount,
    this.reteFuenteBase,
    this.reteIvaPercentage,
    this.reteIvaTotal,
    this.reteIvaAccount,
    this.reteIvaBase,
    this.reteIcaPercentage,
    this.reteIcaTotal,
    this.reteIcaAccount,
    this.reteIcaBase,
    this.reteOtherPercentage,
    this.reteOtherTotal,
    this.reteOtherAccount,
    this.reteOtherBase,
    this.resolucion,
    required this.documentTypeId,
    this.destinationReferenceNo,
    this.registrationDate,
    this.wmsPickingStatus,
    this.wmsPackingStatus,
  });

  int? idCloud;
  int? id;
  String? date;
  String? referenceNo;
  int customerId;
  String customer;
  int billerId;
  String biller;
  int warehouseId;
  dynamic note;
  dynamic staffNote;
  double? total;
  double productDiscount;
  dynamic orderDiscountId;
  double totalDiscount;
  double orderDiscount;
  double productTax;
  dynamic orderTaxId;
  int orderTax;
  double totalTax;
  double? shipping;
  double grandTotal;
  String saleStatus;
  dynamic paymentStatus;
  dynamic paymentTerm;
  String? dueDate;
  int createdBy;
  dynamic updatedBy;
  dynamic updatedAt;
  int totalItems;
  int? pos;
  int paid;
  dynamic returnId;
  int? surcharge;
  dynamic attachment;
  dynamic returnSaleRef;
  dynamic saleId;
  int? returnSaleTotal;
  dynamic rounding;
  dynamic suspendNote;
  int? api;
  int shop;
  int sellerId;
  int addressId;
  dynamic reserveId;
  String? hash;
  dynamic manualPayment;
  dynamic cgst;
  dynamic sgst;
  dynamic igst;
  String? paymentMethod;
  int? payPartner;
  int? reteFuentePercentage;
  int? reteFuenteTotal;
  int? reteFuenteAccount;
  dynamic reteFuenteBase;
  double? reteIvaPercentage;
  dynamic reteIvaTotal;
  dynamic reteIvaAccount;
  dynamic reteIvaBase;
  dynamic reteIcaPercentage;
  dynamic reteIcaTotal;
  dynamic reteIcaAccount;
  dynamic reteIcaBase;
  dynamic reteOtherPercentage;
  dynamic reteOtherTotal;
  dynamic reteOtherAccount;
  dynamic reteOtherBase;
  dynamic resolucion;
  String documentTypeId;
  dynamic destinationReferenceNo;
  String? registrationDate;
  dynamic wmsPickingStatus;
  dynamic wmsPackingStatus;

  factory OrderModel.fromRawJson(String str) =>
      OrderModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        idCloud: json["id_cloud"],
        id: json["id"],
        date: json["date"],
        referenceNo: json["reference_no"],
        customerId: json["customer_id"],
        customer: json["customer"],
        billerId: json["biller_id"],
        biller: json["biller"],
        warehouseId: json["warehouse_id"],
        note: json["note"],
        staffNote: json["staff_note"],
        total: double.tryParse(json["total"].toString()),
        productDiscount:
            double.tryParse(json["product_discount"].toString()) ?? 0.0,
        orderDiscountId: json["order_discount_id"],
        totalDiscount:
            double.tryParse(json["total_discount"].toString()) ?? 0.0,
        orderDiscount:
            double.tryParse(json["order_discount"].toString()) ?? 0.0,
        productTax: double.tryParse(json["product_tax"].toString()) ?? 0.0,
        orderTaxId: json["order_tax_id"],
        orderTax: json["order_tax"],
        totalTax: double.tryParse(json["total_tax"].toString()) ?? 0.0,
        shipping: double.tryParse(json["shipping"].toString()),
        grandTotal: double.tryParse(json["grand_total"].toString()) ?? 0.0,
        saleStatus: json["sale_status"],
        paymentStatus: json["payment_status"],
        paymentTerm: json["payment_term"],
        dueDate: json["due_date"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        updatedAt: json["updated_at"],
        totalItems: json["total_items"],
        pos: json["pos"],
        paid: json["paid"],
        returnId: json["return_id"],
        surcharge: json["surcharge"],
        attachment: json["attachment"],
        returnSaleRef: json["return_sale_ref"],
        saleId: json["sale_id"],
        returnSaleTotal: json["return_order_total"],
        rounding: json["rounding"],
        suspendNote: json["suspend_note"],
        api: int.tryParse(json["api"].toString()),
        shop: json["shop"],
        sellerId: json["seller_id"],
        addressId: json["address_id"],
        reserveId: json["reserve_id"],
        hash: json["hash"],
        manualPayment: json["manual_payment"],
        cgst: json["cgst"],
        sgst: json["sgst"],
        igst: json["igst"],
        paymentMethod: json["payment_method"],
        payPartner: json["pay_partner"],
        reteFuentePercentage:
            int.tryParse(json["rete_fuente_percentage"].toString()),
        reteFuenteTotal: int.tryParse(json["rete_fuente_total"].toString()),
        reteFuenteAccount: int.tryParse(json["rete_fuente_account"].toString()),
        reteFuenteBase: json["rete_fuente_base"],
        reteIvaPercentage:
            double.tryParse(json["rete_iva_percentage"].toString()),
        reteIvaTotal: json["rete_iva_total"],
        reteIvaAccount: json["rete_iva_account"],
        reteIvaBase: json["rete_iva_base"],
        reteIcaPercentage: json["rete_ica_percentage"],
        reteIcaTotal: json["rete_ica_total"],
        reteIcaAccount: json["rete_ica_account"],
        reteIcaBase: json["rete_ica_base"],
        reteOtherPercentage: json["rete_other_percentage"],
        reteOtherTotal: json["rete_other_total"],
        reteOtherAccount: json["rete_other_account"],
        reteOtherBase: json["rete_other_base"],
        resolucion: json["resolucion"],
        documentTypeId: json["document_type_id"].toString(),
        destinationReferenceNo: json["destination_reference_no"],
        registrationDate: json["registration_date"],
        wmsPickingStatus: json["wms_picking_status"],
        wmsPackingStatus: json["wms_packing_status"],
      );

  Map<String, dynamic> toJson({bool toCreateOrder = true}) {
    if (toCreateOrder) {
      return {
        "reference_no": referenceNo,
        "customer_id": customerId,
        "customer": customer,
        "biller_id": billerId,
        "biller": biller,
        "warehouse_id": warehouseId,
        "note": note,
        "staff_note": staffNote,
        "total": total,
        "product_discount": productDiscount,
        "order_discount_id": orderDiscountId,
        "total_discount": totalDiscount,
        "order_discount": orderDiscount,
        "product_tax": productTax,
        "order_tax_id": orderTaxId,
        "order_tax": orderTax,
        "total_tax": totalTax,
        "shipping": shipping,
        "grand_total": grandTotal,
        "sale_status": saleStatus,
        "payment_status": paymentStatus,
        "payment_term": paymentTerm,
        "due_date": dueDate,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "updated_at": updatedAt,
        "total_items": totalItems,
        "pos": pos,
        "paid": paid,
        "return_id": returnId,
        "surcharge": surcharge,
        "attachment": attachment,
        "return_sale_ref": returnSaleRef,
        "sale_id": saleId,
        "return_sale_total": returnSaleTotal,
        "rounding": rounding,
        "suspend_note": suspendNote,
        "api": api,
        "shop": shop,
        "seller_id": sellerId,
        "address_id": addressId,
        "reserve_id": reserveId,
        "hash": hash,
        "manual_payment": manualPayment,
        "cgst": cgst,
        "sgst": sgst,
        "igst": igst,
        "payment_method": paymentMethod,
        "pay_partner": payPartner,
        "rete_fuente_percentage": reteFuentePercentage,
        "rete_fuente_total": reteFuenteTotal,
        "rete_fuente_account": reteFuenteAccount,
        "rete_fuente_base": reteFuenteBase,
        "rete_iva_percentage": reteIvaPercentage,
        "rete_iva_total": reteIvaTotal,
        "rete_iva_account": reteIvaAccount,
        "rete_iva_base": reteIvaBase,
        "rete_ica_percentage": reteIcaPercentage,
        "rete_ica_total": reteIcaTotal,
        "rete_ica_account": reteIcaAccount,
        "rete_ica_base": reteIcaBase,
        "rete_other_percentage": reteOtherPercentage,
        "rete_other_total": reteOtherTotal,
        "rete_other_account": reteOtherAccount,
        "rete_other_base": reteOtherBase,
        "resolucion": resolucion,
        "document_type_id": documentTypeId,
        "destination_reference_no": destinationReferenceNo,
        "wms_picking_status": wmsPickingStatus,
        "wms_packing_status": wmsPackingStatus,
      };
    } else {
      return {
        "id": id,
        "id_cloud": idCloud,
        "date": date,
        "reference_no": referenceNo,
        "customer_id": customerId,
        "customer": customer,
        "biller_id": billerId,
        "biller": biller,
        "warehouse_id": warehouseId,
        "note": note,
        "staff_note": staffNote,
        "total": total,
        "product_discount": productDiscount,
        "order_discount_id": orderDiscountId,
        "total_discount": totalDiscount,
        "order_discount": orderDiscount,
        "product_tax": productTax,
        "order_tax_id": orderTaxId,
        "order_tax": orderTax,
        "total_tax": totalTax,
        "shipping": shipping,
        "grand_total": grandTotal,
        "sale_status": saleStatus,
        "payment_status": paymentStatus,
        "payment_term": paymentTerm,
        "due_date": dueDate,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "updated_at": updatedAt,
        "total_items": totalItems,
        "pos": pos,
        "paid": paid,
        "return_id": returnId,
        "surcharge": surcharge,
        "attachment": attachment,
        "return_sale_ref": returnSaleRef,
        "sale_id": saleId,
        "return_sale_total": returnSaleTotal,
        "rounding": rounding,
        "suspend_note": suspendNote,
        "api": api,
        "shop": shop,
        "seller_id": sellerId,
        "address_id": addressId,
        "reserve_id": reserveId,
        "hash": hash,
        "manual_payment": manualPayment,
        "cgst": cgst,
        "sgst": sgst,
        "igst": igst,
        "payment_method": paymentMethod,
        "pay_partner": payPartner,
        "rete_fuente_percentage": reteFuentePercentage,
        "rete_fuente_total": reteFuenteTotal,
        "rete_fuente_account": reteFuenteAccount,
        "rete_fuente_base": reteFuenteBase,
        "rete_iva_percentage": reteIvaPercentage,
        "rete_iva_total": reteIvaTotal,
        "rete_iva_account": reteIvaAccount,
        "rete_iva_base": reteIvaBase,
        "rete_ica_percentage": reteIcaPercentage,
        "rete_ica_total": reteIcaTotal,
        "rete_ica_account": reteIcaAccount,
        "rete_ica_base": reteIcaBase,
        "rete_other_percentage": reteOtherPercentage,
        "rete_other_total": reteOtherTotal,
        "rete_other_account": reteOtherAccount,
        "rete_other_base": reteOtherBase,
        "resolucion": resolucion,
        "document_type_id": documentTypeId,
        "destination_reference_no": destinationReferenceNo,
        "registration_date": registrationDate,
        "wms_picking_status": wmsPickingStatus,
        "wms_packing_status": wmsPackingStatus,
      };
    }
  }

  static List<OrderModel> fromJsonList(List<Map> list) {
    List<OrderModel> orders = [];
    Map<String, dynamic> temp = {};
    for (var item in list) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      orders.add(OrderModel.fromJson(temp));
    }

    return orders;

    // prString(temp);
  }

  @override
  toString() => referenceNo ?? '';

  /// Build an instance of OrderModel given productDetails, user, customer and
  /// customerAddress
  static OrderModel buildOrder(
      UserModel user, Map<String, dynamic> productsDetails) {
    return OrderModel(
        // here we add order tax if needed
        totalTax: productsDetails['product_total_tax'],
        saleStatus: 'pending',
        referenceNo: null,
        pos: 0,
        surcharge: 0,
        orderTax: 0,
        total: orderBloc.getSubTotalWithoutDiscount(),
        grandTotal: orderBloc.getSubTotal(),
        orderDiscount: orderBloc.getOrderDiscount,
        customer:
            orderBloc.getCustomer!.name ?? orderBloc.getCustomer!.company ?? '',
        customerId: int.parse(orderBloc.getCustomer!.idCloud ?? '0'),
        biller: user.billerName,
        billerId: user.billerId,
        note: orderBloc.getOrderNote ?? '',
        sellerId: user.sellerId,
        warehouseId: user.warehouseId,
        createdBy: int.parse(dataBloc.userData!.id),
        // paymentMethod: orderBloc.getPaymentMethod!.idCloud,
        dueDate: null,
        staffNote: orderBloc.getInternalNote ?? '',
        addressId: orderBloc.getCustomerAddresses!.idCloud,
        totalItems: orderBloc.getItemsCount(),
        productTax: productsDetails['product_total_tax'],
        paymentTerm: null,
        documentTypeId: orderBloc.getOrderDocumentType?.idCloud ?? '',
        productDiscount: productsDetails['product_total_discount'],
        totalDiscount: productsDetails['product_total_discount'] +
            orderBloc.getOrderDiscount,
        shop: 0,
        payPartner: 0);
  }

  Future<Map> buildPrintDataMap() async {
    final customer =
        await CompaniesProvider.getCompanyById(customerId.toString());
    final biller = await CompaniesProvider.getCompanyById(billerId.toString());
    final billerData =
        await BillerDataProvider.loadBillerDataId(billerId.toString());
    final customerAddress = await CustomerAddressesProvider.loadCustomerAddress(
        addressId.toString());
    // Load only first sale payment

    final settings = dataBloc.settings;
    final docDetails =
        await DBProvider.db.getDocumentDetails(documentTypeId.toString());
    final temp = removeRareSpaceChr(docDetails?['invoice_footer'] ?? '');

    final productsInfo = await _productsMap(idCloud!);

    return {
      "products": productsInfo['products'],
      "customer": customer?.toJson() ?? {},
      "customer_address": customerAddress?.toJson() ?? {},
      "order_data": {
        'reference_no': referenceNo,
        'resolucion': resolucion,
        'date': registrationDate
      },
      "pos_note": note ?? '',
      "total": total,
      "grand_total": grandTotal,
      "products_discount": productDiscount,
      "order_discount": orderDiscount,
      "total_discount": totalDiscount,
      "iva": productsInfo['iva'],
      "company_data": biller,
      "biller_data": billerData,
      "settings": settings,
      "footer": temp
    };
  }

  static Future<Map<String, dynamic>> _productsMap(int saleId) async {
    final saleItems = await OrderSaleItemsProvider.loadFromDB(saleId);

    List<Map<String, dynamic>> productsMap = [];
    Map<double, dynamic> ivasMap = {};
    try {
      for (var item in saleItems) {
        final unit = await UnitsProvider.getUnitInfo(item.productUnitId);
        final bUnit = await UnitsProvider.getUnitInfo(unit?.baseUnit);
        final tItempMap = {
          'quantity': item.quantity,
          'price': item.unitPrice,
          'name': item.productName,
          'unit': unit,
          'base_unit': bUnit
        };
        productsMap.add(tItempMap);
        final taxRate = (item.unitPrice / item.netUnitPrice) - 1;
        if (ivasMap.containsKey(taxRate)) {
          ivasMap[taxRate]['value'] =
              ivasMap[taxRate]['value'] + (item.priceBeforeTax * item.quantity);
        } else {
          ivasMap[taxRate] = {
            'value': (item.priceBeforeTax * item.quantity),
            'name': item.tax
          };
        }
      }
    } catch (e) {
      printConsole(e);
      return {};
    }
    return {
      'iva': ivasMap,
      'products': productsMap,
    };
  }
}
