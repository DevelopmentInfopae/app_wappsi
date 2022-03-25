// ignore_for_file: unnecessary_statements

import 'package:flutter/material.dart';

import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/go_back_bottom.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/customer_addresses_provider.dart';

import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/screens/customers/add_customer_address.dart';

// import 'package:pos_wappsi/utils/text_formating/functions.dart';

import 'components/address_card.dart';
// import 'package:pos_wappsi/utils/alerts.dart';

class ListAddresses extends StatefulWidget {
  final CompanyModel customer;
  const ListAddresses({Key? key, required this.customer}) : super(key: key);

  @override
  _ListAddressesState createState() => _ListAddressesState();
}

class _ListAddressesState extends State<ListAddresses> {
  late Size _size;
  late Color _pc;
  List<CustomerAddressesModel> address = [];
  List<ProductModel> favoritesToDelete = [];

  final _addressesListController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _addressesListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pc = pColor;
    _size = MediaQuery.of(context).size;

    // initialize search controller
    return Scaffold(appBar: _buildAppBar(context), body: _body());
  }

  PreferredSize _buildAppBar(BuildContext context) {
    return appBar(
      context,
      'Sucursales',
      elevation: true,
      radius: 0,
      image: 'assets/images/locations.png',
    );
  }

  Future<void> _reload(BuildContext context) async {
    final addresses = await CustomerAddressesProvider.loadCustomerAddresses(
        widget.customer.idCloud!);

    setState(() {
      address = addresses;
    });
  }

  Widget _body() {
    // ignore: unnecessary_null_comparison
    return Column(
      children: [_addresses().expand(), bottom(_bottom(), _pc, _size)],
    );
  }

  Widget _addresses() {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: FutureBuilder<List<CustomerAddressesModel>?>(
            future: CustomerAddressesProvider.loadCustomerAddresses(
                widget.customer.idCloud!),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                address = snapshot.data!;
              }
              return _addressList(context);
            }));
  }

  Widget _addressList(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          await _reload(context);
        },
        child: ListView(
            controller: _addressesListController,
            children: address
                .map((e) => AddressCard(customer: widget.customer, address: e)
                    .paddingSymmetric(horizontal: 4, vertical: 4))
                .toList()));
  }

  Widget _bottom() {
    return bottom(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // _saveChanges(context),
            const GoBackBottom(),
            addAddress(context),
          ],
        ),
        _pc,
        _size);
  }

  AppButton addAddress(BuildContext context) {
    return AppButton(
      onTap: () async {
        final res = await NewAddress(
          customer: widget.customer,
        ).launch(context);
        if (res == true) {
          await _reload(context);
          _addressesListController
              .jumpTo(_addressesListController.position.minScrollExtent);
        }
      },
      color: Colors.white,
      padding: kButtonPadding,
      // disabledColor: Colors.white,

      margin: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add,
            size: kIconSize,
            color: pColor,
          ),
          Text(
            ' Agregar',
            style: buttonsSmallTextStyle(
              context,
              color: pColor,
            ),
          ),
        ],
      ),
    );
  }

  // AppButton _saveChanges(BuildContext context) {
  //   return AppButton(
  //     onTap: () async {},
  //     color: Colors.white,
  //     padding: kButtonPadding,
  //     // disabledColor: Colors.white,

  //     margin: EdgeInsets.zero,
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         const Icon(
  //           Icons.save_outlined,
  //           size: kIconSize,
  //           color: pColor,
  //         ),
  //         Text(
  //           ' Guardar',
  //           style: buttonsSmallTextStyle(
  //             context,
  //             color: pColor,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
