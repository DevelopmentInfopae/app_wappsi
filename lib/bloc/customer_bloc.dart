// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// ignore: unused_import
import 'package:nb_utils/src/extensions/widget_extensions.dart';
// import 'package:place_picker/entities/location_result.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/models/product_model.dart';

import 'package:pos_wappsi/providers/user_provider.dart';

import 'package:rxdart/subjects.dart';

class CustomerBloc {
  // to save data of user
  // final _tokenController = BehaviorSubject<String>();
  bool disposed = false;

  BehaviorSubject<CompanyModel?> _customerController =
      BehaviorSubject<CompanyModel?>();
  // to manage addresses creation data
  BehaviorSubject<CustomerAddressesModel?> _addressController =
      BehaviorSubject<CustomerAddressesModel?>();
  BehaviorSubject<Map<String, ProductModel>> _favoritesController =
      BehaviorSubject<Map<String, ProductModel>>();
  BehaviorSubject<String?> _userNameController = BehaviorSubject<String?>();
  BehaviorSubject<String?> _passwordController = BehaviorSubject<String?>();
  BehaviorSubject<String?> _imageController = BehaviorSubject<String?>();
  BehaviorSubject<GeoPoint?> _locationController = BehaviorSubject<GeoPoint?>();

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
      context,
      _userNameController.value!,
    );
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
      _customerController.value = CompanyModel();
    }
    return _customerController.value!;
  }

  CustomerAddressesModel get getAddress {
    if (!_addressController.hasValue) {
      _addressController.value = CustomerAddressesModel(
        id: '',
        direccion: '',
        vatNo: '',
        idCloud: 0,
        customerGroupId: '',
        sucursal: '',
        companyId: '',
        priceGroupId: '',
      );
    } else if (_addressController.hasValue &&
        _addressController.value == null) {
      _addressController.value = CustomerAddressesModel(
        id: '',
        direccion: '',
        vatNo: '',
        idCloud: 0,
        customerGroupId: '',
        sucursal: '',
        companyId: '',
        priceGroupId: '',
      );
    }
    return _addressController.value!;
  }

  String? get getUserName {
    return _userNameController.valueOrNull;
  }

  String? get getPassword {
    return _passwordController.valueOrNull;
  }

  String? get getImagePath {
    return _imageController.valueOrNull;
  }

  GeoPoint? get getLocation {
    return _locationController.valueOrNull;
  }

  Map<String, ProductModel>? getProducts() {
    return _favoritesController.valueOrNull;
  }

  //______________________________________________________________________________________________________________
  //
  //                                       SETTERS
  //_______________________________________________________________________________________________________________

  Function(String) get setUserName => _userNameController.sink.add;
  Function(String?) get setImage => _imageController.sink.add;
  Function(GeoPoint?) get setLocation => _locationController.sink.add;
  Function(String) get setPassword => _passwordController.sink.add;

  dispose() {
    disposed = true;
    _customerController.close();
    _userNameController.close();
    _passwordController.close();
    _favoritesController.close();
    _imageController.close();
    _locationController.close();
    _addressController.close();
  }

  reload() {
    disposed = false;
    _customerController = BehaviorSubject<CompanyModel?>();
    _addressController = BehaviorSubject<CustomerAddressesModel?>();
    _favoritesController = BehaviorSubject<Map<String, ProductModel>>();
    _userNameController = BehaviorSubject<String?>();
    _passwordController = BehaviorSubject<String?>();
    _imageController = BehaviorSubject<String?>();
    _locationController = BehaviorSubject<GeoPoint?>();
  }

  clearAddressCreationData() {
    _addressController.value = null;
  }
}

final customerBloc = CustomerBloc();
