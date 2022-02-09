import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/config/regimen_person_type_form_params.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

Widget legalInformation(TextTheme textTheme, Map<dynamic, dynamic> printData) {
  final companyData = printData['company_data'];
  final settings = printData['settings'];
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
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          capitalizeText((companyData!.address ?? '') +
              ' - ' +
              (printData['company_data'].city ?? '')),
          textAlign: TextAlign.center,
        ),
      ),
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
  return const SizedBox(
    height: 10,
  );
}

Widget invoiceRef(TextTheme textTheme, Map<dynamic, dynamic> printData) {
  final data = printData['sale_data'];
  return Column(
    children: [
      Text(
        'Factura POS',
        style: textTheme.bodyText1,
      ),
      Text(
        data['reference_no'] ?? '',
        style:
            textTheme.bodyText1!.apply(fontWeightDelta: 5, fontSizeFactor: 1.2),
      ),
    ],
  );
}

Widget orderRef(TextTheme textTheme, Map<dynamic, dynamic> printData) {
  final data = printData['order_data'];
  return Column(
    children: [
      Text(
        'Orden de Pedido',
        style: textTheme.bodyText1,
      ),
      Text(
        data['reference_no'] ?? '',
        style:
            textTheme.bodyText1!.apply(fontWeightDelta: 5, fontSizeFactor: 1.2),
      ),
    ],
  );
}

Widget billerData(TextTheme textTheme, Map<dynamic, dynamic> printData) {
  final customer = printData['customer'];
  final data = printData['sale_data'] ?? printData['order_data'];
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
            TextSpan(text: data['date'] ?? '', style: textTheme.bodyText1)
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

Widget products(Map<dynamic, dynamic> printData) {
  // final size = MediaQuery.of(context).size;
  final List<Map> products = printData['products'];
  return DataTable(
    columns: _pColumnsNames(),
    rows: _products(products),
    dataRowHeight: 50,
    showBottomBorder: true,
    columnSpacing: 5,
    horizontalMargin: 10,
    dividerThickness: 2,
    headingRowHeight: 30,
  );
}

List<DataRow> _products(List<Map<dynamic, dynamic>> products) {
  return products.map((p) {
    String value = getFormatedCurrency(p['quantity'] * p['price'], decimals: 1);
    return DataRow(
      cells: <DataCell>[
        DataCell(Text(getIntDouble(p['quantity']))),
        DataCell(Text(
          capitalizeText(p['name']),
          maxLines: 3,
        )),
        DataCell(
          Text(
            value,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }).toList();
}

List<DataColumn> _pColumnsNames() {
  return [
    const DataColumn(
      label: Text(
        'Cant',
        // style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
    const DataColumn(
      label: Text(
        'Producto',
        // style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
    const DataColumn(
      label: Text(
        'Valor',
        // style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
  ];
}

Widget paymentDetails(TextTheme textTheme, Map<dynamic, dynamic> printData) {
  final total = getFormatedCurrency(printData['total']);
  final payment = getFormatedCurrency(printData['payment'] + 0.0);
  final cambio = printData['payment'] - printData['total'];
  final payMethod = printData['payment_method']['name'].toString();

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

Widget orderValueDetails(TextTheme textTheme, Map<dynamic, dynamic> printData) {
  final total = getFormatedCurrency(printData['total'], decimals: 1);
  final discount =
      getFormatedCurrency(printData['total_discount'], decimals: 1);
  final grandTotal = getFormatedCurrency(printData['grand_total'], decimals: 1);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtotal: ',
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
              'Descuento: ',
              style: textTheme.bodyText1!.apply(fontWeightDelta: 5),
            ),
            Text(
              discount,
              style: textTheme.bodyText1,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total a pagar: ',
              style: textTheme.bodyText1!.apply(fontWeightDelta: 5),
            ),
            Text(
              grandTotal,
              style: textTheme.bodyText1,
            ),
          ],
        ),
      ],
    ),
  );
}

Widget taxRatesValues(TextTheme textTheme, Map<dynamic, dynamic> printData) {
  final taxValues = printData['iva'] as Map;

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
    const DataColumn(
      label: Text(
        'Tarifa',
        // style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
    const DataColumn(
      label: Text(
        'Base',
        // style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
    const DataColumn(
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

Widget posNote(TextTheme textTheme, Map<dynamic, dynamic> printData) {
  final posNote = printData['pos_note'];
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

Widget resolution(TextTheme textTheme, Map<dynamic, dynamic> printData) {
  final resolution = printData['sale_data']['resolucion'];
  return Text(
    resolution,
    style: textTheme.bodyText1,
    textAlign: TextAlign.center,
  );
}

Widget wappsiSpam(TextTheme textTheme, Map<dynamic, dynamic> printData) {
  final List<String> footer = printData['footer'];
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
