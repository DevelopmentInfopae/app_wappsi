import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
// ignore: implementation_imports
// import 'package:nb_utils/src/extensions/widget_extensions.dart';
// import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/config/bd_sync.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/providers/sync_db_provider.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/screens/db_sync/components/widgets.dart';
import 'package:pos_wappsi/screens/home/components/tab_item.dart';

class DBSyncElements extends StatefulWidget {
  DBSyncElements({Key? key, required this.options}) : super(key: key);
  final Map<String, bool> options;

  @override
  _DBSyncElementsState createState() => _DBSyncElementsState();
}

class _DBSyncElementsState extends State<DBSyncElements> {
  late Size _size;
  late Color _pc;

  final syncDB = new SyncDBProvider();
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _pc = Theme.of(context).primaryColor;

    return WillPopScope(
      onWillPop: () async {
        await dataBloc.refreshToken(context);
        return true;
      },
      child: Scaffold(
        appBar: appBar(context, 'Sincronización',
            image: 'assets/images/sync.gif', onPop: () async {
          Navigator.pop(context);
          await dataBloc.refreshToken(context);
        }),
        body: _body(),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [_elementsLoading().expand(), _bottom()],
    );
  }

  Widget _elementsLoading() {
    return SingleChildScrollView(
      child: Column(
          children: widget.options.keys.map((option) {
        return FutureBuilder(
            future: syncDB.syncOption(context, option),
            // future: null,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                widget.options[option] = false;
                // dataBloc.setSyncStatus(widget.options);

                return elementSync(option, completed: true);
              } else {
                return elementSync(option);
              }
            });
      }).toList()),
    );
  }

  Widget elementSync(String option, {bool completed = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/images/' +
                (options[option]?['image'] ?? 'countries.png'))
            .paddingSymmetric(horizontal: 10, vertical: 3)
            .withHeight(
              _size.height * 0.07 > 60 ? _size.height * 0.07 : 60,
            ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            descText(option, context, fontSizeFactor: 0.9, maxLines: 2)
                .withWidth(_size.width * 0.55),
            syncStatus(completed),
          ],
        )
      ],
    ).paddingSymmetric(horizontal: 13, vertical: 7);
  }

  Widget _bottom() {
    return bottom(
        AppButton(
          padding: kButtonPadding,
          child: Text(
            'Menu principal ',
            style: buttonsTextStyle(context),
          ),
          color: pColor,
          onTap: () async {
            await dataBloc.refreshToken(context);

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            );
            dataBloc.homeKey.currentState?.selectTab(TabItem.home);
          },
        ),
        _pc,
        _size);
  }
}
