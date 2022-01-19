import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/providers/API_provider.dart';

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
    }

    print(res);
  }
}
