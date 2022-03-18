// To parse this JSON data, do
//
//     final QuoteModel = QuoteModelFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/quotes_bloc.dart';
import 'package:pos_wappsi/models/user_model.dart';
import 'package:pos_wappsi/providers/biller_data_provider.dart';
import 'package:pos_wappsi/providers/companies_provider.dart';
import 'package:pos_wappsi/providers/customer_addresses_provider.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/quote_items_provider.dart';
import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

// import 'package:pos_wappsi/bloc/orders_bloc.dart';
// import 'package:pos_wappsi/models/user_model.dart';

class QuoteModel {
  QuoteModel({
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
    this.internalNote,
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
    required this.status,
    required this.createdBy,
    this.updatedBy,
    this.updatedAt,
    this.attachment,
    required this.sellerId,
    required this.addressId,
    this.supplierId,
    this.hash,
    this.cgst,
    this.sgst,
    this.igst,
    this.supplier,
    this.quoteCurrency,
    this.quoteCurrencyTrm,
    this.quoteType,
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
    required this.documentTypeId,
    this.destinationReferenceNo,
    this.paymentStatus,
    this.paymentTerm,
    this.paymentMethod,
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
  dynamic internalNote;
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
  String status;
  int createdBy;
  dynamic updatedBy;
  dynamic updatedAt;
  dynamic attachment;
  int sellerId;
  int? paymentStatus;
  int? paymentTerm;
  int addressId;
  int? supplierId;
  String? supplier;
  String? hash;
  dynamic cgst;
  dynamic sgst;
  dynamic igst;
  String? quoteCurrency;
  double? quoteCurrencyTrm;
  int? quoteType;
  int? reteFuentePercentage;
  int? reteFuenteTotal;
  int? reteFuenteAccount;
  dynamic reteFuenteBase;
  dynamic paymentMethod;
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
  String documentTypeId;
  dynamic destinationReferenceNo;

  factory QuoteModel.fromRawJson(String str) =>
      QuoteModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory QuoteModel.fromJson(Map<String, dynamic> json) => QuoteModel(
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
        internalNote: json["internal_note"],
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
        status: json["status"],
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        updatedAt: json["updated_at"],
        attachment: json["attachment"],
        sellerId: json["seller_id"],
        addressId: json["address_id"],
        supplierId: json["supplier_id"],
        hash: json["hash"],
        cgst: json["cgst"],
        sgst: json["sgst"],
        igst: json["igst"],
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
        documentTypeId: json["document_type_id"].toString(),
        destinationReferenceNo: json["destination_reference_no"],
        paymentMethod: json["payment_method"],
      );

  Map<String, dynamic> toJson({bool toCreateQuote = true}) {
    if (toCreateQuote) {
      return {
        "reference_no": referenceNo,
        "customer_id": customerId,
        "customer": customer,
        "biller_id": billerId,
        "biller": biller,
        "warehouse_id": warehouseId,
        "note": note,
        "internal_note": internalNote,
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
        "status": status,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "updated_at": updatedAt,
        "attachment": attachment,
        "seller_id": sellerId,
        "address_id": addressId,
        "supplier_id": supplierId,
        "hash": hash,
        "cgst": cgst,
        "sgst": sgst,
        "igst": igst,
        "quote_currency": quoteCurrency,
        "quote_currency_trm": quoteCurrencyTrm,
        "quote_type": quoteType,
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
        "document_type_id": documentTypeId,
        "destination_reference_no": destinationReferenceNo,
        "payment_status": paymentStatus,
        "payment_term": paymentTerm,
        "payment_method":paymentMethod??''
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
        "internal_note": internalNote,
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
        "status": status,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "updated_at": updatedAt,
        "attachment": attachment,
        "seller_id": sellerId,
        "address_id": addressId,
        "supplier_id": supplierId,
        "supplier": supplier,
        "hash": hash,
        "cgst": cgst,
        "sgst": sgst,
        "igst": igst,
        "quote_currency": quoteCurrency,
        "quote_currency_trm": quoteCurrencyTrm,
        "quote_type": quoteType,
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
        "document_type_id": documentTypeId,
        "destination_reference_no": destinationReferenceNo,
        "payment_status": paymentStatus,
        "payment_term": paymentTerm??'',
      };
    }
  }

  static List<QuoteModel> fromJsonList(List<Map> list) {
    List<QuoteModel> orders = [];
    Map<String, dynamic> temp = {};
    for (var item in list) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      orders.add(QuoteModel.fromJson(temp));
    }

    return orders;

    // prString(temp);
  }

  @override
  toString() => referenceNo ?? '';

  /// Build an instance of QuoteModel given productDetails, user, customer and
  /// customerAddress
  static QuoteModel buildQuote(
      UserModel user, Map<String, dynamic> productsDetails) {
    return QuoteModel(
      // here we add order tax if needed
      totalTax: productsDetails['product_total_tax'],
      status: 'pending',
      referenceNo: null,
      orderTax: 0,
      total: quoteBloc.getSubTotalWithoutDiscount(),
      grandTotal: quoteBloc.getSubTotal(),
      orderDiscount: quoteBloc.getQuoteDiscount,
      customer:
          quoteBloc.getCustomer!.name ?? quoteBloc.getCustomer!.company ?? '',
      customerId: int.parse(quoteBloc.getCustomer!.idCloud ?? '0'),
      biller: user.billerName,
      billerId: user.billerId,
      note: quoteBloc.getNote ?? '',
      sellerId: user.sellerId,
      warehouseId: user.warehouseId,
      paymentStatus: 0,
      paymentTerm: 0,
      createdBy: int.parse(dataBloc.userData!.id),
      internalNote: quoteBloc.getInternalNote ?? '',
      addressId: quoteBloc.getCustomerAddresses!.idCloud,
      productTax: productsDetails['product_total_tax'],
      documentTypeId: quoteBloc.getQuoteDocumentType?.idCloud ?? '',
      productDiscount: productsDetails['product_total_discount'],
      totalDiscount: productsDetails['product_total_discount'] +
          quoteBloc.getTotalDiscount(),
    );
  }

  Future<Map> buildPrintDataMap() async {
    final customer = await CompaniesProvider.getCompanyById(customerId.toString());
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
      "quote_data": {
        'reference_no': referenceNo,
      },
      "pos_note": note ?? '',
      "total": total,
      "grand_total": grandTotal,
      "products_discount": productDiscount,
      "quote_discount": orderDiscount,
      "total_discount": totalDiscount,
      "iva": productsInfo['iva'],
      "company_data": biller,
      "biller_data": billerData,
      "settings": settings,
      "footer": temp
    };
  }

  static Future<Map<String, dynamic>> _productsMap(int quoteId) async {
    final quoteItems = await QuoteItemsProvider.loadFromDB(quoteId);

    List<Map<String, dynamic>> productsMap = [];
    Map<double, dynamic> ivasMap = {};
    try {
      for (var item in quoteItems) {
        final unit = await UnitsProvider.getUnitInfo(item.productUnitId);
        final bUnit = await UnitsProvider.getUnitInfo(unit?.baseUnit);
        final tItempMap = {
          'quantity': item.quantity,
          'price': item.unitPrice,
          'name': item.productName,
          'unit': unit?.toJson(),
          'base_unit': bUnit?.toJson()
        };
        productsMap.add(tItempMap);
        final taxRate =
            roundDouble((item.unitPrice / item.netUnitPrice) - 1, 2);
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
            await logError(e, from: 'Building products info to quote');

      // printConsole(e);
      return {};
    }

    return {
      'iva': ivasMap,
      'products': productsMap,
    };
  }
}
