import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/constant.dart';

class GoBackBottom extends StatelessWidget {
  const GoBackBottom({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      color: Colors.white,
      padding: kButtonPadding,
      // disabledColor: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.arrow_back_ios, size: kIconSize),
          Text(
            'Regresar',
            style: buttonsSmallTextStyle(context),
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
