import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pos_wappsi/models/biller_data_model.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/permissions_model.dart';
import 'package:pos_wappsi/models/register_model.dart';
import 'package:pos_wappsi/models/user_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/sync_db_provider.dart';
import 'package:pos_wappsi/providers/user_provider.dart';
import 'package:pos_wappsi/screens/home/home.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';
import 'package:rxdart/rxdart.dart';

class DataBloc {
  // to save data of user
  // final _tokenController   = BehaviorSubject<String>();
  final _userController = BehaviorSubject<UserModel?>();
  final _permissionsController = BehaviorSubject<PermissionsModel?>();
  final _registerController = BehaviorSubject<RegisterModel?>();
  final _billerDataController = BehaviorSubject<BillerDataModel?>();
  final _companiesBillerController = BehaviorSubject<CompanyModel?>();
  final _settingsController = BehaviorSubject<Map<String, dynamic>?>();

  final _dirPathController = BehaviorSubject<String?>();

  final _syncingController = StreamController<Map<String, bool>>.broadcast();

  /// To control HomeState and switch between offstages and update Home bottom widget
  final _homeKeyController = BehaviorSubject<GlobalKey<HomeState>?>();

  //______________________________________________________________________________________________________________
  //
  //                                           STREAMS
  //_______________________________________________________________________________________________________________

  Stream<Map<String, bool>> get syncStatusStream => _syncingController.stream;

  //______________________________________________________________________________________________________________
  //
  //                                       SETTERS
  //_______________________________________________________________________________________________________________
  // Function(String) get setToken => _tokenController.sink.add;

  Function(UserModel) get setUserData => _userController.sink.add;

  Function(PermissionsModel) get setPermissions =>
      _permissionsController.sink.add;
  Function(RegisterModel) get setRegisterData => _registerController.sink.add;
  Function(BillerDataModel) get setBillerData => _billerDataController.sink.add;
  Function(CompanyModel) get setBillerCompany =>
      _companiesBillerController.sink.add;
  Function(String) get setDirPath => _dirPathController.sink.add;

  Function(GlobalKey<HomeState>) get setHomeKey => _homeKeyController.sink.add;

  Function(Map<String, dynamic>) get setSettings =>
      _settingsController.sink.add;

  Function(Map<String, bool>) get setSyncStatus => _syncingController.sink.add;

  //______________________________________________________________________________________________________________
  _setSettings() async {
    final settings = await DBProvider.db.getSettings();
    if (settings != null) {
      dataBloc.setSettings(settings);
    }
  }
  //
  //                                       GETTERS
  //_______________________________________________________________________________________________________________

  Future<Map<String, dynamic>> getSettings() async {
    if (dataBloc.settings != null) {
      return dataBloc.settings!;
    } else {
      await _setSettings();
      return await getSettings();
    }
  }

  Map<String, dynamic>? get settings => _settingsController.valueOrNull;

  String getToken() {
    return dataBloc.userData?.token ?? '';
  }

  /// To control Home state, like selected tab item or current bottomBar
  GlobalKey<HomeState>? get homeKey => _homeKeyController.valueOrNull;

  Map<String, dynamic> get userDataMap => _userController.value!.toJson();

  UserModel? get userData => _userController.valueOrNull;

  PermissionsModel? get permissions => _permissionsController.valueOrNull;

  String? get dirPath => _dirPathController.valueOrNull;

  BillerDataModel? get getBIllerData => _billerDataController.valueOrNull;

  CompanyModel? get getBillerCompany => _companiesBillerController.valueOrNull;

  Map<String, dynamic> get registerDataMap =>
      _registerController.value!.toJson();

  // Map<String, bool>? get getSyncStatus => _syncingController.valueOrNull;

  RegisterModel? get registerData => _registerController.valueOrNull;

  //______________________________________________________________________________________________________________
  //
  //                                       FUNCTIONS
  //_______________________________________________________________________________________________________________

  /// Request server logout
  Future<Map<String, dynamic>> logout() async {
    dataBloc.homeKey?.currentState?.syncLoader(true);
    final res = await UserProvider.logout();
    dataBloc.homeKey?.currentState?.syncLoader(false);
    return res;
  }

  /// update current JWT token to extend session time
  Future refreshToken(BuildContext context) async {
    if (!(dataBloc.homeKey?.currentState?.syncing ?? true)) {
      dataBloc.homeKey?.currentState?.syncLoader(true);
      Map<String, dynamic>? res;
      try {
        res = await UserProvider.refreshToken();
      } catch (e) {
        // printConsole(e);
        await logError(e, from: 'Refresh token');
      }
      dataBloc.homeKey?.currentState?.syncLoader(false);
      if (res != null) {
        // ignore: require_trailing_commas
        reloadDialog(
          context,
          res['body']['message'] ?? '',
          'assets/images/dizzy-robot.png',
        );
      }
    }
  }

  Future<List> syncElements(List<String> elements, BuildContext context) async {
    dataBloc.homeKey?.currentState?.syncLoader(true);
    final syncDB = SyncDBProvider();
    final res = await Future.wait(
      elements.map((element) {
        return syncDB.syncOption(context, element);
      }).toList(),
    );

    dataBloc.homeKey?.currentState?.syncLoader(false);
    return res;
  }

  Map<String, String> getHeaders() {
    return {
      'content-Type': 'application/json',
      'Authorization': dataBloc.getToken()
    };
  }

  reload() {
    _userController.value = null;
    _registerController.value = null;
    _billerDataController.value = null;
    _companiesBillerController.value = null;
    _dirPathController.value = null;
    _permissionsController.value = null;
    _homeKeyController.value = null;
    _settingsController.value = null;
  }

  dispose() {
    _userController.close();
    _homeKeyController.close();
    // _tokenController.close();
    _registerController.close();
    _companiesBillerController.close();
    _settingsController.close();
    _billerDataController.close();
    _dirPathController.close();
    _syncingController.close();
    _permissionsController.close();
  }
}

final dataBloc = DataBloc();
