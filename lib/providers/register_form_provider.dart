// import 'package:dropdown_search/dropdown_search.dart';
// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:pos_wappsi/models/documents_types_model.dart';
import 'package:pos_wappsi/models/payment_methods_model.dart';
import 'package:pos_wappsi/providers/api_provider.dart';
import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/screens/cash_accounting/print_register_close.dart';
import 'package:pos_wappsi/utils/alerts.dart';

class RegisterFormProvider extends ChangeNotifier {
  String value = '';

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
    DataProvider api = DataProvider();

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
    DataProvider api = DataProvider();

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

  closeRegister(BuildContext context) async {
    //close popup
    // Navigator.of(context).pop();
    // final choice = await choiceAlert(
    //     context, '¿Esta seguro de cerrar caja?', 'assets/images/alert.png');
    // if (choice) {
    // loading(context);
    // Navigator.pop(context);
    final apiProvider = DataProvider();
    final headers = {
      'content-Type': 'application/json',
      'Authorization': dataBloc.getToken()
    };
    // ignore: unnecessary_null_comparison
    if (value == '' || value == null) {
      value = '0';
    }
    final body = _closeToJson();
    // loading(context);
    final res = await apiProvider.postPetition(regCloseEndP, body, headers);
    if (res['status'] == -1) {
      await reloadDialog(
          context, res['body']['message'], 'assets/images/dizzy-robot.png');
    } else if (res['error']) {
      scaffoldAlert(
          context, res['body']['message'], const Duration(seconds: 1), backGroundColor: errorColor);
    } else {
      final Map<String, String> registerCloseData = {
        'user_name': ((dataBloc.userData?.firstName ?? '') +
                ' ' +
                (dataBloc.userData?.lastName ?? ''))
            .toString(),
        'date': (res['body']['date'] ?? '').toString(),
        'biller_name': (dataBloc.userData?.billerName ?? '').toString(),
        'value': (body['total_cash_submitted'] ?? '')..toString()
      };
      Navigator.pop(context);
      // Navigator.pop(context);

      // to update view
      PrintRegisterClose(
        closeRegisterInfo: registerCloseData,
      ).launch(context);
      // return registerCloseData;
      // confirmDialog(
      //     context, res['body']['message'], 'assets/images/success.png');
      scaffoldAlert(
          context, res['body']['message'], const Duration(seconds: 1));
      // hideCurrentScaffoldAlert(context);
      //set current register status = close
      dataBloc.registerData?.status = 'close';
    }
    // }
  }
}
