import 'package:flutter/material.dart';
import 'package:pos_wappsi/utils/parsing/to_double.dart';

TimeOfDay parseTimeOfDay(String time) {
  final timeParts = time.split(":");

  final timeOfDay = TimeOfDay(
      hour: parsingToInt(timeParts[0]), minute: parsingToInt(timeParts[1]));
  return timeOfDay;
}
