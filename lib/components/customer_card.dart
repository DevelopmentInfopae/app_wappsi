import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/screens/customers/customer_details.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

// class to show customer indormation in form of a card

class CustomerCard extends StatelessWidget {
  final CompanyModel customer;

  final String action;
  const CustomerCard({Key? key, required this.customer, required this.action})
      : super(key: key);

  // late Size _size;

  @override
  Widget build(BuildContext context) {
    // _size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        CustomerDetails(customer: customer).launch(context);
      },
      child: Card(
        // color: Color.fromRGBO(245, 245, 245, 1),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        elevation: 5,
        child: Row(
          children: [
            customerPhoto(customer.customerProfilePhoto ?? '',
                    fit: BoxFit.cover)
                .withSize(height: 90, width: 90),
            vDivider(width: 2, heigh: 80),
            _description(context).flexible(flex: 7)
          ],
        ).withHeight(100),
      ),
    );
  }

  Widget _description(var context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            capitalizeText(customer.name ?? ''),
            style: buttonsSmallTextStyle(context),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            capitalizeText(customer.company ?? ''),
            style: normalTextStyle(context),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'NIT/CC : ${customer.vatNo}',
            style: normalTextStyle(context),
            overflow: TextOverflow.ellipsis,
          )

          // ]),
        ],
      ),
    );
  }
}
