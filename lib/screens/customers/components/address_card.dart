import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/screens/customers/addresses_details.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

import '../../../models/companies_model.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({Key? key, required this.customer, required this.address})
      : super(key: key);

  final CompanyModel customer;
  final CustomerAddressesModel address;

  @override
  Widget build(BuildContext context) {
    String stateCity = '';
    if (address.state != null) {
      stateCity = address.state! + ' - ';
    }
    if (address.city != null) {
      stateCity = address.city!;
    }
    return AppButton(
      onTap: () {
        AddressDetails(customer: customer, address: address).launch(context);
      },
      padding: EdgeInsets.zero,
      elevation: 2,
      child: Row(
        children: [
          // addressPhoto(customer.customerProfilePhoto ?? '')
          Image.asset('assets/images/locations.png')
              .paddingAll(12)
              .withSize(width: 90, height: 90),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address.sucursal ?? '',
                style: buttonsTextStyle(context, color: greyDarkerColor),
              ),
              Text(
                customer.name ?? '',
                style: normalTextStyle(context),
              ),
              Text(
                address.direccion ?? '',
                style: normalTextStyle(context),
              ),
              Text(
                capitalizeText(stateCity),
                style: normalTextStyle(context),
              ),
            ],
          ).paddingSymmetric(horizontal: 8)
        ],
      ),
    );
  }
}
