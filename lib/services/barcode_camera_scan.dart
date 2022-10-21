import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

Future<void> startBarcodeScanStream() async {
  FlutterBarcodeScanner.getBarcodeStreamReceiver(
    '#ff6666',
    'Cancel',
    true,
    ScanMode.BARCODE,
  )!
      .listen((barcode) => printConsole(barcode));
}

// Platform messages are asynchronous, so we initialize in an async method.
Future<String?> scanBarcodeNormal() async {
  String barcodeScanRes;
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancelar',
      true,
      ScanMode.BARCODE,
    );
    printConsole(barcodeScanRes);
  } on PlatformException {
    barcodeScanRes = 'Fallo al obtener versión de plataforma.';
  }

  // If the widget was removed from the tree while the asynchronous platform
  // message was in flight, we want to discard the reply rather than calling
  // setState to update our non-existent appearance.
  // if (!mounted) return;
  if (barcodeScanRes == '-1') {
    return '';
  }
  return barcodeScanRes;
}
