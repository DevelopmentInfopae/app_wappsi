import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';
// import 'package:restart_app/restart_app.dart';

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
  try {
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
  } catch (e) {
    printConsole(e);
  }
}

void hideCurrentScaffoldAlert(BuildContext context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
}

///Shows a popUp alert dialog to display information
confirmDialog(BuildContext context, String msg, String img) async {
  final size = MediaQuery.of(context).size;
  await showCupertinoDialog(
      barrierDismissible: true,
      useRootNavigator: false,
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

///Shows a popUp alert dialog to take or select image
Future<XFile?> imagePickerDialog(BuildContext context) async {
  XFile? image;
  final _picker = ImagePicker();
  return await showCupertinoDialog<XFile?>(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Selecciona la forma en la que deseas cargar la imagen',
            ),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Tooltip(
                message: 'Tomar foto',
                child: AppButton(
                  padding: kButtonPadding,
                  width: 30,
                  child: const Icon(
                    Icons.add_a_photo_outlined,
                    size: kIconSize + 25,
                    color: pColor,
                  ),
                  onTap: () async {
                    image = await _picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: dataBloc.settings?['iwidth'] != null
                          ? (dataBloc.settings!['iwidth'] + 0.0)
                          : null,
                      maxHeight: dataBloc.settings?['iheight'] != null
                          ? (dataBloc.settings!['iheight'] + 0.0)
                          : null,
                    );
                  },
                ),
              ),
              Tooltip(
                message: 'Elegir de galería',
                child: AppButton(
                  width: 30,
                  padding: kButtonPadding,
                  child: const Icon(
                    Icons.image_search_rounded,
                    size: kIconSize + 25,
                    color: pColor,
                  ),
                  onTap: () async {
                    image = await _picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: dataBloc.settings?['iwidth'] != null
                          ? (dataBloc.settings!['iwidth'] * 1.0)
                          : null,
                      maxHeight: dataBloc.settings?['iheight'] != null
                          ? (dataBloc.settings!['iheight'] * 1.0)
                          : null,
                    );
                  },
                ),
              )
            ],
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
                  Navigator.of(context).pop(image);
                },
              ),
            ),
          ],
        );
      });
  // return image;
}

reloadDialog(BuildContext context, String msg, String img) async {
  final size = MediaQuery.of(context).size;
  showCupertinoDialog(
      context: context,
      useRootNavigator: true,
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
                  dataBloc.reload();
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  // Restart.restartApp(webOrigin: '/loginForm');
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
    bool useRootNav = false,
    customWidget = false,
    Widget? widget}) async {
  final size = MediaQuery.of(context).size;

  final result = await showCupertinoDialog(
      barrierDismissible: skipeable,
      context: context,
      useRootNavigator: useRootNav,
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
                        double.parse(e[column2Key].toString()),
                        decimals: 0)
                    : e[column2Key].toString();
                return labelContentH(e[column1Key].toString(), value, context,
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
