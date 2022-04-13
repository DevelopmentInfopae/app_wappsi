import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: implementation_imports
// import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/preference_category_model.dart';
import 'package:pos_wappsi/models/preference_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/units_model.dart';

import 'package:pos_wappsi/utils/text_formating/functions.dart';
// import 'package:provider/single_child_widget.dart';

/// Custom alert dialog to manage open and close operations on Register, to open action = 'open'
/// to close action = 'close'
///
class SelectProductPrefsDialog extends StatefulWidget {
  final UnitsModel? unit;
  final double? uQtty;
  final Map<PreferenceCategoryModel, List<PreferenceModel>> productPrefs;
  const SelectProductPrefsDialog(
      {Key? key,
      required this.product,
      this.prefsSelection = false,
      this.uQtty,
      required this.productPrefs,
      required this.unit})
      : super(key: key);
  final ProductModel product;
  final bool prefsSelection;
  @override
  SelectProductPrefsDialogState createState() {
    return SelectProductPrefsDialogState();
  }
}

class SelectProductPrefsDialogState extends State<SelectProductPrefsDialog> {
  UnitsModel? _selectUnition;

  Map<PreferenceCategoryModel, List<PreferenceModel>> productPrefsSelected = {};

  @override
  void initState() {
    super.initState();
    _selectUnition = widget.unit;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    double hInsetPadding = 10.0;
    double vInsetPadding = kBottomNavigationBarHeight;
    if (width > 400) {
      hInsetPadding = width * 0.1;
    }
    if (height > 800) {
      vInsetPadding = height * 0.1;
    }
    return SafeArea(
      child: AlertDialog(
        backgroundColor: alertBackground,
        // alignment: Alignment.,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(alertBorderRadius),
        ),
        // insetPadding: EdgeInsets.zero,
        // contentPadding: EdgeInsets.zero,
        // contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        insetPadding: EdgeInsets.symmetric(
            horizontal: hInsetPadding, vertical: vInsetPadding),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seleccione preferencias de producto para: ',
              textAlign: TextAlign.center,
              style: buttonsSmallTextStyle(context),
            ),
            _productName(context)
          ],
        ),

        // _ordersList(),

        content: Material(
          color: Colors.transparent,
          child: _prefsSelection(context),
        ),
        actionsPadding: EdgeInsets.zero,
        buttonPadding: EdgeInsets.zero,
        actions: <Widget>[
          Row(
            children: [
              Container(
                color: Colors.red.withOpacity(0.8),
                child: CupertinoDialogAction(
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(null);
                  },
                ),
              ).flexible(flex: 1),
              Container(
                color: pColor.withOpacity(0.8),
                child: CupertinoDialogAction(
                  child: const Text(
                    "Aceptar",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () async {
                    if (_selectUnition != null) {
                      _returnInfo(context);
                    }

                    // return widget.product;
                  },
                ),
              ).flexible(flex: 1),
            ],
          ),
        ],
      ),
    );
  }

  SingleChildScrollView _prefsSelection(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.productPrefs.keys.map((prefCat) {
          return Container(
            // margin: const EdgeInsets.symmetric(horizontal: 4),
            // padding: kButtonPadding,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
                borderRadius: BorderRadius.circular(5)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 4),
                  width: double.infinity,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    (prefCat.name ?? ''),
                    style: buttonsSmallTextStyle(context),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 4),
                  width: double.infinity,
                  // padding: kButtonVPadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.productPrefs[prefCat]!.map((e) {
                      return _preffButton(e, context, prefCat)
                          .paddingSymmetric(horizontal: 2, vertical: 3);
                    }).toList(),
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  AppButton _preffButton(PreferenceModel e, BuildContext context,
      PreferenceCategoryModel prefCat) {
    return AppButton(
      elevation: 3,
      width: double.infinity,
      child: ListTile(
        dense: true,
        title: Text(
          e.name ?? '',
          style: normalTextStyle(context),
        ),
      ),
      shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(
              color: ((productPrefsSelected[prefCat] ?? [])
                      .where((element) => element == e)
                      .isNotEmpty)
                  ? pColor.withOpacity(0.5)
                  : Colors.white,
              width: 3)),
      padding: EdgeInsets.zero,
      onTap: () {
        if (productPrefsSelected.containsKey(prefCat)) {
          if (productPrefsSelected[prefCat]!
              .where((element) => element == e)
              .isEmpty) {
            setState(() {
              productPrefsSelected[prefCat]!.add(e);
            });
          } else {
            setState(() {
              productPrefsSelected[prefCat]!.remove(e);
            });
            if (productPrefsSelected[prefCat]!.isEmpty) {
              productPrefsSelected.remove(prefCat);
            }
          }
        } else {
          setState(() {
            productPrefsSelected[prefCat] = [e];
          });
        }
      },
    );
  }

  void _returnInfo(BuildContext context) {
    Navigator.of(context).pop(productPrefsSelected);
  }

  Padding _productName(BuildContext context) {
    return Text(
      capitalizeText(widget.product.name),
      style: normalTextStyle(context, fontSizeFactor: 1.1),
    ).paddingTop(8);
  }

  Widget _unitSelectedName(BuildContext context) {
    return _selectUnition != null
        ? Text(
            getRoundedQtty(widget.uQtty ?? 1) +
                ' - ' +
                (_selectUnition?.name ?? ''),
            style: buttonsSmallTextStyle(context),
          )
        : Container();
  }
}
