import 'dart:io';

import 'package:flutter/material.dart' hide Key;
import 'package:encrypt/encrypt.dart';
import 'package:pos_wappsi/config/host_params.dart';
// import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/providers/API_provider.dart';
import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/utils/encode_pass.dart';

class LoginFormProvider extends ChangeNotifier {
  String user = '';
  String passsword = '';

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

  //   final encrypted = encrypter.encrypt(passsword, iv: iv);

  //   // print(encrypted.base64);

  //   return encrypted.base64;
  //   // var digest = sha1.convert(bytes);
  //   // return digest.toString();
  // }

  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  Map<String, dynamic> _toJson(bool override) {
    return {
      'username': user.replaceAll(' ', ''),
      'password': encodePass(passsword),
      'override_login': override
    };
  }

  Future<Map<dynamic, dynamic>> login({bool override = false}) async {
    DataProvider provider = new DataProvider();

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
