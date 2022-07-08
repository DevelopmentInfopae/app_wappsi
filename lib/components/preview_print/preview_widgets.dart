import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports, unnecessary_import
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/params/regimen_person_type_form_params.dart';
import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/utils/text_formating/date_to_text.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';
import 'package:pos_wappsi/utils/text_formating/hmtl_formating.dart';

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
          capitalizeText((companyData?.address ?? '') +
              ' - ' +
              (printData['company_data']?.city ?? '')),
          textAlign: TextAlign.center,
        ),
      ),
      RichText(
          text: TextSpan(
              text: 'Telefono: ',
              style: textTheme.bodyText1!.apply(fontWeightDelta: 2),
              children: [
            TextSpan(text: companyData?.phone ?? '', style: textTheme.bodyText1)
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
  final data = printData['sale_data']['data'] ?? printData['sale_data'];
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

Widget quoteRef(TextTheme textTheme, Map<dynamic, dynamic> printData) {
  final data = printData['quote_data'];
  return Column(
    children: [
      Text(
        'Cotización',
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

Widget headerData(TextTheme textTheme, Map<dynamic, dynamic> printData) {
  final customer = printData['customer'];
  final data = printData['sale_data']?['data'] ??
      printData['sale_data'] ??
      printData['sale_data'];
  final sellerName = dataBloc.userData!.sellerName;
  final Map zoneSzoneData = printData['zone_szone_data'] ?? {};
  final date = data != null
      ? data['date'] ?? data['current_server_date'] ?? ''
      : DateTime.now().toString();
  return Column(
    // mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RichText(
          text: TextSpan(
              text: 'Fecha/hora: ',
              style: textTheme.bodyText1!.apply(fontWeightDelta: 5),
              children: [
            TextSpan(
                text: parseDateStrES(date) + ' ' + parseTimeStrES(date),
                style: textTheme.bodyText1)
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
      zoneSzoneData.isNotEmpty
          ? Column(
              children: [
                RichText(
                    text: TextSpan(
                        text: 'Zona: ',
                        style: textTheme.bodyText1!.apply(fontWeightDelta: 5),
                        children: [
                      TextSpan(
                          text: capitalizeText((zoneSzoneData['zone_data']
                                  ?["zone_name"] ??
                              '--')),
                          style: textTheme.bodyText1)
                    ])),
                RichText(
                    text: TextSpan(
                        text: 'Barrio: ',
                        style: textTheme.bodyText1!.apply(fontWeightDelta: 5),
                        children: [
                      TextSpan(
                          text: capitalizeText((zoneSzoneData['subzone_data']
                                  ?["subzone_name"] ??
                              '--')),
                          style: textTheme.bodyText1)
                    ])),
              ],
            )
          : Container(),
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
        customer['email'] ?? '',
        style: textTheme.bodyText1?.apply(fontWeightDelta: 2),
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

Widget products(Map<dynamic, dynamic> printData, {int? pricePolicy}) {
  // final size = MediaQuery.of(context).size;
  final List<Map> products = printData['products'];
  return DataTable(
    columns: pricePolicy == 10 ? _pColumnsNamesWUnits() : _pColumnsNames(),
    rows: pricePolicy == 10 ? _productsWUnit(products) : _products(products),
    // dataRowHeight: 50,
    showBottomBorder: true,
    columnSpacing: 5,
    horizontalMargin: 10,
    dividerThickness: 0,
    headingRowHeight: 30,
  );
}

Widget productsFavs(Map<dynamic, dynamic> printData) {
  // final size = MediaQuery.of(context).size;
  final List<Map> products = printData['products'];
  final Map<String, dynamic> customerInfo = printData['customer'];
  final List<Widget> pFavList = [
    Center(
      child: const Text(
        'Productos',
        style: TextStyle(fontWeight: FontWeight.bold),
      ).paddingBottom(5),
    )
  ];
  for (Map element in products) {
    final pName = Text(
      element['name'],
    );
    pFavList.add(pName);
    final units = FutureBuilder(
      future: UnitsProvider.getProductUnits(
          element['id_cloud'].toString(), customerInfo['price_group_id']),
      builder:
          (BuildContext context, AsyncSnapshot<List<UnitsModel>> snapshot) {
        if (snapshot.hasData) {
          final List<Widget> uDesc = [];
          for (var element in snapshot.data!) {
            uDesc.add(Row(
              children: [
                Text(
                  element.name,
                  // maxLines: 2,
                ).expand(),
                Text(getFormatedCurrency(element.unitValue)),
                const Text('  _______'),
              ],
            ));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: uDesc,
          );
        } else {
          //to return something
          return Container();
        }
      },
    );
    pFavList.add(units);
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: pFavList,
  );
}

List<DataRow> _products(List<Map<dynamic, dynamic>> products) {
  List<DataRow> rows = [];
  for (var p in products) {
    String value = getFormatedCurrency(p['quantity'] * p['price']);
    rows.add(DataRow(
      cells: <DataCell>[
        DataCell(Text(getRoundedQtty(p['quantity']))),
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
    ));
    if (p['preferences'] != null && p['preferences'] != '') {
      rows.add(DataRow(cells: <DataCell>[
        const DataCell(Text('')),
        DataCell(Text(capitalizeText(p['preferences'] ?? ''))),
        const DataCell(Text('')),
      ]));
    }
  }
  return rows;
}

List<DataRow> _productsWUnit(List<Map<dynamic, dynamic>> products) {
  List<DataRow> rows = [];
  for (var p in products) {
    final value = p['quantity'] * p['price'];
    String valueS = getFormatedCurrency(value);
    final unit = p['unit'];
    final qtty = p['quantity'] / unit['operation_value'];

    // List<Widget> productDesc = [Text(capitalizeText(p['name']))];
    String text = capitalizeText(p['name']);
    // printConsole(qtty);
    // if (p['base_unit'] != null) {
    //   final bUnit = p['base_unit'];
    //   final bUnitValue = value / unit['operation_value'];
    //   final bUnitValueS = getFormatedCurrency(bUnitValue);
    //   text += '. ' +
    //       capitalizeText(
    //           (bUnit['code'] ?? unit['code']) + ' x ' + bUnitValueS) +
    //       capitalizeText(p['preferences']);
    // }

    rows.add(DataRow(
      cells: <DataCell>[
        DataCell(Text(getRoundedQtty(qtty))),
        DataCell(Text(
          capitalizeText(unit['code']),
          maxLines: 3,
        )),
        DataCell(Text(text)),
        DataCell(
          Text(
            valueS,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ));

    if (p['base_unit'] != null) {
      final bUnit = p['base_unit'];
      final bUnitValue = value / unit['operation_value'];
      final bUnitValueS = getFormatedCurrency(bUnitValue);
      rows.add(DataRow(cells: <DataCell>[
        const DataCell(Text('')),
        const DataCell(Text('')),
        DataCell(Text(capitalizeText(
                (bUnit['code'] ?? unit['code']) + ' x ' + bUnitValueS) +
            '. ' +
            capitalizeText(p['preferences'] ?? ''))),
        const DataCell(Text('')),
      ]));
    }
  }

  return rows;
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

List<DataColumn> _pColumnsNamesWUnits() {
  return [
    const DataColumn(
      label: Text(
        'Cant',
        // style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
    const DataColumn(
      label: Text(
        'UM',
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

Widget ordQuotValueDetails(
    TextTheme textTheme, Map<dynamic, dynamic> printData) {
  final total = getFormatedCurrency(printData['total']);
  final discount = getFormatedCurrency(printData['total_discount']);
  final grandTotal = getFormatedCurrency(printData['grand_total']);

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
            Html(
              data: htmlFormating(posNote.toString()),
              style: {
                'p': Style(
                    textAlign: TextAlign.justify, fontSize: FontSize.medium)
              },
            ),
            emptyLine(),
          ],
        );
}

Widget resolution(TextTheme textTheme, Map<dynamic, dynamic> printData) {
  final resolution = printData['sale_data']?['data']?['resolucion'] ??
      printData['sale_data']?['resolucion'];
  return Text(
    resolution ?? '',
    style: textTheme.bodyText1,
    textAlign: TextAlign.center,
  );
}

Widget deliveryInfo(BuildContext context, Map<dynamic, dynamic> printData) {
  final String? day = printData['order_data']['delivery_day'];
  // final date = DateTime.parse(day ?? '');
  final dateString = parseDateStrES(day ?? '');
  final String? deliveryTime = printData['order_data']['delivery_text'];

  return day != null
      ? Column(children: [
          const Text(
            'Fecha de entrega ',
            // style: normalTextStyle(context, color: greyDarkerColor),
          ),
          Text(
            capitalizeText(dateString),
            style: buttonsSmallTextStyle(context, color: black),
          ).paddingBottom(10),
          const Text(
            'Franja Horaria',
            // style: normalTextStyle(context, color: greyDarkerColor),
          ),
          Text(
            deliveryTime ?? '',
            style: buttonsSmallTextStyle(context, color: black),
          ),
        ])
      : Container();
}

Widget wappsiSpam(TextTheme textTheme, Map<dynamic, dynamic> printData) {
  final List<String>? footer = printData['footer'];
  return footer != null
      ? Column(
          children: footer.map((element) {
            return Text(
              element,
              style: textTheme.bodyText1,
              textAlign: TextAlign.center,
            );
          }).toList(),
        )
      : Container();
}
