import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/providers/api_provider.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/local_storage/local_db.dart';

class ErrorsProvider {
  Future<List<Map<String, dynamic>>> getAllErrors() async {
    final res = await DBProvider.db
        .sqlQuery('errors_log', columns: ['error', 'from', 'date']);

    if (res != null) {
      return res;
    }
    return [];
  }

  Future<bool> deleteAllErrors() async {
    final res = await DBProvider.db.sqlDelete('errors_log', null);
    return res;
  }

  Future<bool> sendErrorLog(BuildContext context, String? message) async {
    List<Map<String, dynamic>> temp = await getAllErrors();

    temp = queryResultToMapList(temp);

    final body = {
      'errors_info': temp.isNotEmpty
          ? temp
          : [
              {
                'error': 'No error',
                'from': 'sended report without error register',
                'date': DateTime.now().toIso8601String()
              }
            ],
      'message': message ?? '',
      'user_data':
          '${dataBloc.userData?.firstName} ${dataBloc.userData?.lastName} ${dataBloc.userData?.companyName}',
    };

    scaffoldAlert(
        context, 'Enviando reporte de error', const Duration(seconds: 1),
        key: UniqueKey());
    final apiProvider = DataProvider();
    final res = await apiProvider.postPetition(
        sendErrorEndP, body, dataBloc.getHeaders());
    bool sendOk = false;
    hideCurrentScaffoldAlert(context);
    if (res['status'] == -1) {
      await reloadDialog(
          context, res['body']['message'], 'assets/images/dizzy-robot.png');
    } else if (res['error']) {
      confirmDialog(
          context, res['body']['message'], 'assets/images/dizzy-robot.png');
    } else if (!res['error']) {
      scaffoldAlert(
          context, 'Reporte de errores exitoso', const Duration(seconds: 1),
          key: UniqueKey());
      sendOk = true;
      await deleteAllErrors();
      // Navigator.pop(context);
    }
    return sendOk;
  }
}
