import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:pos_wappsi/bloc/printer_bloc.dart';
import 'package:pos_wappsi/config/bd_sync.dart';
import 'package:pos_wappsi/models/companies_model.dart';

import 'package:pos_wappsi/providers/api_provider.dart';
import 'package:pos_wappsi/providers/cities_provider.dart';
import 'package:pos_wappsi/providers/countries_provider.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/states_provider.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

import 'biller_data_provider.dart';

class SyncDBProvider {
  String updateDate = '';
  String syncDate = '';
  bool firstTime = false;

  _getUpdates(Map<String, dynamic> options, {bool isPost = true}) async {
    String? updateDate;
    DataProvider api = DataProvider();

    Map<String, dynamic> res;
    if (isPost) {
      updateDate = await DBProvider.db.getUpdateDate(options['sync_id']);
      // ignore: unnecessary_null_comparison
      if (updateDate == '[]' || updateDate == null || updateDate == 'null') {
        updateDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now());
        firstTime = true;
      }
      Map<String, dynamic> body = {
        'last_sync': updateDate,
        'first_time': firstTime
      };
      res = await api.postPetition(options['path'], body, dataBloc.getHeaders(),
          awaitTime: 150);
    } else {
      res = await api.getPetition(options['path'], dataBloc.getHeaders());
    }
    return res;
  }

  /// Load sma_countries, sma_states and sma_cities from local json files
  Future<bool> loadCSC() async {
    bool res = true;
    List<Map<String, dynamic>>? temp =
        await CountriesProvider.allCountries() ?? [];
    if (temp.isEmpty) {
      res = await CountriesProvider.writeToDBfromJsonFile();
    }
    temp = await StatesProvider.allStates() ?? [];
    if (temp.isEmpty) {
      res = await StatesProvider.writeToDBfromJson();
    }
    temp = await CitiesProvider.allCities() ?? [];
    if (temp.isEmpty) {
      res = await CitiesProvider.writeToDBfromJson();
    }

    return res;
  }

  Future<Map> update(
    String option, {
    Map<String, dynamic>? selectedOption,
    bool isSpecial = false,
    bool post = true,
  }) async {
    final res =
        await _getUpdates(selectedOption ?? options[option]!, isPost: post);
    //check if JWT is ok, if not logout
    if (res['status'] == -1) {
      return {
        'error': true,
        'status': -1,
        'message': "Error al sincronizar, ${res['body']['message']}"
      };
    } else {
      if (res['error']) {
        // syncBloc.setProgressMessage(res['body']['message']);
        return {'error': true, 'status': 2, 'message': res['body']['message']};
      } else {
        // syncBloc.setProgressMessage('Escribiendo actualizaciones en la base de datos local');
        bool result = false;
        // ignore: unrelated_type_equality_checks

        if (specialSync.contains(option)) {
          final optionInfo = options[option];
          result = await _specialWriteIntoLocalDB(res,
              deleteBefore: optionInfo!['delete_before'],
              independentTable: optionInfo['independent_table'],
              dependentTable: optionInfo['dependent_table'],
              idKey: optionInfo['id_key'],
              columnName: optionInfo['column_name']);
        } else {
          result = await _writeIntoLocalDB(
              res, (selectedOption ?? options[option])!['table']);
        }

        if ((selectedOption ?? options[option])!['table'] == 'sma_settings') {
          await dataBloc.getSettings();
        }

        // set update time from server, in theory this always come valid
        if (result) {
          // syncBloc.setProgressMessage('Estableciendo fecha de ultima actualización para $option');

          await DBProvider.db.setUpdateDate(res['body']['server_date_time'],
              (selectedOption ?? options[option])!['sync_id']);

          // syncBloc.setProgressMessage('$option sincronizados');
          return {
            'error': false,
            'status': 1,
            'message': '$option sincronizados'
          };
        } else {
          // syncBloc.setProgressMessage('Error al sincronizar $option');
          return {
            'error': true,
            'status': 2,
            'message': 'Error al sincronizar $option'
          };
        }
      }
    }
  }

  Future<bool> setUpdateDate(String date, int idSync) async {
    final bool result = await DBProvider.db.setUpdateDate(date, idSync);
    return result;
  }

  Future<Map> updateBillerTables() async {
    // String updateDate = '';
    Map<String, dynamic> billerSync = options['Datos de Facturación']!;
    DataProvider api = DataProvider();

    Map<String, dynamic> body = {'biller_id': dataBloc.userData!.billerId};

    Map<String, dynamic> res = await api.postPetition(
        billerSync['path_data'], body, dataBloc.getHeaders(),
        awaitTime: 150);

    bool result = false;

    if (res['status'] == 1) {
      result = await _writeIntoLocalDB(res, billerSync['table_data']);
    } else if (res['status'] == -1) {
      return {
        'error': true,
        'status': -1,
        'message': "Error al sincronizar, ${res['body']['message']}"
      };
    } else {
      // syncBloc.setProgressMessage('Error al sincronizar datos de sucursal');
      return {
        'error': true,
        'status': 2,
        'message': 'Error al sincronizar datos de sucursal'
      };
    }
    if (result) {
      res = await api.postPetition(
          billerSync['path_documents_data'], body, dataBloc.getHeaders(),
          awaitTime: 150);
      if (res['status'] == 1) {
        result =
            await _writeIntoLocalDB(res, billerSync['table_documents_data']);
      } else if (res['status'] == -1) {
        return {
          'error': true,
          'status': -1,
          'message': "Error al sincronizar, ${res['body']['message']}"
        };
      } else {
        // syncBloc.setProgressMessage('Error al sincronizar datos de sucursal');
        return {
          'error': true,
          'status': 2,
          'message': 'Error al sincronizar datos de sucursal'
        };
      }
    } else {
      // syncBloc.setProgressMessage('Error al sincronizar datos de sucursal');
      return {
        'error': true,
        'status': 2,
        'message': 'Error al sincronizar datos de sucursal'
      };
    }

    return {
      'error': false,
      'status': 1,
      'message': 'Datos de sucursal sincronizados'
    };
  }

  Future<void> _updateBillerInDataBLoc() async {
    final companyData = await CompanyModel.getCompanyBiller();
    try {
      dataBloc.setBillerCompany(companyData!);
    } catch (e) {
      printConsole(e);
    }

    // update current companyBiller on dataBloc
    final billerData = await BillerDataProvider.loadBillerData();
    try {
      dataBloc.setBillerData(billerData!);
    } catch (e) {
      printConsole(e);
    }
  }

  Future<bool> _writeIntoLocalDB(Map<String, dynamic> res, String table) async {
    bool result = false;
    if ((res['body']['data'] != null) ||
        (res['body']['data'] != "[]") ||
        (res['body']['data'] != [])) {
      result =
          await DBProvider.db.insertOrUpdateQuerys(table, res['body']['data']);
    }
    return result;
  }

  ///This function is used to sync tables who have tables directly related, like sma_order_sales and
  ///sma_order_sale_items. If we dont have a unique constraint, we can delete before insert using delete_before
  ///param, with that we need to specify the identifierKey (id) and the columnName to build delete query.
  Future<bool> _specialWriteIntoLocalDB(Map<String, dynamic> res,
      {bool deleteBefore = false,
      String? idKey,
      String? independentTable,
      String? dependentTable,
      String? columnName}) async {
    bool result = true;
    if ((res['body']['data'] != null) ||
        (res['body']['data'] != "[]") ||
        (res['body']['data'] != [])) {
      final data = res['body']['data'];

      if (data != null) {
        // data always come organized in father table and son table
        await Future.forEach(data.keys, (String key) async {
          if (deleteBefore) {
            String? idValue;

            if (key == independentTable) {
              for (var i = 0; i < data[key]!.length; i++) {
                idValue = data[key][i][idKey];
                if (idValue != null) {
                  final res = await DBProvider.db.deleteQuerys(
                      dependentTable!,
                      '$columnName=$idValue');
                  printConsole(res);
                }
              }
            }
          }
          result = await DBProvider.db.insertOrUpdateQuerys(key, data[key]);
        });
      }
    }
    // print(result);
    return result;
  }

  Future syncOption(BuildContext context, String option,
      {bool deleteBefore = false}) async {
    if (option == 'Datos de Facturación') {
      final res = await updateBillerData(context);
      if (res['status'] == -1) {
        await reloadDialog(
            context,
            'Sesión expirada, es necesario a iniciar sesión',
            'assets/images/warning.png');
      } else {
        if (res['error'] == true) {
          return await syncOption(context, option);
        }
      }
      return res;
    } else {
      final res = await update(option);
      if (res['status'] == -1) {
        await reloadDialog(
            context,
            'Sesión expirada, es necesario a iniciar sesión',
            'assets/images/warning.png');
      } else {
        if (res['error'] == true) {
          final choice = await choiceAlert(context,
              res['message'] + '¿Reintentar?', 'assets/images/warning.png');

          if (choice) {
            return await syncOption(context, option);
          }
        }
      }
      if (option == 'Terceros') {
        // update current companyBiller on dataBloc
        await _updateBillerInDataBLoc();
      }
      // Environment().env!='DEV'?null:print('xd');
      return res;
    }
  }

  Future<void> synSelectedOption(Map<String, dynamic> option, context,
      {bool isPost = true}) async {
    final res = await update(
      '',
      selectedOption: option,
      post: isPost,
    );
    if (res['status'] == -1) {
      await reloadDialog(
          context,
          'Sesión expirada, es necesario a iniciar sesión',
          'assets/images/warning.png');
    } else {
      if (res['error'] == true) {
        final choice = await choiceAlert(context,
            res['message'] + '¿Reintentar?', 'assets/images/warning.png');

        if (choice) {
          return await synSelectedOption(option, context, isPost: isPost);
        }
      }
    }
  }

  Future<bool> syncSpecialSelectedOption(String option, context,
      {bool isPost = true}) async {
    bool result = false;
    final res = await _getUpdates(options[option]!, isPost: isPost);
    if (res['status'] == -1) {
      await reloadDialog(
          context,
          'Sesión expirada, es necesario a iniciar sesión',
          'assets/images/warning.png');
    } else {
      if (res['error'] == true) {
        final choice = await choiceAlert(context,
            res['message'] + '¿Reintentar?', 'assets/images/warning.png');

        if (choice) {
          return await syncSpecialSelectedOption(option, context);
        }
      } else {
        final optionInfo = options[option];
        return await _specialWriteIntoLocalDB(res,
            deleteBefore: optionInfo!['delete_before'],
            independentTable: optionInfo['independent_table'],
            dependentTable: optionInfo['dependent_table'],
            idKey: optionInfo['id_key'],
            columnName: optionInfo['column_name']);
      }
    }
    return result;
  }

  Future<Map> updateBillerData(BuildContext context) async {
    final res = await updateBillerTables();

    if (res['status'] == -1) {
      reloadDialog(context, 'Sesión expirada, es necesario a iniciar sesión',
          'assets/images/warning.png');
    } else {
      if (res['error'] == true) {
        final choice = await choiceAlert(context,
            res['message'] + '¿Reintentar?', 'assets/images/warning.png');

        if (choice) {
          return await updateBillerData(context);
        }
      }
    }
    return res;
  }
}
