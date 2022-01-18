import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';

import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/screens/customers/customer_details.dart';
import 'package:pos_wappsi/utils/functions.dart';

// class to show customer indormation in form of a card

class CustomerCard extends StatefulWidget {
  final CompanyModel customer;

  final String action;
  CustomerCard({Key? key, required this.customer, required this.action})
      : super(key: key);

  @override
  _CustomerCardState createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard> {
  // late Size _size;

  @override
  Widget build(BuildContext context) {
    // _size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        CustomerDetails(customer: widget.customer).launch(context);
      },
      child: Card(
        // color: Color.fromRGBO(245, 245, 245, 1),
        margin: EdgeInsets.symmetric(horizontal: 5),
        elevation: 5,
        child: Row(
          children: [
            customerPhoto(widget.customer.customerProfilePhoto!)
                .flexible(flex: 2),
            // hDivider(heigh: 60, width: 1, pleft: 6),
            _description().flexible(flex: 7)
          ],
        ),
      ),
    );
  }

  Widget _description() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _name(),
          _company(),
          _docNumber()
          // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

          // ]),
        ],
      ),
    );
  }

  Text _docNumber() {
    return Text(
      'NIT/CC : ${widget.customer.vatNo}',
      style: normalTextStyle(context),
      overflow: TextOverflow.ellipsis,
    );
  }

  Text _company() {
    return Text(
      capitalizeText(widget.customer.company ?? ''),
      style: normalTextStyle(context),
      overflow: TextOverflow.ellipsis,
    );
  }

  Text _name() {
    return Text(
      capitalizeText(widget.customer.name ?? ''),
      style: buttonsSmallTextStyle(context),
      overflow: TextOverflow.ellipsis,
    );
  }
}
