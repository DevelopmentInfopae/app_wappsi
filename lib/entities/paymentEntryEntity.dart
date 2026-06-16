import 'package:flutter/material.dart';
import 'package:pos_wappsi/models/payment_methods_model.dart';

class PaymentEntry {
  final TextEditingController paymentMethodController;
  final TextEditingController valuePController;
  final TextEditingController paymentTermController;
  final FocusNode focusNode = FocusNode();
  final GlobalKey<FormState> inputsKey;
  PaymentMethods? selectedPaymentMethod;
  int valueP;
  // Contadores propios de cada entry
  int count5000;
  int count10000;
  int count20000;
  int count50000;

  PaymentEntry()
      : paymentMethodController = TextEditingController(),
        valuePController = TextEditingController(),
        paymentTermController = TextEditingController(),
        inputsKey = GlobalKey<FormState>(),
        valueP = 0,
        count5000 = 0,
        count10000 = 0,
        count20000 = 0,
        count50000 = 0;

  void dispose() {
    paymentMethodController.dispose();
    valuePController.dispose();
    paymentTermController.dispose();
    focusNode.dispose();
  }

  // Resetea los contadores
  void resetCounts() {
    count5000 = 0;
    count10000 = 0;
    count20000 = 0;
    count50000 = 0;
  }
}
