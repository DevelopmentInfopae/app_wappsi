import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/models/payment_methods_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';

class PaymentMethodsProvider {
  static loadDefaultPaymentMethod() async {
    final data = await findPaymentMethods(search: 'Efectivo');

    if (data != null) {
      if (data.length > 0 && posBloc.getPaymentMethod == null) {
        posBloc.setPaymentMethod(PaymentMethods.fromJson(data.first));
        return true;
      }
    }
  }

  static Future<List<PaymentMethods>> getPaymentMethods(filter) async {
    final data = await findPaymentMethods(search: filter, pos: true);

    if (data != null) {
      return PaymentMethods.fromListJson(data);
    }

    return [];
  }

  /// Returns PaymentMethod object given an payment method id
  static Future<PaymentMethods?> loadPayDoc(String idPayM) async {
    Map<String, dynamic>? data = await loadPaymentMethod(idPayM);
    if (data != null) {
      return PaymentMethods.fromJson(data);
    } else {
      return null;
    }
  }

  /// Returns PaymentMethod object given an payment method code
  static Future<PaymentMethods?> loadPayMByCode(String code) async {
    Map<String, dynamic>? data = await loadPaymentMethodByCode(code);
    if (data != null) {
      return PaymentMethods.fromJson(data);
    } else {
      return null;
    }
  }

  //-----------------------------------------------------------------------------
  //                                PAYMENT METHODS
  //
  //-----------------------------------------------------------------------------
  /// Return all rows in sma_payment_methods wich fields (name) LIKE given string
  // ignore: avoid_init_to_null
  static Future<List<Map<String, dynamic>>?> findPaymentMethods(
      {String? search = '', pos: true}) async {
    String where = '';
    if (pos) {
      where = "name LIKE '%$search%' AND state_sale = 1 AND code!='deposit'";
    } else {
      where = "name LIKE '%$search%'";
    }
    return await DBProvider.db.sqlQuery('sma_payment_methods', where: where);
  }

  /// Return payMethod info given a pay method id
  static Future<Map<String, dynamic>?> loadPaymentMethod(String idPayM) async {
    return await DBProvider.db
        .sqlFirstQuery('sma_payment_methods', where: 'id_cloud = $idPayM');
  }

  /// Return payMethod info given a pay method id
  static Future<Map<String, dynamic>?> loadPaymentMethodByCode(
      String code) async {
    return await DBProvider.db
        .sqlFirstQuery('sma_payment_methods', where: 'code="$code"');
  }
}
