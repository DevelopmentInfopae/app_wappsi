// ignore_for_file: implementation_imports

import 'package:dio/dio.dart';

import 'package:nb_utils/src/extensions/string_extensions.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/config/host_params.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';

// import 'package:pos_wappsi/constant.dart';

// import 'package:pos_wappsi/constant.dart';

class DataProvider {
  // POST petitons
  Future<Map<String, dynamic>> postPetition(String endpoint,
      Map<String, dynamic> authData, Map<String, String> headers,
      {int awaitTime = 30}) async {
    var resp;

    var dio = Dio();
    dio.options.headers = headers;

    String body = jsonEncode(authData);

    String url =
        (dataBloc.userData == null ? HOST : dataBloc.userData?.hostUrl ?? '') +
            '/wappsi_apis/$endpoint';
    // print(authData);
    try {
      resp = await dio
          .post(url, data: body)
          .timeout(Duration(seconds: awaitTime), onTimeout: () {
        throw TimeoutException('Now answer, try again.');
      });
      dynamic decodedRespBody;

      if (resp.data is Map) {
        decodedRespBody = resp.data;
      } else {
        // print(resp.body.toString());
        return {
          'status': 2,
          'error': true,
          'body': {'message': "Respuesta inesperada", 'data': []}
        };
      }

      String message = '';
      try {
        final messages = decodedRespBody['message'] as Map;
        message = messages.values.toList().join(' ');
      } catch (e) {
        print(e);
        message = decodedRespBody['message'].toString();
      }
      decodedRespBody['message'] = message;
      if (decodedRespBody['reload'] ?? false) {
        // to handle JWT problems
        return {
          'status': -1,
          'error': decodedRespBody['error'],
          'body': decodedRespBody
        };
      } else {
        if (decodedRespBody['status'] == 200 ||
            decodedRespBody['status'] == 201) {
          return {
            'status': 1,
            'error': decodedRespBody['error'],
            'body': decodedRespBody
          };
        } else {
          // print(resp['status']);
          return {
            'status': 2,
            'error': decodedRespBody['error'],
            'body': decodedRespBody
          };
        }
      }
    } on SocketException {
      return {
        'status': 3,
        'error': true,
        'body': {
          'message': 'Verifica tu conexión a internet',
        }
      };
      // controlador = 'sinConexion';
    } on TimeoutException {
      return {
        'status': 4,
        'error': true,
        'body': {
          'message': 'Sin respuesta, intenta de nuevo',
        }
      };
    } catch (e) {
      print(e);
      return {
        'status': 0,
        'error': true,
        'body': {
          'message': 'Petición fallida',
        }
      };
    }
  }

  // GET
  Future<Map<String, dynamic>> getPetition(
      String endpoint, Map<String, String> headers) async {
    var resp;

    var dio = Dio();
    dio.options.headers = headers;
    String url =
        (dataBloc.userData == null ? HOST : dataBloc.userData?.hostUrl ?? '') +
            '/wappsi_apis/$endpoint';
    try {
      resp = await dio.get(url).timeout(Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Now answer, try again.');
      });

      dynamic decodedRespBody;
      if (resp.data is Map) {
        decodedRespBody = resp.data;
      } else {
        return {
          'status': 2,
          'error': true,
          'body': {'message': "Respuesta inesperada"}
        };
      }

      String message = '';
      try {
        final messages = decodedRespBody['message'] as Map;
        message = messages.values.toList().join(' ');
      } catch (e) {
        print(e);
        message = decodedRespBody['message'].toString();
      }
      decodedRespBody['message'] = message;

      if (decodedRespBody['reload'] ?? false) {
        // to handle JWT problems
        return {
          'status': -1,
          'error': decodedRespBody['error'],
          'body': decodedRespBody
        };
      } else {
        if (decodedRespBody['status'] == 200 ||
            decodedRespBody['status'] == 201) {
          return {
            'status': 1,
            'error': decodedRespBody['error'],
            'body': decodedRespBody
          };
        } else {
          // print(resp['status']);
          return {
            'status': 2,
            'error': decodedRespBody['error'],
            'body': decodedRespBody
          };
        }
      }
    } on SocketException {
      return {
        'status': 3,
        'error': true,
        'body': {
          'message': 'Verifica tu conexión a internet',
        }
      };
      // controlador = 'sinConexion';
    } on TimeoutException {
      return {
        'status': 4,
        'error': true,
        'body': {
          'message': 'Sin respuesta, intenta de nuevo',
        }
      };
    } catch (e) {
      return {
        'status': 0,
        'error': true,
        'body': {
          'message': 'Petición fallida',
        }
      };
    }
  }

  handleErrorJWT() {}

  // DELETE

  // Future<Map<String,dynamic>> deletePetition
  //       (String endpoint,{Map<String, String> headers}) async {
  //   var resp;
  //   String _url = URL + '/api/$endpoint';
  //   try {
  //     resp = await http.delete(
  //       _url,
  //       headers: headers
  //     ).timeout(
  //       Duration(seconds: 15),
  //       onTimeout: (){
  //         throw TimeoutException('Now answer, try again.');
  //       }
  //     );

  //     if (resp['status'] == 200) {
  //       return {
  //         'body':decodedRespBody,
  //         'status':1
  //       };
  //     }else if(resp['status'] == 401){
  //       return {
  //         'status': 2,
  //         'message': decodedRespBody['message']
  //       };
  //     }else {
  //       // print(resp['status']);
  //       return {'status': 3, 'message': 'Something went wrong, try again!', 'body': null};
  //     }
  //   }

  //   on SocketException {
  //     return {'status': 1, 'message': 'Verify your internet connection', 'body': null};
  //       // controlador = 'sinConexion';
  //   } on http.ClientException {
  //     // print('ClientException');
  //     return {'status': 2, 'message': 'Something went wrong, try again', 'body': null};
  //   } on TimeoutException {
  //     return {'status': 3, 'message': 'No answer, try again', 'body': null};
  //   }

  //   catch (e) {
  //     return {'status': 0, 'message': 'Failed request', 'body': null};
  //   }
  // }
}
