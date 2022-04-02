import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/screens/home/components/tab_item.dart';
import 'package:pos_wappsi/screens/settings/errors_report.dart';
import 'package:pos_wappsi/screens/settings/print_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, 'Ajustes', image: 'assets/images/settings.png',
          onPop: () {
        dataBloc.homeKey?.currentState?.selectTab(TabItem.home);
      }),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      child: SettingSection(
        title: Text('Ajustes generales', style: boldTextStyle(size: 24)),
        subTitle: Text('Controla algunos parametros de la aplicación',
            style: primaryTextStyle()), // Optional
        items: _settings(context),
      ),
    );
  }

  List<Widget> _settings(BuildContext context) {
    return [
      SettingItemWidget(
          title: 'Ajustes de impresión',
          subTitle: 'Conectate y configura tus dispositivos de impresión',
          decoration: BoxDecoration(borderRadius: radius()),
          trailing: Icon(Icons.keyboard_arrow_right_rounded,
              color: context.dividerColor),
          onTap: () {
            const PrintSettings().launch(context);
          }),
      SettingItemWidget(
          title: 'Reportar errores',
          subTitle: 'Reporta los errores que has tenido hasta la fecha',
          decoration: BoxDecoration(borderRadius: radius()),
          trailing: Icon(Icons.keyboard_arrow_right_rounded,
              color: context.dividerColor),
          onTap: () {
            const ReportErrorScreen().launch(context);

          }),
      // SettingItemWidget(
      //   title: 'Close account',
      //   subTitle:
      //       'Learn about your options, and close your account if you wish',
      //   decoration: BoxDecoration(borderRadius: radius()),
      //   trailing: Icon(Icons.keyboard_arrow_right_rounded,
      //       color: context.dividerColor),
      //   onTap: () {
      //     //
      //   },
      // )
    ];
  }
}
