// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

// const kMainColor = Color(0xFF3F8CFF);
const kMainColor = Color(0xFF007AD0);
const kGreyTextColor = Color(0xFF828282);
const kBorderColorTextField = Color(0xFFC2C2C2);
const kDarkWhite = Color(0xFFF1F7F7);
const pColor = Color.fromRGBO(0, 125, 204, 1);
const okColor = Color.fromRGBO(21, 178, 106, 1);
const okColorWappsi = Color.fromRGBO(0, 176, 82, 1);

const kIconSize = 19.0;

const kButtonDecoration = BoxDecoration(
  borderRadius: BorderRadius.all(
    Radius.circular(5),
  ),
);

const kButtonPadding = EdgeInsets.all(10);
const kIconButtonPadding = EdgeInsets.all(15);

const kIconPadding = EdgeInsets.all(5);

const kTextFieldPadding = EdgeInsets.symmetric(vertical: 12.0, horizontal: 15);
const kTextFieldPaddingSmall =
    EdgeInsets.symmetric(vertical: 8, horizontal: 16);

const kInputDecoration = InputDecoration(
  hintStyle: TextStyle(color: kBorderColorTextField),
  filled: true,
  fillColor: Colors.white70,
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: kBorderColorTextField, width: 2),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6.0)),
    borderSide: BorderSide(color: kBorderColorTextField, width: 2),
  ),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.0),
    borderSide: const BorderSide(color: kBorderColorTextField),
  );
}

OutlineInputBorder outlineFocusedInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.0),
    borderSide: const BorderSide(color: pColor),
  );
}

final otpInputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
  border: outlineInputBorder(),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.0),
    borderSide: const BorderSide(color: pColor),
  ),
  enabledBorder: outlineInputBorder(),
);

TextStyle buttonsTextStyle(BuildContext context,
    {fontSizeFactor = 1.2, fontWeightDelta = 1, color = Colors.white}) {
  return Theme.of(context).primaryTextTheme.headline6!.apply(
      fontSizeFactor: fontSizeFactor,
      color: color,
      fontWeightDelta: fontWeightDelta);
}

TextStyle buttonsSmallTextStyle(BuildContext context,
    {double fontSizeFactor = 0.95, Color? color}) {
  return Theme.of(context)
      .primaryTextTheme
      .headline6!
      .apply(fontSizeFactor: fontSizeFactor, color: color ?? greyColor);
}

TextStyle appBarTextStyle({double fontSizeFactor = 1}) {
  return TextStyle(fontWeight: FontWeight.w900, fontSize: 20 * fontSizeFactor);
}

TextStyle normalTextStyle(BuildContext context,
    {fontSizeFactor = 1.0, int fontWeightDelta = 0, Color? color}) {
  return Theme.of(context).primaryTextTheme.subtitle1!.apply(
      fontSizeFactor: fontSizeFactor,
      color: color ?? greyDarkerColor,
      fontWeightDelta: fontWeightDelta);
}

double bottomBarIconSize(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return size.height * 0.1 > 66
      ? (size.height * 0.1 > 70 ? 42 : size.height * 0.0555)
      : 38;
}

double iconSize(BuildContext context) {
  final _size = MediaQuery.of(context).size;
  return _size.height * 0.038 > 30 ? _size.height * 0.038 : 30;
}

/// Default height of search field
double searchHeight = 55;

/// Default height of leading widget of appBar
double leadingWidgetSize = 50;

/// Default height of icon of leading widget of appBar
double leadingIconSize = 27;

/// Color to subtitles
Color greyColor = Colors.grey[700]!;

Color greyLight = Colors.grey[100]!;

Color greyMediumLight = Colors.grey[200]!;

/// Color to subtitles
Color blueTextColor = const Color.fromRGBO(0, 124, 209, 1);

/// Color darker to subtitles
Color greyDarkerColor = Colors.grey[850]!;

/// Default padding for bottom widget
double bottomPadding = 20;

double bottomWigetHeight(BuildContext context) {
  Size size = MediaQuery.of(context).size;
  return size.height * 0.1 > 66
      ? (size.height * 0.1 > 70 ? 70 : size.height * 0.1)
      : 66;
}

double loginFormSpacer(BuildContext context) {
  Size size = MediaQuery.of(context).size;
  return size.height * 0.04 < 25
      ? 25
      : (size.height * 0.04 < 35 ? 35 : size.height * 0.04);
}

double loginLogoWidth(BuildContext context) {
  Size size = MediaQuery.of(context).size;
  return size.width > 500 ? 500 : size.width;
}

/// Height on bottom widget with
double getBottomNavBarHeight(BuildContext context) {
  Size size = MediaQuery.of(context).size;
  return size.height * 0.1 > 75
      ? (size.height * 0.11 > 80 ? 80 : size.height * 0.1)
      : 75;
}

Size imageIconSize() => const Size(60, 60);

/// Home grid elements size
Size gridItemSize(BuildContext context) {
  final _size = MediaQuery.of(context).size;
  double width = _size.width > 500 ? 120 : 95;
  double height = width * 1.253;
  return Size(width, height);
}

/// Big numbers text theme
TextStyle numbersTextStyle(
    {double fontSizeFactor = 1, fontWeight = FontWeight.w900, Color? color}) {
  return TextStyle(
      fontFamily: 'Arial',
      fontSize: 20 * fontSizeFactor,
      fontWeight: fontWeight,
      color: color ?? greyColor);
}
