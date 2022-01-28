import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/config/bd_sync.dart';
import 'package:pos_wappsi/constant.dart';

import 'package:pos_wappsi/providers/sync_db_provider.dart';

/// Custom alert dialog to manage open and close operations on Register, to open action = 'open'
/// to close action = 'close'
///
class SyncAlertDialog extends StatefulWidget {
  final Map<String, bool> options;
  const SyncAlertDialog({Key? key, required this.options}) : super(key: key);

  @override
  SyncAlertDialogState createState() {
    return new SyncAlertDialogState();
  }
}

class SyncAlertDialogState extends State<SyncAlertDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  late Size _size;
  // late Color _pc;
  // late TextTheme _textTheme;

  final syncDB = new SyncDBProvider();

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    // _pc = pColor;
    // _textTheme = Theme.of(context).textTheme;
    return Container(
      child: CupertinoAlertDialog(
        title: Text('Sincronizando Base de Datos'),
        content: _elementsLoading(),
        actions: [
          Container(
            color: pColor.withOpacity(0.7),
            child: CupertinoDialogAction(
              child: Text(
                'Aceptar',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _elementsLoading() {
    return ListView(
        children: widget.options.keys.map((option) {
      return FutureBuilder(
          future: syncDB.syncOption(context, option),
          // future: null,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return elementSync(option, completed: true);
            } else {
              return elementSync(option);
            }
          });
    }).toList());
  }

  Widget elementSync(String option, {bool completed = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/images/' +
                (options[option]?['image'] ?? 'synchronization.png'))
            .paddingSymmetric(horizontal: 10, vertical: 3)
            .withHeight(
              _size.height * 0.07 > 60 ? _size.height * 0.07 : 60,
            ),
      ],
    ).paddingSymmetric(horizontal: 13, vertical: 7);
  }
}
