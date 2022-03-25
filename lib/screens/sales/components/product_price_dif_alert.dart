import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/utils/alerts.dart';

// import 'package:pos_wappsi/utils/alerts.dart';

priceDiffAlert(
    BuildContext context, List<Map<String, dynamic>> difs, String saleId) {
  return showCupertinoDialog(
      barrierDismissible: true,
      useRootNavigator: false,
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            'Reanudar venta',
            style: buttonsSmallTextStyle(context).apply(fontSizeDelta: 1.2),
          ).paddingBottom(8),
          content: Column(
            children: [
              Text(
                'Se han detectado cambios en los precios de los productos.',
                style:
                    buttonsSmallTextStyle(context).apply(color: kGreyTextColor),
                textAlign: TextAlign.justify,
              ),
              TextButton(
                  onPressed: () {
                    // listInfoDialog(context, difs, column1Key, column2Key, column1, column2)
                  },
                  child: Text(
                    'Ver cambios',
                    style: buttonsTextStyle(context, color: pColor),
                  )),
              Text(
                '¿Desea conservar los precios?',
                style:
                    buttonsSmallTextStyle(context).apply(color: kGreyTextColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            Container(
              color: Colors.redAccent,
              child: CupertinoDialogAction(
                child: const Text(
                  'No',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ),
            Container(
              color: pColor.withOpacity(0.8),
              child: CupertinoDialogAction(
                child: const Text(
                  "Si",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                onPressed: () async {
                  // await posBloc.suspendSale(keyWord: _keyWord);
                  //   await posBloc.suspendSale();
                  // THis shouldn't be like this, but it works :)
                  final errors = await posBloc.loadSuspSaleWPrices(saleId);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  if (errors.isNotEmpty) {
                    listInfoDialog(context, errors, 'name', 'inventory',
                        'Producto', 'Stock',
                        flexCol1: 3,
                        flexCol2: 1,
                        title:
                            'Error al cargar los siguientes productos de la venta:');
                  } else {
                    confirmDialog(
                        context,
                        'Venta suspendida cargada correctamente',
                        'assets/images/success.png');
                  }
                },
              ),
            ),
          ],
        );
      });
}
