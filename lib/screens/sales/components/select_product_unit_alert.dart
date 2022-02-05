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
      content: SingleChildScrollView(child: _select(context)),
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
                Navigator.of(context).pop(
                    widget.units.where((u) => u.idCloud == _selection).first);
              }
              // return widget.product;
            },
          ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      u.name,
                      maxLines: 2,
                    ).flexible(flex: 7),
                    unitValue(u).flexible(flex: 5),
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
}
