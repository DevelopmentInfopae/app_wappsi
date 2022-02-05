import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/constant.dart';

Widget buttonTextIcon(Function onTap,
    {String text = 'Ver más', IconData icon = Icons.search}) {
  return AppButton(
    color: Colors.white,
    padding: EdgeInsets.zero,
    onTap: onTap,
    width: 70,
    shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: const BorderSide(color: pColor)),
    child: Row(
      children: [
        Icon(
          icon,
          color: pColor,
        ),
        // Text( text,style: TextStyle(
        //   color: Colors.white
        // ),),
      ],
    ),
  );
}

Container barCode(BuildContext context, Function onTap) {
  final size = MediaQuery.of(context).size;
  const _pc = pColor;
  return Container(
    // width: 70,
    color: Colors.white,
    height: searchHeight,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    margin: EdgeInsets.only(left: size.width - (searchHeight + 16)),
    child: _cameraBarCodeButton(size, onTap, _pc),
  );
}

AppButton _cameraBarCodeButton(Size size, Function onTap, Color color) {
  return AppButton(
      shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: color)),
      onTap: onTap,
      width: searchHeight - 1,
      height: searchHeight - 1,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Icon(
        Icons.camera_alt_outlined,
        color: color,
      ));
}
