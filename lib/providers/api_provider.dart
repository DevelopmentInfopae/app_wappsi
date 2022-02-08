// ignore_for_file: implementation_imports

import 'dart:convert';

import 'package:dio/dio.dart';

// import 'package:nb_utils/src/extensions/string_extensions.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:pos_wappsi/config/environment.dart';
// import 'package:pos_wappsi/config/host_params.dart';
import 'package:pos_wappsi/environment/environment.dart';

import 'dart:async';
// import 'dart:convert';
import 'dart:io';

import 'package:pos_wappsi/utils/print_errors.dart';

class DataProvider {
  // POST petitons
  Future<Map<String, dynamic>> postPetition(
      String endpoint, Map<String, dynamic> data, Map<String, String> headers,
      {int awaitTime = 30}) async {
    // ignore: prefer_typing_uninitialized_variables
    var resp;
    // add Access-Control-Allow-Origin header
    // headers['Access-Control-Allow-Origin'] = '*';
    var dio = Dio();
    // dio.options.
    dio.options.baseUrl = ((dataBloc.userData == null
            ? Environment().config.apiHost
            : dataBloc.userData?.hostUrl ?? '')) +
        Environment().config.hostFolder;
    // dio.options.baseUrl = LHOST;
    dio.options.headers = headers;
    // to seconds to milliseconds, seconds * 1000
    dio.options.receiveTimeout = awaitTime * 1000;
    dio.options.method = 'POST';
    final data2 = jsonEncode(data);

    try {
      resp = await dio
          .post(endpoint, data: data)
          .timeout(Duration(seconds: awaitTime), onTimeout: () {
        throw TimeoutException('Now answer, try again.');
      });
      dynamic decodedRespBody;

      if (resp.data is Map) {
        decodedRespBody = resp.data;
      } else {
        // printConsole(resp.body.toString());
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
        printConsole(e);
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
          // printConsole(resp['status']);
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
      printConsole(e);
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
    // ignore: prefer_typing_uninitialized_variables
    var resp;

    var dio = Dio();
    // headers['Access-Control-Allow-Origin'] = '*';

    dio.options.baseUrl = ((dataBloc.userData == null
            ? Environment().config.apiHost
            : dataBloc.userData?.hostUrl ?? '')) +
        Environment().config.hostFolder;
    dio.options.headers = headers;
    dio.options.method = 'GET';
    // String url =
    //     (dataBloc.userData == null ? HOST : dataBloc.userData?.hostUrl ?? '') +
    //         '/wappsi_apis/$endpoint';
    try {
      resp = await dio.get(endpoint);

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
        printConsole(e);
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
          // printConsole(resp['status']);
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
  //       // printConsole(resp['status']);
  //       return {'status': 3, 'message': 'Something went wrong, try again!', 'body': null};
  //     }
  //   }

  //   on SocketException {
  //     return {'status': 1, 'message': 'Verify your internet connection', 'body': null};
  //       // controlador = 'sinConexion';
  //   } on http.ClientException {
  //     // printConsole('ClientException');
  //     return {'status': 2, 'message': 'Something went wrong, try again', 'body': null};
  //   } on TimeoutException {
  //     return {'status': 3, 'message': 'No answer, try again', 'body': null};
  //   }

  //   catch (e) {
  //     return {'status': 0, 'message': 'Failed request', 'body': null};
  //   }
  // }
}
