import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';

/// Custom alert dialog to manage open and close operations on Register, to open action = 'open'
/// to close action = 'close'
///
class SelectProductUnitDialog extends StatefulWidget {
  const SelectProductUnitDialog({Key? key, required this.product})
      : super(key: key);
  final ProductModel product;
  @override
  SelectProductUnitDialogState createState() {
    return new SelectProductUnitDialogState();
  }
}

class SelectProductUnitDialogState extends State<SelectProductUnitDialog> {
  late FocusNode _valueFocus;

  final formKey = new GlobalKey<FormState>();

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
    return Container(
      // color: Colors.transparent,
      child: CupertinoAlertDialog(
        title: Text(
          'Seleccione la unidad de producto',
          style: buttonsSmallTextStyle(context).apply(fontSizeDelta: 1.2),
        ).paddingBottom(10),
        content: new SingleChildScrollView(child: _select(context)),
        actions: <Widget>[
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.8),
            child: CupertinoDialogAction(
              child: Text(
                "Aceptar",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              onPressed: () async {
                Navigator.of(context).pop(true);
                // return widget.product;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _select(BuildContext context) {
    // final _textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formKey,
        child: Column(),
      ),
    );
  }
}
