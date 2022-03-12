

import 'dart:convert';

import 'package:pos_wappsi/utils/print_errors.dart';

Map? decodeJson(dynamic element){
  Map? result;

  element = element.toString();
  
  try {
    result = jsonDecode(element);
  } catch (e) {
    printConsole(e);
  }
  return result;
} 