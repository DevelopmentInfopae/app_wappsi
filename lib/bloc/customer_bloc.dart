// ignore_for_file: implementation_imports

import 'dart:io';

import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/groups_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/API_provider.dart';
import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/screens/home/components/tab_item.dart';
// import 'package:pos_wappsi/screens/customers/new_customer.dart';
// import 'package:pos_wappsi/screens/home/home_screen.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/encode_pass.dart';
import 'package:pos_wappsi/utils/manage_server_resp.dart';
import 'package:rxdart/subjects.dart';

import 'data_bloc.dart';

class CustomerBloc {
  // to save data of user
  // final _tokenController = BehaviorSubject<String>();

  final _customerController = BehaviorSubject<CompanyModel?>();
  final _favoritesController = BehaviorSubject<Map<String, ProductModel>>();
  final _userNameController = BehaviorSubject<String?>();
  final _passwordController = BehaviorSubject<String?>();

  //-----------------------------------------------------------------------------
  //                                Streams
  //
  //-----------------------------------------------------------------------------

  Stream<Map<String, ProductModel>> get favoritesStream =>
      _favoritesController.stream.asBroadcastStream();

  //______________________________________________________________________________________________________________
  //
  //                                       Functions
  //_______________________________________________________________________________________________________________

  sendCustomerInfo(BuildContext context) async {
    final customerGroup = await Groups.loadCustomerGroup();
    final apiProvider = new DataProvider();
    if (customerGroup == null) {
      return {
        'error': true,
        'body': {'message': 'No fue posible seleccionar grupo de company'}
      };
    } else {
      getCustomer.groupId = customerGroup.idCloud.toString();
      getCustomer.groupName = customerGroup.name;
    }

    Map<String, String> headers = {
      'content-Type': 'application/json',
      'Authorization': dataBloc.getToken()
    };

    final body = getCustomer.customerToJson();

    if (_userNameController.valueOrNull != null &&
        _passwordController.valueOrNull != null) {
      final temp = {};
      temp['username'] = _userNameController.value;
      temp['password'] = encodePass(_passwordController.value!);
      body['user_data'] = temp;
    }

    // ignore: unnecessary_null_comparison
    if (_favoritesController.valueOrNull != null) {
      List<int> favorites = [];
      _favoritesController.value.forEach((key, value) {
        favorites.add(value.idCloud);
      });
      body['favorites'] = favorites;
    }

    scaffoldAlert(context, 'Registrando cliente', Duration(seconds: 10),
        key: UniqueKey());

    final res = await apiProvider.postPetition(addCompanyEndP, body, headers);

    hideCurrentScaffoldAlert(context);
    if (res['status'] == -1) {
      await reloadDialog(
          context, res['body']['message'], 'assets/images/dizzy-robot.png');
    } else if (res['error']) {
      confirmDialog(
          context, res['body']['message'], 'assets/images/dizzy-robot.png');
    } else {
      // update local DB with new company info
      bool dbUpdated = await CompanyModel.writeCustomerInLDB(body, res);

      // if fails we force DB sync
      if (!dbUpdated) {
        _goHome(context);
        // DBSyncElements(
        //   options: {'Terceros': true, 'Sucursales': true},
        // ).launch(context);
        await dataBloc.syncElements(['Terceros', 'Sucursales'], context);
        confirmDialog(
            context, res['body']['message'], 'assets/images/success.png');
      } else {
        // if local db update success, go to home
        _goHome(context);
        // dataBloc.homeKey.currentState?.selectTab(TabItem.clients);
        confirmDialog(
            context, res['body']['message'], 'assets/images/success.png');
      }

      // Navigator.pop(context);
    }
  }

  Future<bool> verifyUserName(BuildContext context) async {
    final apiProvider = new DataProvider();

    Map<String, String> headers = {
      'content-Type': 'application/json',
      'Authorization': dataBloc.getToken()
    };
   
    final response = await apiProvider.postPetition(
        verifyUserNameEndP, {'username': _userNameController.value}, headers);
    
    manageResponseAlerts(response, context);
    
    return response['error'] ?? true;
  }

  void _goHome(BuildContext context) {
    customerBloc.clear();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  void addProductToFav(ProductModel product, String key) {
    if (_favoritesController.hasValue) {
      _favoritesController.value[key] = (product);
    } else {
      _favoritesController.value = {};
      _favoritesController.value[key] = (product);
    }
    // to update listeners
    _favoritesController.sink.add(_favoritesController.value);
  }

  void removeProductFromFav(String key) {
    _favoritesController.value.remove(key);
    _favoritesController.sink.add(_favoritesController.value);
  }

  //______________________________________________________________________________________________________________
  //
  //                                       GETTERS
  //_______________________________________________________________________________________________________________

  CompanyModel get getCustomer {
    if (!_customerController.hasValue) {
      _customerController.value = new CompanyModel();
    }
    return _customerController.value!;
  }

  String? get getUserName {
    return _userNameController.valueOrNull;
  }

  String? get getPassword {
    return _passwordController.valueOrNull;
  }

  Map<String, ProductModel>? getProducts() {
    return _favoritesController.valueOrNull;
  }

  //______________________________________________________________________________________________________________
  //
  //                                       SETTERS
  //_______________________________________________________________________________________________________________

  Function(String) get setUserName => _userNameController.sink.add;
  Function(String) get setPassword => _passwordController.sink.add;

  dispose() {
    _customerController.close();
    _userNameController.close();
    _passwordController.close();
    _favoritesController.close();
  }

  clear() {
    _customerController.value = new CompanyModel();
    _userNameController.value = null;
    _passwordController.value = null;
    _favoritesController.value = {};
  }
}

final customerBloc = CustomerBloc();
