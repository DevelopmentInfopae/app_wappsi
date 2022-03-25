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
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: kTextFieldPadding,
        border: outlineInputBorder(),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                size: 18,
              )
            : null);
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
        fillColor: Colors.grey[50],
        contentPadding: kTextFieldPadding,
        border: outlineInputBorder(),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                size: 18,
              )
            : null);
  }

  static InputDecoration formInputDecoration(
      {required String hintText,
      required String labelText,
      IconData? prefixIcon}) {
    return InputDecoration(
        enabledBorder: const UnderlineInputBorder(),
        focusedBorder:
            const UnderlineInputBorder(borderSide: BorderSide(width: 2)),
        hintText: hintText,
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null);
  }

  static InputDecoration noBorders(
      {required String hintText,
      required String labelText,
      IconData? prefixIcon}) {
    return InputDecoration(
        // fillColor: Colors.red,
        contentPadding: EdgeInsets.zero,
        hintText: hintText,
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null);
  }
}
