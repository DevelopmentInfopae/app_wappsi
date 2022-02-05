
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/screens/db_sync/components/widgets.dart';

class ElementSync extends StatelessWidget {
  const ElementSync({
    Key? key,
    required this.context,
    
    required this.status,
    required this.optionInfo,required this.optionName
  }) : super(key: key);

  final BuildContext context;

  final Map<String,dynamic> optionInfo;
  final String optionName;
  final bool status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/images/' +
                (optionInfo['image'] ?? 'countries.png'))
            .paddingSymmetric(horizontal: 10, vertical: 3)
            .withSize(width: imageIconSize().width,height: imageIconSize().height).flexible(flex: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            descText(optionName, context, fontSizeFactor: 0.9, maxLines: 2),
            const Spacer(),
                // .withWidth(_size.width * 0.55),
            syncStatus(status),
          ],
        ).flexible(flex:4)
      ],
    );
  }
}