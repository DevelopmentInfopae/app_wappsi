import 'package:flutter/material.dart';
import 'package:pos_wappsi/constant.dart';

class InputDecorations {
  static InputDecoration authInputDecoration(
      {required String hintText,
      required String labelText,
      IconData? prefixIcon}) {
    return InputDecoration(
        enabledBorder: outlineInputBorder(),
        focusedBorder: outlineFocusedInputBorder(),
        hintText: hintText,
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: kTextFieldPadding,
        border: outlineInputBorder(),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18,) : null);
  }
  static InputDecoration outlineInputDecoration(
      {required String hintText,
      required String labelText,
      IconData? prefixIcon}) {
    return InputDecoration(
        enabledBorder: outlineInputBorder(),
        focusedBorder: outlineFocusedInputBorder(),
        hintText: hintText,
        labelText: labelText,
        labelStyle: TextStyle(color: greyColor),
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: kTextFieldPadding,
        border: outlineInputBorder(),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18,) : null);
  }

  static InputDecoration formInputDecoration(
      {required String hintText,
      required String labelText,
      IconData? prefixIcon}) {
    return InputDecoration(
        enabledBorder: UnderlineInputBorder(),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2)),
        hintText: hintText,
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null);
  }
}
