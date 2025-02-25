// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/providers/errors_provider.dart';
import 'package:pos_wappsi/screens/components/back_app_bar.dart';
import 'package:pos_wappsi/screens/components/go_back_bottom.dart';
import 'package:pos_wappsi/screens/components/widgets.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';

class ReportErrorScreen extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  /// Receive an string `print` which could be ['settings','movement','pos'], with that, print
  /// different things depending on the `print`, also receive `movementInfo` which is required when trying
  /// to print movement receipt
  const ReportErrorScreen({Key? key}) : super(key: key);
  @override
  _ReportErrorScreenState createState() => _ReportErrorScreenState();
}

class _ReportErrorScreenState extends State<ReportErrorScreen> {
  String _messageText = '';
  late Color _pc;
  late Size _size;

  final _messageController = TextEditingController();
  final _messageFocus = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _pc = pColor;
    return Scaffold(
      appBar: appBar(
        context,
        'Reportar errores',
        image: 'assets/images/clipboard.png',
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return Center(
      child: Column(
        // mainAxisAlignment: ,
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'A continuación realice una breve descripción del error a reportar',
                  style: buttonsSmallTextStyle(context),
                ).paddingSymmetric(horizontal: 14, vertical: 16),
                _message().paddingSymmetric(horizontal: 16, vertical: 16),
              ],
            ),
          ).expand(),
          bottom(_buttons(), _pc, _size),
        ],
      ),
    );
  }

  Widget _message() {
    return textFormField(
      context,
      'Descripción del error',
      (String value) {},
      (String value) {
        _messageText = value;
      },
      () {},
      controller: _messageController,
      maxLines: 8,
      focus: _messageFocus,
    );
  }

  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [const GoBackBottom(), _sendErrors()],
    );
  }

  AppButton _sendErrors() {
    return AppButton(
      padding: kButtonPadding,
      onTap: () async {
        _messageFocus.unfocus();
        final errorsP = ErrorsProvider();
        final res = await errorsP.sendErrorLog(context, _messageText);

        if (res) Navigator.pop(context);
      },
      child: Row(
        children: [
          const Icon(
            Icons.send,
            size: kIconSize,
            color: pColor,
          ),
          Text(
            ' Enviar',
            style: buttonsSmallTextStyle(context, color: pColor),
          ),
        ],
      ),
    );
  }
}
