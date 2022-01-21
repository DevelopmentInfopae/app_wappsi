// ignore_for_file: implementation_imports, unused_field

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/customer_bloc.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:nb_utils/src/extensions/widget_extensions.dart';

import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/customer_groups_model.dart';
import 'package:pos_wappsi/models/price_groups_model.dart';
import 'package:pos_wappsi/providers/companies_provider.dart';
import 'package:pos_wappsi/providers/customer_groups_provider.dart';
import 'package:pos_wappsi/providers/price_groups_provider.dart';
import 'package:pos_wappsi/screens/customers/add_favorites.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';

class NewCustomerData3 extends StatefulWidget {
  NewCustomerData3({Key? key}) : super(key: key);

  @override
  _NewCustomerData3State createState() => _NewCustomerData3State();
}

class _NewCustomerData3State extends State<NewCustomerData3> {
  late Size _size;
  late Color _pc;
  bool _adduUser = false;
  bool _addFavorites = false;

  TextEditingController _customerGroupController = new TextEditingController();
  TextEditingController _priceGroupController = new TextEditingController();

  CustomerGroupsModel? _customerGroup;
  PriceGroupsModel? _priceGroup;

  bool _loading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pc = Theme.of(context).primaryColor;
    _size = MediaQuery.of(context).size;
    return Scaffold(appBar: _appBar(), body: _body());
  }

  PreferredSize _appBar() {
    return appBar(context, 'Crear Cliente POS',
        image: 'assets/images/add-user.png');
  }

  Widget _body() {
    return Column(
      children: [_form().expand(), bottom(_customerConfig(), _pc, _size)],
    );
  }

  Widget _form() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Form(
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: ListView(
          children: [
            _priceGroups().paddingSymmetric(vertical: 3),
            _customerGroups().paddingSymmetric(vertical: 3),
            CheckboxListTile(
              value: _adduUser,
              title: Text('Crear usuario', style: normalTextStyle(context)),
              secondary: Icon(FontAwesomeIcons.userCheck, size: kIconSize),
              onChanged: (value) {
                setState(() {
                  _adduUser = !_adduUser;
                  if (!_adduUser) _addFavorites = false;
                });
              },
            ),
            _adduUser ? _user() : Container(),
            _adduUser ? _password() : Container(),
            CheckboxListTile(
              // contentPadding:,
              value: _addFavorites,
              title: Text('Añadir productos favoritos',
                  style: normalTextStyle(context)),
              secondary: Icon(FontAwesomeIcons.star, size: kIconSize),
              controlAffinity: ListTileControlAffinity.platform,
              onChanged: (value) {
                setState(() {
                  _addFavorites = !_addFavorites;

                  _adduUser = _addFavorites;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _customerConfig() {
    return AppButton(
      child: Text('Siguiente', style: buttonsTextStyle(context)),
      enabled: !_loading,
      onTap: _loading
          ? null
          : () async {
              if (_formKey.currentState?.validate() ?? false) {
                if (_addFavorites) {
                  final verifyUserN =
                      await customerBloc.verifyUserName(context);
                  if (verifyUserN) {
                    AddFavorites().launch(context);
                  }
                } else {
                  await CompaniesProvider.sendCustomerInfo(context);
                  await dataBloc.refreshToken(context);
                }
              }
            },
      color: _pc,
      disabledColor: _pc,
    ).withSize(width: _size.width);
  }

  Widget _customerGroups() {
    return FutureBuilder(
      // load customer group if already defined in customerdata, if not load default country
      future: customerBloc.getCustomer.customerGroupId == null
          ? null
          : CustomerGroupsProvider.loadCustomerGroup(
              customerBloc.getCustomer.customerGroupId!),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _customerGroup = snapshot.data;
          return _customersGroupDropdown();
        } else {
          return _customersGroupDropdown();
        }
      },
    );
  }

  Widget _customersGroupDropdown() {
    return DropdownSearch<CustomerGroupsModel>(
      searchFieldProps: TextFieldProps(
        controller: _customerGroupController,
        // autofocus: true,
        decoration: InputDecoration(
          labelText: 'Grupo de clientes',
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _customerGroupController.clear();
              if (_customerGroupController.text.length == 0) {}
              Navigator.pop(context);
            },
          ),
        ),
      ),
      mode: Mode.BOTTOM_SHEET,
      validator: (item) {
        if (item == null) return "Campo requerido";
      },
      maxHeight: _size.width * 0.9,
      dialogMaxWidth: _size.width * 0.8,
      isFilteredOnline: true,
      showClearButton: true,
      showSelectedItems: true,
      clearButton: Icon(Icons.clear_rounded),
      compareFn: (item, selectedItem) => item?.name == selectedItem?.name,
      showSearchBox: true,
      selectedItem: _customerGroup,
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Grupo de cliente :',
        labelStyle: TextStyle(color: _pc),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onFind: (String? filter) =>
          CustomerGroupsProvider.loadFromDB(search: filter),
      onChanged: (data) async {
        customerBloc.getCustomer.customerGroupId = data?.idCloud;
        customerBloc.getCustomer.customerGroupName = data?.name;
      },
      // selectedItem: posBloc.getCustomer,
      // popupItemBuilder: _customPopupCountriesItemBuilder,
      popupSafeArea: PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget _priceGroups() {
    return FutureBuilder(
      // load price group if already defined in customerdata, if not load default country
      future: customerBloc.getCustomer.priceGroupId == null
          ? null
          : PriceGroupsProvider.loadPriceGroup(
              customerBloc.getCustomer.priceGroupId!),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _priceGroup = snapshot.data;
          return _priceGroupsDropdown();
        } else {
          return _priceGroupsDropdown();
        }
      },
    );
  }

  Widget _priceGroupsDropdown() {
    return DropdownSearch<PriceGroupsModel>(
      searchFieldProps: TextFieldProps(
        controller: _priceGroupController,
        // autofocus: true,
        decoration: InputDecoration(
          labelText: 'Grupo de precios',
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _customerGroupController.clear();
              if (_customerGroupController.text.length == 0) {}
              Navigator.pop(context);
            },
          ),
        ),
      ),
      mode: Mode.BOTTOM_SHEET,
      validator: (item) {
        if (item == null) return "Campo requerido";
      },
      maxHeight: _size.width * 0.9,
      dialogMaxWidth: _size.width * 0.8,
      isFilteredOnline: true,
      showClearButton: true,
      showSelectedItems: true,
      clearButton: Icon(Icons.clear_rounded),
      compareFn: (item, selectedItem) => item?.name == selectedItem?.name,
      showSearchBox: true,
      selectedItem: _priceGroup,
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Grupo de precios :',
        labelStyle: TextStyle(color: _pc),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onFind: (String? filter) =>
          PriceGroupsProvider.loadFromDB(search: filter),
      onChanged: (data) async {
        customerBloc.getCustomer.priceGroupId = data?.idCloud;
        customerBloc.getCustomer.priceGroupName = data?.name;
      },
      // selectedItem: posBloc.getCustomer,
      // popupItemBuilder: _customPopupCountriesItemBuilder,
      popupSafeArea: PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget _user() {
    return textFormField(
      context,
      'Nombre de usuario',
      (value) {
        customerBloc.setUserName(value);
      },
      (String? value) {
        if ((value?.length ?? 0) == 0) {
          return 'Debe suministrar un nombre de usuario';
        }
      },
      () {},
    ).paddingSymmetric(vertical: 5);
  }

  Widget _password() {
    return textFormField(
      context,
      'Contraseña',
      (value) {
        customerBloc.setPassword(value);
      },
      (String? value) {
        if ((value?.length ?? 0) < 6) {
          return 'Contraseña valida';
        }
      },
      () {},
    ).paddingSymmetric(vertical: 5);
  }
}
