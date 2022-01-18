import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/components/appBar.dart';
import 'package:pos_wappsi/components/basic_widgets.dart';
import 'package:pos_wappsi/constant.dart';

Widget _back(BuildContext context, {Function? onPop}) {
  final _size = MediaQuery.of(context).size;
  return Container(
    padding: EdgeInsets.only(left: 10),
    // color:Colors.red,
    child: IconButton(
        // color: Colors.red,
        onPressed: () {
          // ignore: unnecessary_statements
          onPop != null ? onPop() : Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_back_ios_sharp,
          size: _size.height * 0.043 > 30
              ? (_size.height * 0.043 > 40 ? 40 : _size.height * 0.043)
              : 30,
        )),
  );
}

PreferredSize appBar(BuildContext context, String title,
    {bool back = true,
    String? image,
    String? subtitle,
    bool elevation = true,
    double radius = 5.0,
    Function? onPop,
    Widget? leading}) {
  Size _size = MediaQuery.of(context).size;
  return boxAppBar(
      SafeArea(
          child: _content(context, title, subtitle, back, image,
              onPop: onPop, leading: leading)),
      _size,
      radius: radius,
      elevation: elevation);
}

Widget _content(BuildContext context, String title, String? subtitle, bool back,
    String? image,
    {Function? onPop, Widget? leading}) {
  final _size = MediaQuery.of(context).size;
  return Row(
    // mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      back ? _back(context, onPop: onPop) : Container(),
      (image != null ? imgTumbnail(image: image) : imgTumbnail())
          .withSize(
              height: _size.height * 0.06 > 38
                  ? (_size.height * 0.06 > 42 ? 42 : _size.height * 0.06)
                  : 38,
              width: _size.height * 0.06 > 38
                  ? (_size.height * 0.06 > 42 ? 42 : _size.height * 0.06)
                  : 38)
          .paddingOnly(right: 8, left: back ? 10 : 20, bottom: 0),
      _text(title, context, subtitle: subtitle)
          .paddingRight(leading == null ? _size.width * 0.1 : 0)
          .expand(),
      (leading ?? Container()).paddingRight(leading != null ? 15 : 10)
    ],
  );
}

Widget _text(
  String title,
  BuildContext context, {
  String? subtitle,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AutoSizeText(
        title,
        maxLines: 1,
        style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w900),
      ),
      subtitle == null
          ? Container()
          : Text(
              subtitle,
              style: normalTextStyle(context),
            ),
    ],
  );
}
