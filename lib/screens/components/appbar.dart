// ignore: file_names
import 'package:flutter/material.dart';
import 'package:pos_wappsi/constant.dart';

PreferredSize boxAppBar(
  Widget child,
  Size size, {
  bool elevation = true,
  double radius = 5,
}) {
  return PreferredSize(
    preferredSize: Size(size.width, appBarHeight(size)),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: elevation
            ? [
                const BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                )
              ]
            : null,
      ),
      // height: size.height * 0.11 > 70 ? size.height * 0.11 : 70,
      child: child,
    ),
  );
}
