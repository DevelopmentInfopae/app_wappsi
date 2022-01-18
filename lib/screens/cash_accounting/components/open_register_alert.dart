import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/providers/register_form_provider.dart';
import 'package:pos_wappsi/screens/cash_accounting/components/functions.dart';
import 'package:pos_wappsi/screens/cash_accounting/components/widgets.dart';
// import 'package:pos_wappsi/utils/functions.dart';
import 'package:provider/provider.dart';

/// Custom alert dialog to manage open and close operations on Register, to open action = 'open'
/// to close action = 'close'
///
class RegisterAlertDialog extends StatefulWidget {
  final String action;
  const RegisterAlertDialog({Key? key, required this.action}) : super(key: key);

  @override
  RegisterAlertDialogState createState() {
    return new RegisterAlertDialogState();
  }
}

class RegisterAlertDialogState extends State<RegisterAlertDialog> {
  late FocusNode _valueFocus;

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
    final registerForm = Provider.of<RegisterFormProvider>(context);
    return Container(
      child: CupertinoAlertDialog(
        title: Column(
          children: [
            Text(
              widget.action == 'open' ? 'Abrir caja' : 'Cerrar caja',
              style: buttonsSmallTextStyle(context).apply(fontSizeDelta: 1.2),
            ).paddingBottom(10),
            Text(
              widget.action == 'open'
                  ? "Digite el valor con el que desea abrir la caja (COP)"
                  : 'Digite el valor total del efectivo en mano (COP)',
              style:
                  buttonsSmallTextStyle(context).apply(color: kGreyTextColor),
            ),
          ],
        ),
        content: new SingleChildScrollView(child: _form(context, registerForm)),
        actions: <Widget>[
          Container(
            color: Colors.redAccent,
            child: CupertinoDialogAction(
              child: Text(
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
            color: Theme.of(context).primaryColor.withOpacity(0.8),
            child: CupertinoDialogAction(
              child: Text(
                "Aceptar",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              onPressed: () async {
                await sendRegisterAction(context, registerForm, _valueFocus,
                    syncDB: false, action: widget.action);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _form(BuildContext context, RegisterFormProvider cashAccForm) {
    // final _textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: cashAccForm.formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            registerInput(context, cashAccForm, _valueFocus,
                action: widget.action)
          ],
        ),
      ),
    );
  }
}
