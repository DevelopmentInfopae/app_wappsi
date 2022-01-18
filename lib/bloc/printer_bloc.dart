import 'dart:async';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:rxdart/subjects.dart';


class PrinterBloc {
  // to save data of user
  // final _tokenController = BehaviorSubject<String>();


  final _printerController = BehaviorSubject<BluetoothDevice?>();

 




  Stream<BluetoothDevice?> get printerDeviceStream => _printerController.stream;




  //______________________________________________________________________________________________________________
  //
  //                                       Functions
  //_______________________________________________________________________________________________________________
  // Function(String) get setToken => _tokenController.sink.add;


  //______________________________________________________________________________________________________________
  //
  //                                       GETTERS
  //_______________________________________________________________________________________________________________

  
  BluetoothDevice? get getPrinterDevice => _printerController.valueOrNull;

  //______________________________________________________________________________________________________________
  //
  //                                       SETTERS
  //_______________________________________________________________________________________________________________

  Function(BluetoothDevice?) get setPrinterDevice => _printerController.sink.add;


  
  dispose() {
   
    _printerController.close();

  }
}

final printerBloc = PrinterBloc();
