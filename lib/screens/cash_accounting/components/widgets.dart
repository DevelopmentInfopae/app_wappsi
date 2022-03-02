// ignore_for_file: body_might_complete_normally_nullable

import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/providers/register_form_provider.dart';
import 'package:pos_wappsi/screens/cash_accounting/components/functions.dart';
import 'package:pos_wappsi/utils/text_formating/currency_formater.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

Widget registerInput(BuildContext context, RegisterFormProvider cashAccForm,
    FocusNode valueFocus,
    {String action = 'open',
    label = '',
    textAlign = TextAlign.center,
    TextStyle? style = const TextStyle(fontSize: 18),
    bool autoFocus = true}) {
  return Padding(
    padding: const EdgeInsets.all(15.0),
    child: TextFormField(
      focusNode: valueFocus,
      autofocus: autoFocus,
      inputFormatters: [CurrencyInputFormatter()],
      initialValue: cashAccForm.value,
      style: style ?? Theme.of(context).textTheme.subtitle1,
      keyboardType: TextInputType.number,
      textAlign: textAlign,
      decoration: InputDecoration(
        // suffixIcon: Icon(FontAwesomeIcons.moneyBillAlt),
        contentPadding: kTextFieldPadding,
        border: outlineInputBorder(),
        focusedBorder: outlineInputBorder(),
        enabledBorder: outlineInputBorder(),
        labelText: label,
        // hintText: '\$ 0.0'
      ),
      onFieldSubmitted: (_) =>
          sendRegisterAction(context, cashAccForm, valueFocus, action: action),
      validator: (value) {
        if (value!.isNotEmpty) {
          return cashAccForm
                  .isNumeric(value.replaceAll(',', '').replaceAll("\$", ''))
              ? null
              : 'El valor ingresado no es valido';
        } else {
          cashAccForm.value = '0';
        }
      },
      onChanged: (value) {
        cashAccForm.value = value.replaceAll('\$', '').replaceAll(',', '');
      },
    ),
  );
}

Widget movementDetails(
    BuildContext context, Map<String, dynamic> movementInfo) {
  // final _size = MediaQuery.of(context).size;
  String value =
      getFormatedCurrency(double.tryParse(movementInfo['value'] ?? '') ?? 0.0);
  value = value.substring(0, value.length - 3);
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            'Usuario: ',
            style: normalTextStyle(context, fontWeightDelta: 5),
          ),
          Text(
            movementInfo['user_name'] ?? '',
            style: normalTextStyle(context),
            textAlign: TextAlign.end,
          ).expand()
        ],
      ),
      Row(
        children: [
          Text(
            'Fecha: ',
            style: normalTextStyle(context, fontWeightDelta: 5),
          ),
          Text(
            movementInfo['date'] ?? '',
            style: normalTextStyle(context),
            textAlign: TextAlign.end,
          ).expand()
        ],
      ),
      Row(
        children: [
          Text(
            'Referencia: ',
            style: normalTextStyle(context, fontWeightDelta: 5),
          ),
          Text(
            movementInfo['reference_no'] ?? '',
            style: normalTextStyle(context),
            textAlign: TextAlign.end,
          ).expand()
        ],
      ),
      Row(
        children: [
          Text(
            'Sucursal: ',
            style: normalTextStyle(context, fontWeightDelta: 5),
          ),
          Text(
            capitalizeText(movementInfo['biller_name'] ?? ''),
            style: normalTextStyle(context),
            textAlign: TextAlign.end,
          ).expand()
        ],
      ),
      Row(
        children: [
          Text(
            'Tipo de movimiento: ',
            style: normalTextStyle(context, fontWeightDelta: 5),
          ),
          Text(
            movementInfo['movement_type'] ?? '',
            style: normalTextStyle(context),
            textAlign: TextAlign.end,
          ).expand()
        ],
      ),
      Row(
        children: [
          Text(
            'Valor: ',
            style: normalTextStyle(context, fontWeightDelta: 5),
          ),
          Text(
            value,
            style: normalTextStyle(context),
            textAlign: TextAlign.end,
          ).expand()
        ],
      ),

      // RichText(
      //     text: TextSpan(
      //         text: 'Nota de movimiento: ',
      //         style: normalTextStyle(context, fontWeightDelta: 5),
      //         children: [
      //       TextSpan(
      //           text: movementInfo['movement_note'] ?? '',
      //           style: normalTextStyle(context))
      //     ])),
    ],
  );
}
