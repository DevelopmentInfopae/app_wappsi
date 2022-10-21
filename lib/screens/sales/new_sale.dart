// ignore_for_file: body_might_complete_normally_nullable

import 'package:badges/badges.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/basic_widgets.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/components/appbar_leading.dart';
import 'package:pos_wappsi/providers/companies_provider.dart';
import 'package:pos_wappsi/providers/customer_addresses_provider.dart';
import 'package:pos_wappsi/providers/suspended_sales_provider.dart';
import 'package:pos_wappsi/screens/sales/components/widgets.dart';

import 'package:pos_wappsi/screens/sales/sale_cart.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/screens/sales/suspended_sales.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

class NewSale extends StatefulWidget {
  const NewSale({Key? key}) : super(key: key);

  @override
  _NewSaleState createState() => _NewSaleState();
}

class _NewSaleState extends State<NewSale> {
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
    if (posBloc.isDisposed) {
      posBloc.reload();
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
        body: _body(),
      ),
    );
  }

  Widget _body() {
    return _form();
  }

  Widget _form() {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _userInfo().expand(),
        bottom(_button(), _pc, _size, elevation: true),
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
            _customers(),
            _customerAddresses(),
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
      'Venta POS',
      image: 'assets/images/add-to-cart.png',
      leading: _appBarLeading(),
      onPop: () {
        dataBloc.homeKey?.currentState?.changeBottomIndex(1);
        Navigator.pop(context);
      },
    );
  }

  Widget _appBarLeading() {
    return FutureBuilder(
      future: SuspendedSalesProvider.loadAllSSales(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        int qtty = 0;
        try {
          qtty = snapshot.data.length;
        } catch (e) {
          printConsole(e);
        }
        return AppBarLeading(
          onTap: () => SuspendedSalesScreen(suspendedSales: snapshot.data)
              .launch(context),
          widget: Badge(
            badgeColor: Colors.red,
            // padding: EdgeInsets.all(6),
            alignment: Alignment.center,
            position: BadgePosition.topEnd(),
            badgeContent: Text(
              qtty.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            child: Icon(
              FontAwesomeIcons.moon,
              size: leadingIconSize,
              color: pColor,
            ),
          ),
        );
      },
    );
  }

  Widget _customers() {
    return FutureBuilder(
      future: CompaniesProvider.selectDefaultCustomer(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (posBloc.getCustomer == null) {
            posBloc.setCustomer(snapshot.data);
          }
          return _customersDropDown();
        } else {
          return _customersDropDown();
        }
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
              if (_customerController.text.isEmpty) {
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
        if (item == null) return 'Campo requerido';
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
      selectedItem: posBloc.getCustomer,
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
      posBloc.setCustomer(data);
      if (posBloc.productsAdded.isNotEmpty) {
        final choice = await choiceAlert(
          context,
          'Se ha encontrado una carrito de compras existente,¿Que desea hacer?',
          'assets/images/warning.png',
          cancel: 'Borrar',
          confirm: 'Calcular precios nuevamente',
          skipeable: false,
        );
        if (choice) {
          final status = await posBloc.reloadAllProducts();
          if (!status) {
            confirmDialog(
              context,
              'Error al calcular precios',
              'assets/images/warning.png',
            );
          }
        } else {
          posBloc.emptyProductsAdded();
        }
      }
      posBloc.setCustomerAddresses(null);
      final addresses = await CustomerAddressesProvider.getDataAdrreses(
        '',
        posBloc.getCustomerId(),
      );
      if (addresses.length == 1) {
        setState(() {
          posBloc.setCustomerAddresses(addresses.first);
        });
      } else {
        _addressesDropDownKey.currentState?.changeSelectedItem(null);
        await Future.delayed(const Duration(milliseconds: 500));
        _addressesDropDownKey.currentState?.openDropDownSearch();
      }
    } else {
      posBloc.setCustomer(null);
      posBloc.setCustomerAddresses(null);

      _addressesDropDownKey.currentState?.changeSelectedItem(null);

      // _addressesDropDownKey.currentState?.openDropDownSearch();

    }
  }

  Widget _customerAddresses() {
    return FutureBuilder(
      future: CustomerAddressesProvider.selectDefaultAddrs(
        posBloc.getCustomer?.idCloud,
      ),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (posBloc.getCustomerAddresses == null) {
            posBloc.setCustomerAddresses(snapshot.data);
          }
          return _customerAddressesDropDown();
        } else {
          return _customerAddressesDropDown();
        }
      },
    );
  }

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
              if (_customerController.text.isEmpty) {
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
      onFind: (String? filter) => CustomerAddressesProvider.getDataAdrreses(
        filter,
        posBloc.getCustomerId(),
      ),
      onChanged: _customerAddrSelection,
      validator: (value) {
        if (value == null) {
          return 'Campo requerido';
        }
      },
      selectedItem: posBloc.getCustomerAddresses,
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
    if (data != null) {
      posBloc.setCustomerAddresses(data);
    } else {
      posBloc.setCustomerAddresses(null);
    }
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
          padding: kButtonPadding,
          // width: _size.width,
          onTap: () async {
            if (_formKey.currentState?.validate() ?? false) {
              const SaleCart().launch(context);
            } else {
              if (posBloc.getCustomer == null) {
                final customer =
                    await CompaniesProvider.selectDefaultCustomer();
                posBloc.setCustomer(customer);
              }
              if (posBloc.getCustomer != null) {
                posBloc.setCustomerAddresses(
                  await CustomerAddressesProvider.selectDefaultAddrs(
                    posBloc.getCustomer?.idCloud,
                  ),
                );
              }
              setState(() {});
              // if (_formKey.currentState?.validate() ?? false) {
              //   const SaleCart().launch(context);
              // }
            }
          },
          child: Row(
            children: [
              const Icon(Icons.add, color: pColor, size: kIconSize),
              Text(
                'Añadir productos',
                style: buttonsSmallTextStyle(context, color: pColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
