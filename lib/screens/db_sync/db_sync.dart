import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
// import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/config/bd_sync.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/sync_db_provider.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/screens/db_sync/components/sync_element.dart';
import 'package:pos_wappsi/screens/db_sync/components/widgets.dart';
import 'package:pos_wappsi/screens/home/home.dart';
import 'package:pos_wappsi/utils/alerts.dart';
// import 'package:google_fonts/google_fonts.dart';

class DBSync extends StatefulWidget {
  const DBSync({Key? key, this.syncElements}) : super(key: key);
  final List<String>? syncElements;
  @override
  State<DBSync> createState() => _DBSyncState();
}

class _DBSyncState extends State<DBSync> {
  late List _options;
  SyncDBProvider syncDB = SyncDBProvider();
  final Map<String, bool> _status = {};

  bool suceesAlertShown = false;

  // late Size _size;

  @override
  void initState() {
    _options = widget.syncElements ?? enabledOptions.keys.toList();
    _status.addAll(Map.fromIterable(_options, value: (value) {
      return false;
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // _size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: appBar(context, 'Sincronización',
            back: false, image: 'assets/images/sync.gif'),
        body: _body(context));
  }

  _body(BuildContext context) {
    return Column(
      children: [_elementsLoading().expand()],
    );
  }

  FutureBuilder _syncCSC() {
    return FutureBuilder(
      future: syncDB.loadCSC(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == true) {
            return elementSync('Paises, departamentos y ciudades',
                completed: true);
          }
          confirmDialog(
              context,
              'Error al escribir paises, departamentos o ciudades en la base de datos local',
              'assets/images/dizzy-robot.png');
          return elementSync('Paises, departamentos y ciudades');
        } else {
          return elementSync('Paises, departamentos y ciudades');
        }
      },
    );
  }

  Widget _elementsLoading() {
    // bool error = false;
    // to create db if not exists
    return FutureBuilder(
      future: DBProvider.db.database,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            child: Column(children: _syncElements(context)),
          );
        } else {
          return Center(
            child: elementSync('Base de datos no encontrada, creandola'),
          );
        }
      },
    );
  }

  List<FutureBuilder<dynamic>> _syncElements(BuildContext context) {
    final elements = _options.map((option) {
      return FutureBuilder(
          future: syncDB.syncOption(context, option),
          // future: null,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              // setState(() {
              _status[option] = true;
              // });
              _navigate();
              return Column(
                children: [
                  elementSync(option, completed: true),
                  const Divider(
                    color: Colors.black38,
                    height: 2,
                  ),
                ],
              );
            } else {
              // _navigate();
              return Column(
                children: [
                  ElementSync(
                    context: context,
                    optionInfo: enabledOptions[option]!,
                    optionName: option,
                    status: false,
                  ),
                  const Divider(
                    color: Colors.black38,
                    height: 2,
                  ),
                ],
              );
            }
          });
    }).toList();
    elements.add(_syncCSC());
    return elements;
  }

  Widget elementSync(String option, {bool completed = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/images/' +
                (enabledOptions[option]?['image'] ?? 'countries.png'))
            .paddingSymmetric(horizontal: 10, vertical: 3)
            .withHeight(50),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            descText(option, context, fontSizeFactor: 1, maxLines: 2)
                .flexible(flex: 5),
            syncStatus(completed).flexible(),
          ],
        ).flexible(flex: 5)
      ],
    ).paddingSymmetric(horizontal: 7, vertical: 4);
  }

  _navigate() {
    // final _pc = pColor;
    if (_status.values.where((element) => element == false).isEmpty) {
      // return ;
      // confirmDialog(context, 'Base de datos sincronizada con exito',
      //     'assets/images/success.png');
      if (!suceesAlertShown) {
        final homeKey = GlobalKey<HomeState>();
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          confirmDialog(context, 'Base de datos sincronizada con exito',
              'assets/images/success.png');
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) {
              dataBloc.setHomeKey(homeKey);
              return Home(
                key: homeKey,
              );
            }),
            (route) => false,
          );
        });
        suceesAlertShown = true;
      }

      // return

    } else {
      return Container();
    }
  }
}
