// import 'package:badges/badges.dart';
// ignore_for_file: body_might_complete_normally_nullable

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/orders_bloc.dart';
// import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/basic_widgets.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/models/companies_model.dart';
// import 'package:pos_wappsi/components/app_bar_leading.dart';
import 'package:pos_wappsi/providers/companies_provider.dart';
import 'package:pos_wappsi/providers/customer_addresses_provider.dart';
import 'package:pos_wappsi/screens/orders/order_products.dart';
// import 'package:pos_wappsi/providers/suspended_sales_provider.dart';
import 'package:pos_wappsi/screens/sales/components/widgets.dart';

import 'package:nb_utils/nb_utils.dart';
// import 'package:pos_wappsi/screens/sales/suspended_sales.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

class NewOrder extends StatefulWidget {
  const NewOrder({Key? key}) : super(key: key);

  @override
  _NewOrderState createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  late Size _size;
  late Color _pc;
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _customerAddrController = TextEditingController();

  final _addressesDropDownKey =
      GlobalKey<DropdownSearchState<CustomerAddressesModel?>>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // final _customerDropDownKey = GlobalKey<DropdownSearchState<CompanyModel?>>();

  // final _customerFocusNode = FocusNode();

  @override
  void initState() {
    if (orderBloc.isDisposed) {
      orderBloc.reload();
    }
    super.initState();
  }

  @override
  void dispose() {
    _customerController.dispose();
    _customerAddrController.dispose();
    super.dispose();
  }

  Map user = dataBloc.userDataMap;

  @override
  Widget build(BuildContext context) {
    _pc = pColor;
    _size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async {
          dataBloc.homeKey?.currentState?.changeBottomIndex(1);
          // printConsole('here i am');
          return true;
        },
        child: Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
            appBar: _appBar(),
            body: _body()));
  }

  Widget _body() {
    return _form();
  }

  Widget _form() {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _userInfo().expand(),
        bottom(_button(), _pc, _size),
      ],
    );
  }

  Widget _userInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _branchOffice(),
            // _document(),
            _warehouse(),
            _sellerInfo(),
            _customersDropDown(),
            _customerAddressesDropDown()
          ],
        ),
      ),
    );
  }

  _branchOffice() {
    return informationText(user['biller_name'], 'Sucursal');
  }

  // Widget _document() {
  //   return informationText('CFG123', 'Documento');
  // }

  Widget _warehouse() {
    return informationText(user['warehouse_name'], 'Bodega');
  }

  Widget _sellerInfo() {
    return informationText(user['seller_name'], 'Vendedor');
  }

  PreferredSize _appBar() {
    return appBar(
      context,
      'Agregar pedido',
      image: 'assets/images/add-order.png',
      // leading: _appBarLeading(),
      onPop: () {
        dataBloc.homeKey?.currentState?.changeBottomIndex(1);
        Navigator.pop(context);
      },
    );
  }



  Widget _customersDropDown() {
    return DropdownSearch<CompanyModel>(
      // key: _customerDropDownKey,
      // focusNode: _customerFocusNode,
      searchFieldProps: TextFieldProps(
        controller: _customerController,

        // autofocus: true,
        decoration: InputDecoration(
          labelText: 'Cliente',
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _customerController.clear();
              if (_customerController.text.isNotEmpty) {
                // _addressesDropDownKey.currentWidget.;
                Navigator.pop(context);
                // _customerFocusNode.unfocus();
              }
            },
          ),
        ),
      ),
      mode: Mode.BOTTOM_SHEET,
      validator: (item) {
        if (item == null) return "Campo requerido";
      },
      // maxHeight: _size.width * 0.9,
      // dialogMaxWidth: _size.width * 0.8,
      isFilteredOnline: true,

      showClearButton: true,
      showSelectedItems: true,
      clearButton: const Icon(Icons.clear_rounded),
      compareFn: (item, selectedItem) => item?.name == selectedItem?.name,
      showSearchBox: true,
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Cliente :',
        labelStyle: TextStyle(color: _pc),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onFind: (String? filter) => CompaniesProvider.getCustomers(filter),
      onChanged: _customerSelection,
      selectedItem: orderBloc.getCustomer,
      popupItemBuilder: customPopupCustomerItemBuilder,
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  void _customerSelection(data) async {
    printConsole(data);
    if (data != null) {
      orderBloc.setCustomer(data);
      if (orderBloc.productsAdded.isNotEmpty) {
        final choice = await choiceAlert(
            context,
            'Se ha encontrado una lista de productos para el pedido existente,¿Que desea hacer?',
            'assets/images/warning.png',
            cancel: 'Borrar',
            confirm: 'Recalcular precios',
            skipeable: false);
        if (choice) {
          final status = await orderBloc.reloadProducts();
          if (!status) {
            confirmDialog(context, 'Error al recalcular precios',
                'assets/images/warning.png');
          }
        } else {
          orderBloc.emptyProductsAdded();
        }
      }
      orderBloc.setCustomerAddresses(null);
      _addressesDropDownKey.currentState?.changeSelectedItem(null);
      await Future.delayed(const Duration(milliseconds: 500));
      _addressesDropDownKey.currentState?.openDropDownSearch();
    } else {
      orderBloc.setCustomer(null);
      orderBloc.setCustomerAddresses(null);

      _addressesDropDownKey.currentState?.changeSelectedItem(null);

      // _addressesDropDownKey.currentState?.openDropDownSearch();

    }
  }

  // Widget _customerAddresses() {
  //   return FutureBuilder(
  //     future: CustomerAddressesProvider.selectDefaultAddrsToOrder(returnBool: true),
  //     builder: (BuildContext context, AsyncSnapshot snapshot) {
  //       if (snapshot.hasData) {
  //         return _customerAddressesDropDown();
  //       } else {
  //         return _customerAddressesDropDown();
  //       }
  //     },
  //   );
  // }

  Widget _customerAddressesDropDown() {
    return DropdownSearch<CustomerAddressesModel>(
      key: _addressesDropDownKey,
      searchFieldProps: TextFieldProps(
        controller: _customerAddrController,
        // autofocus: true,
        decoration: InputDecoration(
          // hintText: 'Sucursal de cliente',
          labelText: 'Sucursal de cliente',
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _customerController.clear();
              if (_customerController.text.isNotEmpty) {
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
      mode: Mode.BOTTOM_SHEET,
      maxHeight: _size.width * 0.9,
      dialogMaxWidth: _size.width * 0.8,
      isFilteredOnline: true,
      showClearButton: true,
      showSelectedItems: true,
      clearButton: const Icon(Icons.clear_rounded),
      compareFn: (item, selectedItem) =>
          item?.sucursal == selectedItem?.sucursal,
      showSearchBox: true,
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Sucursal de cliente :',
        labelStyle: TextStyle(color: _pc),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onFind: (String? filter) =>
          CustomerAddressesProvider.getDataAdrresesToOrder(filter),
      onChanged: _customerAddrSelection,
      selectedItem: orderBloc.getCustomerAddresses,
      popupItemBuilder: popupCustomerAddressesItemBuilder,
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  void _customerAddrSelection(data) {
    printConsole(data);

    orderBloc.setCustomerAddresses(data);
  }

  Widget _button() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AppButton(
          color: Colors.white,
          padding: kButtonPadding,
          // width: _size.width,
          onTap: () async {
            Navigator.pop(context);
            dataBloc.homeKey?.currentState?.changeBottomIndex(1);
          },
          child: Row(
            children: [
              const Icon(
                Icons.arrow_back_ios_rounded,
                color: pColor,
                size: kIconSize,
              ),
              Text(
                'Salir',
                style: buttonsSmallTextStyle(context, color: pColor),
              ),
            ],
          ),
        ),
        AppButton(
          color: Colors.white,
          // width: _size.width,
          padding: kButtonPadding,
          onTap: () async {
            // await CompaniesProvider.selectDefaultCustomer(
            //     fromOrderCreation: true);
            // await CustomerAddressesProvider.selectDefaultAddrs(
            //     fromOrderCreation: true);
            // if (orderBloc.getCustomer != null &&
            //     orderBloc.getCustomerAddresses != null) {
            //   const OrderProducts().launch(context);
            // }
            if (_formKey.currentState?.validate() ?? false) {
              const OrderProducts().launch(context);
            } else {
              if (orderBloc.getCustomer == null) {
                final customer =
                    await CompaniesProvider.selectDefaultCustomer();
                orderBloc.setCustomer(customer);
              }
              if (orderBloc.getCustomer != null) {
                orderBloc.setCustomerAddresses(
                    await CustomerAddressesProvider.selectDefaultAddrs(
                        orderBloc.getCustomer?.idCloud));
              }
              setState(() {});
              // if (_formKey.currentState?.validate() ?? false) {
              //   const SaleCart().launch(context);
              // }
            }
          },
          child: Text(
            'Añadir productos',
            style: buttonsSmallTextStyle(context, color: pColor),
          ),
        ),
      ],
    );
  }
}
