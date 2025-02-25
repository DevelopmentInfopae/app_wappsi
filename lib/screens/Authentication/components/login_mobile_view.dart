import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/providers/login_form_provider.dart';
import 'package:pos_wappsi/screens/Authentication/components/login_form.dart';
import 'package:pos_wappsi/screens/Authentication/components/login_logo.dart';
import 'package:pos_wappsi/utils/responsive.dart';
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
    final responsive = ResponsiveDesign(context);
    return SingleChildScrollView(
      child: Card(
        color: Colors.white,
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(),
            Logo(
              width: _size.width,
              height: responsive.maxHeightValue(150),
              fit: BoxFit.fitHeight,
              image: 'assets/logos/logo_wappsi.png',
            ),
            MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => LoginFormProvider(),
                ),
              ],
              child: const LoginFormInputs(),
            ),
            Column(
              children: const [
                Logo(
                  width: 250,
                  fit: BoxFit.fitWidth,
                  image: 'assets/images/logo_wappsi_pos_movil.png',
                ),
                CurrentVersion(),
              ],
            ),
          ],
        ).withSize(
          height: _size.height,
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
