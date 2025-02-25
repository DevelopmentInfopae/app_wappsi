// To parse this JSON data, do
//
//     final documentsTypes = documentsTypesFromJson(jsonString);

import 'dart:convert';

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
        idCloud: json['id_cloud']?.toString() ?? '',
        module: json['module']?.toString() ?? '',
        nombre: json['nombre']?.toString() ?? '',
        facturaElectronica: json['factura_electronica']?.toString() ?? '',
        facturaContingencia: json['factura_contingencia'],
        numResolucion: json['num_resolucion']?.toString() ?? '',
        palabraResolucion: json['palabra_resolucion']?.toString() ?? '',
        salesPrefix: json['sales_prefix']?.toString() ?? '',
        salesConsecutive: json['sales_consecutive']?.toString() ?? '',
        inicioResolucion: json['inicio_resolucion']?.toString() ?? '',
        finResolucion: json['fin_resolucion']?.toString() ?? '',
        emisionResolucion: json['emision_resolucion']?.toString() ?? '',
        vencimientoResolucion: json['vencimiento_resolucion']?.toString() ?? '',
        claveTecnica: json['clave_tecnica'],
        feWorkEnvironment: json['fe_work_environment'],
        feTestid: json['fe_testid'],
        invoiceFooter: json['invoice_footer']?.toString() ?? '',
        keyLog: json['key_log']?.toString() ?? '',
        moduleInvoiceFormatId:
            json['module_invoice_format_id']?.toString() ?? '',
        saveResolutionInSale: json['save_resolution_in_sale']?.toString() ?? '',
        wordTypeSale: json['word_type_sale']?.toString() ?? '',
        feTransactionId: json['fe_transaction_id']?.toString() ?? '',
        notAccounting: json['not_accounting']?.toString() ?? '',
        invoiceHeader: json['invoice_header']?.toString() ?? '',
        addConsecutiveLeftZeros:
            json['add_consecutive_left_zeros']?.toString() ?? '',
        lastUpdate: json['last_update']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id_cloud': idCloud,
        'module': module,
        'nombre': nombre,
        'factura_electronica': facturaElectronica,
        'factura_contingencia': facturaContingencia,
        'num_resolucion': numResolucion,
        'palabra_resolucion': palabraResolucion,
        'sales_prefix': salesPrefix,
        'sales_consecutive': salesConsecutive,
        'inicio_resolucion': inicioResolucion,
        'fin_resolucion': finResolucion,
        'emision_resolucion': emisionResolucion,
        'vencimiento_resolucion': vencimientoResolucion,
        'clave_tecnica': claveTecnica,
        'fe_work_environment': feWorkEnvironment,
        'fe_testid': feTestid,
        'invoice_footer': invoiceFooter,
        'key_log': keyLog,
        'module_invoice_format_id': moduleInvoiceFormatId,
        'save_resolution_in_sale': saveResolutionInSale,
        'word_type_sale': wordTypeSale,
        'fe_transaction_id': feTransactionId,
        'not_accounting': notAccounting,
        'invoice_header': invoiceHeader,
        'add_consecutive_left_zeros': addConsecutiveLeftZeros,
        'last_update': lastUpdate,
      };

  @override
  String toString() => nombre;
}
