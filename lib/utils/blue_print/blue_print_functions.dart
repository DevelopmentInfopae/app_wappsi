import 'dart:io';
import 'dart:typed_data';

import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:pos_wappsi/config/regimen_person_type_form_params.dart';
import 'package:pos_wappsi/config/thermal_printer_params.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

// return bytes of two columns labes : values
List<int> printLabeledValues(Generator generator, List<int> bytes,
    List<String> labels, List<String> values, bool _innerPrinter,
    {bool boldLabels = true,
    PosAlign col1 = PosAlign.left,
    PosAlign col2 = PosAlign.left}) {
  generator.reset();

  const numChr = 32;

  for (var i = 0; i < labels.length; i++) {
    final value =
        _innerPrinter ? replaceSpecialCharacters(values[i]) : values[i];
    final label =
        _innerPrinter ? replaceSpecialCharacters(labels[i]) : labels[i];

    const maxCols = 12;

    const magicN = numChr / maxCols;

    final column1Width = ((maxCols * label.length) / numChr).round();
    final column2Width = maxCols - column1Width;

    // Idk why -1 works
    final emptySpacesCol2Total = (32 - ((column1Width) * magicN).round());

    final valueCol2Len =
        value.length < emptySpacesCol2Total ? (value.length + 1) : value.length;
    final emptySpacesCol2 =
        (emptySpacesCol2Total - (valueCol2Len).toInt()).abs();

    if (column1Width < 12) {
      bytes += generator.row([
        PosColumn(
          text: label,
          width: column1Width,
          styles: PosStyles(align: col1, bold: boldLabels),
        ),
        PosColumn(
          text: getEmptySpaces(emptySpacesCol2) + value,
          width: column2Width,
          styles: PosStyles(align: col2),
        ),
      ]);
    } else {
      bytes += generator.text(label,
          styles: PosStyles(align: col1, bold: boldLabels));
    }

    if ((valueCol2Len - 1) > emptySpacesCol2Total) {
      final start = emptySpacesCol2;
      final end = value.length;
      final str = value.substring(start, end);
      bytes += generator.text(str, styles: PosStyles(align: col2));
    }
  }

  return bytes;
}

List<int> printLabelValues(Generator generator, List<int> bytes,
    List<String> labels, List<String> values, bool innerPrinter,
    {bool boldLabels = true,
    PosAlign col1 = PosAlign.left,
    PosAlign col2 = PosAlign.left}) {
  generator.reset();

  for (var i = 0; i < labels.length; i++) {
    final label =
        innerPrinter ? replaceSpecialCharacters(labels[i]) : labels[i];
    final value =
        innerPrinter ? replaceSpecialCharacters(values[i]) : values[i];
    // bytes += generator.text(label+getEmptySpaces(32-label.length-value.length)+value);
    int column1Width = (label.length / spPerCol).round();
    int column2Width = 12 - column1Width;

    List<String> formatedS =
        formatString(value, chrSpaces: (column2Width * spPerCol).round());

    for (var str in formatedS) {
      // text = '';
      if (str == formatedS.first) {
        bytes += generator.row([
          PosColumn(
            text: label,
            width: column1Width,
            styles: PosStyles(align: col1, bold: boldLabels),
          ),
          PosColumn(
            text:
                getEmptySpaces((column2Width * 2.6).round() - str.length) + str,
            width: column2Width,
            styles: PosStyles(align: col2),
          ),
        ]);
      } else {
        bytes += generator.row([
          PosColumn(
            text: getEmptySpaces(label.length),
            width: column1Width,
            styles: PosStyles(align: col1, bold: boldLabels),
          ),
          PosColumn(
            text: str,
            width: column2Width,
            styles: PosStyles(align: col2),
          ),
        ]);
      }
    }
  }

  return bytes;
}

// return bytes Info of current company
List<int> legalInfo(List<int> bytes, Generator generator, bool _innerPrinter,
    settings, regType, companyData) {
  bytes += generator.text(
      _innerPrinter
          ? replaceSpecialCharacters(settings?['razon_social'])
          : settings?['razon_social'],
      styles: const PosStyles(bold: true, align: PosAlign.center));

  bytes += generator.emptyLines(1);
  bytes += generator.text(
      'NIT:' +
          (_innerPrinter
              ? (replaceSpecialCharacters(settings?['numero_documento']))
              : (((settings?['numero_documento'] ?? '').toString()))),
      styles: const PosStyles(bold: false, align: PosAlign.center));
  bytes += generator.text(
      _innerPrinter
          ? replaceSpecialCharacters(regimenT[regType.toString()]!.name)
          : (regimenT[regType.toString()]!.name),
      styles: const PosStyles(bold: true, align: PosAlign.center));

  final dir = _innerPrinter
      ? capitalizeText(replaceSpecialCharacters(
          (companyData!.address ?? '') + '-' + companyData.city ?? ''))
      : capitalizeText(
          (companyData!.address ?? '') + '-' + (companyData.city ?? ''));
  bytes += generator.text(dir,
      styles: const PosStyles(bold: false, align: PosAlign.center));
  bytes += generator.text(
      'Telefono:' +
          (_innerPrinter
              ? replaceSpecialCharacters(companyData.phone ?? '')
              : (companyData.phone ?? '').toString()),
      styles: const PosStyles(bold: false, align: PosAlign.center));
  return bytes;
}

// Returns bytes from sale reference
List<int> invoiceData(List<int> bytes, Generator generator, saleData) {
  bytes += generator.text('Factura POS ',
      styles: const PosStyles(bold: false, align: PosAlign.center));
  bytes += generator.text(saleData['reference_no'],
      styles: const PosStyles(bold: true, align: PosAlign.center));
  return bytes;
}

// Return image Bytes of a given local
image(Generator generator, String pathImage, {bool assetImage = false}) async {
  Uint8List imgBytes;
  if (assetImage) {
    final ByteData imBytes = await rootBundle.load(pathImage);
    imgBytes = imBytes.buffer.asUint8List();
  } else {
    final file = File(pathImage);
    imgBytes = await file.readAsBytes();
  }
  final Image image = decodeImage(imgBytes)!;

  return generator.image(image);
  // return imgBytes;
}

List<String> formatString(String v, {int chrSpaces = 18}) {
  int lines = (v.length / chrSpaces).ceil();
  List<String> strList = [];
  if (lines == 0) {
    lines = 1;
    return [v];
  }

  for (int i = 0; i < lines; i++) {
    strList.add(v.substring(
        i == 0 ? 0 : (i * chrSpaces),
        i * chrSpaces + chrSpaces > v.length
            ? v.length
            : i * chrSpaces + chrSpaces));
  }

  return strList;
}

List<int> wappsiSpam(bool _innerPrinter, List<int> bytes, Generator generator) {
  final wappsiSpam = 'Impreso por Wappsi POS ' +
      (_innerPrinter ? 'Movil' : 'Móvil') +
      '\n www.wappsi.com';
  bytes += generator.text(wappsiSpam,
      styles: const PosStyles(bold: false, align: PosAlign.center));
  return bytes;
}
