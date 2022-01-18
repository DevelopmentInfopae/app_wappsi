// To parse this JSON data, do
//
//     final documentsTypes = documentsTypesFromJson(jsonString);

import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/config/documents_types.dart';
import 'dart:convert';

import 'package:pos_wappsi/providers/local_db_provider.dart';

DocumentsTypes documentsTypesFromJson(String str) =>
    DocumentsTypes.fromJson(json.decode(str));

String documentsTypesToJson(DocumentsTypes data) => json.encode(data.toJson());

class DocumentsTypes {
  DocumentsTypes({
    required this.idCloud,
    required this.module,
    required this.nombre,
    required this.facturaElectronica,
    required this.facturaContingencia,
    required this.numResolucion,
    required this.palabraResolucion,
    required this.salesPrefix,
    required this.salesConsecutive,
    required this.inicioResolucion,
    required this.finResolucion,
    required this.emisionResolucion,
    required this.vencimientoResolucion,
    required this.claveTecnica,
    required this.feWorkEnvironment,
    required this.feTestid,
    required this.invoiceFooter,
    required this.keyLog,
    required this.moduleInvoiceFormatId,
    required this.saveResolutionInSale,
    required this.wordTypeSale,
    required this.feTransactionId,
    required this.notAccounting,
    required this.invoiceHeader,
    required this.addConsecutiveLeftZeros,
    required this.lastUpdate,
  });

  String idCloud;
  String module;
  String nombre;
  String facturaElectronica;
  dynamic facturaContingencia;
  String numResolucion;
  String palabraResolucion;
  String salesPrefix;
  String salesConsecutive;
  String inicioResolucion;
  String finResolucion;
  String emisionResolucion;
  String vencimientoResolucion;
  dynamic claveTecnica;
  dynamic feWorkEnvironment;
  dynamic feTestid;
  String invoiceFooter;
  String keyLog;
  String moduleInvoiceFormatId;
  String saveResolutionInSale;
  String wordTypeSale;
  dynamic feTransactionId;
  String notAccounting;
  dynamic invoiceHeader;
  String addConsecutiveLeftZeros;
  String lastUpdate;

  factory DocumentsTypes.fromJson(Map<String, dynamic> json) => DocumentsTypes(
      idCloud: json["id_cloud"]?.toString() ?? '',
      module: json["module"]?.toString() ?? '',
      nombre: json["nombre"]?.toString() ?? '',
      facturaElectronica: json["factura_electronica"]?.toString() ?? '',
      facturaContingencia: json["factura_contingencia"],
      numResolucion: json["num_resolucion"]?.toString() ?? '',
      palabraResolucion: json["palabra_resolucion"]?.toString() ?? '',
      salesPrefix: json["sales_prefix"]?.toString() ?? '',
      salesConsecutive: json["sales_consecutive"]?.toString() ?? '',
      inicioResolucion: json["inicio_resolucion"]?.toString() ?? '',
      finResolucion: json["fin_resolucion"]?.toString() ?? '',
      emisionResolucion: json["emision_resolucion"]?.toString() ?? '',
      vencimientoResolucion: json["vencimiento_resolucion"]?.toString() ?? '',
      claveTecnica: json["clave_tecnica"],
      feWorkEnvironment: json["fe_work_environment"],
      feTestid: json["fe_testid"],
      invoiceFooter: json["invoice_footer"]?.toString() ?? '',
      keyLog: json["key_log"]?.toString() ?? '',
      moduleInvoiceFormatId: json["module_invoice_format_id"]?.toString() ?? '',
      saveResolutionInSale: json["save_resolution_in_sale"]?.toString() ?? '',
      wordTypeSale: json["word_type_sale"]?.toString() ?? '',
      feTransactionId: json["fe_transaction_id"]?.toString() ?? '',
      notAccounting: json["not_accounting"]?.toString() ?? '',
      invoiceHeader: json["invoice_header"]?.toString() ?? '',
      addConsecutiveLeftZeros:
          json["add_consecutive_left_zeros"]?.toString() ?? '',
      lastUpdate: json["last_update"]?.toString() ?? '');

  Map<String, dynamic> toJson() => {
        "id_cloud": idCloud,
        "module": module,
        "nombre": nombre,
        "factura_electronica": facturaElectronica,
        "factura_contingencia": facturaContingencia,
        "num_resolucion": numResolucion,
        "palabra_resolucion": palabraResolucion,
        "sales_prefix": salesPrefix,
        "sales_consecutive": salesConsecutive,
        "inicio_resolucion": inicioResolucion,
        "fin_resolucion": finResolucion,
        "emision_resolucion": emisionResolucion,
        "vencimiento_resolucion": vencimientoResolucion,
        "clave_tecnica": claveTecnica,
        "fe_work_environment": feWorkEnvironment,
        "fe_testid": feTestid,
        "invoice_footer": invoiceFooter,
        "key_log": keyLog,
        "module_invoice_format_id": moduleInvoiceFormatId,
        "save_resolution_in_sale": saveResolutionInSale,
        "word_type_sale": wordTypeSale,
        "fe_transaction_id": feTransactionId,
        "not_accounting": notAccounting,
        "invoice_header": invoiceHeader,
        "add_consecutive_left_zeros": addConsecutiveLeftZeros,
        "last_update": lastUpdate
      };

  static Future<List<DocumentsTypes>> loadFromDB(
      {String? search, String? module}) async {
    List<Map<String, dynamic>>? data = [];
    if (search == null || search == '') {
      data = await allDocumentsTypes(
          dataBloc.userData!.billerId.toString(),
          module: module ?? posDocModule);
    } else {
      data = await findDocumentsTypes(
          dataBloc.userData!.billerId.toString(), search,
          module: module ?? posDocModule);
    }
    List<DocumentsTypes> list = [];
    if (data != null) {
      Map<String, dynamic> temp = {};
      data.forEach((item) {
        for (var i = 0; i < item.keys.length; i++) {
          temp[item.keys.toList()[i]] = item.values.toList()[i];
        }
        list.add(DocumentsTypes.fromJson(temp));
      });
    }

    return list;
  }

  static Future<DocumentsTypes?> loadPayDoc(String idDoc) async {
    Map<String, dynamic>? data =
        await findDocumentsTypesById(idDoc);

    if (data != null) {
      return DocumentsTypes.fromJson(data);
    } else {
      return null;
    }
  }


  //____________________________________________________________________________
  //
  //                DOCUMENTS TYPES AND BILLER DOCUMENTS TYPES
  //____________________________________________________________________________

  /// Return all rows in sma_cities
  static Future<List<Map<String, dynamic>>?> allDocumentsTypes(String billerId,
      {String module = '19'}) async {
    return await DBProvider.db.sqlRawQuery(
        '''select * from sma_documents_types dt INNER JOIN sma_biller_documents_types bdt 
    ON dt.id_cloud = bdt.document_type_id AND bdt.biller_id = $billerId WHERE dt.module= $module ''');
  }

  static Future<List<Map<String, dynamic>>?> findDocumentsTypes(
      String billerId, String searchs,
      {String module = '19'}) async {
    return await DBProvider.db.sqlRawQuery(
        '''select * from sma_documents_types dt INNER JOIN sma_biller_documents_types bdt 
    ON dt.id_cloud = bdt.document_type_id AND bdt.biller_id = $billerId WHERE dt.module= '$module' AND dt.nombre LIKE "%$searchs%"''');
  }

  static Future<Map<String, dynamic>?> findDocumentsTypesById(String id) async {
    return await DBProvider.db.sqlFirstQuery('sma_documents_types', where: "id_cloud='$id'");
  }


  @override
  String toString() => nombre;
}
