import 'package:flutter/material.dart' hide Key;
import 'package:pos_wappsi/config/endpoints.dart';
// import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/providers/api_provider.dart';
import 'package:pos_wappsi/utils/validation_encoding/encode_pass.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginFormProvider extends ChangeNotifier {
  String user = '';
  String password = '';
  bool recordarUsuario = false;
  bool recordarPassword = false;

  Future<void> cargarRecordados() async {
    final prefs = await SharedPreferences.getInstance();
    recordarUsuario  = prefs.getBool('recordar_usuario') ?? false;
    recordarPassword = prefs.getBool('recordar_password') ?? false;
    notifyListeners();
  }

  // Al hacer toggle, guarda el valor
  void toggleRecordarUsuario(bool? value) async {
    recordarUsuario = value ?? false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('recordar_usuario', recordarUsuario);
    notifyListeners();
  }

  void toggleRecordarPassword(bool? value) async {
    recordarPassword = value ?? false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('recordar_password', recordarPassword);
    notifyListeners();
  }

  // to enable or disable send loginFormData to backend while waiting for response

  bool _isLoading = false;

  get loading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  //______________________________________________________________________________________________________________
  //
  //                                    ENCODE PASS FOR SECURITY REASONS
  //_______________________________________________________________________________________________________________

  // String _encodePass() {
  //   // data being hashed

  //   final iv = IV.fromUtf8(iV);
  //   final key = Key.fromBase64(encodedKey);

  //   final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

  //   final encrypted = encrypter.encrypt(password, iv: iv);

  //   // printConsole(encrypted.base64);

  //   return encrypted.base64;
  //   // var digest = sha1.convert(bytes);
  //   // return digest.toString();
  // }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  Map<String, dynamic> _toJson(bool override) {
    return {
      'username': user.replaceAll(' ', ''),
      'password': encodePass(password),
      'override_login': override,
    };
  }

  Future<Map<dynamic, dynamic>> login({bool override = false}) async {
    DataProvider provider = DataProvider();

    final resp = await provider.postPetition(loginEndP, _toJson(override), {
      'content-Type': 'application/json',
    });

    Map<String, dynamic> decodedResp = resp; //Sin conexión
    if (decodedResp['status'] == 1) {
      if (decodedResp['body']['status'] == 400) {
        return {'status': 2, 'body': decodedResp['body']};
      } else if (decodedResp['body']['status'] == 401) {
        return {'status': 3, 'body': decodedResp['body']};
      }
      if (decodedResp['body']['status'] == 402) {
        return {'status': 4, 'body': decodedResp['body']};
      }
      if (decodedResp['body']['status'] == 403) {
        return {'status': 5, 'body': decodedResp['body']};
      } else {
        return {'status': 1, 'body': decodedResp['body']};
      }
    } else {
      return {'status': 0, 'body': decodedResp['body']};
    }
  }
}
