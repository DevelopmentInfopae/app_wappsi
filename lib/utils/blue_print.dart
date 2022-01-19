import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

// import 'package:image_downloader/image_downloader.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/printer_bloc.dart';
import 'package:pos_wappsi/utils/blue_print_functions.dart';
import 'package:pos_wappsi/utils/functions.dart';

class PrintFormat {
  PrintFormat({this.productsList, this.movementInfo});
  List<Map>? productsList;
  Map<String, String>? movementInfo;

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  Future<bool?> printPOS(
      String pathImage, Map<dynamic, dynamic>? printData) async {
    await bluetooth.isConnected.then((isConnected) async {
      if (isConnected!) {
        final _innerPrinter =
            (printerBloc.getPrinterDevice?.name == 'InnerPrinter');
        final profile = await CapabilityProfile.load();
        final generator =
            Generator(PaperSize.mm58, profile, spaceBetweenRows: 1);
        // delete print buffer

        await bluetooth.writeBytes(Uint8List.fromList(await ticketHeader(
            generator, _innerPrinter, pathImage, printData)));
        await bluetooth.writeBytes(
            Uint8List.fromList(await ticketProducts(generator, _innerPrinter)));
        await bluetooth.writeBytes(Uint8List.fromList(
            await ticketPayDetails(generator, _innerPrinter, printData)));
        await bluetooth.writeBytes(Uint8List.fromList(
            await ticketTax(generator, _innerPrinter, printData)));

        await bluetooth.writeBytes(Uint8List.fromList(
            await ticketFooter(generator, _innerPrinter, printData)));
      }
    });

    return true;
  }

  /// To test printer
  Future<bool?> printTest() async {
    await bluetooth.isConnected.then((isConnected) async {
      if (isConnected!) {
        final _innerPrinter =
            (printerBloc.getPrinterDevice?.name == 'InnerPrinter');
        final profile = await CapabilityProfile.load();
        final generator =
            Generator(PaperSize.mm58, profile, spaceBetweenRows: 1);
        List<int> bytes = [];
        // delete print buffer
        bytes = await image(generator, 'assets/images/wappsi.png',
            assetImage: true);
        bytes += generator.text(
            'Prueba de funcionamiento de \n' +
                (_innerPrinter ? 'impresion' : 'impresión'),
            styles: PosStyles(bold: true, align: PosAlign.center));
        bytes += generator.emptyLines(1);
        bytes = wappsiSpam(_innerPrinter, bytes, generator);

        bytes += generator.feed(2);
        // ignore: unnecessary_statements
        _innerPrinter ? null : bytes += generator.cut();

        await bluetooth.writeBytes(Uint8List.fromList(bytes));
      }
    });

    return true;
  }

  /// To print favorite products
  Future<bool?> printFavorites() async {
    await bluetooth.isConnected.then((isConnected) async {
      if (isConnected!) {
        final _innerPrinter =
            (printerBloc.getPrinterDevice?.name == 'InnerPrinter');
        final profile = await CapabilityProfile.load();
        final generator =
            Generator(PaperSize.mm58, profile, spaceBetweenRows: 1);
        List<int> bytes = [];
        // delete print buffer
        bytes = await image(generator, 'assets/images/wappsi.png',
            assetImage: true);
        bytes += generator.text(
            'Prueba de funcionamiento de \n' +
                (_innerPrinter ? 'impresion' : 'impresión'),
            styles: PosStyles(bold: true, align: PosAlign.center));
        bytes += generator.emptyLines(1);
        bytes = wappsiSpam(_innerPrinter, bytes, generator);

        bytes += generator.feed(2);
        // ignore: unnecessary_statements
        _innerPrinter ? null : bytes += generator.cut();

        await bluetooth.writeBytes(Uint8List.fromList(bytes));
      }
    });

    return true;
  }

  Future<bool?> printMovement(String pathImage) async {
    await bluetooth.isConnected.then((isConnected) async {
      if (isConnected!) {
        final _innerPrinter =
            (printerBloc.getPrinterDevice?.name == 'InnerPrinter');
        final profile = await CapabilityProfile.load();
        final generator =
            Generator(PaperSize.mm58, profile, spaceBetweenRows: 1);
        generator.spaceBetweenRows = 1;
        // generator.
        generator.setGlobalCodeTable('CP1252');
        generator.setGlobalFont(PosFontType.fontB);

        final value = getFormatedCurrency(
            double.tryParse(movementInfo!['value'].toString()) ?? 0.0);
        final Map<String, String> keyValues2 = {
          'Usuario: ': movementInfo!['user_name'].toString(),
          'Fecha: ': movementInfo!['date'].toString(),
          'Referencia: ': movementInfo!['reference_no'].toString(),
          'Sucursal: ': movementInfo!['biller_name'].toString(),
          'Tipo movimiento:': movementInfo!['movement_type'].toString(),
          'Valor: ': value.substring(0, value.length - 3),
          // 'Nota de movimiento: ': movementInfo!['biller_name'].toString(),
          // 'Tipo de movimiento: ': movementInfo!['movement_type'],
        };

        List<int> bytes = [];

        // delete print buffer
        bytes = await image(generator, pathImage, assetImage: false);
        bytes += generator.text(
            _innerPrinter
                ? replaceSpecialCharacters(
                    dataBloc.settings?['razon_social'] ?? '')
                : dataBloc.settings?['razon_social'] ?? '',
            styles: PosStyles(bold: true, align: PosAlign.center));
        generator.reset();
        bytes += generator.emptyLines(1);
        bytes = printLabelValues(generator, bytes, keyValues2.keys.toList(),
            keyValues2.values.toList(), _innerPrinter,
            col1: PosAlign.left, col2: PosAlign.left);

        bytes += generator.emptyLines(3);
        bytes += generator.hr(len: 32, ch: '_');
        bytes += generator.text('Firma y sello',
            styles: PosStyles(align: PosAlign.center));
        bytes += generator.emptyLines(1);
        bytes = wappsiSpam(_innerPrinter, bytes, generator);

        bytes += generator.feed(2);
        // ignore: unnecessary_statements
        _innerPrinter ? null : bytes += generator.cut();

        await bluetooth.writeBytes(Uint8List.fromList(bytes));
      }
    });

    return true;
  }

  Future<List<int>> ticketHeader(Generator generator, bool innerPrinter,
      String pathImage, Map<dynamic, dynamic>? printData) async {
    //init print format values
    List<int> bytes = [];
    // delete print buffer
    generator.reset();
    generator.spaceBetweenRows = 1;
    // generator.
    generator.setGlobalCodeTable('CP1252');
    generator.setGlobalFont(PosFontType.fontA);

    ///data to print
    final settings = printData?['settings'];
    final saleData = printData?['sale_data'];
    final customer = printData?['customer'];
    final companyData = printData?['company_data'];
    final regType = settings?['tipo_regimen'];

    final labelsCustomer = [
      'Cliente:',
      'NIT/CC:',
      innerPrinter ? 'Direccion: ' : 'Dirección: ',
      'Email:'
    ];
    final valuesCustomer = [
      (innerPrinter
              ? replaceSpecialCharacters(customer['name'])
              : customer['name'])
          .toString(),
      customer['vat_no'].toString(),
      (innerPrinter
              ? (replaceSpecialCharacters(
                  customer['address'] + '-' + capitalizeText(customer['city'])))
              : customer['address'] + '-' + capitalizeText(customer['city']))
          .toString(),
      customer['email'].toString()
    ];
    final labelsSeller = ['Vendedor:  '];
    final valuesSeller = [
      innerPrinter
          ? replaceSpecialCharacters(dataBloc.userData!.sellerName)
          : dataBloc.userData!.sellerName
    ];

    //image
    bytes += await image(generator, pathImage);

    //legal info
    bytes = legalInfo(
        bytes, generator, innerPrinter, settings, regType, companyData);
    bytes += generator.emptyLines(1);
    //invoice data
    bytes = invoiceData(bytes, generator, saleData);
    bytes += generator.emptyLines(1);
    //customer data
    generator.reset();
    bytes = printLabeledValues(
        generator, bytes, labelsCustomer, valuesCustomer, innerPrinter,
        col2: PosAlign.right, col1: PosAlign.left);
    //seller data
    generator.reset();
    bytes = printLabeledValues(
        generator, bytes, labelsSeller, valuesSeller, innerPrinter,
        col2: PosAlign.right, col1: PosAlign.left);

    // bytes = _seller(bytes, generator, _innerPrinter);
    bytes += generator.emptyLines(1);

    return bytes;
  }

  Future<List<int>> ticketPayDetails(Generator generator, bool innerPrinter,
      Map<dynamic, dynamic>? printData) async {
    // cambio
    final cambio = printData?['payment'] - printData?['total'];
    //init print format values
    List<int> bytes = [];
    // delete print buffer
    generator.reset();
    generator.spaceBetweenRows = 1;
    // generator.
    generator.setGlobalCodeTable('CP1252');
    generator.setGlobalFont(PosFontType.fontB);
    final valueRec = getFormatedCurrency(printData?['payment'] + 0.0)
        .toString()
        .substring(1);
    final labelsPayDetails = [
      'Total    ',
      'Valor recibido ',
      'Cambio   ',
      'Pagado en '
    ];
    final valuesPayDetails = [
      getFormatedCurrency((printData!['total']! ?? '')).toString().substring(1),
      valueRec,
      getFormatedCurrency(cambio < 0 ? 0 : cambio).toString().substring(1),
      printData['payment_method']['name'].toString()
    ];
    generator.reset();
    bytes = printLabeledValues(
        generator, bytes, labelsPayDetails, valuesPayDetails, innerPrinter,
        col2: PosAlign.left, col1: PosAlign.left);

    return bytes;
  }

  Future<List<int>> ticketFooter(Generator generator, bool innerPrinter,
      Map<dynamic, dynamic>? printData) async {
    //init print format values
    List<int> bytes = [];
    // delete print buffer
    generator.reset();
    generator.spaceBetweenRows = 1;
    // generator.
    generator.setGlobalCodeTable('CP1252');
    generator.setGlobalFont(PosFontType.fontB);
    bytes = _footer(generator, bytes, innerPrinter, printData);
    // // ignore: unnecessary_statements
    bytes += generator.feed(1);
    // ignore: unnecessary_statements
    innerPrinter ? null : bytes += generator.cut();
    return bytes;
  }

  Future<List<int>> ticketProducts(
    Generator generator,
    bool innerPrinter,
  ) async {
    //init print format values
    List<int> bytes = [];
    // delete print buffer
    generator.reset();
    generator.spaceBetweenRows = 1;
    // generator.
    generator.setGlobalCodeTable('CP1252');
    generator.setGlobalFont(PosFontType.fontB);
    // bytes += generator.hr(len: 32, ch: '_');
    bytes += generator.text('Cant  Producto             Valor',
        styles: PosStyles(bold: true, align: PosAlign.left));
    bytes += generator.hr(len: 32, ch: '-');

    productsList!.forEach((Map element) {
      List<String> formatedS = formatString(element['name'].toString());
      String text = '';
      formatedS.forEach((String str) {
        // text = '';
        if (str == formatedS.first) {
          String value =
              getFormatedCurrency(element['quantity'] * element['price'])
                  .toString()
                  .substring(1);
          value = value.substring(0, value.length - 1);
          final namePart = innerPrinter ? replaceSpecialCharacters(str) : str;

          text = element['quantity'].toString() +
              getEmptySpaces(4 - element['quantity'].toString().length) +
              namePart +
              getEmptySpaces(17 - namePart.length) +
              getEmptySpaces(10 - value.length) +
              value;
        } else {
          final namePart = innerPrinter ? replaceSpecialCharacters(str) : str;
          text += '\n' +
              getEmptySpaces(4) +
              namePart +
              getEmptySpaces(32 - 4 - namePart.length);
        }
      });
      bytes += generator.text(text,
          styles: PosStyles(bold: false, align: PosAlign.left));
    });
    // bluetooth.printNewLine();
    bytes += generator.hr(len: 32, ch: '-');
    return bytes;
  }

  Future<List<int>> ticketTax(Generator generator, bool innerPrinter,
      Map<dynamic, dynamic>? printData) async {
    //init print format values
    List<int> bytes = [];
    // delete print buffer
    generator.reset();
    generator.spaceBetweenRows = 1;
    // generator.
    generator.setGlobalCodeTable('CP1252');
    generator.setGlobalFont(PosFontType.fontB);
    bytes += generator.emptyLines(1);
    bytes += generator.text('Resumen de impuestos',
        styles: PosStyles(bold: true, align: PosAlign.center));
    bytes += generator.text('Tarifa      Base     Impuesto',
        styles: PosStyles(bold: true, align: PosAlign.center));
    bytes += generator.hr(len: 30, ch: '-');

    printData?['iva'].keys.toList().forEach((element) async {
      final itemp = printData['iva']![element]!;
      double iva = element > 1 ? element / 100 : element;
      String temp = getFormatedCurrency(itemp['value']).toString().substring(1);
      String temp2 =
          getFormatedCurrency(itemp['value'] * iva).toString().substring(1);

      bytes += generator.text(
          (itemp['name'] +
              getEmptySpaces(11 - temp.length) +
              temp +
              getEmptySpaces(11 - temp2.length) +
              temp2),
          styles: PosStyles(bold: false, align: PosAlign.left));
    });
    return bytes;
  }

  List<int> _footer(Generator generator, List<int> bytes, bool _innerPrinter,
      Map<dynamic, dynamic>? printData) {
    bytes += generator.emptyLines(1);
    final resolution = _innerPrinter
        ? replaceSpecialCharacters(printData?['sale_data']['resolucion'])
        : printData?['sale_data']['resolucion'];
    bytes += generator.text(resolution,
        styles: PosStyles(bold: true, align: PosAlign.center));
    if (printData?['pos_note'] != '') {
      final pNote = 'Nota: ' +
          (_innerPrinter
              ? replaceSpecialCharacters(printData?['pos_note'])
              : printData?['pos_note']);
      bytes += generator.emptyLines(1);
      bytes += generator.text(pNote,
          styles: PosStyles(bold: false, align: PosAlign.center));
    }
    final List<String> footer = printData?['footer'];
    String _companyFooter = '';
    footer.forEach((element) {
      _companyFooter +=
          (_innerPrinter ? replaceSpecialCharacters(element) : element) + '\n';
    });
    bytes += generator.text(_companyFooter,
        styles: PosStyles(bold: false, align: PosAlign.center));
    bytes = wappsiSpam(_innerPrinter, bytes, generator);
    return bytes;
  }
}
