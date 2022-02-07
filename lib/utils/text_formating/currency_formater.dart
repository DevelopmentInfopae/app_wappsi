// import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0 || newValue.text == '\$') {
      // printConsole(true);
      return newValue;
    }

    double value =
        double.parse(newValue.text.replaceAll('\$', '').replaceAll(',', ''));

    final formatter =
        NumberFormat.simpleCurrency(locale: "en", decimalDigits: 0);

    String newText = formatter.format(value);

    return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length));
  }
}
