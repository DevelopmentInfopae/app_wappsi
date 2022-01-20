// import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:pos_wappsi/models/documents_types_model.dart';
import 'package:pos_wappsi/models/payment_methods_model.dart';
import 'package:pos_wappsi/providers/API_provider.dart';
import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/utils/alerts.dart';

class RegisterFormProvider extends ChangeNotifier {
  String value = '';

  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  // to enable or disable send cashAccOpenForm to backend while waiting for response

  bool _isLoading = false;

  String movementType = '';

  String? documentType = '';

  PaymentMethods? paymentOrigin;

  PaymentMethods? paymentDestiny;

  String? movementNote = '';

  get loading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  openRegister() async {
    DataProvider api = new DataProvider();

    // ignore: unnecessary_null_comparison
    if (value == '' || value == null) {
      value = '0';
    }
    final body = _openToJson();
    final res =
        await api.postPetition(regOpenEndP, body, dataBloc.getHeaders());

    return res;
  }

  movement() async {
    DataProvider api = new DataProvider();

    // ignore: unnecessary_null_comparison
    if (value == '' || value == null) {
      value = '0';
    }
    final body = _movementToJson();
    final res = await api.postPetition(regMovEndP, body, dataBloc.getHeaders(),
        awaitTime: 10);

    return res;
  }

  Map<String, dynamic> _openToJson() {
    return {'base': value};
  }

  Map<String, dynamic> _movementToJson() {
    return {
      'mv_biller': dataBloc.userData!.billerId,
      'mv_movement_type': movementType,
      'mv_document_type_id': documentType,
      'mv_amount': value,
      'mv_origin_paid_by': paymentOrigin!.idCloud,
      'mv_destination_paid_by': paymentDestiny!.idCloud,
      'mv_note': movementNote,
      'created_by': dataBloc.userData!.id
      // 'destination_mv_biller':mvBiller,
      // 'mv_user':mvUser,
    };
  }

  Map<String, dynamic> _closeToJson() {
    return {'total_cash_submitted': value};
  }

  bool isNumeric(String s) {
    // ignore: unnecessary_null_comparison
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  Future<void> closeRegister(BuildContext context) async {
    final choice = await choiceAlert(
        context, '¿Esta seguro de cerrar caja?', 'assets/images/alert.png');
    if (choice) {
      final apiProvider = new DataProvider();
      final headers = {
        'content-Type': 'application/json',
        'Authorization': dataBloc.getToken()
      };
      // ignore: unnecessary_null_comparison
      if (value == '' || value == null) {
        value = '0';
      }
      final body = _closeToJson();
      final res = await apiProvider.postPetition(regCloseEndP, body, headers);
      if (res['status'] == -1) {
        await reloadDialog(
            context, res['body']['message'], 'assets/images/dizzy-robot.png');
      } else if (res['error']) {
        confirmDialog(
            context, res['body']['message'], 'assets/images/dizzy-robot.png');
      } else {
        Navigator.pop(context);
        confirmDialog(
            context, res['body']['message'], 'assets/images/success.png');
        //set current register status = close
        dataBloc.registerData.status = 'close';
        // to update view
      }
    }
  }
}
