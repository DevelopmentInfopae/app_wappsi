import 'package:flutter/material.dart';
import 'package:pos_wappsi/utils/functions.dart';

Widget imgTumbnail({String image = 'assets/images/wappsi.png'}) {
  return Image(
    image: AssetImage(image),
    fit: BoxFit.cover,
    // height: 42,
    // width: 42,
  );
}

Widget informationText(String description, String information,
    {Color descColor = const Color.fromRGBO(0, 97, 224, 1)}) {
  return TextFormField(
    initialValue: capitalizeText(description),
    // expands: ,
    enabled: false,
    decoration: InputDecoration(
        labelText: information,
        labelStyle: TextStyle(color: descColor, fontSize: 20)),
  );
}
