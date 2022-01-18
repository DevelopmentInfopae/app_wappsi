import 'package:flutter/material.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/providers/register_form_provider.dart';
import 'package:pos_wappsi/screens/cash_accounting/components/register_movements_form.dart';
import 'package:provider/provider.dart';

class RegisterMovements extends StatefulWidget {
  RegisterMovements({Key? key}) : super(key: key);

  @override
  _RegisterMovementsState createState() => _RegisterMovementsState();
}

class _RegisterMovementsState extends State<RegisterMovements> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  child: child,
      appBar: appBar(context, 'Movimientos',
          image: 'assets/images/cash-register.png'),
      body: ChangeNotifierProvider(
          create: (_) => RegisterFormProvider(),
          child: RegisterMovementsForm()),
    );
  }
}
