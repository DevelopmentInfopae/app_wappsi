import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/constant.dart';
// import 'package:pos_wappsi/utils/alerts.dart';

priceDiffAlert(
    BuildContext context, List<Map<String, dynamic>> difs, String saleId) {
  return showCupertinoDialog(
      barrierDismissible: true,
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
                child: Text(
                  'No',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                onPressed: () async {
                  await posBloc.loadSuspendedSale(saleId);
                },
              ),
            ),
            Container(
              color: pColor.withOpacity(0.8),
              child: CupertinoDialogAction(
                child: Text(
                  "Si",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                onPressed: () async {
                  // await posBloc.suspendSale(keyWord: _keyWord);
                  //   await posBloc.suspendSale();
                  // THis shouldn't be like this, but it works :)
                  await posBloc.loadSuspSaleWPrices(saleId);
                  Navigator.of(context).pop(false);
                },
              ),
            ),
          ],
        );
      });
}
