import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/suspended_sale_model.dart';
import 'package:pos_wappsi/screens/sales/suspended_sales.dart';

class SuspendedSalesIcon extends StatelessWidget {
  final int quantity;
  final List<SuspendedSales>? suspendedSales;
  const SuspendedSalesIcon(
      {Key? key, required this.quantity, required this.suspendedSales})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      padding: kIconButtonPadding,
      width: leadingWidgetSize,
      height: leadingWidgetSize,
      elevation: 0,
      color: Colors.white,
      shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey[400]!)),
      // hoverColor: pColor,

      child: Badge(
          badgeColor: Colors.red,
          padding: EdgeInsets.all(6),
          alignment: Alignment.center,
          position: BadgePosition.topEnd(),
          badgeContent: Text(
            quantity.toString(),
            style: TextStyle(color: Colors.white),
          ),
          child: Icon(
            FontAwesomeIcons.cashRegister,
            size: leadingIconSize,
          )),
      onTap: () {
        SuspendedSalesScreen(suspendedSales: suspendedSales).launch(context);
      },
    );
  }
}
