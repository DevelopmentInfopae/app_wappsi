import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/purchases_bloc.dart';
// ignore: implementation_imports
// import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/screens/components/input_decoration.dart';
import 'package:pos_wappsi/utils/text_formating/currency_formatter.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';
// import 'package:provider/single_child_widget.dart';

/// Custom alert dialog to manage open and close operations on Register, to open action = 'open'
/// to close action = 'close'
///
class EditProductAlert extends StatefulWidget {
  const EditProductAlert({Key? key, required this.productKey})
      : super(key: key);
  final String productKey;
  @override
  EditProductAlertState createState() {
    return EditProductAlertState();
  }
}

class EditProductAlertState extends State<EditProductAlert> {
  final _valueController = TextEditingController();
  UnitsModel? unit;
  late ProductModel product;

  double _value = 1;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _valueController.text = _value.toString();
    unit = purchaseBloc.getProductUnits?[widget.productKey];
    product = purchaseBloc.getProductData(widget.productKey)!;
    if (unit != null) {
      _value = product.cost;
      _valueController.text = getFormatedCurrency(
        _value * (unit?.operationValue ?? 1),
        decimals: 0,
      );
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _valueController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CupertinoAlertDialog(
        title: Column(
          children: [
            Text(
              capitalizeText(product.name),
              style: buttonsSmallTextStyle(context).apply(fontSizeDelta: 1.2),
              textAlign: TextAlign.center,
            ).paddingBottom(4),
            Text(
              'Valor unitario ' + getFormatedCurrency(_value),
              style: normalTextStyle(context),
              textAlign: TextAlign.center,
            ),
            Text(
              product.taxMethod == 0 ? 'IVA incluido' : 'IVA no incluido',
              style: normalTextStyle(context, fontSizeFactor: 0.8),
            ).paddingBottom(10)
          ],
        ),
        content: Material(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // _valueEditing(context),
                AppTextField(
                  controller: _valueController,
                  inputFormatters: [CurrencyInputFormatter()],
                  decoration: InputDecorations.authInputDecoration(
                    hintText: '',
                    labelText: unit != null
                        ? 'Valor por ' + unit!.name
                        : 'Valor unitario',
                  ),
                  textFieldType: TextFieldType.PHONE,
                  textStyle: Theme.of(context).textTheme.subtitle1,
                  autoFocus: false,
                  isValidationRequired: true,
                  validator: (value) {
                    if (value == null || value == '') {
                      return 'Debe suministrar un valor';
                    } else {
                      try {
                        final val = double.parse(
                          value
                              .replaceAll('\$', '')
                              .replaceAll(',', '')
                              .replaceAll('.', ''),
                        );
                        if (val == 0) {
                          return 'Valor no valido';
                        }
                      } catch (e) {
                        return 'Valor no valido';
                      }
                    }

                    return null;
                  },
                  // textStyle: const TextStyle(fontSize: 20),
                  onChanged: (value) {
                    setState(() {
                      if (value != '') {
                        try {
                          final val = double.parse(
                            value
                                .replaceAll('\$', '')
                                .replaceAll(',', '')
                                .replaceAll('.', ''),
                          );
                          if (unit != null) {
                            _value = val / unit!.operationValue;
                          } else {
                            _value = val;
                          }
                        } catch (e) {
                          _value = 0;
                        }
                      } else {
                        _value = 0;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          Row(
            children: [
              Container(
                color: Colors.red.withOpacity(0.8),
                child: CupertinoDialogAction(
                  child: const Text(
                    'Cancelar',
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
                    'Aceptar',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () async {
                    // return widget.product;
                    if (_formKey.currentState?.validate() ?? false) {
                      product.cost = _value;

                      purchaseBloc.getSubTotalCost();
                      Navigator.pop(context);
                    }
                  },
                ),
              ).flexible(flex: 1),
            ],
          ),
        ],
      ),
    );
  }
}
