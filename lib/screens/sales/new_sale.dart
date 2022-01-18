import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/basic_widgets.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/suspended_sale_model.dart';
import 'package:pos_wappsi/screens/sales/components/suspended_sales.dart';
import 'package:pos_wappsi/screens/sales/components/widgets.dart';

import 'package:pos_wappsi/screens/sales/sale_cart.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/utils/alerts.dart';

class NewSale extends StatefulWidget {
  NewSale({Key? key}) : super(key: key);

  @override
  _NewSaleState createState() => _NewSaleState();
}

class _NewSaleState extends State<NewSale> {
  late Size _size;
  late Color _pc;
  TextEditingController _customerController = new TextEditingController();
  TextEditingController _customerAddrController = new TextEditingController();

  final _addressesDropDownKey =
      GlobalKey<DropdownSearchState<CustomerAddressesModel?>>();
  // final _customerDropDownKey = GlobalKey<DropdownSearchState<CompanyModel?>>();

  // final _customerFocusNode = new FocusNode();

  @override
  void dispose() {
    _customerController.dispose();
    _customerAddrController.dispose();
    super.dispose();
  }

  Map user = dataBloc.userDataMap;

  @override
  Widget build(BuildContext context) {
    _pc = Theme.of(context).primaryColor;
    _size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async {
          dataBloc.homeKey.currentState?.changeBottomIndex(1);
          // print('here i am');
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
      padding: EdgeInsets.symmetric(horizontal: 15),
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
      leading: _appBarLeading().paddingRight(8),
      onPop: () {
        dataBloc.homeKey.currentState?.changeBottomIndex(1);
        Navigator.pop(context);
      },
    );
  }

  Widget _appBarLeading() {
    return FutureBuilder(
      future: SuspendedSales.loadAllSSales(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        int qtty = 0;
        try {
          qtty = snapshot.data.length;
        } catch (e) {
          print(e);
        }
        return SuspendedSalesIcon(
            quantity: qtty, suspendedSales: snapshot.data);
      },
    );
  }

  Widget _customers() {
    return FutureBuilder(
      future: CompanyModel.selectDefaultCustomer(returnBool: true),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
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
            icon: Icon(Icons.clear),
            onPressed: () {
              _customerController.clear();
              if (_customerController.text.length == 0) {
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
      clearButton: Icon(Icons.clear_rounded),
      compareFn: (item, selectedItem) => item?.name == selectedItem?.name,
      showSearchBox: true,
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Cliente :',
        labelStyle: TextStyle(color: _pc),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onFind: (String? filter) => CompanyModel.getCustomers(filter),
      onChanged: _customerSelection,
      selectedItem: posBloc.getCustomer,
      popupItemBuilder: customPopupCustomerItemBuilder,
      popupSafeArea: PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  void _customerSelection(data) async {
    print(data);
    if (data != null) {
      posBloc.setCustomer(data);
      if (posBloc.productsAdded.length > 0) {
        final choice = await choiceAlert(
            context,
            'Se ha encontrado una carrito de compras existente,¿Que desea hacer?',
            'assets/images/warning.png',
            cancel: 'Borrar',
            confirm: 'Recalcular precios',
            skipeable: false);
        if (choice) {
          final status = await posBloc.reloadProducts();
          if (!status) {
            confirmDialog(context, 'Error al recalcular precios',
                'assets/images/warning.png');
          }
        } else {
          posBloc.emptyProductsAdded();
        }
      }
      posBloc.setCustomerAddresses(null);
      _addressesDropDownKey.currentState?.changeSelectedItem(null);
      await Future.delayed(Duration(milliseconds: 500));
      _addressesDropDownKey.currentState?.openDropDownSearch();
    } else {
      posBloc.setCustomer(null);
      posBloc.setCustomerAddresses(null);

      _addressesDropDownKey.currentState?.changeSelectedItem(null);

      // _addressesDropDownKey.currentState?.openDropDownSearch();

    }
  }

  Widget _customerAddresses() {
    return FutureBuilder(
      future: CustomerAddressesModel.selectDefaultAddrs(returnBool: true),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
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
            icon: Icon(Icons.clear),
            onPressed: () {
              _customerController.clear();
              if (_customerController.text.length == 0) {
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
      clearButton: Icon(Icons.clear_rounded),
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
          CustomerAddressesModel.getDataAdrreses(filter),
      onChanged: _customerAddrSelection,
      selectedItem: posBloc.getCustomerAddresses,
      popupItemBuilder: popupCustomerAddressesItemBuilder,
      popupSafeArea: PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  void _customerAddrSelection(data) {
    print(data);
    if (data != null) {
      posBloc.setCustomerAddresses(data);
    } else {
      posBloc.setCustomerAddresses(null);
    }
  }

  Widget _button() {
    return AppButton(
      color: _pc,
      width: _size.width,
      onTap: () async {
        await CompanyModel.selectDefaultCustomer();
        await CustomerAddressesModel.selectDefaultAddrs();
        SaleCart().launch(context);
      },
      child: Text(
        'Añadir productos',
        style: buttonsTextStyle(context),
      ),
    );
  }
}
