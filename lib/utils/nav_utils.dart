import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/customer_bloc.dart';

void goHomeAndEmptyCustomerBloc(BuildContext context) {
  customerBloc.clear();
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/',
    (route) => false,
  );
}

void gobackTwoTimes(BuildContext context) {
  Navigator.pop(context);
  Navigator.pop(context);
}
