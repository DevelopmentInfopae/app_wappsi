// To parse this JSON data, do
//
//     final SuspendedSales = SuspendedSalesFromJson(jsonString);

import 'dart:convert';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/customer_addresses_provider.dart';
import 'package:pos_wappsi/providers/document_types_provider.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/payment_methods_provider.dart';
import 'package:pos_wappsi/providers/products_provider.dart';

SuspendedSales suspendedSalesFromJson(String str) =>
    SuspendedSales.fromJson(json.decode(str));

String suspendedSalesToJson(SuspendedSales data) => json.encode(data.toJson());

class SuspendedSales {
  SuspendedSales(
      {required this.id,
      required this.idCustomer,
      required this.idAddress,
      required this.idPayDocument,
      required this.idPayMethod,
      required this.payValue,
      required this.invoiceNote,
      required this.dispatchNote,
      required this.customerName,
      required this.createdDate,
      required this.keyWord,
      required this.totalValue,
      required this.items});

  int id;
  int idCustomer;
  int idAddress;
  int? idPayDocument;
  int? idPayMethod;
  int? payValue;
  int items;
  double totalValue;
  String? invoiceNote;
  String? keyWord;
  String customerName;
  String? dispatchNote;
  String createdDate;

  factory SuspendedSales.fromJson(Map<String, dynamic> json) => SuspendedSales(
        id: json["id"],
        idCustomer: json["id_customer"],
        idAddress: json["id_address"],
        idPayDocument:
            json["id_pay_document"] == '' ? null : json["id_pay_document"],
        idPayMethod: json["id_pay_method"] == '' ? null : json["id_pay_method"],
        payValue: json["pay_value"] == '' ? null : json["pay_value"],
        dispatchNote: json["invoice_note"] ?? '',
        invoiceNote: json["dispatch_note"] ?? '',
        customerName: json["customer_name"] ?? '',
        createdDate: json["created_date"] ?? '',
        items: json["items"] ?? 1,
        keyWord: json["key_word"] ?? '',
        totalValue: (json["total_value"] ?? 0.0) + 0.0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_customer": idCustomer,
        "id_address": idAddress,
        "id_pay_document": idPayDocument,
        "id_ay_method": idPayMethod,
        "pay_value": payValue,
        "invoice_note": invoiceNote,
        "dispatch_note": dispatchNote,
        "customer_name": customerName,
        "items": items,
        "total_value": totalValue,
        "key_word": keyWord,
        "created_date": items,
      };

  /// Load sale into SuspendedSale model given an SuspendedSale id
  static Future<SuspendedSales?> loadFromDB(String id) async {
    // Map<String, dynamic> data = await DBProvider.db.findBrand(0);
    Map<String, dynamic>? data = await DBProvider.db
        .sqlFirstQuery('suspended_sales', where: 'id=$id AND status=1');

    if (data != null) {
      return SuspendedSales.fromJson(data);
    } else {
      return null;
    }
  }

  static Future<List<SuspendedSales>> loadAllSSales() async {
    List<Map<String, dynamic>>? data =
        await DBProvider.db.sqlQuery('suspended_sales', where: 'status=1');

    List<SuspendedSales> list = [];
    if (data != null) {
      Map<String, dynamic> temp = {};
      data.forEach((item) {
        for (var i = 0; i < item.keys.length; i++) {
          temp[item.keys.toList()[i]] = item.values.toList()[i];
        }
        list.add(SuspendedSales.fromJson(temp));
      });
    }

    return list;
  }

  /// Save sale basic data into local DB and returns it's id
  static Future<bool> suspendSale({String keyWord = ''}) async {
    bool result = false;
    if (posBloc.getProducts != null &&
        posBloc.getProducts != {} &&
        posBloc.getCustomer != null &&
        posBloc.getCustomerAddresses != null) {
      final saleBasicData = {
        'id_customer': posBloc.getCustomer!.idCloud,
        'key_word': keyWord,
        'id_address': posBloc.getCustomerAddresses!.idCloud,
        'id_pay_document': posBloc.getPaymentDocument?.idCloud ?? '',
        'id_pay_method': posBloc.getPaymentMethod?.idCloud ?? '',
        'pay_value': posBloc.getPaymentValue ?? '',
        'invoice_note': posBloc.getInvoiceNote ?? '',
        'dispatch_note': posBloc.getDispatchNote ?? '',
        'items': posBloc.getItemsCount(),
        'total_value': posBloc.getSubTotal(),
        'customer_name':
            posBloc.getCustomer!.name ?? posBloc.getCustomer!.company,
        'status': 1
      };
      final res = await DBProvider.db
          .insertQuery('suspended_sales', saleBasicData, returnId: true);
      if (res != 0) {
        result = await ProductsProvider.saveProductsSpSale(res ?? 0);
      }
    }

    return result;
  }

  /// Delete suspended sale from DB given a suspended sale id
  static Future<bool> deleteSuspSale(String id) async {
    final res = await DBProvider.db
        .sqlUpdateQuery('suspended_sales', {'status': 0}, 'id=$id');
    return res != null;
  }

  /// Load suspended sale given a suspended sale id. Param getPrices is
  ///used to know if product prices should or not be calculated
  static Future<List<Map<String, dynamic>>> loadSale(String id,
      {bool getPrices = true}) async {
    final suspendedSale = await loadFromDB(id);

    final prodInfo = await ProductsProvider.loadSuspSaleProducts(id);
    final customer = await CompanyModel.getCompanyDetails(
        suspendedSale!.idCustomer.toString());
    final customerAdd = await CustomerAddressesProvider.loadCustomerAddress(
        suspendedSale.idAddress.toString());

    final payDocument = await DocumentsTypesProvider.loadPayDoc(
        (suspendedSale.idPayDocument ?? '').toString());

    final payMethod = await PaymentMethodsProvider.loadPayDoc(
        (suspendedSale.idPayMethod ?? '').toString());

    posBloc.setPaymentDocument(payDocument);
    posBloc.setPaymentMethod(payMethod);
    posBloc.setCustomer(customer);
    posBloc.setCustomerAddresses(customerAdd);

    final products = prodInfo['products'];
    List<Map<String, dynamic>> errors = [];
    await Future.forEach(products, (ProductModel p) async {
      // final res = await posBloc.addProduct(p, getPrices: getPrices);
      // if (!res) {
      //   errors.add(p.toJson());
      // }
    });

    return errors;
  }

  static Future<Map<String, dynamic>> suspSaleInfo(
      String id, String keyWord, double totalValue, int items) async {
    final suspendedSale = await loadFromDB(id);

    final products = await ProductsProvider.loadSuspSaleProducts(id);
    final customer = await CompanyModel.getCompanyDetails(
        suspendedSale!.idCustomer.toString());
    final customerAdd = await CustomerAddressesProvider.loadCustomerAddress(
        suspendedSale.idAddress.toString());

    final payDocument = await DocumentsTypesProvider.loadPayDoc(
        (suspendedSale.idPayDocument ?? '').toString());

    final payMethod = await PaymentMethodsProvider.loadPayDoc(
        (suspendedSale.idPayMethod ?? '').toString());

    return {
      'suspended_sale': suspendedSale.id,
      'products_info': products,
      'customer': customer,
      'pay_document': payDocument,
      'customer_add': customerAdd,
      'pay_method': payMethod,
      'total_value': totalValue,
      'key_word': keyWord,
      'items': items,
    };
  }
}
