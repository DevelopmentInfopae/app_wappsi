import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pos_wappsi/constant.dart';
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Logo(
              width: _size.width,
              height: _size.height * 0.19,
              fit: BoxFit.fitHeight,
              image: 'assets/logos/logo_wappsi.png',
            ).paddingOnly(top: _size.height * 0.15),
            MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => LoginFormProvider(),
                )
              ],
              child: const LoginFormInputs(),
            ).withHeight(_size.height * 0.38),
            Column(
              children: [
                Logo(
                  width: 250,
                  height: _size.height * 0.065,
                  fit: BoxFit.fitWidth,
                  image: 'assets/images/logo_wappsi_pos_movil.png',
                ),
                const CurrentVersion(),
              ],
            )
          ],
        ).withSize(
          height: _size.height * 0.98,
          width: _size.width > 500 ? 500 : _size.width,
        ),
      ),
    );
  }
}

class CurrentVersion extends StatelessWidget {
  const CurrentVersion({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, AsyncSnapshot<PackageInfo> snapshot) {
        String appName = '';
        // String packageName = '';
        String version = '';
        // String buildNumber = '';
        if (snapshot.hasData) {
          // packageName = packageInfo.packageName;
          appName = snapshot.data!.appName;
          version = snapshot.data!.version;
          // buildNumber = snapshot.data!.buildNumber;
        }
        return Text(
          '$appName v $version',
          style: normalTextStyle(
            context,
            fontSizeFactor: 0.8,
          ),
        );
      },
    );
  }
}
