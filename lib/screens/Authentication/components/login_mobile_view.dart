import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/providers/login_form_provider.dart';
import 'package:pos_wappsi/screens/Authentication/components/login_form.dart';
import 'package:pos_wappsi/screens/Authentication/components/login_logo.dart';
import 'package:provider/provider.dart';

class LoginMobileView extends StatelessWidget {
  const LoginMobileView({
    Key? key,
    required Size size,
  })  : _size = size,
        super(key: key);

  final Size _size;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        color: Colors.white,
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Logo(
              width: _size.width,
              height: _size.height * 0.2,
              fit: BoxFit.fitHeight,
              image: 'assets/logos/logo_wappsi.png',
            ).paddingOnly(top: _size.height * 0.16),
            MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => LoginFormProvider(),
                )
              ],
              child: const LoginFormInputs(),
            ).withHeight(_size.height * 0.4),
            Logo(
              width: 250,
              height: _size.height * 0.07,
              fit: BoxFit.fitWidth,
              image: 'assets/images/logo wappsi pos móvil.png',
            )
          ],
        ).withSize(
            height: _size.height * 0.99,
            width: _size.width > 500 ? 500 : _size.width),
      ),
    );
  }
}
