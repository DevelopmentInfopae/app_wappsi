import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/screens/components/appbar.dart';
import 'package:pos_wappsi/screens/components/basic_widgets.dart';

Widget _back(BuildContext context, {Function? onPop}) {
  return Container(
    padding: const EdgeInsets.only(left: 10),
    // color:Colors.red,
    child: IconButton(
      // color: Colors.red,
      onPressed: () {
        // ignore: unnecessary_statements
        onPop != null ? onPop() : Navigator.pop(context);
      },
      icon: const Icon(
        Icons.arrow_back_ios_sharp,
        size: 25,
      ),
    ),
  );
}

PreferredSize appBar(
  BuildContext context,
  String title, {
  bool back = true,
  String? image,
  String? subtitle,
  bool elevation = true,
  double radius = 5.0,
  Function? onPop,
  Widget? leading,
}) {
  Size _size = MediaQuery.of(context).size;
  return boxAppBar(
    SafeArea(
      child: _content(
        context,
        title,
        subtitle,
        back,
        image,
        onPop: onPop,
        leading: leading,
      ),
    ),
    _size,
    radius: radius,
    elevation: elevation,
  );
}

Widget _content(
  BuildContext context,
  String title,
  String? subtitle,
  bool back,
  String? image, {
  Function? onPop,
  Widget? leading,
}) {
  final _size = MediaQuery.of(context).size;
  return Row(
    // mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      back ? _back(context, onPop: onPop) : Container(),
      (image != null ? imgThumbnail(image: image) : imgThumbnail())
          .withSize(
            height: 26,
            width: 26,
          )
          .paddingOnly(right: 8, left: 10, bottom: 0),
      _text(title, context, subtitle: subtitle)
          .paddingRight(leading == null ? _size.width * 0.1 : 10)
          .expand(),
      (leading ?? Container())
          .withSize(height: 55, width: leading != null ? 55 : 0)
          .paddingRight(leading != null ? 10 : 16)
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
        style: const TextStyle(fontSize: 26.0, fontWeight: FontWeight.w900),
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
