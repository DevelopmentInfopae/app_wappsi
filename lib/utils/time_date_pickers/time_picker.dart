import 'package:flutter/material.dart';

Future<TimeOfDay?> selectTime(BuildContext context) async {
  final TimeOfDay? timeOfDay = await showTimePicker(
    builder: (BuildContext context, Widget? child) {
      final Widget mediaQueryWrapper = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          alwaysUse24HourFormat: false,
        ),
        child: child ?? Container(),
      );
      // A hack to use the es_US dateTimeFormat value.
      if (Localizations.localeOf(context).languageCode == 'es') {
        return Localizations.override(
          context: context,
          locale: const Locale('es'),
          child: mediaQueryWrapper,
        );
      }
      return mediaQueryWrapper;
    },
    context: context,
    initialTime: const TimeOfDay(hour: 0, minute: 0),
    initialEntryMode: TimePickerEntryMode.dial,
  );
  return timeOfDay;
}
