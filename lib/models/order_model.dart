// To parse this JSON data, do
//
//     final orderModel = orderModelFromJson(jsonString);

import 'dart:convert';

// import 'package:pos_wappsi/bloc/orders_bloc.dart';
// import 'package:pos_wappsi/models/user_model.dart';

class OrderModel {
    OrderModel({
        this.idCloud,
        required this.id,
        required this.date,
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
        required this.shipping,
        required this.grandTotal,
        required this.orderStatus,
        this.paymentStatus,
        this.paymentTerm,
        required this.dueDate,
        required this.createdBy,
        this.updatedBy,
        this.updatedAt,
        required this.totalItems,
        required this.pos,
        required this.paid,
        this.returnId,
        required this.surcharge,
        this.attachment,
        this.returnOrderRef,
        this.orderId,
        required this.returnOrderTotal,
        this.rounding,
        this.suspendNote,
        required this.api,
        required this.shop,
        required this.sellerId,
        required this.addressId,
        this.reserveId,
        required this.hash,
        this.manualPayment,
        this.cgst,
        this.sgst,
        this.igst,
        required this.paymentMethod,
        required this.payPartner,
        required this.reteFuentePercentage,
        required this.reteFuenteTotal,
        required this.reteFuenteAccount,
        this.reteFuenteBase,
        required this.reteIvaPercentage,
        required this.reteIvaTotal,
        required this.reteIvaAccount,
        this.reteIvaBase,
        required this.reteIcaPercentage,
        required this.reteIcaTotal,
        required this.reteIcaAccount,
        this.reteIcaBase,
        required this.reteOtherPercentage,
        required this.reteOtherTotal,
        required this.reteOtherAccount,
        this.reteOtherBase,
        this.resolucion,
        required this.documentTypeId,
        this.destinationReferenceNo,
        required this.registrationDate,
        this.wmsPickingStatus,
        this.wmsPackingStatus,
    });

    int? idCloud;
    int id;
    String date;
    String referenceNo;
    int customerId;
    String customer;
    int billerId;
    String biller;
    int warehouseId;
    dynamic note;
    dynamic staffNote;
    int total;
    int productDiscount;
    dynamic orderDiscountId;
    int totalDiscount;
    int orderDiscount;
    int productTax;
    dynamic orderTaxId;
    int orderTax;
    int totalTax;
    int shipping;
    int grandTotal;
    String orderStatus;
    dynamic paymentStatus;
    dynamic paymentTerm;
    String dueDate;
    int createdBy;
    dynamic updatedBy;
    dynamic updatedAt;
    int totalItems;
    int pos;
    int paid;
    dynamic returnId;
    int surcharge;
    dynamic attachment;
    dynamic returnOrderRef;
    dynamic orderId;
    int returnOrderTotal;
    dynamic rounding;
    dynamic suspendNote;
    int api;
    int shop;
    int sellerId;
    int addressId;
    dynamic reserveId;
    String hash;
    dynamic manualPayment;
    dynamic cgst;
    dynamic sgst;
    dynamic igst;
    String paymentMethod;
    int payPartner;
    int reteFuentePercentage;
    int reteFuenteTotal;
    int reteFuenteAccount;
    dynamic reteFuenteBase;
    int reteIvaPercentage;
    int reteIvaTotal;
    int reteIvaAccount;
    dynamic reteIvaBase;
    int reteIcaPercentage;
    int reteIcaTotal;
    int reteIcaAccount;
    dynamic reteIcaBase;
    int reteOtherPercentage;
    int reteOtherTotal;
    int reteOtherAccount;
    dynamic reteOtherBase;
    dynamic resolucion;
    int documentTypeId;
    dynamic destinationReferenceNo;
    String registrationDate;
    dynamic wmsPickingStatus;
    dynamic wmsPackingStatus;

    factory OrderModel.fromRawJson(String str) => OrderModel.fromJson(json.decode(str));

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
        total: json["total"],
        productDiscount: json["product_discount"],
        orderDiscountId: json["order_discount_id"],
        totalDiscount: json["total_discount"],
        orderDiscount: json["order_discount"],
        productTax: json["product_tax"],
        orderTaxId: json["order_tax_id"],
        orderTax: json["order_tax"],
        totalTax: json["total_tax"],
        shipping: json["shipping"],
        grandTotal: json["grand_total"],
        orderStatus: json["Order_status"],
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
        returnOrderRef: json["return_Order_ref"],
        orderId: json["Order_id"],
        returnOrderTotal: json["return_Order_total"],
        rounding: json["rounding"],
        suspendNote: json["suspend_note"],
        api: json["api"],
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
        reteFuentePercentage: json["rete_fuente_percentage"],
        reteFuenteTotal: json["rete_fuente_total"],
        reteFuenteAccount: json["rete_fuente_account"],
        reteFuenteBase: json["rete_fuente_base"],
        reteIvaPercentage: json["rete_iva_percentage"],
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
        documentTypeId: json["document_type_id"],
        destinationReferenceNo: json["destination_reference_no"],
        registrationDate: json["registration_date"],
        wmsPickingStatus: json["wms_picking_status"],
        wmsPackingStatus: json["wms_packing_status"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
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
        "Order_status": orderStatus,
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
        "return_Order_ref": returnOrderRef,
        "Order_id": orderId,
        "return_Order_total": returnOrderTotal,
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
  toString()=>referenceNo;


  /// Build an instance of OrderModel given productDetails, user, customer and
  /// customerAddress
  // static OrderModel buildOrder(
  //     UserModel user, Map<String, dynamic> productsDetails) {
  //   final customer = orderBloc.getCustomer!;
  //   final customerAddress = orderBloc.getCustomerAddresses!;

  //   final today = DateTime.now();
  //   DateTime? dueDate;
  //   return OrderModel(
  //       total: orderBloc.getSubTotal().toInt(),
  //       grandTotal: orderBloc.getSubTotal().toInt(),
  //       customer: orderBloc.getCustomer!.name??orderBloc.getCustomer!.company??'',
  //       customerId: int.parse(orderBloc.getCustomer!.idCloud??'0'),
  //       biller: user.billerName,
  //       billerId: user.billerId,
  //       posNote: orderBloc.getInvoiceNote ?? '',
  //       verifyPrices: orderBloc.getVerifyPrices ?? 1,
  //       sellerId: user.sellerId,
  //       netPrice: productsDetails['net_price'],
  //       quantity: productsDetails['quantity'],
  //       unitPrice: productsDetails['unit_price'],
  //       meanPaymentCodeFe: orderBloc.getPaymentMethod?.codeFe.toString(),
  //       posbiller: user.billerId,
  //       docTypeId: user.documentTypeId ?? 0,
  //       warehouse: user.warehouseId,
  //       seller: user.sellerId,
  //       customer: customer.idCloud!,
  //       productId: productsDetails['product_id'],
  //       staffNote: orderBloc.getDispatchNote ?? '',
  //       addressId: customerAddress.idCloud,
  //       totalItems: orderBloc.getItemsCount(),
  //       productTax: productsDetails['product_tax'],
  //       paymentTerm: null,
  //       duePayment: dueDate == null ? [] : [dueDate.toIso8601String()],
  //       productUnit: productsDetails['product_unit'],
  //       productType: productsDetails['product_type'],
  //       productCode: productsDetails['product_code'],
  //       productName: productsDetails['product_name'],
  //       costCenterId: null,
  //       productTaxVal: productsDetails['product_tax_val'],
  //       realUnitPrice: productsDetails['real_unit_price'],
  //       unitProductTax: productsDetails['unit_product_tax'],
  //       customerBranch: customerAddress.idCloud,
  //       documentTypeId: user.documentTypeId ?? null,
  //       productTaxRate: productsDetails['product_tax_rate'],
  //       productDiscount: productsDetails['product_discount'],
  //       productDiscountVal: productsDetails['product_discount_val'],
  //       productBaseQuantity: productsDetails['product_base_quantity'],
  //       productUnitIdSelected: productsDetails['product_unit_id_selected'],
  //       paymentDocumentTypeId: orderBloc.getPaymentDocument!.idCloud.toString());
  // }
}
