import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

String parseDateStrES(String inputString) {
  initializeDateFormatting('es'); // This will initialize Spanish locale
  DateFormat format = DateFormat.yMMMMEEEEd('es');
  try {
    return format.format(DateTime.parse(inputString));
  } catch (e) {
    return '';
  }
}

String parseTimeStrES(String inputString) {
  initializeDateFormatting('es'); // This will initialize Spanish locale
  DateFormat format = DateFormat.Hm('es');
  try {
    return format.format(DateTime.parse(inputString));
  } catch (e) {
    return '';
  }
}

String formatTimeOfDay(TimeOfDay tod) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
  final format = DateFormat.jm(); //"6:00 AM"
  return format.format(dt);
}
