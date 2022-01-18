// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

PreferredSize boxAppBar(Widget child, Size size,
    {bool elevation = true, double radius = 5}) {
  return PreferredSize(
      preferredSize: new Size(
          size.width,
          size.height * 0.1 > 75
              ? (size.height * 0.11 > 85 ? 85 : size.height * 0.1)
              : 75),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: elevation
                ? [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 6.0,
                    )
                  ]
                : null),
        // height: size.height * 0.11 > 70 ? size.height * 0.11 : 70,
        child: child,
      ));
}
