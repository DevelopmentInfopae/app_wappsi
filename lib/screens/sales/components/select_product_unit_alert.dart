import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
// import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

/// Custom alert dialog to manage open and close operations on Register, to open action = 'open'
/// to close action = 'close'
///
class SelectProductUnitDialog extends StatefulWidget {
  final List<UnitsModel> units;
  const SelectProductUnitDialog(
      {Key? key, required this.product, required this.units})
      : super(key: key);
  final ProductModel product;
  @override
  SelectProductUnitDialogState createState() {
    return SelectProductUnitDialogState();
  }
}

class SelectProductUnitDialogState extends State<SelectProductUnitDialog> {
  late FocusNode _valueFocus;

  int _selection = 0;

  int qtty = 1;

  @override
  void initState() {
    super.initState();
    _valueFocus = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _valueFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Column(
        children: [
          Text(
            'Seleccione la unidad de producto para:',
            style: buttonsSmallTextStyle(context).apply(fontSizeDelta: 1.2),
          ),
          Text(
            capitalizeText(widget.product.name),
            style: normalTextStyle(context, fontSizeFactor: 1.1),
          ).paddingTop(8)
        ],
      ).paddingBottom(10),
      content: Column(
        children: [
          SingleChildScrollView(child: _select(context)),
          qttyControl(context).paddingTop(4),
        ],
      ),
      actions: <Widget>[
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
        ),
        Container(
          color: pColor.withOpacity(0.8),
          child: CupertinoDialogAction(
            child: const Text(
              "Aceptar",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            onPressed: () async {
              if (_selection != 0) {
                Navigator.of(context).pop({
                  "unit":
                      widget.units.where((u) => u.idCloud == _selection).first,
                  "quantity": qtty
                });
              }
              // return widget.product;
            },
          ),
        ),
      ],
    );
  }

  Widget qttyControl(BuildContext context) {
    return Column(
      children: [
        Text(
          'Unidad U.M seleccionada:',
          style: buttonsSmallTextStyle(context),
        ).paddingSymmetric(vertical: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _rmQty(),
            Container(
              padding: kButtonPadding,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Text(
                qtty.toString(),
                style: buttonsSmallTextStyle(context),
              ),
            ),
            _addQty()
          ],
        ),
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
                  _selection = u.idCloud;
                });
              },
              color: greyLight,
              shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(
                      color: u.idCloud == _selection ? pColor : Colors.white,
                      width: 3)),
              padding: EdgeInsets.zero,
              child: ListTile(
                title: Row(
                  children: [
                    Text(
                      u.name,
                      maxLines: 2,
                    ).expand(),
                    unitValue(u),

                    // Checkbox(
                    //   checkColor: Colors.white,
                    //   activeColor: pColor,
                    //   value: u.idCloud == _selection,
                    //   shape: CircleBorder(),
                    //   onChanged: (bool? value) {
                    //     setState(() {
                    //       _selection = u.idCloud;
                    //     });
                    //   },
                    // ).flexible(flex: 1)
                  ],
                ),
              ),
            ).paddingSymmetric(vertical: 4);
          }).toList(),
        ),
      ),
    );
  }

  Text unitValue(UnitsModel u) {
    final value = getFormatedCurrency(u.unitValue);
    return Text(
      value.substring(0, value.length - 3),
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
      enabled: _selection != 0,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      onTap: () {
        if (qtty > 1) {
          setState(() {
            qtty = qtty - 1;
          });
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
      enabled: _selection != 0,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      onTap: () async {
        setState(() {
          qtty = qtty + 1;
        });
      },
      child: const Icon(
        Icons.add,
        color: Colors.red,
      ),
    );
  }
}
