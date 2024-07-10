// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/environment/environment.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

class DataProvider {
  // Peticiones POST
  Future<Map<String, dynamic>> postPetition(
    String endpoint,
    Map<String, dynamic> data,
    Map<String, String> headers, {
    int awaitTime = 30,
  }) async {
    // ignore: prefer_typing_uninitialized_variables
    var resp;
    // add Access-Control-Allow-Origin header
    // headers['Access-Control-Allow-Origin'] = '*';
    var dio = Dio();
    // dio.options.
    dio.options.baseUrl =
        Environment().config.apiHost + Environment().config.hostFolder;
    // dio.options.baseUrl = LHOST;
    dio.options.headers = headers;
    // to seconds to milliseconds, seconds * 1000
    dio.options.receiveTimeout = awaitTime * 1000;
    dio.options.method = 'POST';
    // ignore: unused_local_variable
    final data2 = jsonEncode(data);

    try {
      resp = await dio.post(endpoint, data: data).timeout(
        Duration(seconds: awaitTime),
        onTimeout: () {
          throw TimeoutException('Now answer, try again.');
        },
      );
      dynamic decodedRespBody;

      if (resp.data is Map) {
        decodedRespBody = resp.data;
      } else {
        // printConsole(resp.body.toString());
        return {
          'status': 2,
          'error': true,
          'body': {'message': 'Respuesta inesperada', 'data': []}
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
      // controlador = 'sinConexión';
    } on TimeoutException {
      return {
        'status': 4,
        'error': true,
        'body': {
          'message': 'Sin respuesta, intenta de nuevo',
        }
      };
    } catch (e) {
      await logError(e, from: 'Api provider, http.post');
      log(e);
      return {
        'status': 0,
        'error': true,
        'body': {
          'message': 'Error de conexión con el servidor',
          // 'message': 'Error de conexión con el servidor: ${e.toString()}',
        }
      };
    }
  }

  // GET
  Future<Map<String, dynamic>> getPetition(
    String endpoint,
    Map<String, String> headers,
  ) async {
    // ignore: prefer_typing_uninitialized_variables
    var resp;

    var dio = Dio();
    // headers['Access-Control-Allow-Origin'] = '*';

    dio.options.baseUrl =
        Environment().config.apiHost + Environment().config.hostFolder;
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
          'body': {'message': 'Respuesta inesperada'}
        };
      }

      String message = '';
      try {
        final messages = decodedRespBody['message'] as Map;
        message = messages.values.toList().join(' ');
      } catch (e) {
        printConsole(e);
        // await logError(e, from: 'Api provider, http.post');
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
      // controlador = 'sinConexión';
    } on TimeoutException {
      return {
        'status': 4,
        'error': true,
        'body': {
          'message': 'Sin respuesta, intenta de nuevo',
        }
      };
    } catch (e) {
      await logError(e, from: 'Api provider, http.get');
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
}
