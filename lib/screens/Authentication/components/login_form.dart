import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
// import 'package:flutter/services.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/permissions_model.dart';
import 'package:pos_wappsi/models/register_model.dart';
import 'package:pos_wappsi/models/user_model.dart';
import 'package:pos_wappsi/providers/login_form_provider.dart';
import 'package:pos_wappsi/screens/components/buttons.dart';
import 'package:pos_wappsi/screens/components/input_decoration.dart';
import 'package:pos_wappsi/screens/components/spacers.dart';
import 'package:pos_wappsi/utils/utils.dart';
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
  late TextEditingController _userController;    
  late TextEditingController _passwordController; 

  @override
  void dispose() {
    super.dispose();
    userFocusNode.dispose();
    passwordFocusNode.dispose();
    _userController.dispose();
    _passwordController.dispose();
  }

  @override
  void initState() {
    super.initState();
    userFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    _userController     = TextEditingController(); 
    _passwordController = TextEditingController(); 
    _cargarCredencialesGuardadas();
  }

  Future<void> _cargarCredencialesGuardadas() async {
    final prefs = await SharedPreferences.getInstance();
    final loginForm = Provider.of<LoginFormProvider>(context, listen: false);

    final usuarioGuardado  = prefs.getString('usuario_guardado') ?? '';

    final passwordGuardado = prefs.getString('password_guardado') ?? '';

    if (usuarioGuardado.isNotEmpty) {
      loginForm.user            = usuarioGuardado;
      loginForm.recordarUsuario = true;
      _userController.text      = usuarioGuardado; // 👈 Setea el controller
    }
    if (passwordGuardado.isNotEmpty) {
      loginForm.password         = passwordGuardado;
      loginForm.recordarPassword = true;
      _passwordController.text   = passwordGuardado; // 👈 Setea el controller
    }
    loginForm.notifyListeners();
  }

  Widget _password(BuildContext context, LoginFormProvider loginForm) {
    return SizedBox(
      width: 250,
      child: TextFormField(
        // controller: TextEditingController(), // Optional
        // textFieldType: TextFieldType.PASSWORD,
        // isPassword: true,
        // focus: passwordFocusNode,
        focusNode: passwordFocusNode,
        obscureText: true,
        style: Theme.of(context).textTheme.labelMedium,
        controller: _passwordController,
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
        decoration: InputDecorations.authInputDecoration(
          hintText: '',
          labelText: 'Contraseña',
          prefixIcon: FontAwesomeIcons.key,
        ),
      ),
    );
  }

  Widget _userName(LoginFormProvider loginForm) {
    return SizedBox(
      width: 250,
      child: TextFormField(
        // textFieldType: TextFieldType.USERNAME,
        // focus: userFocusNode,
        focusNode: userFocusNode,
        // controller: TextEditingController(),
        keyboardType: TextInputType.text,
        controller: _userController,
        style: Theme.of(context).textTheme.labelMedium,
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
      ),
    );
  }

  Widget _loginButton(
    BuildContext context,
    LoginFormProvider loginForm,
  ) {
    return SizedBox(
      width: 250,
      child: CustomButtonWithState(
        onTap: loginForm.loading
            // ignore: unnecessary_statements
            ? () {}
            : () async => await _login(loginForm, context),
        text: 'Iniciar sesión',
      ),
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

      // disable login button
      loginForm.isLoading = true;

      final res = await loginForm.login(override: override);

      await _action(res, loginForm, context, override);

      // hide loading snackbar
    } else {
      userFocusNode.requestFocus();
    }
    loginForm.isLoading = false;
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
    if (res['status'] == 1) {
      _navigate(context, res);
      return;
    }
    if (res['body']['logged'] ?? false) {
      _overrideLogin(loginForm, context, res);
      return;
    } else if (res['body']['incorrect_password'] ?? false) {
      loginForm.isLoading = false;
      passwordFocusNode.requestFocus();
    } else if (res['body']['user_not_found'] ?? false) {
      userFocusNode.requestFocus();
    } else {
      // hide loading snackbar
      loginForm.isLoading = false;
    }
    AppDialogs.genericConfirmationDialog(
      title: res['body']['message'],
    );
  }

  Future<void> _navigate(BuildContext context, Map res) async {
    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.pop(context);

    // 👇 Guardar credenciales si está marcado
    final loginForm = Provider.of<LoginFormProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    if (loginForm.recordarUsuario) {
      await prefs.setString('usuario_guardado', loginForm.user);
    } else {
      await prefs.remove('usuario_guardado'); // 👈 Si desmarcó, borra
    }

    if (loginForm.recordarPassword) {
      await prefs.setString('password_guardado', loginForm.password);
    } else {
      await prefs.remove('password_guardado'); // 👈 Si desmarcó, borra
    }

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
            _userName(loginForm),
            const SafeSpacer(),
            _password(context, loginForm),
            const SafeSpacer(
              height: 36,
            ),
            _loginButton(context, loginForm),
          ],
        ),
      ),
    );
  }
}
