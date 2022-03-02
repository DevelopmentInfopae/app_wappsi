import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';

import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/widgets.dart';

import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/screens/customers/adresses_list.dart';

import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/screens/customers/favorites.dart';

class CustomerDetails extends StatefulWidget {
  const CustomerDetails({required this.customer, Key? key}) : super(key: key);

  final CompanyModel customer;

  @override
  State<CustomerDetails> createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails> {
  // late Size _size = MediaQuery.of(context).size;
  // late Color _pc;

  @override
  Widget build(BuildContext context) {
    // _pc = pColor;

    return Scaffold(
      appBar: appBar(context, 'Detalle de cliente',
          image: 'assets/images/enterprise.png'),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        customerPhotoAndName(context, widget.customer),
        _customerDetails().paddingOnly(left: 10, right: 10, bottom: 5).expand(),
        bottom(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // const GoBackBottom(),
                _addresses(context),
                _favorites(context),
              ],
            ),
            pColor,
            size)
      ],
    );
  }

  AppButton _favorites(BuildContext context) {
    return AppButton(
      onTap: () async {
        await dataBloc.refreshToken(context);
        ListFavorites(customer: widget.customer).launch(context);
      },
      color: Colors.white,
      padding: kButtonPadding,
      // disabledColor: Colors.white,

      margin: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FontAwesomeIcons.star, size: kIconSize, color: pColor),
          Text(
            ' Favoritos',
            style: buttonsSmallTextStyle(context, color: pColor),
          ),
        ],
      ),
    );
  }

  AppButton _addresses(BuildContext context) {
    return AppButton(
      onTap: () async {
        // await dataBloc.refreshToken(context);
        ListAddresses(customer: widget.customer).launch(context);
      },
      color: Colors.white,
      padding: kButtonPadding,
      // disabledColor: Colors.white,

      margin: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FontAwesomeIcons.building, size: kIconSize, color: pColor),
          Text(
            ' Sucursales',
            style: buttonsSmallTextStyle(context, color: pColor),
          ),
        ],
      ),
    );
  }

  Widget _customerDetails() {
    return Card(
        elevation: 5,
        child: ListView(
          padding: const EdgeInsets.all(5),
          children: [
            labelContent('Drección ', widget.customer.address ?? ''),
            hDivider(),
            labelContent('Ubicación ',
                '${widget.customer.city ?? ''} ${widget.customer.state ?? ''}-${widget.customer.country ?? ''}'),
            hDivider(),
            labelContent('Email ', widget.customer.email ?? ''),
            hDivider(),
            labelContent('Telefono ', widget.customer.phone ?? ''),
            hDivider(),
            labelContent(
                'Lista de precios ', widget.customer.priceGroupName ?? ''),
            hDivider(),
            labelContent(
                'Descuentos ', widget.customer.customerGroupName ?? ''),
            hDivider(),
            // futureLabelContent(DBProvider.db.findCustomerDiscount(customer.customerGroupId??1), 'name', 'Marca')
          ],
        ));
  }
}
