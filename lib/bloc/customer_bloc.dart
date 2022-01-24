// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/product_model.dart';

import 'package:pos_wappsi/providers/user_provider.dart';

import 'package:rxdart/subjects.dart';

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

  Future<bool> verifyUserName(BuildContext context) async {
    final res = await UserProvider.verifyIfUserNameExist(
        context, _userNameController.value!);
    return res;
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
