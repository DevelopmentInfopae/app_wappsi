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

  List<PreferenceCategoryModel> reqCatPrefs = [];

  Map<int, bool> markAsNeeded = {};

  Map<int, String?> errorMessage = {};

  bool initVariables = false;

  @override
  void initState() {
    _selectUnition = widget.unit;

    // for some reason this is not working to init this variables
    // widget.productPrefs.keys.map((prefCat) {
    //   // build a list of required product preferences
    //   if (prefCat.required == 1) {
    //     if (!reqCatPrefs.contains(prefCat)) {
    //       reqCatPrefs.add(prefCat);
    //     }
    //   }

    //   // add a preference cateogory marker to change card border if
    //   // preference category is required

    //   markAsNeeded[prefCat.id ?? 0] = false;
    // });
    super.initState();
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
                    Map<PreferenceCategoryModel, List<PreferenceModel>> t = {};
                    Navigator.of(context).pop(t);
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
          if (!initVariables) {
            // build a list of required product preferences
            if (prefCat.required == 1) {
              if (!reqCatPrefs.contains(prefCat)) {
                reqCatPrefs.add(prefCat);
              }
            }

            // add a preference cateogory marker to change card border if
            // preference category is required

            markAsNeeded[prefCat.id ?? 0] = false;
            initVariables = true;
          }
          return Column(
            children: [
              Container(
                // margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: kButtonPadding,
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: (markAsNeeded[prefCat.id] ?? false)
                            ? errorColor
                            : Colors.transparent),
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
              ),
              markAsNeeded[prefCat.id ?? 0] == true
                  ? Text(
                      errorMessage[prefCat.id ?? 0] ?? '',
                      textAlign: TextAlign.center,
                      style: normalTextStyle(context, color: errorColor),
                    ).paddingTop(4)
                  : const SizedBox()
            ],
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
        trailing: Checkbox(
          hoverColor: greyMediumLight,
          checkColor: okColorWappsi,
          // fillColor: MaterialStateProperty.resolveWith((){return Colors.white};),
          activeColor: Colors.white,
          value: ((productPrefsSelected[prefCat] ?? [])
              .where((element) => element == e)
              .isNotEmpty),
          shape: const CircleBorder(),

          onChanged: (bool? value) {
            value;
            _selectUnselectPref(prefCat, e);
          },
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
        _selectUnselectPref(prefCat, e);
      },
    );
  }

  void _selectUnselectPref(PreferenceCategoryModel prefCat, PreferenceModel e) {
    if (productPrefsSelected[prefCat] != null) {
      if (productPrefsSelected[prefCat]!
          .where((element) => element == e)
          .isEmpty) {
        setState(() {
          productPrefsSelected[prefCat]?.add(e);
        });
      } else {
        setState(() {
          productPrefsSelected[prefCat]?.remove(e);
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
  }

  void _returnInfo(BuildContext context) {
    bool returnInfo = true;

    for (PreferenceCategoryModel reqCatPref in reqCatPrefs) {
      int? selectionLimit;
      if (reqCatPref.selectionLimit == 0 || reqCatPref.selectionLimit == null) {
        selectionLimit = 999;
      } else {
        selectionLimit = reqCatPref.selectionLimit!;
      }
      if ((!productPrefsSelected.keys.contains(reqCatPref)) ||
          ((productPrefsSelected[reqCatPref]?.length ?? 1) > selectionLimit)) {
        String error = '';
        if ((productPrefsSelected[reqCatPref]?.length ?? 1) > selectionLimit) {
          error =
              "Debe seleccionar como maximo ${reqCatPref.selectionLimit ?? 1} preferencia(s) para esta categoria";
        } else {
          error =
              "Debe seleccionar almenos una preferencia para esta categoria";
        }
        setState(() {
          errorMessage[reqCatPref.id ?? 0] = error;
          markAsNeeded[reqCatPref.id ?? 0] = true;
          markAsNeeded;
        });
        returnInfo = false;
      }
    }
    if (returnInfo) {
      Navigator.of(context)
          .pop(productPrefsSelected.isEmpty ? null : productPrefsSelected);
    }
  }

  Padding _productName(BuildContext context) {
    return Text(
      capitalizeText(widget.product.name),
      style: normalTextStyle(context, fontSizeFactor: 1.1),
    ).paddingTop(8);
  }

  // Widget _unitSelectedName(BuildContext context) {
  //   return _selectUnition != null
  //       ? Text(
  //           getRoundedQtty(widget.uQtty ?? 1) +
  //               ' - ' +
  //               (_selectUnition?.name ?? ''),
  //           style: buttonsSmallTextStyle(context),
  //         )
  //       : Container();
  // }
}
