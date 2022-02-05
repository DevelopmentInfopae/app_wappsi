import 'package:encrypt/encrypt.dart';
import 'package:pos_wappsi/config/host_params.dart';
// import 'package:pos_wappsi/constant.dart';

String encodePass(String password) {
  // data being hashed

  final iv = IV.fromUtf8(iV);
  final key = Key.fromBase64(encodedKey);

  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

  final encrypted = encrypter.encrypt(password, iv: iv);

  // printConsole(encrypted.base64);

  return encrypted.base64;
  // var digest = sha1.convert(bytes);
  // return digest.toString();
}
