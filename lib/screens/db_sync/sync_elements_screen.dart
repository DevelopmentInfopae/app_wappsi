import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
// import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/config/bd_sync.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/screens/components/back_app_bar.dart';
import 'package:pos_wappsi/screens/components/widgets.dart';
import 'package:pos_wappsi/screens/db_sync/db_sync_elements.dart';
import 'package:pos_wappsi/utils/alerts.dart';

class SyncElementsScreen extends StatefulWidget {
  const SyncElementsScreen({Key? key}) : super(key: key);

  @override
  _SyncElementsScreenState createState() => _SyncElementsScreenState();
}

class _SyncElementsScreenState extends State<SyncElementsScreen> {
  // late List<Map> elements;

  // bool _syncing = false;

  late List<String> keys;
  late Map<String, bool> values;

  late Size _size;
  late Color _pc;

  @override
  void initState() {
    // elements = syncDB.options.values.toList();
    keys = enabledOptions.keys.toList();
    values = Map.fromIterable(
      keys,
      value: (value) {
        return false;
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _pc = pColor;
    return WillPopScope(
      onWillPop: () async {
        dataBloc.homeKey?.currentState?.changeBottomIndex(1);
        return true;
      },
      child: Scaffold(
        appBar: _appBar(context),
        body: _body(),
      ),
    );
  }

  PreferredSize _appBar(BuildContext context) => appBar(
        context,
        'Sincronización',
        image: 'assets/images/synchronization.png',
        onPop: () {
          dataBloc.homeKey?.currentState?.changeBottomIndex(1);
          Navigator.pop(context);
        },
      );

  Widget _body() {
    return Column(
      children: [
        _elements().expand(),
        _bottom(),
      ],
    );
  }

  Widget _elements() {
    //     });
    return SingleChildScrollView(
      child: Wrap(
        children: keys.map((key) {
          return _elementWidget(key)
              .paddingSymmetric(horizontal: 5, vertical: 5);
        }).toList(),
      ),
    );
  }

  Widget _elementWidget(String key) {
    final size = gridItemSize(context);
    return AppButton(
      onTap: () {
        setState(() {
          values[key] = !values[key]!;
        });
      },
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: BorderSide(color: values[key]! ? _pc : Colors.white, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child:
          _elementParts(key).withSize(width: size.width, height: size.height),
    );
  }

  Column _elementParts(String key) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Image.asset(
            'assets/images/' + enabledOptions[key]!['image'],
            fit: BoxFit.fitWidth,
          ),
        ).paddingTop(4).flexible(flex: 6),
        Text(
          key,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: Theme.of(context).textTheme.subtitle1,
        ).center().paddingBottom(4).flexible(flex: 4)
      ],
    );
  }

  Widget _bottom() => bottom(_options(), _pc, _size);

  Widget _options() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [_selectAll(), _sync()],
    );
  }

  Widget _selectAll() {
    return AppButton(
      // width: 70,
      // height: 50,
      padding: kButtonPadding,
      child: Row(
        children: [
          const Icon(Icons.select_all, size: kIconSize, color: pColor),
          Text(
            ' Seleccionar todo',
            maxLines: 2,
            style: buttonsSmallTextStyle(context, color: pColor),
          ),
        ],
      ),
      onTap: () {
        setState(() {
          if (values.values.where((element) => element == false).isEmpty) {
            values.forEach((key, value) {
              values[key] = false;
            });
          } else {
            values.forEach((key, value) {
              values[key] = true;
            });
          }
        });
      },
    );
  }

  Widget _sync() {
    return AppButton(
      padding: kButtonPadding,
      // width: 70,
      child: Row(
        children: [
          const Icon(Icons.sync, size: kIconSize, color: pColor),
          Text(
            ' Sincronizar',
            maxLines: 2,
            style: buttonsSmallTextStyle(context, color: pColor),
          ),
        ],
      ),
      onTap: () {
        final Map<String, bool> syncOptions = {};
        syncOptions.addAll(values);
        syncOptions.removeWhere((key, value) => value == false);
        if (syncOptions.keys.isNotEmpty) {
          // dataBloc.setSyncStatus(syncOptions);
          DBSyncElements(
            options: syncOptions,
          ).launch(context);
        } else {
          confirmDialog(
            context,
            'Sin elementos a sincronizar',
            'assets/images/dizzy-robot.png',
          );
        }
      },
    );
  }
}
