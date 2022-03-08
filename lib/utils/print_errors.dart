// ignore_for_file: avoid_print

// import 'package:flutter/foundation.dart';
import 'package:pos_wappsi/environment/environment.dart';

printConsole(var error) {
  Environment().config.printErrors ? print(error.toString()) : null;
}
