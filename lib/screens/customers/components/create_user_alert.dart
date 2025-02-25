import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/customer_bloc.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';

/// Custom alert dialog to manage open and close operations on Register, to open action = 'open'
/// to close action = 'close'
///
class CreateUserAlertDialog extends StatefulWidget {
  const CreateUserAlertDialog({Key? key, required this.customer})
      : super(key: key);
  final CompanyModel customer;
  @override
  CreateUserAlertDialogState createState() {
    return CreateUserAlertDialogState();
  }
}

class CreateUserAlertDialogState extends State<CreateUserAlertDialog> {
  late FocusNode _valueFocus;

  final formKey = GlobalKey<FormState>();

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
            'Usuario asignado requerido',
            style: buttonsSmallTextStyle(context).apply(fontSizeDelta: 1.2),
          ).paddingBottom(10),
          Text(
            'Para asignar productos favoritos al cliente, primero debe asignarle un usuario',
            style: buttonsSmallTextStyle(context).apply(color: kGreyTextColor),
          ),
        ],
      ),
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
              customerBloc.setPassword('');
              customerBloc.setUserName('');
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
              final verifyUserN = await customerBloc.verifyUserName(context);
              if (!verifyUserN) {
                Navigator.of(context).pop(true);
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
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            textFormField(
              context,
              'Nombre de usuario',
              (value) {
                customerBloc.setUserName(value);
              },
              (String? value) {
                if ((value?.length ?? 0) == 0) {
                  return 'Debe suministrar un nombre de usuario';
                }
              },
              () {},
            ).paddingSymmetric(vertical: 5),
            textFormField(
              context,
              'Contraseña',
              (value) {
                customerBloc.setPassword(value);
              },
              (String? value) {
                if ((value?.length ?? 0) < 6) {
                  return 'Contraseña valida';
                }
              },
              () {},
            ).paddingSymmetric(vertical: 5),
          ],
        ),
      ),
    );
  }
}
