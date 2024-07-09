import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
// import 'package:flutter/services.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/components/button_global.dart';
import 'package:pos_wappsi/components/input_decoration.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/permissions_model.dart';
import 'package:pos_wappsi/models/register_model.dart';
import 'package:pos_wappsi/models/user_model.dart';

import 'package:pos_wappsi/providers/login_form_provider.dart';

import 'package:pos_wappsi/utils/alerts.dart';

import 'package:provider/provider.dart';

class LoginFormInputs extends StatefulWidget {
  const LoginFormInputs({
    Key? key,
  }) : super(key: key);

  @override
  _LoginFormInputsState createState() => _LoginFormInputsState();
}

class _LoginFormInputsState extends State<LoginFormInputs> {
  late FocusNode passwordFocusNode;
  late FocusNode userFocusNode;

  @override
  void dispose() {
    super.dispose();
    userFocusNode.dispose();
    passwordFocusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    userFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  Widget _password(BuildContext context, LoginFormProvider loginForm) {
    return TextFormField(
      // controller: TextEditingController(), // Optional
      // textFieldType: TextFieldType.PASSWORD,
      // isPassword: true,
      // focus: passwordFocusNode,
      focusNode: passwordFocusNode,
      obscureText: true,
      style: Theme.of(context).textTheme.subtitle1,
      initialValue: loginForm.password,
      keyboardType: TextInputType.visiblePassword,
      validator: (value) {
        if (value!.length < 6) {
          return 'La contraseña debe tener mínimo 6 caracteres';
        }
        return null;
      },
      onChanged: (value) {
        loginForm.password = value;
      },
      onFieldSubmitted: (_) {
        loginForm.loading
            // ignore: unnecessary_statements
            ? null
            : _login(loginForm, context);
      },
      decoration: InputDecorations.authInputDecoration(
        hintText: '',
        labelText: 'Contraseña',
        prefixIcon: FontAwesomeIcons.key,
      ),
    );
  }

  Widget _userName(LoginFormProvider loginForm) {
    return TextFormField(
      // textFieldType: TextFieldType.USERNAME,
      // focus: userFocusNode,
      focusNode: userFocusNode,
      // controller: TextEditingController(),
      keyboardType: TextInputType.text,
      initialValue: loginForm.user,
      style: Theme.of(context).textTheme.subtitle1,
      // nextFocus: passwordFocusNode,

      validator: (value) {
        if (value!.isEmpty) {
          return 'Debe suministrar un nombre de usuario';
        }
        return null;
      },
      onChanged: (value) {
        loginForm.user = value;
      },
      onFieldSubmitted: (_) {
        passwordFocusNode.requestFocus();
      },
      decoration: InputDecorations.authInputDecoration(
        hintText: '',
        labelText: 'Nombre de usuario',
        prefixIcon: FontAwesomeIcons.user,
      ),
    );
  }

  ButtonGlobalWithoutIcon _loginButton(
    BuildContext context,
    LoginFormProvider loginForm,
  ) {
    return ButtonGlobalWithoutIcon(
      buttonText: 'Iniciar sesión',
      buttonDecoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        // to change color based on _isLoading property
        color: loginForm.loading ? Colors.grey : pColor,
      ),
      onPressed: loginForm.loading
          ? () {}
          : () async => await _login(loginForm, context),
    );
  }

  _login(
    LoginFormProvider loginForm,
    BuildContext context, {
    bool override = false,
  }) async {
    if (loginForm.isValidForm()) {
      // hide keyboard
      passwordFocusNode.unfocus();

      loading(context);

      // disable login button
      loginForm.isLoading = true;

      final res = await loginForm.login(override: override);

      await _action(res, loginForm, context, override);

      // hide loading snackbar

    } else {
      userFocusNode.requestFocus();
    }
  }

  Future<void> _saveData(Map res) async {
    //______________________________________________________________________________________________________________
    //
    //                                    SAVE DATA INTO USER PROVIDER
    //_______________________________________________________________________________________________________________

    dataBloc.setUserData(UserModel.fromJson(res['body']['user_data']));

    dataBloc.userData?.token = res['body']['access_token'];

    /// set current logged user id on sharedPrefs
    // set current user value
    await setValue('current_user', dataBloc.userData?.id);

    //______________________________________________________________________________________________________________
    //
    //                                    SAVE PERMISSIONS DATA INTO DATABLOC
    //_______________________________________________________________________________________________________________

    dataBloc
        .setPermissions(PermissionsModel.fromJson(res['body']['permissions']));

    //______________________________________________________________________________________________________________
    //
    //                                  SAVE DATA INTO REGISTER PROVIDER
    //_______________________________________________________________________________________________________________

    if (res['body']['register_data']['status'] == 'open') {
      dataBloc.setRegisterData(
        RegisterModel.fromJson(res['body']['register_data']),
      );
    }
  }

  void _overrideLogin(
    LoginFormProvider loginForm,
    BuildContext context,
    Map res,
  ) async {
    bool override = await choiceAlert(
      context,
      res['body']['message'] + '¿Desea iniciar sesión igualmente?',
      'assets/images/warning.png',
      skipeable: false,
    );

    if (override) {
      await _login(loginForm, context, override: override);
    } else {
      loginForm.isLoading = false;
    }
  }

  //______________________________________________________________________________________________________________
  //
  //                                 WHAT TO DO IN ANY RESPONSE STATUS
  //_______________________________________________________________________________________________________________

  Future<void> _action(
    Map res,
    LoginFormProvider loginForm,
    BuildContext context,
    bool override,
  ) async {
    if (res['body']['logged'] ?? false) {
      // ScaffoldMessenger.of(context).hideCurrentSnackBar();
      Navigator.pop(context);
      _overrideLogin(loginForm, context, res);
    } else if (res['body']['incorrect_password'] ?? false) {
      // ScaffoldMessenger.of(context).hideCurrentSnackBar();
      Navigator.pop(context);
      confirmDialog(context, res['body']['message'], 'assets/images/alert.png');
      loginForm.isLoading = false;
      passwordFocusNode.requestFocus();
    } else if (res['body']['user_not_found'] ?? false) {
      // ScaffoldMessenger.of(context).hideCurrentSnackBar();
      Navigator.pop(context);
      confirmDialog(context, res['body']['message'], 'assets/images/alert.png');
      loginForm.isLoading = false;
      userFocusNode.requestFocus();
    } else if (res['status'] == 1) {
      _navigate(context, res);
    } else {
      // hide loading snackbar
      loginForm.isLoading = false;
      // ScaffoldMessenger.of(context).hideCurrentSnackBar();
      Navigator.pop(context);
      confirmDialog(context, res['body']['message'], 'assets/images/alert.png');
    }
  }

  Future<void> _navigate(BuildContext context, Map res) async {
    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.pop(context);

    // change current user value

    await _saveData(res);
    //route to go
    String route = '/cash';

    if (res['body']['register_data']['status'] == 'open') {
      // change route to db_sync
      //
      route = '/db_sync';
      // route = '/home';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: loginForm.formKey,
      child: Padding(
        padding: kTextFieldPaddingSmall,
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _userName(loginForm),
                SizedBox(height: loginFormSpacer(context)),
                _password(context, loginForm),
              ],
            ).flexible(flex: 7),
            _loginButton(context, loginForm).flexible(flex: 3)
          ],
        ),
      ),
    );
  }
}
