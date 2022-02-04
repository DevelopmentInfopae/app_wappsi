import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/providers/register_form_provider.dart';
import 'package:pos_wappsi/screens/cash_accounting/components/open_register_alert.dart';
import 'package:pos_wappsi/screens/cash_accounting/register_movements.dart';

import 'package:provider/provider.dart';

class RegisterOptions extends StatefulWidget {
  const RegisterOptions({Key? key}) : super(key: key);

  @override
  State<RegisterOptions> createState() => _RegisterOptionsState();
}

class _RegisterOptionsState extends State<RegisterOptions> {
  late bool registerStatus;

  @override
  void initState() {
    registerStatus = dataBloc.registerData.status == 'open';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        dataBloc.homeKey.currentState?.changeBottomIndex(1);
        // print('here i am');
        return true;
      },
      child: Scaffold(
        appBar: appBar(context, 'Caja',
            image: 'assets/images/cash-register.png', onPop: () {
          dataBloc.homeKey.currentState?.changeBottomIndex(1);
          Navigator.pop(context);
        }),
        body: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    // final _textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: SettingSection(
        title: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: 'Estado de caja: ',
                style:  buttonsSmallTextStyle(context,)),
            TextSpan(
                text: registerStatus ? 'Abierta' : 'Cerrada',
                style:  buttonsSmallTextStyle(context)
                    .apply(color: registerStatus ? Colors.green : Colors.red)),
          ]),
        ),
        subTitle:
            Text('Operaciones de caja', style: primaryTextStyle()), // Optional
        items: _settings(context),
      ),
    );
  }

  List<Widget> _settings(BuildContext context) {
    return [_openOrCloseRegister(context), _registerMovements(context)];
  }

  SettingItemWidget _openOrCloseRegister(BuildContext context) {
    final title = registerStatus ? 'Cerrar caja' : 'Abrir caja';
    final subTitle = registerStatus
        ? 'Cerrar caja actual y generar comprobante de cierre'
        : 'Abrir caja con una base determinada';
    return SettingItemWidget(
        title: title,
        subTitle: subTitle,
        decoration: BoxDecoration(borderRadius: radius()),
        trailing: Icon(Icons.keyboard_arrow_right_rounded,
            color: context.dividerColor),
        onTap: () async {
          await _controlRegister(registerStatus ? 'close' : 'open');

          /// update JWT token
          await dataBloc.refreshToken(context);
          setState(() {
            registerStatus = dataBloc.registerData.status == 'open';
          });
        });
  }

  SettingItemWidget _registerMovements(BuildContext context) {
    return SettingItemWidget(
        title: 'Realizar movimiento de caja',
        subTitle: 'Transfiere efectivo de caja sin cerrarla',
        decoration: BoxDecoration(
            borderRadius: radius(),
            color: registerStatus ? null : Colors.red[100]),
        trailing: Icon(Icons.keyboard_arrow_right_rounded,
            color: context.dividerColor),
        onTap: registerStatus
            ? () {
                RegisterMovements().launch(context);
              }
            : null);
  }

  _controlRegister(String action) async {
    await showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return ChangeNotifierProvider(
              create: (_) => RegisterFormProvider(),
              child: RegisterAlertDialog(
                action: action,
              ));
        });
  }
}
