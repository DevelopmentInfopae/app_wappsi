// import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';

// import 'package:image_downloader/image_downloader.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
// import 'package:pos_wappsi/bloc/printer_bloc.dart';
import 'package:pos_wappsi/config/regimen_personT_form_params.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

import 'blue_print_functions.dart';

class PrintFormat {
  PrintFormat({required this.productsList});
  List<Map> productsList;

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  Future<bool?> sample(String pathImage) async {
    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT

    await bluetooth.isConnected.then((isConnected) async {
      if (isConnected!) {
        //testing pos utils
        // await bluetooth.printCustom('aA áÁ',0,1,charset: 'ASCII');

        // bluetooth.printNewLine();
        // await _image();
        await bluetooth.printImage(pathImage);
        await _comercialName();
        await _billerData();
        await bluetooth.printNewLine();
        await _header();

        await _products();
        await _total();
        await _paymentDetails();

        await _ivas();

        await _posNote();
        await bluetooth.printNewLine();
        await bluetooth.printCustom(
            _replaceSpecialCharacters(
                posBloc.getPrintData!['sale_data']['resolucion']),
            1,
            1,
            charset: 'ASCII');

        await _footer();
        await bluetooth.printNewLine();
        await bluetooth.printCustom("Impreso por Wappsi POS Movil", 1, 1);
        await bluetooth.printCustom("www.wappsi.com", 1, 1);
        await bluetooth.printNewLine();
        await bluetooth.printNewLine();
        await bluetooth.paperCut();
      }
    });

    return true;
  }

  Future<void> _header() async {
    final saleData = posBloc.getPrintData!['sale_data'];
    final customer = posBloc.getPrintData!['customer'];
    bluetooth.printCustom('Factura POS ', 1, 1, charset: 'UTF-8');
    bluetooth.printCustom(
        _replaceSpecialCharacters(saleData['reference_no']), 2, 1,
        charset: 'UTF-8');

    bluetooth.printNewLine();
    bluetooth.printCustom('Fecha/hora: ' + saleData['date'], 1, 0,
        charset: 'UTF-8');

    bluetooth.printCustom(
        'Cliente: ' + _replaceSpecialCharacters(customer['name']), 1, 0,
        charset: 'UTF-8');

    bluetooth.printCustom(
        'NIT/CC: ' + _replaceSpecialCharacters(customer['vat_no']), 1, 0);

    bluetooth.printCustom(
      'Tel: ' + _replaceSpecialCharacters(customer['phone']),
      1,
      0,
    );

    bluetooth.printCustom(
        'Direccion:' +
            _replaceSpecialCharacters(customer['address']) +
            '-' +
            _replaceSpecialCharacters(customer['city']),
        1,
        0,
        charset: 'UTF-8');

    bluetooth.printCustom(_replaceSpecialCharacters(customer['email']), 1, 0);
    bluetooth.printCustom(
        'Vendedor: ' + _replaceSpecialCharacters(dataBloc.userData!.sellerName),
        1,
        0);
  }

  _posNote() async {
    // ignore: unnecessary_statements
    posBloc.getPrintData!['pos_note'] != '' ? bluetooth.printNewLine() : null;
    posBloc.getPrintData!['pos_note'] != ''
        ? bluetooth.printCustom(
            'Nota: ' +
                _replaceSpecialCharacters(posBloc.getPrintData!['pos_note']),
            1,
            1,
            charset: 'ASCII')
        // ignore: unnecessary_statements
        : null;
  }

  _total() async {
    await bluetooth.printCustom("________________________________", 1, 1);
    final total = getFormatedCurrency(posBloc.getPrintData!['total'])
        .toString()
        .substring(1);
    await bluetooth.printLeftRight("Total a pagar:", total, 1);
  }

  _comercialName() async {
    final settings = posBloc.getPrintData!['settings'];
    // await bluetooth.printCustom(
    //     _replaceSpecialCharacters(_name?.first['nombre_comercial'] ?? ''), 1, 1,
    //     charset: 'UTF-8');
    await bluetooth.printCustom(
        _replaceSpecialCharacters(settings?['razon_social'] ?? ''), 1, 1,
        charset: 'UTF-8');
    await bluetooth.printCustom(
        'NIT: ' +
            _replaceSpecialCharacters(settings?['numero_documento'] ?? ''),
        1,
        1,
        charset: 'UTF-8');
    final regType = settings?['tipo_regimen'];
    await bluetooth.printCustom(
        _replaceSpecialCharacters(regimenT[regType.toString()]!.name), 1, 1,
        charset: 'UTF-8');
  }

  _billerData() async {
    final companyData = posBloc.getPrintData!['company_data'];

    final dir = _replaceSpecialCharacters(
        (companyData!.address ?? '') + '-' + (companyData.city ?? ''));
    await bluetooth.printCustom(dir, 1, 1, charset: 'UTF-8');
    await bluetooth.printCustom(
        'Telefono: ' + _replaceSpecialCharacters(companyData.phone ?? ''), 1, 1,
        charset: 'UTF-8');
    // final email = _replaceSpecialCharacters(_biller.email ?? '');
    // await bluetooth.printCustom('E-mail: ' + email, 1, 1, charset: 'UTF-8');
  }

  _products() async {
    await bluetooth.printCustom("________________________________", 1, 1);
    await bluetooth.printCustom('Cant Producto        Valor', 1, 0);
    await bluetooth.printCustom("--------------------------------", 1, 1);
    await Future.forEach(productsList, (Map element) async {
      List<String> formatedS = formatString(element['name'].toString());
      Future.forEach(formatedS, (String str) async {
        if (str == formatedS.first) {
          String value =
              getFormatedCurrency(element['quantity'] * element['price'])
                  .toString()
                  .substring(1);
          bluetooth.printCustom(
              element['quantity'].toString() +
                  _getEmptySpaces(4 - element['quantity'].toString().length) +
                  _replaceSpecialCharacters(str) +
                  _getEmptySpaces(17 - str.length) +
                  _getEmptySpaces(10 - value.length) +
                  value,
              1,
              0,
              charset: 'UTF-8');
        } else {
          bluetooth.printCustom('    ' + _replaceSpecialCharacters(str), 1, 0);
        }
      });
    });
    // bluetooth.printNewLine();
  }

  _paymentDetails() async {
    final value = getFormatedCurrency(posBloc.getPrintData!['payment'] + 0.0)
        .toString()
        .substring(1);
    await bluetooth.printLeftRight('Valor recibido:', value, 1);
    final cambio = getFormatedCurrency(
            (posBloc.getPrintData!['payment'] - posBloc.getPrintData!['total']))
        .toString()
        .substring(1);
    await bluetooth.printLeftRight(
      'Cambio:',
      cambio,
      1,
    );
    final payMethod =
        posBloc.getPrintData!['payment_method']['name'].toString();
    await bluetooth.printLeftRight(
      "Pagado en:",
      payMethod,
      1,
    );
  }

  _footer() async {
    final List<String> footer = posBloc.getPrintData!['footer'];
    footer.forEach((element) {
      bluetooth.printCustom(element, 1, 1);
    });
  }

  String _getEmptySpaces(int n) {
    String empty = ' ';

    return empty * n;
  }

  _ivas() async {
    posBloc.getPrintData!['iva'].keys.toList().forEach((element) async {
      final itemp = posBloc.getPrintData!['iva'][element];
      double iva = element > 1 ? element / 100 : element;
      String temp = getFormatedCurrency(itemp['value']).toString().substring(1);
      String temp2 =
          getFormatedCurrency(itemp['value'] * iva).toString().substring(1);

      await bluetooth.printNewLine();
      await bluetooth.printCustom('Resumen de impuestos', 1, 1);
      await bluetooth.printCustom("Tarifa     Base       Impuesto", 1, 0);
      await bluetooth.printCustom("--------------------------------", 1, 1);
      await bluetooth.printCustom(
          itemp['name'] +
              _getEmptySpaces(13 - temp.length) +
              temp +
              _getEmptySpaces(11 - temp2.length) +
              temp2,
          1,
          0);
    });
  }

  String _replaceSpecialCharacters(String character) {
    final chr = [
      {'from': 'á', 'replace': 'a'},
      {'from': 'Á', 'replace': 'A'},
      {'from': 'é', 'replace': 'e'},
      {'from': 'é', 'replace': 'E'},
      {'from': 'í', 'replace': 'i'},
      {'from': 'Í', 'replace': 'I'},
      {'from': 'ó', 'replace': 'o'},
      {'from': 'Ó', 'replace': 'O'},
      {'from': 'ú', 'replace': 'u'},
      {'from': 'Ú', 'replace': 'U'},
      {'from': 'ñ', 'replace': 'n'},
      {'from': 'Ñ', 'replace': 'N'},
      {'from': '<p>', 'replace': ''},
      {'from': '</p>', 'replace': ''},
    ];
    chr.forEach((element) {
      character = character.replaceAll(element['from']!, element['replace']!);
    });
    return character;
  }
}
