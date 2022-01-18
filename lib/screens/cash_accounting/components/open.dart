// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:pos_wappsi/components/button_global.dart';
import 'package:pos_wappsi/providers/register_form_provider.dart';
import 'package:pos_wappsi/screens/cash_accounting/components/functions.dart';
import 'package:pos_wappsi/screens/cash_accounting/components/widgets.dart';

import 'package:provider/provider.dart';

import '../../../constant.dart';

class OpenForm extends StatefulWidget {
  OpenForm({Key? key}) : super(key: key);

  @override
  _OpenFormState createState() => _OpenFormState();
}

class _OpenFormState extends State<OpenForm> {
  late FocusNode _value;

  @override
  void initState() {
    super.initState();
    _value = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _value.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registerForm = Provider.of<RegisterFormProvider>(context);
    return Center(
      child: _form(context, registerForm),
    );
  }

  Form _form(BuildContext context, RegisterFormProvider cashAccForm) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: cashAccForm.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          registerInput(context, cashAccForm,_value,style: TextStyle(fontSize: 20)),
          const SizedBox(height: 15.0),
          _button(context, cashAccForm),
        ],
      ),
    );
  }

  ButtonGlobalWithoutIcon _button(
      BuildContext context, RegisterFormProvider cashAccForm) {
    return ButtonGlobalWithoutIcon(
      buttontext: 'Abrir',
      onPressed: () {
        cashAccForm.loading
            // ignore: unnecessary_statements
            ? null
            : sendRegisterAction(context, cashAccForm,_value);
      },
      buttonDecoration:
          kButtonDecoration.copyWith(color: Theme.of(context).primaryColor),
    );
  }

  
  

  
}
