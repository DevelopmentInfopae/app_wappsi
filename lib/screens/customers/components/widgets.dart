import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/components/input_decoration.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

Widget descRichText(String label, String? desc, BuildContext context,
    {double fontsizeF = 0.9, int fontW = 1, Color color = Colors.black}) {
  return RichText(
    text: TextSpan(
        text: label,
        style: buttonsTextStyle(context,
            fontSizeFactor: fontsizeF, fontWeightDelta: 4, color: color),
        children: [
          TextSpan(
            text: capitalizeText(desc ?? ''),
            // overflow: TextOverflow.ellipsis,
            // maxLines: 2,
            style: buttonsTextStyle(context,
                fontSizeFactor: fontsizeF, color: color),
          )
        ]),
    // style: textTheme,
  );
}

Widget descText(String? desc, BuildContext context,
    {int maxLines = 1,
    double fontSizeFactor = 0.82,
    int fweigth = 1,
    Color color = Colors.black,
    TextAlign? textAlign,
    TextStyle? textStyle}) {
  textStyle ??= buttonsTextStyle(context,
        fontSizeFactor: fontSizeFactor, color: color, fontWeightDelta: fweigth);
  return Text(
    // ignore: unnecessary_null_comparison
    capitalizeText(desc ?? ''),
    overflow: TextOverflow.ellipsis,
    maxLines: maxLines,
    textAlign: textAlign,
    style: textStyle,
  );
}

Widget textFormField(BuildContext context, String label, Function function,
    Function validation, Function onEditingComplete,
    {TextInputType keyBType = TextInputType.name,
    bool readOnly = false,
    TextEditingController? controller,
    FocusNode? focus,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    Color labelColor = pColor,
    int? maxLines,
    TextStyle? style}) {
  return TextFormField(
    focusNode: focus,
    readOnly: readOnly,
    keyboardType: keyBType,
    
    autovalidateMode: autovalidateMode,
    controller: controller,
    style: style ?? normalTextStyle(context),
    maxLines: maxLines,
    decoration:
        InputDecorations.outlineInputDecoration(hintText: '', labelText: label),
        
    validator: (String? value) {
      return validation(value);
    },
    onEditingComplete: () {
      onEditingComplete();
    },
    onChanged: (String? value) {
      function(value);
    },
  );
}

Widget customerPhotoAndName(BuildContext context, CompanyModel customer) {
  final Size _size = MediaQuery.of(context).size;
  return Card(
    elevation: 1,
    child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          customerPhoto(customer.customerProfilePhoto ?? '')
              .withWidth(_size.width * 0.3),
          customerDesc(context, customer).expand()
        ]),
  );
}

Widget customerDesc(BuildContext context, CompanyModel customer) {
  return Padding(
    padding: const EdgeInsets.only(top: 5, bottom: 5, right: 5, left: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // SizedBox(height: 8,),
        descText(customer.company ?? customer.name, context,
                maxLines: 2, fontSizeFactor: 1.1, fweigth: 10)
            .paddingSymmetric(vertical: 1),
        descText(customer.name, context, fontSizeFactor: 0.75)
            .paddingSymmetric(vertical: 1),
        descRichText('NIT/CC : ', customer.vatNo, context,
                fontsizeF: 0.75, fontW: 2)
            .paddingSymmetric(vertical: 1),
        descRichText('Telefono : ', customer.phone, context,
                fontW: 2, fontsizeF: 0.75)
            .paddingSymmetric(vertical: 1),
      ],
    ).paddingRight(6),
  );
}
