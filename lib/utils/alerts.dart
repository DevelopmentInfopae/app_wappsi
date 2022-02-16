import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';
import 'package:restart_app/restart_app.dart';

void simpleAlert(BuildContext context, String msj) {
  showConfirmDialogCustom(
    context,
    title: msj,
    negativeText: 'Cancelar',
    positiveText: 'Aceptar',
    onAccept: (_) {},
  );
}

void scaffoldAlert(BuildContext context, String message, Duration duration,
    {Color backGroundColor = Colors.green,
    Color textColor = Colors.white,
    Key? key}) {
  final _size = MediaQuery.of(context).size;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    key: key,
    duration: duration,
    padding: EdgeInsets.zero,
    content: bottom(
      Text(
        message,
        style: Theme.of(context)
            .textTheme
            .headline6!
            .apply(fontSizeFactor: 0.8, color: textColor),
      ).paddingSymmetric(horizontal: 8),
      backGroundColor,
      _size,
      alignment: Alignment.center,
    ),
    backgroundColor: backGroundColor,
  ));
}

void hideCurrentScaffoldAlert(BuildContext context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
}

///Shows a popUp alert dialog to display information
confirmDialog(BuildContext context, String msg, String img) async {
  final size = MediaQuery.of(context).size;
  await showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              img,
              height: size.height * 0.15,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              msg,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          actions: <Widget>[
            Container(
              color: pColor.withOpacity(0.7),
              child: CupertinoDialogAction(
                child: const Text(
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
        );
      });
}

reloadDialog(BuildContext context, String msg, String img) async {
  final size = MediaQuery.of(context).size;
  showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              img,
              height: size.height * 0.15,
            ),
          ),
          content: Text(
            msg,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          actions: <Widget>[
            Container(
              color: pColor.withOpacity(0.7),
              child: CupertinoDialogAction(
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                onPressed: () async {
                  if ((posBloc.getProducts?.length ?? 0) > 0) {
                    await posBloc.suspendSale();
                  }
                  Restart.restartApp(webOrigin: '/loginForm');
                },
              ),
            ),
          ],
        );
      });
}

/// Choice alert who returns a bool based on user selection, it can also show a custom widget if required
choiceAlert(BuildContext context, String msj, String img,
    {String cancel = 'Cancelar',
    String confirm = 'Aceptar',
    bool skipeable = true,
    customWidget = false,
    Widget? widget}) async {
  final size = MediaQuery.of(context).size;

  final result = await showCupertinoDialog(
      barrierDismissible: skipeable,
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              img,
              height: size.height * 0.15,
            ),
          ),
          content: customWidget
              ? Column(
                  children: [
                    Text(
                      msj,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    widget ?? Container()
                  ],
                )
              : Text(
                  msj,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
          actions: <Widget>[
            Container(
              color: Colors.redAccent,
              child: CupertinoDialogAction(
                child: Text(
                  cancel,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ),
            Container(
              color: pColor.withOpacity(0.8),
              child: CupertinoDialogAction(
                child: Text(
                  confirm,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ),
          ],
        );
      });
  return result;
}

loadCart(BuildContext context, String msj, String img) {
  final size = MediaQuery.of(context).size;

  showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              img,
              height: size.height * 0.15,
            ),
          ),
          content: Text(
            msj,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          actions: <Widget>[
            Container(
              color: Colors.redAccent,
              child: CupertinoDialogAction(
                child: const Text(
                  'No cargar',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  posBloc.emptyProductsAdded();
                  Navigator.of(context).pop();
                },
              ),
            ),
            Container(
              color: pColor.withOpacity(0.8),
              child: CupertinoDialogAction(
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      });
}

choiceAlertAndroid(
  BuildContext context,
  String msj,
) async {
  // final size = MediaQuery.of(context).size;

  bool result = false;

  await showConfirmDialogCustom(context,
      title: msj,
      negativeText: 'Cancelar',
      positiveText: 'Aceptar', onAccept: (_) {
    result = true;
  }, onCancel: (_) {});

  return result;
}

void loading(BuildContext context,
    {String img = 'assets/images/loading.gif', String? message}) {
  final size = MediaQuery.of(context).size;
  showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
            content: message == null
                ? Container()
                : Text(
                    message,
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .apply(fontSizeFactor: 0.8),
                  ),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                img,
                height: size.height * 0.15,
              ),
            ));
      });
}

listInfoDialog(BuildContext context, List<Map> info, String column1Key,
    String column2Key, String column1, String column2,
    {bool isPrice = false,
    int flexCol1 = 2,
    int flexCol2 = 1,
    String? title}) async {
  // final size = MediaQuery.of(context).size;
  showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Column(
            children: [
              Text(
                title ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .apply(fontWeightDelta: 2),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(column1).flexible(flex: 1),
                  // Container(),
                  Text(column2).flexible(flex: 1),
                ],
              ).paddingOnly(left: 10, right: 10, bottom: 5),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: info.map<Widget>((e) {
                final value = isPrice
                    ? getFormatedCurrency(
                        double.parse(e[column2Key].toString()))
                    : e[column2Key].toString();
                return labelContentH(e[column1Key].toString(),
                    isPrice ? value.substring(1, value.length) : value, context,
                    flexCol1: flexCol1, flexCol2: flexCol2);
              }).toList(),
            ),
          ),
          actions: <Widget>[
            Container(
              color: pColor.withOpacity(0.7),
              child: CupertinoDialogAction(
                child: const Text(
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
        );
      });
}

Future<bool> listInfoDialogChoice(BuildContext context, List<Map> info,
    String column1Key, String column2Key, String column1, String column2,
    {bool isPrice = false,
    int flexCol1 = 2,
    int flexCol2 = 1,
    String? title}) async {
  // final size = MediaQuery.of(context).size;
  bool choice = false;
  await showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Column(
            children: [
              Text(
                title ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .apply(fontWeightDelta: 2),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(column1).flexible(flex: 1),
                  // Container(),
                  Text(column2).flexible(flex: 1),
                ],
              ).paddingOnly(left: 10, right: 10, bottom: 5),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: info.map<Widget>((e) {
                final value = isPrice
                    ? getFormatedCurrency(
                        double.parse(e[column2Key].toString()))
                    : e[column2Key].toString();
                return labelContentH(
                    capitalizeText(e[column1Key].toString()),
                    isPrice
                        ? value.substring(1, value.length)
                        : capitalizeText(value),
                    context,
                    flexCol1: flexCol1,
                    flexCol2: flexCol2);
              }).toList(),
            ),
          ),
          actions: <Widget>[
            Container(
              color: Colors.redAccent,
              child: CupertinoDialogAction(
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ),
            Container(
              color: pColor.withOpacity(0.7),
              child: CupertinoDialogAction(
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  choice = true;
                  Navigator.of(context).pop(true);
                },
              ),
            ),
          ],
        );
      });

  return choice;
}
