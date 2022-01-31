import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/providers/API_provider.dart';
import 'package:pos_wappsi/utils/manage_server_resp.dart';

class UserProvider {
  static Future<Map<String, dynamic>> logout() async {
    DataProvider api = new DataProvider();

    Map<String, String> headers = {'Authorization': dataBloc.getToken()};

    final res = await api.getPetition(logoutEndP, headers);

    if (res['status'] == 1 || res['status'] == -1) {
      return {'status': true};
    } else {
      return {'status': false, 'body': res['body']};
    }

    // print(res);
  }

  static Future refreshToken() async {
    DataProvider api = new DataProvider();

    Map<String, String> headers = {'Authorization': dataBloc.getToken()};

    final res = await api.getPetition(refreshTokenEndP, headers);

    if (res['status'] == 1) {
      dataBloc.userData?.token =
          res['body']['token'] ?? dataBloc.userData?.token;
    } else if (res['status'] == -1) {
      return res;
    } else {
      return res;
    }

    print(res);
  }

  static Future<bool> verifyIfUserNameExist(
      BuildContext context, String userName) async {
    final apiProvider = new DataProvider();

    final response = await apiProvider.postPetition(
        verifyUserNameEndP, {'username': userName}, dataBloc.getHeaders());

    manageResponseAlerts(response, context);

    return response['error'] ?? true;
  }

  static Future<bool> verifyIfCompanyHaveUser(
      BuildContext context, String companyId) async {
    final apiProvider = new DataProvider();

    final response = await apiProvider.postPetition(
        verifyUserExistEndP, {'company_id': companyId}, dataBloc.getHeaders());

    manageResponseAlerts(response, context, showErrorDialog: false);

    return response['error'] ?? true;
  }
}
