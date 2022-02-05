// ignore_for_file: avoid_print

import 'package:pos_wappsi/environment/environment.dart';

printConsole(var error){
  Environment().config.printErrors?null:print(error);
}