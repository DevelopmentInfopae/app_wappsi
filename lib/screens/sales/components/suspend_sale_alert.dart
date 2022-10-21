import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/components/input_decoration.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/screens/home/home_screen.dart';
import 'package:pos_wappsi/screens/sales/new_sale.dart';
import 'package:pos_wappsi/utils/alerts.dart';
// import 'package:pos_wappsi/utils/functions.dart';

/// Custom alert dialog to manage open and close operations on Register, to open action = 'open'
/// to close action = 'close'
///
class SuspendSaleAlertDialog extends StatefulWidget {
  const SuspendSaleAlertDialog({Key? key}) : super(key: key);

  @override
  SuspendSaleAlertDialogState createState() {
    return SuspendSaleAlertDialogState();
  }
}

class SuspendSaleAlertDialogState extends State<SuspendSaleAlertDialog> {
  late FocusNode _valueFocus;

  String _keyWord = '';

  @override
  void initState() {
    super.initState();
    _valueFocus = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _valueFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Column(
        children: [
          Text(
            'Suspender venta',
            style: buttonsSmallTextStyle(context).apply(fontSizeDelta: 1.2),
          ).paddingBottom(10),
          Text(
            'A continuación ingrese una palabra clave para identificar la venta suspendida:',
            style: buttonsSmallTextStyle(context).apply(color: kGreyTextColor),
          ),
        ],
      ).paddingBottom(10),
      content: SingleChildScrollView(child: _form(context)),
      actions: <Widget>[
        Container(
          color: Colors.redAccent,
          child: CupertinoDialogAction(
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ),
        Container(
          color: pColor.withOpacity(0.8),
          child: CupertinoDialogAction(
            child: const Text(
              'Aceptar',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            onPressed: () async {
              final res = await posBloc.suspendSale(keyWord: _keyWord);

              // Check if suspendSale fails
              if (res) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const HomeScreen(),
                  ),
                  (route) => false,
                );
                const NewSale().launch(context);
              } else {
                confirmDialog(
                  context,
                  'Hubo un error al suspender la venta, intente nuevamente.',
                  'assets/images/warning.png',
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _form(BuildContext context) {
    // final _textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            onChanged: (String value) {
              setState(() {
                _keyWord = value;
              });
            },
            decoration: InputDecorations.formInputDecoration(
              hintText: '',
              labelText: 'Palabra clave',
            ),
          )
        ],
      ),
    );
  }
}
