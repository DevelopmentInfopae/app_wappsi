// ignore_for_file: unnecessary_statements

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/models/register_model.dart';
import 'package:pos_wappsi/providers/register_form_provider.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';

sendRegisterAction(BuildContext context, RegisterFormProvider registerProvider,
    FocusNode valueFocus,
    {bool syncDB = true, String action = 'open'}) async {
  valueFocus.unfocus();

  if (registerProvider.isValidForm()) {
    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    //   Navigator.pushNamed(context, '/home');
    // });

    if (registerProvider.value == '' || registerProvider.value == '0') {
      await confirmDialog(
          context,
          'Debe suministrar un valor valido para continuar',
          'assets/images/warning.png');
      valueFocus.requestFocus();
    } else {
      return await _executeAction(action, context, registerProvider, syncDB);
    }
  }
}

_executeAction(String action, BuildContext context,
    RegisterFormProvider registerProvider, bool syncDB) async {
  if (action == 'open') {
    await _open(context, registerProvider, syncDB);
  } else if (action == 'movement') {
    return await _movement(context, registerProvider, syncDB);
  } else {
    // loading(context);
    scaffoldAlert(context, 'Cerrando caja...', const Duration(seconds: 4));
    await registerProvider.closeRegister(context);
    hideCurrentScaffoldAlert(context);
  }
}

_movement(BuildContext context, RegisterFormProvider registerProvider,
    bool syncDB) async {
  // loading(context);
  scaffoldAlert(
      context, 'Realizando movimiento...', const Duration(seconds: 10));

  // diable login button
  registerProvider.isLoading = true;

  // await Future.delayed(Duration(seconds: 4));

  final res = await registerProvider.movement();

  // hide loading snackbar

  if (!res['body']['error']) {
    // ScaffoldMessenger.of(context).hideCurrentSnackBar();

    hideCurrentScaffoldAlert(context);
    syncDB ? null : Navigator.pop(context);
    // confirmDialog(context, res['body']['message'], 'assets/images/success.png');
    scaffoldAlert(context, res['body']['message'], const Duration(seconds: 1));

    return res['body'];
  } else {
    registerProvider.isLoading = false;

    // to handle error first time usign token

    if (res['status'] == -1) {
      reloadDialog(context, 'Sesión expirada, es necesario a iniciar sesión',
          'assets/images/warning.png');
    }

    if (res['body']['message'] != null) {
      // Navigator.pop(context);
      hideCurrentScaffoldAlert(context);
      // confirmDialog(
      //     context, res['body']['message'], 'assets/images/dizzy-robot.png');

      scaffoldAlert(context, res['body']['message'], const Duration(seconds: 1),
          backGroundColor: errorColor);
    } else {
      // Navigator.pop(context);
      hideCurrentScaffoldAlert(context);
      confirmDialog(context, 'Error en la respuesta del servidor',
          'assets/images/dizzy-robot.png');
    }
    return null;
  }
}

_open(BuildContext context, RegisterFormProvider registerProvider,
    bool syncDB) async {
  // loading(context);

  scaffoldAlert(context, 'Abriendo caja...', const Duration(seconds: 4));

  // diable login button
  registerProvider.isLoading = true;

  // await Future.delayed(Duration(seconds: 4));

  final res = await registerProvider.openRegister();
  //
  Navigator.of(context).pop();
  // hide loading snackbar

  if (!res['body']['error']) {
    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
    // Navigator.pop(context);
    // syncDB ? null : Navigator.pop(context);
    // confirmDialog(context, res['body']['message'], 'assets/images/success.png');

    hideCurrentScaffoldAlert(context);

    scaffoldAlert(
          context, res['body']['message'], const Duration(seconds: 1));
    if (res['body']['register_data']['status'] == 'open') {
      dataBloc.setRegisterData(
          RegisterModel.fromJson(res['body']['register_data']));
    }

    // await Future.delayed(const Duration(milliseconds: 300));
    if (res['status'] == 1) {
      syncDB
          ? WidgetsBinding.instance!.addPostFrameCallback((_) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/db_sync', (route) => false);
            })
          : null;
    }
  } else {
    registerProvider.isLoading = false;
    // Navigator.pop(context);
    // to handle error first time usign token

    if (res['status'] == -1) {
      reloadDialog(context, 'Sesión expirada, es necesario a iniciar sesión',
          'assets/images/warning.png');
    }

    if (res['body']['message'] != null) {
      String strMessage = '';
      try {
        final m = res['body']['message'] as Map;
        for (var e in m.values) {
          // if (e = m.values.first) {
          // strMessage += e;
          // } else {
          if (strMessage != '') {
            strMessage += '\n' + e;
          } else {
            strMessage += e;
          }
          // }
        }
      } catch (e) {
        await logError(e, from: 'Function _open');

        strMessage = res['body']['message'].toString();
      }
    } else {
      // confirmDialog(context, res['body']['message'].toString(),
      //     'assets/images/dizzy-robot.png');
      scaffoldAlert(
          context, res['body']['message'], const Duration(seconds: 1), backGroundColor: errorColor);
    }
  }
}
