import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/components/input_decoration.dart';
// ignore: implementation_imports
// import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';
// import 'package:provider/single_child_widget.dart';

/// Custom alert dialog to manage open and close operations on Register, to open action = 'open'
/// to close action = 'close'
///
class SelectProductUnitDialog extends StatefulWidget {
  final List<UnitsModel> units;
  const SelectProductUnitDialog(
      {Key? key,
      required this.product,
      this.showInvInstOfPrice = false,
      required this.units})
      : super(key: key);
  final ProductModel product;
  final bool showInvInstOfPrice;
  @override
  SelectProductUnitDialogState createState() {
    return SelectProductUnitDialogState();
  }
}

class SelectProductUnitDialogState extends State<SelectProductUnitDialog> {
  final _valueController = TextEditingController();

  UnitsModel? _selection;

  double qtty = 1;

  @override
  void initState() {
    _valueController.text = qtty.toString();
    super.initState();
    if (widget.units.length == 1) {
      _selection = widget.units.first;
    }
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
              'Seleccione la unidad de producto para:',
              style: buttonsSmallTextStyle(context).apply(fontSizeDelta: 1.2),
              textAlign: TextAlign.center,
            ),
            Text(
              capitalizeText(widget.product.name),
              style: normalTextStyle(context, fontSizeFactor: 1.1),
            ).paddingTop(8)
          ],
        ),
        content: Column(
          children: [
            _select(context).expand(),
            qttyControl(context).paddingTop(8),
          ],
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
                    // return widget.product;
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
                    if (_selection != null) {
                      Navigator.of(context).pop({
                        "unit": _selection,
                        "quantity": qtty == 0 ? 1.0 : qtty
                      });
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

  Widget qttyControl(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _rmQty(),
            Container(
                height: 40,
                width: 55,
                // padding: kButtonPadding,
                decoration: BoxDecoration(
                    // color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 2.0,
                        spreadRadius: 0.0, // shadow direction: bottom right
                      )
                    ]),
                child: Material(
                  color: Colors.transparent,
                  child: AppTextField(
                    onChanged: (value) {
                      if (isNumeric(value)) {
                        qtty = double.tryParse(value) ?? 1.0;
                      }
                    },
                    enabled: _selection != null,
                    controller: _valueController,
                    textStyle: buttonsSmallTextStyle(context),
                    textFieldType: TextFieldType.PHONE,
                    textAlign: TextAlign.center,
                    decoration:
                        InputDecorations.noBorders(hintText: '', labelText: ''),
                  ),
                )),
            _addQty()
          ],
        ),
        _selection != null
            ? Text(
                getRoundedQtty(qtty) + ' - ' + _selection!.name,
                style: buttonsSmallTextStyle(context),
              )
            : Container()
      ],
    );
  }

  Widget _select(BuildContext context) {
    // final _textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          children: widget.units.map((UnitsModel u) {
            return AppButton(
              onTap: () {
                setState(() {
                  _selection = u;
                });
              },
              color: greyLight,
              shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(
                      color: u == _selection ? pColor : Colors.white,
                      width: 3)),
              padding: EdgeInsets.zero,
              child: ListTile(
                title: Row(
                  children: [
                    Text(
                      u.name,
                      maxLines: 2,
                    ).expand(),
                    widget.showInvInstOfPrice
                        ? inventoryValue(u)
                        : unitValue(u),
                  ],
                ),
              ),
            ).paddingSymmetric(vertical: 2);
          }).toList(),
        ),
      ),
    );
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
    final value = getRoundedQtty(widget.product.inventory / u.operationValue);
    return Text(
      value.substring(0, value.length),
      maxLines: 2,
      style: normalTextStyle(context, fontWeightDelta: 2),
    );
  }

  Widget _rmQty() {
    return AppButton(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
      margin: EdgeInsets.zero,
      color: Colors.grey[100],
      width: 10,
      enabled: _selection != null,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      onTap: () {
        if (qtty > 1) {
          setState(() {
            qtty = qtty - 1;
          });
          _valueController.text = qtty.toString();
        }
      },
      child: const Icon(
        Icons.remove,
        color: Colors.black,
      ),
    );
  }

  Widget _addQty() {
    return AppButton(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
      color: Colors.grey[100],
      margin: EdgeInsets.zero,
      width: 10,
      enabled: _selection != null,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      onTap: () async {
        setState(() {
          qtty = qtty + 1;
        });
        _valueController.text = qtty.toString();
      },
      child: const Icon(
        Icons.add,
        color: Colors.red,
      ),
    );
  }
}
