import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
// import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
// import 'package:pos_wappsi/config/regimen_personT_form_params.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/utils/functions.dart';

Widget subTotal({bool large = false}) {
  return StreamBuilder<double>(
      stream: posBloc.subTotalStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final value = getFormatedCurrency(snapshot.data!);
          return large
              ? _totalLarge(context, value)
              : _totalValue(context, value)
                  .paddingSymmetric(horizontal: 8, vertical: 8);
        } else {
          posBloc.setSubTotal(posBloc.getSubTotal());
          return large
              ? _totalLarge(context, " 0.00")
              : _totalValue(context, " 0.00")
                  .paddingSymmetric(horizontal: 8, vertical: 8);
        }
      });
}

Widget _totalSmall(BuildContext context, String value) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text("Total", style: buttonsTextStyle(context, fontSizeFactor: 0.6)),
      _totalValue(context, value),
    ],
  ).paddingBottom(8);
}

Widget _totalLarge(BuildContext context, String value) {
  return Row(
    children: [
      Text("Total: ", style: buttonsTextStyle(context, fontSizeFactor: 1.4)),
      _totalValue(context, value)
          .paddingOnly(top: 10, bottom: 10, right: 8)
          .expand(),
    ],
  );
}

Widget _totalValue(BuildContext context, String value) {
  return FittedBox(
    fit: BoxFit.fitHeight,
    child: Text("${value.substring(0, value.length - 3)}",
            style: numbersTextStyle(
                color: Colors.white,
                fontSizeFactor: 1.15,
                fontWeight: FontWeight.w800))
        .paddingOnly(bottom: 6, top: 10),
  );
}

Widget popupCustomerAddressesItemBuilder(
    BuildContext context, CustomerAddressesModel? item, bool isSelected) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 8),
    decoration: !isSelected
        ? null
        : BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
    child: ListTile(
      selected: isSelected,
      title: Text(capitalizeText(item?.sucursal ?? '')),
      subtitle: Text(item?.vatNo ?? ''),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset('assets/images/location.png').paddingAll(2),
      ),
    ),
  );
}

Widget customPopupCustomerItemBuilder(
    BuildContext context, CompanyModel? item, bool isSelected) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 8),
    decoration: !isSelected
        ? null
        : BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
    child: ListTile(
      selected: isSelected,
      title: Text(capitalizeText(item?.name ?? '')),
      subtitle: Text(capitalizeText(item?.vatNo ?? '')),
      leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: customerPhoto(item!.logoSquare!)),
    ),
  );
}
