import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/components/widgets.dart';
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
class ProductChangesAlert extends StatefulWidget {
  const ProductChangesAlert(
      {Key? key,
      required this.product,
      required this.productKey,
      this.qttyDiff = false,
      this.fromSale = true,
      this.priceDiff = false})
      : super(key: key);

  final ProductModel? product;
  final String productKey;
  final bool qttyDiff;
  final bool fromSale;
  final bool priceDiff;

  @override
  ProductChangesAlertState createState() {
    return ProductChangesAlertState();
  }
}

class ProductChangesAlertState extends State<ProductChangesAlert> {
  final _valueController = TextEditingController();

  UnitsModel? unit;

  ProductModel? oProduct;
  ProductModel? selectedP;

  bool prefsSelection = false;

  Map<PreferenceCategoryModel, List<PreferenceModel>> productrefs = {};

  double qtty = 1;

  final List<PreferenceModel> selectedPrefs = [];

  @override
  void initState() {
    _valueController.text = qtty.toString();
    if (widget.fromSale) {
      oProduct = posBloc.getProducts?[widget.productKey];
    }

    selectedP = oProduct;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _valueController.dispose();
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(alertBorderRadius),
        ),
        // insetPadding: EdgeInsets.zero,
        // contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.symmetric(
            horizontal: hInsetPadding, vertical: vInsetPadding),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        title: Column(
          children: [
            Text(
              "Se han detectado cambios en el siguiente producto:",
              textAlign: TextAlign.center,
              style: buttonsSmallTextStyle(context, fontSizeFactor: 1),
            ).paddingTop(8),
            _productName(context).paddingTop(8),
            _unitSelectedName(context)
          ],
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.priceDiff
                ? _priceDiff(context)
                : widget.qttyDiff
                    ? _stock(context)
                    : Container(),

            // qttyControl(context).paddingTop(8),
          ],
        ),
        actionsPadding: EdgeInsets.zero,
        buttonPadding: EdgeInsets.zero,
        actions: <Widget>[
          Container(
            color: pColor.withOpacity(0.8),
            child: CupertinoDialogAction(
              child: const Text(
                "Aceptar",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              onPressed: () async {
                if (widget.priceDiff) {
                  if (selectedP == widget.product) {
                    // set current qtty to new product object
                    selectedP?.quantity = oProduct?.quantity ?? 1;
                    if (widget.fromSale) {
                      // reload product on sale products list
                      await posBloc.reloadOnlyProductPrice(
                          widget.productKey, selectedP!);
                    }
                  }
                  // set not verify prices param to sale if price selected is
                  // not the one calculated with current db info
                  if (selectedP == oProduct) {
                    if (widget.fromSale) {
                      posBloc.setVerifyPrices(0);
                    }
                  }
                  // return widget.product;
                  Navigator.pop(context);
                } else if (widget.qttyDiff) {
                  if (widget.fromSale) {
                    posBloc.getProducts?[widget.productKey]?.quantity =
                        widget.product!.inventory;
                    // posBloc.getProducts?[widget.productKey]?.inventory =
                    //     widget.product!.inventory;
                    posBloc.reloadProductStream();
                    posBloc.setSubTotal(posBloc.getSubTotal());
                  }
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Column _stock(BuildContext context) {
    return Column(
      children: [
        Text(
          'Sin stock',
          style: buttonsSmallTextStyle(context, color: pColor),
        ).paddingBottom(10),
        SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                child: Column(
                  children: [
                    Text(
                      getRoundedQtty(oProduct?.quantity ?? 0),
                      style: buttonsSmallTextStyle(context),
                    ),
                    Text(
                      'Selección',
                      style: normalTextStyle(context),
                    ).paddingTop(2)
                  ],
                ),
                padding: kButtonPadding,
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                    border: Border.all(color: errorColor),
                    borderRadius: BorderRadius.circular(radius2)),
              ).flexible(flex: 1),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: iconSize(context),
              ),
              Container(
                child: Column(
                  children: [
                    Text(
                      getRoundedQtty(widget.product?.inventory ?? 0),
                      style: buttonsSmallTextStyle(context),
                    ),
                    Text(
                      'Stock',
                      style: normalTextStyle(context),
                    ).paddingTop(2)
                  ],
                ),
                padding: kButtonPadding,
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                    border: Border.all(color: pColor),
                    borderRadius: BorderRadius.circular(radius2)),
              ).flexible(flex: 1),
            ],
          ),
        ),
        Text(
          'Se fijará el stock disponible como cantidad seleccionada del producto.',
          textAlign: TextAlign.center,
          style: normalTextStyle(context),
        ).paddingTop(10)
      ],
    );
  }

  Column _priceDiff(BuildContext context) {
    return Column(
      children: [
        Text(
          'Diferencia de precios',
          style: buttonsSmallTextStyle(context, color: pColor),
        ).paddingBottom(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AppButton(
              elevation: 4,
              child: DecoratedLabeledContent(
                label: 'Facturado',
                content: getFormatedCurrency(oProduct?.price ?? 0),
                backgroundColor: Colors.white,
              ),
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(
                      color: selectedP == oProduct ? pColor : Colors.white,
                      width: 2)),
              onTap: () {
                setState(() {
                  selectedP = oProduct;
                });
              },
            ).flexible(flex: 1),
            AppButton(
              child: DecoratedLabeledContent(
                label: 'Actualizado',
                content: getFormatedCurrency(widget.product?.price ?? 0),
                backgroundColor: Colors.white,
              ),
              shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(
                      color:
                          selectedP == widget.product ? pColor : Colors.white,
                      width: 2)),
              padding: EdgeInsets.zero,
              elevation: 4,
              margin: EdgeInsets.zero,
              onTap: () {
                setState(() {
                  selectedP = widget.product;
                });
              },
            ).flexible(flex: 1),
          ],
        ),
        Text(
          selectedP == widget.product
              ? 'Recargar producto con el precio actualizado.'
              : 'Conservar precio actual.',
          textAlign: TextAlign.center,
          style: normalTextStyle(context),
        ).paddingTop(10)
      ],
    );
  }

  Widget _productName(BuildContext context) {
    return Text(
      capitalizeText(widget.product?.name ?? ''),
      style: normalTextStyle(context, fontSizeFactor: 1.1),
      textAlign: TextAlign.center,
    );
  }

  Widget _unitSelectedName(BuildContext context) {
    return unit != null
        ? Text(
            getRoundedQtty(qtty) + ' - ' + (unit?.name ?? ''),
            style: buttonsSmallTextStyle(context),
          )
        : Container();
  }

  Text unitValue(UnitsModel u) {
    final value = getFormatedCurrency(u.unitValue);
    return Text(
      value.substring(0, value.length),
      maxLines: 2,
      style: normalTextStyle(context, fontWeightDelta: 2),
    );
  }

  Text inventoryValue(UnitsModel u) {
    final value =
        getRoundedQtty((widget.product?.inventory ?? 1) / u.operationValue);
    return Text(
      value.substring(0, value.length),
      maxLines: 2,
      style: normalTextStyle(context, fontWeightDelta: 2),
    );
  }
}
