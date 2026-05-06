import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/models/payment_methods_model.dart';
import 'package:pos_wappsi/models/payment_model.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

import 'local_db_provider.dart';

class PaymentProvider {
  static Future<bool> saveAllIntoDB(
    int saleId, {
    String type = 'received',
  }) async {
    final payments = _buildPaymentList(saleId);
    try {
      await Future.forEach(payments, (
        PaymentsModel element,
      ) async {
        await element.savePayments();
      });
    } catch (e) {
      printConsole(e);
    }
    // Payment(
    //     saleId: saleId,
    //     paidBy: paidBy,
    //     amount: amount,
    //     createdBy: createdBy,
    //     type: type,
    //     meanPaymentCodeFe: meanPaymentCodeFe);
    return true;
  }

  static List<PaymentsModel> _buildPaymentList(
    int saleId, {
    String type = 'received',
  }) {
    List<PaymentsModel> payments = [];
    // only 1 payMethod are allowed per sale
    List<double> totalValues = [posBloc.getSubTotal()];
    List<double> paymentValues = [(posBloc.getPaymentValue ?? 0).toDouble()];
    List<double> balanceValues = [
      _getPosBalance(
        (posBloc.getPaymentValue ?? 0).toDouble(),
        posBloc.getSubTotal(),
      ),
    ];
    List<PaymentMethods> paymentMethods = [posBloc.getPaymentMethod!];
    for (int i = 0; i < paymentValues.length; i++) {
      final temp = {
        'sale_id': saleId,
        'paid_by': paymentMethods[i].code,
        'amount': totalValues[i],
        'created_by': int.tryParse(dataBloc.userData!.id) ?? 0,
        'type': type,
        'mean_payment_code_fe': '',
        'seller_id': dataBloc.userData!.billerId,
        'pos_paid': paymentValues[i],
        'pos_balance': balanceValues[i],
        'document_type_id': posBloc.getPaymentDocument?.idCloud.toString()
      };
      payments.add(PaymentsModel.fromJson(temp));
    }

    return payments;
  }

  static double _getPosBalance(double paid, double total) {
    double balance = paid - total;
    if (balance < 0) {
      balance = 0;
    }
    return balance;
  }

  static List<PaymentsModel> fromMapList(List<Map<String, dynamic>> list) {
    List<PaymentsModel> payments = [];
    for (var item in list) {
      payments.add(PaymentsModel.fromJson(item));
    }

    return payments;

    // prString(temp);
  }

  static Future<PaymentsModel?> loadPayment(int saleId) async {
    final res = await DBProvider.db
        .sqlFirstQuery('sma_payments', where: 'sale_id=$saleId');
    if (res != null) {
      return PaymentsModel.fromJson(res);
    } else {
      return null;
    }
  }

  static Future<List<PaymentsModel>> loadPayments(int saleId) async {
    final res =
        await DBProvider.db.sqlQuery('sma_payments', where: 'sale_id=$saleId');
    if (res != null) {
      return PaymentsModel.fromJsonList(res);
    } else {
      return [];
    }
  }
}
