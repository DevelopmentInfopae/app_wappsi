import 'package:flutter/material.dart';

import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/constant.dart';

class AppBarLeading extends StatelessWidget {
  final Widget widget;
  final Color? backgroundColor;
  final Color? borderSideColor;
  final Function onTap;
  final EdgeInsets padding;
  final bool enabled;
  const AppBarLeading(
      {Key? key,
      required this.widget,
      required this.onTap,
      this.backgroundColor,
      this.borderSideColor,
      this.padding = kIconButtonPadding,
      this.enabled = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      padding: padding,
      width: leadingWidgetSize,
      height: leadingWidgetSize,
      enabled: enabled,
      elevation: 0,
      color: backgroundColor ?? Colors.white,
      shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: borderSideColor ?? greyMediumLight)),
      // hoverColor: pColor,

      child: widget,
      onTap: onTap,
      // onTap: () {
      //   SuspendedSalesScreen(suspendedSales: suspendedSales).launch(context);
      // },
    );
  }
}
