import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/config/regimen_personT_form_params.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

Widget imageFile(String pathImage, {BoxFit? fit}) {
  // final imgURL = dataBloc.userData!.hostUrl +
  //     dataBloc.userData!.companyFolder +
  //     '/assets/uploads/logos/' +
  //     posPrintData['company_data'].logo;
  return FadeInImage(
      placeholder: AssetImage('assets/images/no_image.png'),
      fit: fit,
      image: FileImage(new File(pathImage)));
  // return Image.file(new File(pathImage));
}

Widget legalInformation(
    TextTheme textTheme, Map<dynamic, dynamic> posPrintData) {
  final companyData = posPrintData['company_data'];
  final settings = posPrintData['settings'];
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      socialReason(settings['razon_social'], textTheme),
      RichText(
          text: TextSpan(
              text: 'NIT: ',
              style: textTheme.bodyText1!.apply(fontWeightDelta: 2),
              children: [
            TextSpan(
                text: settings['numero_documento'] ?? '',
                style: textTheme.bodyText1)
          ])),
      Text(
        regimenT[settings['tipo_regimen'].toString()]?.name ?? '',
        style: textTheme.bodyText1!.apply(fontWeightDelta: 2),
      ),
      Text(capitalizeText((companyData!.address ?? '') +
          ' - ' +
          (posPrintData['company_data'].city ?? ''))),
      RichText(
          text: TextSpan(
              text: 'Telefono: ',
              style: textTheme.bodyText1!.apply(fontWeightDelta: 2),
              children: [
            TextSpan(text: companyData.phone ?? '', style: textTheme.bodyText1)
          ])),
    ],
  );
}

Text socialReason(String? socialReason, TextTheme textTheme) {
  return Text(
    socialReason ?? '',
    style: textTheme.bodyText1,
  );
}

Widget emptyLine() {
  return SizedBox(
    height: 10,
  );
}

Widget invoiceRef(TextTheme textTheme, Map<dynamic, dynamic> posPrintData) {
  final saleData = posPrintData['sale_data'];
  return Column(
    children: [
      Text(
        'Factura POS',
        style: textTheme.bodyText1,
      ),
      Text(
        saleData['reference_no'] ?? '',
        style:
            textTheme.bodyText1!.apply(fontWeightDelta: 5, fontSizeFactor: 1.2),
      ),
    ],
  );
}

Widget billerData(TextTheme textTheme, Map<dynamic, dynamic> posPrintData) {
  final customer = posPrintData['customer'];
  final saleData = posPrintData['sale_data'];
  final sellerName = dataBloc.userData!.sellerName;
  return Column(
    // mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RichText(
          text: TextSpan(
              text: 'Fecha/hora: ',
              style: textTheme.bodyText1!.apply(fontWeightDelta: 5),
              children: [
            TextSpan(text: saleData['date'] ?? '', style: textTheme.bodyText1)
          ])),
      RichText(
          text: TextSpan(
              text: 'Cliente: ',
              style: textTheme.bodyText1!.apply(fontWeightDelta: 5),
              children: [
            TextSpan(
                text: capitalizeText(customer['name'] ?? ''),
                style: textTheme.bodyText1)
          ])),
      RichText(
          text: TextSpan(
              text: 'NIT/CC: ',
              style: textTheme.bodyText1!.apply(fontWeightDelta: 5),
              children: [
            TextSpan(text: customer['vat_no'] ?? '', style: textTheme.bodyText1)
          ])),
      RichText(
          text: TextSpan(
              text: 'Tel: ',
              style: textTheme.bodyText1!.apply(fontWeightDelta: 5),
              children: [
            TextSpan(text: customer['phone'] ?? '', style: textTheme.bodyText1)
          ])),
      RichText(
          text: TextSpan(
              text: 'Dirección: ',
              style: textTheme.bodyText1!.apply(fontWeightDelta: 5),
              children: [
            TextSpan(
                text: capitalizeText((customer['address'] ?? '') +
                    ' - ' +
                    (customer['city'] ?? '')),
                style: textTheme.bodyText1)
          ])),
      Text(
        customer['email'],
        style: textTheme.bodyText1,
      ),
      RichText(
          text: TextSpan(
              text: 'Vendedor: ',
              style: textTheme.bodyText1!.apply(fontWeightDelta: 5),
              children: [
            TextSpan(text: sellerName, style: textTheme.bodyText1)
          ])),
    ],
  );
}

Widget products(Map<dynamic, dynamic> posPrintData) {
  // final size = MediaQuery.of(context).size;
  final List<Map> products = posPrintData['products'];
  return DataTable(
    columns: _pColumnsNames(),
    rows: _products(products),
    dataRowHeight: 50,
    showBottomBorder: true,
    columnSpacing: 5,
    horizontalMargin: 5,
    dividerThickness: 2,
    headingRowHeight: 30,
  );
}

List<DataRow> _products(List<Map<dynamic, dynamic>> products) {
  return products.map((p) {
    String value =
        getFormatedCurrency(p['quantity'] * p['price']).toString().substring(1);
    return DataRow(
      cells: <DataCell>[
        DataCell(Text(p['quantity'].toString())),
        DataCell(Text(
          capitalizeText(value),
          maxLines: 3,
        )),
        DataCell(Text(value)),
      ],
    );
  }).toList();
}

List<DataColumn> _pColumnsNames() {
  return [
    DataColumn(
      label: Text(
        'Cant',
        // style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
    DataColumn(
      label: Text(
        'Producto',
        // style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
    DataColumn(
      label: Text(
        'Valor',
        // style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
  ];
}

Widget paymentDetails(TextTheme textTheme, Map<dynamic, dynamic> posPrintData) {
  final total = getFormatedCurrency(posPrintData['total']);
  final payment = getFormatedCurrency(posPrintData['payment'] + 0.0);
  final cambio = posPrintData['payment'] - posPrintData['total'];
  final payMethod = posPrintData['payment_method']['name'].toString();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total a pagar: ',
            style: textTheme.bodyText1!.apply(fontWeightDelta: 5),
          ),
          Text(
            total,
            style: textTheme.bodyText1,
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Valor recibido: ',
            style: textTheme.bodyText1!.apply(fontWeightDelta: 5),
          ),
          Text(
            payment,
            style: textTheme.bodyText1,
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Cambio: ',
            style: textTheme.bodyText1!.apply(fontWeightDelta: 5),
          ),
          Text(
            getFormatedCurrency(cambio < 0 ? 0 : cambio),
            style: textTheme.bodyText1,
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Pagado en: ',
            style: textTheme.bodyText1!.apply(fontWeightDelta: 5),
          ),
          Text(
            payMethod,
            style: textTheme.bodyText1,
          ),
        ],
      ),
    ],
  );
}

Widget taxRatesValues(TextTheme textTheme, Map<dynamic, dynamic> posPrintData) {
  final taxValues = posPrintData['iva'] as Map;

  return Column(
    children: [
      Text(
        'Resumen de impuestos',
        style: textTheme.bodyText1,
      ),
      DataTable(
        columns: _taxValuesColumns(),
        rows: _taxValuesRows(taxValues),
        dataRowHeight: 50,
        showBottomBorder: true,
        // columnSpacing: 10,
        horizontalMargin: 10,
        dividerThickness: 2,
        headingRowHeight: 30,
      ),
    ],
  );
}

List<DataColumn> _taxValuesColumns() {
  return [
    DataColumn(
      label: Text(
        'Tarifa',
        // style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
    DataColumn(
      label: Text(
        'Base',
        // style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
    DataColumn(
      label: Text(
        'Impuesto',
        // style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
  ];
}

List<DataRow> _taxValuesRows(Map taxValues) {
  return taxValues.keys.toList().map((element) {
    final itemp = taxValues[element];
    double iva = element > 1 ? element / 100 : element;
    String temp = getFormatedCurrency(itemp['value']).toString().substring(1);
    String temp2 =
        getFormatedCurrency(itemp['value'] * iva).toString().substring(1);
    return DataRow(
      cells: <DataCell>[
        DataCell(Text(itemp['name'])),
        DataCell(Text(
          temp,
          maxLines: 3,
        )),
        DataCell(Text(temp2)),
      ],
    );
  }).toList();
}

Widget posNote(TextTheme textTheme, Map<dynamic, dynamic> posPrintData) {
  final posNote = posPrintData['pos_note'];
  return posNote == ''
      ? Container()
      : Column(
          children: [
            Text(
              posNote,
              style: textTheme.bodyText1,
            ),
            emptyLine(),
          ],
        );
}

Widget resolution(TextTheme textTheme, Map<dynamic, dynamic> posPrintData) {
  final resolution = posPrintData['sale_data']['resolucion'];
  return Text(
    resolution,
    style: textTheme.bodyText1,
    textAlign: TextAlign.center,
  );
}

Widget wappsiSpam(TextTheme textTheme, Map<dynamic, dynamic> posPrintData) {
  final List<String> footer = posPrintData['footer'];
  return Column(
    children: footer.map((element) {
      return Text(
        element,
        style: textTheme.bodyText1,
        textAlign: TextAlign.center,
      );
    }).toList(),
  );
}
