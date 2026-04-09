
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_wappsi/providers/login_form_provider.dart';

class RememberChecks extends StatelessWidget {
  const RememberChecks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginFormProvider>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 250, // 👈 Mismo ancho que los inputs
          child: CheckboxListTile(
            value: provider.recordarUsuario,
            onChanged: provider.toggleRecordarUsuario,
            title: const Text('Recordar usuario'),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        SizedBox(
          width: 250, // 👈 Mismo ancho que los inputs
          child: CheckboxListTile(
            value: provider.recordarPassword,
            onChanged: provider.toggleRecordarPassword,
            title: const Text('Recordar contraseña'),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}