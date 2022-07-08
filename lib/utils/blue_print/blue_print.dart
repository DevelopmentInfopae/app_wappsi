import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

// import 'package:image_downloader/image_downloader.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/printer_bloc.dart';
import 'package:pos_wappsi/environment/environment.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/utils/blue_print/blue_print_functions.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
import 'package:pos_wappsi/utils/text_formating/date_to_text.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

class PrintFormat {
  PrintFormat({this.productsList, this.movementInfo, this.registerCloseInfo});
  List<Map>? productsList;
  Map<String, String>? movementInfo;
  Map<String, String>? registerCloseInfo;
  // int chrLen = 48;
  int chrLen = 32;

  int valueMaxCharLen = 12;

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  Future<bool?> printPOS(
      String pathImage, Map<dynamic, dynamic>? printData) async {
    await bluetooth.isConnected.then((isConnected) async {
      chrLen = Environment().printerPaperSize == '1' ? 32 : 48;
      if (isConnected!) {
        final _innerPrinter = ((printerBloc.getPrinterDevice?.name ??
                // ignore: unrelated_type_equality_checks
                (Environment().printerPaperSize == 1
                    ? 'InnerPrinter'
                    : null)) ==
            'InnerPrinter');
        final profile = await CapabilityProfile.load();
        final generator = Generator(
            chrLen == 32 ? PaperSize.mm58 : PaperSize.mm80, profile,
            spaceBetweenRows: 1);
        // delete print buffer

        await bluetooth.writeBytes(Uint8List.fromList(await ticketHeader(
            generator, _innerPrinter, pathImage, printData, chrLen,
            printDate: true)));
        await bluetooth.writeBytes(Uint8List.fromList(
            await ticketProducts(generator, _innerPrinter, roundPrices: true)));
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

  Future<bool?> printOrder(
      String pathImage, Map<dynamic, dynamic>? printData) async {
    await bluetooth.isConnected.then((isConnected) async {
      chrLen = Environment().printerPaperSize == '1' ? 32 : 48;
      if (isConnected!) {
        final _innerPrinter =
            (printerBloc.getPrinterDevice?.name == 'InnerPrinter');
        final profile = await CapabilityProfile.load();
        final generator = Generator(
            chrLen == 32 ? PaperSize.mm58 : PaperSize.mm80, profile,
            spaceBetweenRows: 1);
        // delete print buffer

        await bluetooth.writeBytes(Uint8List.fromList(await ticketHeader(
            generator, _innerPrinter, pathImage, printData, chrLen,
            type: 'Orden de Pedido',
            printAddrLocation: true,
            printDate: true)));
        await bluetooth.writeBytes(
            Uint8List.fromList(await ticketProducts(generator, _innerPrinter)));
        await bluetooth.writeBytes(Uint8List.fromList(
            await ticketOrdQuotValue(generator, _innerPrinter, printData)));
        await bluetooth.writeBytes(Uint8List.fromList(
            await ticketTax(generator, _innerPrinter, printData)));

        await bluetooth.writeBytes(Uint8List.fromList(
            await orderDeliveryInfo(generator, _innerPrinter, printData)));

        await bluetooth.writeBytes(Uint8List.fromList(
            await ticketFooter(generator, _innerPrinter, printData)));
      }
    });

    return true;
  }

  Future<bool?> printQuote(
      String pathImage, Map<dynamic, dynamic>? printData) async {
    await bluetooth.isConnected.then((isConnected) async {
      chrLen = Environment().printerPaperSize == '1' ? 32 : 48;
      if (isConnected!) {
        final _innerPrinter =
            (printerBloc.getPrinterDevice?.name == 'InnerPrinter');
        final profile = await CapabilityProfile.load();
        final generator = Generator(
            chrLen == 32 ? PaperSize.mm58 : PaperSize.mm80, profile,
            spaceBetweenRows: 1);
        // delete print buffer

        await bluetooth.writeBytes(Uint8List.fromList(await ticketHeader(
            generator, _innerPrinter, pathImage, printData, chrLen,
            type: 'Cotización')));
        await bluetooth.writeBytes(
            Uint8List.fromList(await ticketProducts(generator, _innerPrinter)));
        await bluetooth.writeBytes(Uint8List.fromList(
            await ticketOrdQuotValue(generator, _innerPrinter, printData)));
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
      chrLen = Environment().printerPaperSize == '1' ? 32 : 48;
      if (isConnected!) {
        final _innerPrinter =
            (printerBloc.getPrinterDevice?.name == 'InnerPrinter');
        final profile = await CapabilityProfile.load();
        final generator = Generator(
            chrLen == 32 ? PaperSize.mm58 : PaperSize.mm80, profile,
            spaceBetweenRows: 1);
        List<int> bytes = [];
        // delete print buffer
        bytes = await image(generator, 'assets/images/wappsi.png',
            assetImage: true);
        bytes += generator.text(
            'Prueba de funcionamiento de \n' +
                (_innerPrinter ? 'impresion' : 'impresión'),
            styles: const PosStyles(bold: true, align: PosAlign.center));
        bytes += generator.emptyLines(1);
        bytes = wappsiSpam(_innerPrinter, bytes, generator);

        bytes += generator.feed(1);
        // ignore: unnecessary_statements
        _innerPrinter ? null : bytes += generator.cut();

        await bluetooth.writeBytes(Uint8List.fromList(bytes));
      }
    });

    return true;
  }

  /// To print favorite products
  Future<bool?> printFavOrder(
      String pathImage, Map<dynamic, dynamic>? printData) async {
    await bluetooth.isConnected.then((isConnected) async {
      chrLen = Environment().printerPaperSize == '1' ? 32 : 48;
      final customer = printData?['customer'];
      if (isConnected!) {
        final _innerPrinter =
            (printerBloc.getPrinterDevice?.name == 'InnerPrinter');
        final profile = await CapabilityProfile.load();
        final generator = Generator(
            chrLen == 32 ? PaperSize.mm58 : PaperSize.mm80, profile,
            spaceBetweenRows: 1);
        // delete print buffer

        await bluetooth.writeBytes(Uint8List.fromList(await ticketHeader(
            generator, _innerPrinter, pathImage, printData, chrLen,
            type: 'Pre-Orden')));
        await bluetooth.writeBytes(Uint8List.fromList(
            await ticketFavProducts(generator, _innerPrinter, customer)));

        await bluetooth.writeBytes(Uint8List.fromList(
            await ticketFooter(generator, _innerPrinter, printData)));
      }
    });

    return true;
  }

  Future<bool?> printMovement(String pathImage) async {
    chrLen = Environment().printerPaperSize == '1' ? 32 : 48;
    await bluetooth.isConnected.then((isConnected) async {
      if (isConnected!) {
        final _innerPrinter =
            (printerBloc.getPrinterDevice?.name == 'InnerPrinter');
        final profile = await CapabilityProfile.load();
        final generator = Generator(
            chrLen == 32 ? PaperSize.mm58 : PaperSize.mm80, profile,
            spaceBetweenRows: 1);
        generator.spaceBetweenRows = 1;
        // generator.
        generator.setGlobalCodeTable('CP1252');
        generator.setGlobalFont(PosFontType.fontB);

        final value = getFormatedCurrency(
            double.tryParse(movementInfo!['value'].toString()) ?? 0.0);
        final Map<String, String> keyValues2 = {
          'Usuario:    ': movementInfo!['user_name'].toString(),
          'Fecha:      ': movementInfo!['date'].toString(),
          'Referencia: ': movementInfo!['reference_no'].toString(),
          'Sucursal:   ': movementInfo!['biller_name'].toString(),
          'Tipo movimiento:': movementInfo!['movement_type'].toString(),
          'Valor:      ': value.substring(0, value.length),
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
            styles: const PosStyles(bold: true, align: PosAlign.center));
        generator.reset();
        bytes += generator.emptyLines(1);
        bytes = printLabeledValues(
          generator,
          bytes,
          keyValues2.keys.toList(),
          keyValues2.values.toList(),
          _innerPrinter,
          chrLen,
          col2: PosAlign.left,
          col1: PosAlign.left,
        );

        bytes += generator.emptyLines(3);
        bytes += generator.hr(len: chrLen, ch: '_');
        bytes += generator.text('Firma y sello',
            styles: const PosStyles(align: PosAlign.center));
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

  Future<bool?> printRegisterClose(String pathImage) async {
    chrLen = Environment().printerPaperSize == '1' ? 32 : 48;
    await bluetooth.isConnected.then((isConnected) async {
      if (isConnected!) {
        final _innerPrinter =
            (printerBloc.getPrinterDevice?.name == 'InnerPrinter');
        final profile = await CapabilityProfile.load();
        final generator = Generator(
            chrLen == 32 ? PaperSize.mm58 : PaperSize.mm80, profile,
            spaceBetweenRows: 1);
        generator.spaceBetweenRows = 1;
        // generator.
        generator.setGlobalCodeTable('CP1252');
        generator.setGlobalFont(PosFontType.fontB);

        final value = getFormatedCurrency(
            double.tryParse((registerCloseInfo?['value'] ?? '').toString()) ??
                0.0,
            decimals: 0);
        final Map<String, String> keyValues2 = {
          'Usuario:  ': (registerCloseInfo?['user_name'] ?? '').toString(),
          'Fecha:    ': (registerCloseInfo?['date'] ?? '').toString(),
          'Sucursal: ': (registerCloseInfo?['biller_name'] ?? '').toString(),
          // 'Tipo movimiento:': (registerCloseInfo?['movement_type']??'').toString(),
          'Valor:    ': value,
        };

        List<int> bytes = [];

        // delete print buffer
        bytes = await image(generator, pathImage, assetImage: false);
        bytes += generator.text(
            _innerPrinter
                ? replaceSpecialCharacters(
                    dataBloc.settings?['razon_social'] ?? '')
                : dataBloc.settings?['razon_social'] ?? '',
            styles: const PosStyles(bold: true, align: PosAlign.center));
        bytes += generator.emptyLines(1);
        bytes += generator.text('Cierre de caja',
            styles: const PosStyles(bold: true, align: PosAlign.center));
        generator.reset();
        bytes += generator.emptyLines(1);
        bytes = printLabeledValues(
          generator,
          bytes,
          keyValues2.keys.toList(),
          keyValues2.values.toList(),
          _innerPrinter,
          chrLen,
          col2: PosAlign.left,
          col1: PosAlign.left,
        );

        bytes += generator.emptyLines(3);
        bytes += generator.hr(len: chrLen, ch: '_');
        bytes += generator.text('Firma y sello',
            styles: const PosStyles(align: PosAlign.center));
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
      String pathImage, Map<dynamic, dynamic>? printData, int chrLen,
      {String type = 'Factura POS',
      bool printAddrLocation = false,
      bool printDate = false}) async {
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
    final data = printData?['sale_data']?['data'] ??
        printData?['sale_data'] ??
        printData?['order_data'] ??
        printData?['quote_data'];
    final date = data != null
        ? data['date'] ?? data['current_server_date'] ?? ''
        : DateTime.now().toString();
    final customer = printData?['customer'];
    final customerAddres =
        printData?['customer_address'] ?? printData?['customer'];
    final Map zoneSzoneData = printData?['zone_szone_data'] ?? {};
    final companyData = printData?['company_data'];
    final regType = settings?['tipo_regimen'];

    final labelsCustomer = [
      'Cliente: ',
      'NIT/CC: ',
      innerPrinter ? 'Direccion: ' : 'Dirección: ',
    ];

    final valuesCustomer = [
      capitalizeText(innerPrinter
          ? replaceSpecialCharacters(customer['name'])
          : customer['name']),
      customer['vat_no'].toString(),
      capitalizeText(innerPrinter
              ? (replaceSpecialCharacters(customerAddres['direccion'] ??
                  customerAddres['address'] +
                      '-' +
                      capitalizeText(customerAddres['city'])))
              : customerAddres['direccion'] ??
                  customerAddres['address'] +
                      '-' +
                      capitalizeText(customerAddres['city']))
          .toString(),
    ];

    if (printAddrLocation) {
      labelsCustomer.add('Zona/Barrio: ');
      valuesCustomer.add(capitalizeText(
          (zoneSzoneData['zone_data']?["zone_name"] ?? '--') +
              ' / ' +
              (zoneSzoneData['subzone_data']?["subzone_name"] ?? '--')));
    }
    labelsCustomer.add('Email: ');
    valuesCustomer.add(customer['email'].toString());
    final labelsSeller = ['Vendedor: '];
    final valuesSeller = [
      innerPrinter
          ? replaceSpecialCharacters(dataBloc.userData!.sellerName)
          : dataBloc.userData!.sellerName
    ];
    if (printDate) {
      labelsSeller.add('Fecha/Hora:');
      // valuesSeller.add(parseDateStrES(date) + ' ' + parseTimeStrES(date));
      valuesSeller.add(date);
    }

    //image
    bytes += await image(generator, pathImage);

    //legal info
    bytes = legalInfo(
        bytes, generator, innerPrinter, settings, regType, companyData);
    bytes += generator.emptyLines(1);
    //invoice data
    bytes = invoiceData(bytes, generator, data, type);
    bytes += generator.emptyLines(1);
    //customer data
    generator.reset();
    bytes = printLabeledValues(
      generator,
      bytes,
      labelsCustomer,
      valuesCustomer,
      innerPrinter,
      chrLen,
      col2: PosAlign.left,
      col1: PosAlign.left,
    );
    //seller data
    generator.reset();
    bytes = printLabeledValues(
        generator, bytes, labelsSeller, valuesSeller, innerPrinter, chrLen,
        col2: PosAlign.left, col1: PosAlign.left);

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
      'Total         ',
      'Valor recibido',
      'Cambio        ',
      'Pagado en     '
    ];
    final valuesPayDetails = [
      getFormatedCurrency((printData!['total']! ?? '')).toString().substring(1),
      valueRec,
      getFormatedCurrency(cambio < 0 ? 0 : cambio).toString().substring(1),
      printData['payment_method']['name'].toString()
    ];
    generator.reset();
    bytes = printLabeledValues(generator, bytes, labelsPayDetails,
        valuesPayDetails, innerPrinter, chrLen,
        col2: PosAlign.left, col1: PosAlign.left);

    return bytes;
  }

  Future<List<int>> ticketOrdQuotValue(Generator generator, bool innerPrinter,
      Map<dynamic, dynamic>? printData) async {
    List<int> bytes = [];
    // delete print buffer
    generator.reset();
    generator.spaceBetweenRows = 1;
    // generator.
    generator.setGlobalCodeTable('CP1252');
    generator.setGlobalFont(PosFontType.fontB);

    final labelsPayDetails = [
      'Subtotal',
      'Descuento',
      'Total',
    ];
    final valuesPayDetails = [
      getFormatedCurrency((printData?['total']! ?? '')),
      getFormatedCurrency((printData?['total_discount']! ?? '')),
      getFormatedCurrency((printData?['grand_total']! ?? ''))
    ];
    generator.reset();
    bytes = printLabeledValues(generator, bytes, labelsPayDetails,
        valuesPayDetails, innerPrinter, chrLen,
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

  Future<List<int>> orderDeliveryInfo(Generator generator, bool innerPrinter,
      Map<dynamic, dynamic>? printData) async {
    //init print format values
    List<int> bytes = [];
    // delete print buffer
    generator.reset();
    generator.spaceBetweenRows = 1;
    // generator.
    generator.setGlobalCodeTable('CP1252');
    generator.setGlobalFont(PosFontType.fontA);
    // generator.setStyles(const PosStyles(
    //     bold: true, height: PosTextSize.size1, align: PosAlign.center));
    bytes = _deliveryInfo(generator, bytes, innerPrinter, printData);
    // // ignore: unnecessary_statements
    // bytes += generator.feed(1);
    // ignore: unnecessary_statements
    // innerPrinter ? null : bytes += generator.cut();
    return bytes;
  }

  Future<List<int>> ticketProducts(Generator generator, bool innerPrinter,
      {bool roundPrices = false}) async {
    //init print format values
    List<int> bytes = [];
    // delete print buffer
    generator.reset();
    generator.spaceBetweenRows = 1;
    // generator.
    generator.setGlobalCodeTable('CP1252');
    generator.setGlobalFont(PosFontType.fontB);
    // generator.setGlobalFont(PosFontType.fontB);
    // bytes += generator.hr(len: chrLen, ch: '_');

    if (dataBloc.settings!['prioridad_precios_producto'] == 10) {
      bytes = await ticketProductsPP10(generator, innerPrinter);
    } else if (dataBloc.settings!['prioridad_precios_producto'] == 6) {
      bytes = await ticketProductsPP6(generator, innerPrinter,
          roundPrices: roundPrices);
    }

    return bytes;
  }

  Future<List<int>> ticketProductsPP6(Generator generator, bool innerPrinter,
      {bool roundPrices = false}) async {
    //init print format values
    List<int> bytes = [];
    // delete print buffer
    generator.reset();
    generator.spaceBetweenRows = 1;
    // generator.
    generator.setGlobalCodeTable('CP1252');
    generator.setGlobalFont(PosFontType.fontB);
    // bytes += generator.hr(len: chrLen, ch: '_');

    int qttyLenght = 2;
    int valueLenght = 0;
    // to get value and qtty max values
    for (var element in productsList!) {
      if (getRoundedQtty(element['quantity']).length > qttyLenght) {
        qttyLenght = getRoundedQtty(element['quantity']).length;
      }
      final price = element['quantity'] * element['price'];
      String vTemp = getFormatedCurrency(price).substring(1);
      vTemp = vTemp.substring(
          0,
          vTemp.length > valueMaxCharLen
              ? vTemp.length - (vTemp.length - vTemp.split('.').first.length)
              : vTemp.length);
      if (vTemp.length > valueLenght && vTemp.length < valueMaxCharLen) {
        valueLenght = vTemp.length;
      }
    }

    final qttyEmptSpces = (qttyLenght - 5) > 0 ? (qttyLenght - 5) : 0;
    final header = 'CT ' +
        getEmptySpaces(qttyEmptSpces) +
        'Producto' +
        getEmptySpaces(chrLen - (16 + qttyEmptSpces)) +
        'Valor';

    bytes += generator.text(header,
        styles: const PosStyles(bold: true, align: PosAlign.left));
    bytes += generator.hr(len: chrLen, ch: '-');
    for (var element in productsList!) {
      List<String> formatedS = formatString(element['name'].toString(),
          chrSpaces: (chrLen - (qttyLenght + valueLenght + 2)));
      String text = '';
      // text = '';
      final price = element['quantity'] * element['price'];

      String value =
          getFormatedCurrency(price, decimals: roundPrices ? 0 : null)
              .substring(1);
      value = value.substring(
          0,
          value.length > valueMaxCharLen
              ? value.length - (value.length - value.split('.').first.length)
              : value.length);
      final qttyDouble = element['quantity'];
      final qtty = getRoundedQtty(qttyDouble);

      for (var str in formatedS) {
        if (str == formatedS.first) {
          final namePart = innerPrinter ? replaceSpecialCharacters(str) : str;

          text = qtty +
              getEmptySpaces((qttyLenght + 1) - qtty.length) +
              namePart +
              getEmptySpaces(
                  (chrLen - (qttyLenght + valueLenght + 2)) - namePart.length) +
              getEmptySpaces((valueLenght + 1) - value.length) +
              value;
        } else {
          final namePart = innerPrinter ? replaceSpecialCharacters(str) : str;
          final emptySpace = chrLen - (namePart.length + qttyLenght + 1);
          text += getEmptySpaces(qttyLenght + 1) +
              namePart +
              getEmptySpaces(emptySpace);
        }
      }
      bytes += generator.text(text,
          styles: const PosStyles(bold: false, align: PosAlign.left));
    }
    // bluetooth.printNewLine();
    bytes += generator.feed(1);
    // bytes += generator.hr(len: chrLen, ch: '-');
    return bytes;
  }

  Future<List<int>> ticketProductsPP10(
    Generator generator,
    bool innerPrinter,
  ) async {
    //init print format values
    List<int> bytes = [];
    // delete print buffer

    int qttyLenght = 2;
    int valueLenght = 0;
    int umdLenght = 0;
    // to get value and qtty max values
    for (var element in productsList!) {
      if (dataBloc.settings!['prioridad_precios_producto'] == 10) {
        final qttyDouble = element['quantity'];
        final unitOpertor = element['unit']['operation_value'];
        final qtty = qttyDouble / (unitOpertor ?? 1);
        if (getRoundedQtty(qtty).length > qttyLenght) {
          qttyLenght = getRoundedQtty(qtty).length;
        }
        if (element['unit']['code'].length > umdLenght) {
          umdLenght = element['unit']['code'].length;
        }
      } else {
        if (getRoundedQtty(element['quantity']).length > qttyLenght) {
          qttyLenght = getRoundedQtty(element['quantity']).length;
        }
      }
      final price = element['quantity'] * element['price'];
      String vTemp = getFormatedCurrency(price).substring(1);
      vTemp = vTemp.substring(
          0,
          vTemp.length > valueMaxCharLen
              ? vTemp.length - (vTemp.length - vTemp.split('.').first.length)
              : vTemp.length);
      if (vTemp.length > valueLenght && vTemp.length < valueMaxCharLen) {
        valueLenght = vTemp.length;
      }
    }

    final qttyEmptSpces = (qttyLenght - 3) > 0 ? (qttyLenght - 3) : 0;
    final umdEmptSpcs = (umdLenght - 3) > 0 ? (umdLenght - 3) : 0;
    final header = 'CT ' +
        getEmptySpaces(qttyEmptSpces) +
        'UM ' +
        getEmptySpaces(umdEmptSpcs) +
        'Producto' +
        getEmptySpaces(chrLen - (20 + qttyEmptSpces + umdEmptSpcs)) +
        'Valor';

    bytes += generator.text(header,
        styles: const PosStyles(bold: true, align: PosAlign.left));
    bytes += generator.hr(len: chrLen, ch: '-');
    String text = '';
    for (var element in productsList!) {
      List<String> formatedS = formatString(element['name'].toString(),
          chrSpaces: (chrLen - (qttyLenght + valueLenght + umdLenght + 3)));

      // text = '';
      final price = element['quantity'] * element['price'];

      String value = getFormatedCurrency(price).substring(1);
      value = value.substring(
          0,
          value.length > valueMaxCharLen
              ? value.length - (value.length - value.split('.').first.length)
              : value.length);
      final qttyDouble = element['quantity'];
      final qtty = getRoundedQtty(qttyDouble);

      final unitCode = element['unit']['code'];
      final unitOpertor = element['unit']['operation_value'];
      for (var str in formatedS) {
        if (str == formatedS.first) {
          final namePart = innerPrinter ? replaceSpecialCharacters(str) : str;

          text += getRoundedQtty(qttyDouble / (unitOpertor ?? 1)) +
              getEmptySpaces((qttyLenght + 1) - qtty.length) +
              unitCode +
              getEmptySpaces(((umdLenght + 1) - unitCode.length).toInt()) +
              namePart +
              getEmptySpaces((chrLen -
                  (qttyLenght +
                      umdLenght +
                      valueLenght +
                      3 +
                      namePart.length))) +
              getEmptySpaces((valueLenght + 1) - value.length) +
              value;
        } else {
          final namePart = innerPrinter ? replaceSpecialCharacters(str) : str;
          text += getEmptySpaces(qttyLenght + umdLenght + 2) +
              namePart +
              getEmptySpaces(
                  chrLen - (namePart.length + umdLenght + qttyLenght + 2));
        }
      }

      if (element['base_unit'] != null) {
        final bUnit = element['base_unit'];
        final bUnitValue = price / element['unit']['operation_value'];
        final bUnitValueS = getFormatedCurrency(bUnitValue);
        final unitP = bUnit['code'].toString() + ' x ' + bUnitValueS;
        text += getEmptySpaces(qttyLenght + umdLenght + 2) +
            unitP +
            getEmptySpaces(
                chrLen - (unitP.length + umdLenght + qttyLenght + 2));
        // bytes += generator.text(bUnitDetails,
        //     styles: const PosStyles(bold: false, align: PosAlign.left));
      }
      if (element['preferences'] != null && element['preferences'] != '') {
        final String preferences = (element['preferences'] ?? '');
        List<String> formatedS = formatString(preferences.toString(),
            chrSpaces: (chrLen - (qttyLenght + valueLenght + umdLenght + 3)));
        for (var str in formatedS) {
          text += getEmptySpaces(qttyLenght + umdLenght + 2) +
              capitalizeText(str) +
              getEmptySpaces(
                  chrLen - (str.length + umdLenght + qttyLenght + 2));
        }

        // bytes += generator.text(bUnitDetails,4
        //     styles: const PosStyles(bold: false, align: PosAlign.left));
      }
    }
    bytes += generator.text(text,
        styles: const PosStyles(bold: false, align: PosAlign.left));
    // bluetooth.printNewLine();
    bytes += generator.feed(1);
    // bytes += generator.hr(len: chrLen, ch: '-');
    return bytes;
  }

  Future<List<int>> ticketFavProducts(Generator generator, bool innerPrinter,
      Map<String, dynamic> customer) async {
    //init print format values
    List<int> bytes = [];
    // delete print buffer
    int spacesAfterUName = 4;
    int spacesBeforeUName = 1;

    generator.reset();
    generator.spaceBetweenRows = 1;
    // generator.
    generator.setGlobalCodeTable('CP1252');
    generator.setGlobalFont(PosFontType.fontB);
    // bytes += generator.hr(len: chrLen, ch: '_');
    bytes += generator.text('Mis Productos Favoritos',
        styles: const PosStyles(bold: true, align: PosAlign.center));
    bytes += generator.hr(len: chrLen, ch: '-');

    for (var element in productsList!) {
      List<String> formatedS =
          formatString(element['name'].toString(), chrSpaces: chrLen);
      String text = '';
      // text = '';

      for (var str in formatedS) {
        if (str == formatedS.first) {
          final namePart = innerPrinter ? replaceSpecialCharacters(str) : str;
          text = namePart + getEmptySpaces(chrLen - (namePart.length));
        } else {
          final namePart = innerPrinter ? replaceSpecialCharacters(str) : str;
          text += namePart + getEmptySpaces(chrLen - (namePart.length));
        }
      }
      bytes += generator.text(text,
          styles: const PosStyles(
              bold: true, align: PosAlign.left, fontType: PosFontType.fontB));
      final units = await UnitsProvider.getProductUnits(
          element['id_cloud'].toString(),
          customer['price_group_id'].toString());
      String unitsText = '';
      for (UnitsModel element in units) {
        List<String> formatedU =
            formatString(element.name.toString(), chrSpaces: (chrLen - (15)));

        for (String fU in formatedU) {
          final value = getFormatedCurrency(element.unitValue, decimals: 0);
          if (fU == formatedU.first) {
            final namePart = innerPrinter ? replaceSpecialCharacters(fU) : fU;
            unitsText = getEmptySpaces(spacesBeforeUName) +
                namePart +
                getEmptySpaces(chrLen -
                    (spacesBeforeUName +
                        namePart.length +
                        value.length +
                        spacesAfterUName +
                        1)) +
                ' ' +
                value +
                ('_' * (spacesAfterUName));
          } else {
            final namePart = innerPrinter ? replaceSpecialCharacters(fU) : fU;
            unitsText += getEmptySpaces(spacesBeforeUName) +
                namePart +
                getEmptySpaces(chrLen - (namePart.length + spacesAfterUName));
          }
        }
        bytes += generator.text(unitsText,
            styles: const PosStyles(bold: false, align: PosAlign.left));
      }
    }
    bytes += generator.feed(1);
    // bytes += generator.hr(len: chrLen, ch: '-');
    return bytes;
  }

  Future<List<int>> ticketTax(Generator generator, bool innerPrinter,
      Map<dynamic, dynamic>? printData) async {
    //init print format values
    List<int> bytes = [];
    final header = 'Tarifa' +
        getEmptySpaces(((chrLen - 18) / 2).floor()) +
        'Base' +
        getEmptySpaces(((chrLen - 18) / 2).ceil()) +
        'Impuesto';
    // delete print buffer
    generator.reset();
    generator.spaceBetweenRows = 1;
    // generator.
    generator.setGlobalCodeTable('CP1252');
    generator.setGlobalFont(PosFontType.fontB);
    bytes += generator.emptyLines(1);
    bytes += generator.text('Resumen de impuestos',
        styles: const PosStyles(bold: true, align: PosAlign.center));
    bytes += generator.text(header,
        styles: const PosStyles(bold: true, align: PosAlign.center));
    bytes += generator.hr(len: chrLen, ch: '-');

    printData?['iva'].keys.toList().forEach((element) async {
      final itemp = printData['iva']![element]!;
      double iva = element > 1 ? element / 100 : element;
      String name = itemp['name'];
      String temp = getFormatedCurrency(itemp['value']).substring(1);
      String temp2 = getFormatedCurrency(itemp['value'] * iva).substring(1);
      final tEmptySps = chrLen - (name.length + temp.length + temp2.length);
      String textToPrint = (name +
          getEmptySpaces((tEmptySps / 2).floor()) +
          temp +
          getEmptySpaces((tEmptySps / 2).ceil()) +
          temp2);
      bytes += generator.text((textToPrint),
          styles: const PosStyles(bold: false, align: PosAlign.center));
    });
    return bytes;
  }

  List<int> _footer(Generator generator, List<int> bytes, bool _innerPrinter,
      Map<dynamic, dynamic>? printData) {
    final data = printData?['sale_data']?['data'] ??
        printData?['sale_data'] ??
        printData?['order_data'];
    bytes += generator.emptyLines(1);
    if (data != null) {
      if (data['resolucion'] != null) {
        final resolution = _innerPrinter
            ? replaceSpecialCharacters(data['resolucion'] ?? '')
            : data['resolucion'] ?? '';
        bytes += generator.text(resolution,
            styles: const PosStyles(bold: true, align: PosAlign.center));
      }
    }
    if (data?['pos_note'] != null) {
      final pNote = 'Nota: ' +
          (_innerPrinter
              ? replaceSpecialCharacters(data?['pos_note'] ?? '')
              : data?['pos_note']);
      bytes += generator.emptyLines(1);
      bytes += generator.text(pNote,
          styles: const PosStyles(bold: false, align: PosAlign.center));
    }
    final List<String>? footer = data?['footer'];
    String _companyFooter = '';
    if (footer != null) {
      for (var element in footer) {
        _companyFooter +=
            (_innerPrinter ? replaceSpecialCharacters(element) : element) +
                '\n';
      }
      bytes += generator.text(_companyFooter,
          styles: const PosStyles(bold: false, align: PosAlign.center));
    }

    bytes = wappsiSpam(_innerPrinter, bytes, generator);
    return bytes;
  }

  List<int> _deliveryInfo(Generator generator, List<int> bytes,
      bool _innerPrinter, Map<dynamic, dynamic>? printData) {
    final data = printData?['order_data'];
    bytes += generator.emptyLines(1);
    if (data != null) {
      try {
        if (data['delivery_text'] != null) {
          final deliveryTime = _innerPrinter
              ? replaceSpecialCharacters(data['delivery_text'] ?? '')
              : data['delivery_text'] ?? '';
          bytes += generator.text('Franja Horaria',
              styles: const PosStyles(align: PosAlign.center));
          bytes += generator.text(deliveryTime,
              styles: const PosStyles(
                  bold: true,
                  align: PosAlign.center,
                  height: PosTextSize.size2,
                  width: PosTextSize.size2));
        }
      } catch (e) {
        printConsole(e);
      }
      try {
        if (data['delivery_day'] != null) {
          final deliveryDay = _innerPrinter
              ? replaceSpecialCharacters(data['delivery_day'] ?? '')
              : data['delivery_day'] ?? '';
          final formatedDeliveryDay = parseDateStrES(deliveryDay);
          bytes += generator.text('Fecha de entrega',
              styles: const PosStyles(align: PosAlign.center));
          bytes += generator.text(capitalizeText(formatedDeliveryDay),
              styles: const PosStyles(
                  bold: true,
                  align: PosAlign.center,
                  height: PosTextSize.size1,
                  width: PosTextSize.size1));
        }
      } catch (e) {
        printConsole(e);
      }
    }

    return bytes;
  }
}
