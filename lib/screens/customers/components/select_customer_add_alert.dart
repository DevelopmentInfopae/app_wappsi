import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
// import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

/// Custom alert dialog to manage open and close operations on Register, to open action = 'open'
/// to close action = 'close'
///
class SelectCustomerAddressAlert extends StatefulWidget {
  final List<CustomerAddressesModel> adresses;
  const SelectCustomerAddressAlert(
      {Key? key, required this.customer, required this.adresses})
      : super(key: key);
  final CompanyModel customer;
  @override
  SelectCustomerAddressAlertState createState() {
    return SelectCustomerAddressAlertState();
  }
}

class SelectCustomerAddressAlertState
    extends State<SelectCustomerAddressAlert> {
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
            'Seleccione una sucursal para el cliente:',
            style: buttonsSmallTextStyle(context).apply(fontSizeDelta: 1.2),
          ),
          Text(
            capitalizeText(widget.customer.name!),
            style: normalTextStyle(context, fontSizeFactor: 1.1),
          ).paddingTop(8)
        ],
      ).paddingBottom(10),
      content: Column(
        children: [
          SingleChildScrollView(child: _select(context)),
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
              // return widget.customer;
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
                Navigator.of(context).pop(widget.adresses
                    .where((u) => u.idCloud == _selection)
                    .first);
              }
              // return widget.customer;
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
          children: widget.adresses.map((CustomerAddressesModel a) {
            return AppButton(
              onTap: () {
                if (_selection == a.idCloud) {
                  setState(() {
                    _selection = 0;
                  });
                } else {
                  setState(() {
                    _selection = a.idCloud;
                  });
                }
              },
              color: greyLight,
              shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(
                      color: a.idCloud == _selection ? pColor : Colors.white,
                      width: 3)),
              padding: EdgeInsets.zero,
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      capitalizeText(a.city ?? ''),
                      style: normalTextStyle(context, fontWeightDelta: 2),
                      maxLines: 1,
                    ),
                    Text(
                      capitalizeText(a.direccion!),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ).paddingSymmetric(vertical: 4);
          }).toList(),
        ),
      ),
    );
  }
}
