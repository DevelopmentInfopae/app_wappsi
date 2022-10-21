// ignore_for_file: implementation_imports, unused_field

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: unnecessary_import
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/suplier_bloc.dart';

import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/go_back_bottom.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/params/provider_form_params.dart';
// import 'package:pos_wappsi/params/regimen_person_type_form_params.dart';
import 'package:pos_wappsi/constant.dart';
// import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/cities_model.dart';
import 'package:pos_wappsi/models/countries_dart.dart';
import 'package:pos_wappsi/models/states_model.dart';
import 'package:pos_wappsi/providers/cities_provider.dart';
import 'package:pos_wappsi/providers/companies_provider.dart';
import 'package:pos_wappsi/providers/countries_provider.dart';
import 'package:pos_wappsi/providers/states_provider.dart';
import 'package:pos_wappsi/screens/customers/components/drop_down_s_item.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/screens/customers/new_customer_data3.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';
import 'package:pos_wappsi/utils/validation_encoding/reg_exp.dart';

class NewSupplierPage2 extends StatefulWidget {
  final bool backToHome;
  const NewSupplierPage2({Key? key, this.backToHome = true}) : super(key: key);

  @override
  _NewSupplierPage2State createState() => _NewSupplierPage2State();
}

class _NewSupplierPage2State extends State<NewSupplierPage2> {
  late Size _size;
  late Color _pc;

  TextEditingController personTypeController = TextEditingController();
  final _statesDropDownKey = GlobalKey<DropdownSearchState<StatesModel?>>();
  final _citiesDropDownKey = GlobalKey<DropdownSearchState<CitiesModel?>>();

  final FocusNode _e = FocusNode();
  final FocusNode _p = FocusNode();
  final FocusNode _d = FocusNode();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  CountriesModel? _country;
  StatesModel? _states;
  CitiesModel? _city;

  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  final bool _loading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    supplierBloc.getCustomer.customerPaymentType ??=
        supplierPayM['1']!.value.toString();
    _addressController.text = supplierBloc.getCustomer.address ?? '';
    _emailController.text = supplierBloc.getCustomer.email ?? '';
    _phoneController.text = supplierBloc.getCustomer.phone ?? '';
    super.initState();
  }

  @override
  void dispose() {
    personTypeController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pc = pColor;
    _size = MediaQuery.of(context).size;
    return Scaffold(appBar: _appBar(), key: _scaffoldKey, body: _body());
  }

  PreferredSize _appBar() {
    return appBar(
      context,
      'Agregar proveedor',
      image: 'assets/images/add-user.png',
    );
  }

  Widget _body() {
    return Column(
      children: [_form().expand(), bottom(_sendNewCustomer(), _pc, _size)],
    );
  }

  Widget _form() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Wrap(
            children: [
              _payMTypeDropdown().paddingSymmetric(vertical: 3),
              _countries().paddingSymmetric(vertical: 3),
              _state().paddingSymmetric(vertical: 3),
              _cities().paddingSymmetric(vertical: 3),
              _address().paddingSymmetric(vertical: 3),
              _email().paddingSymmetric(vertical: 3),
              _phone().paddingSymmetric(vertical: 3),
              // _direction().paddingSymmetric(vertical: 3)
            ],
          ),
        ),
      ),
    );
  }

  Widget _countries() {
    return SizedBox(
      height: dropDownHeight,
      child: FutureBuilder<CountriesModel?>(
        // load country if already defined in customerData, if not load default country
        future: supplierBloc.getCustomer.country == null
            ? CountriesProvider.defaultCountry()
            : CountriesProvider.loadCountry(supplierBloc.getCustomer.country!),
        builder:
            (BuildContext context, AsyncSnapshot<CountriesModel?> snapshot) {
          if (snapshot.hasData && _country == null) {
            _country = snapshot.data;
            supplierBloc.getCustomer.country = snapshot.data!.nombre;
            return _countriesDropdown();
          } else {
            return _countriesDropdown();
          }
        },
      ),
    );
  }

  Widget _state() {
    return SizedBox(
      height: dropDownHeight,
      child: FutureBuilder<StatesModel?>(
        //load state if already defined in customer data, if not load default state
        future: supplierBloc.getCustomer.state == null
            ? StatesProvider.defaultState()
            : StatesProvider.loadState(supplierBloc.getCustomer.state!),
        builder: (BuildContext context, AsyncSnapshot<StatesModel?> snapshot) {
          if (snapshot.hasData && _states == null && _country != null) {
            _states = snapshot.data;
            supplierBloc.getCustomer.state = snapshot.data!.departamento;
            return _statesDropdown();
          } else {
            return _statesDropdown();
          }
        },
      ),
    );
  }

  Widget _cities() {
    return SizedBox(
      height: dropDownHeight,
      child: FutureBuilder<CitiesModel?>(
        //load city if already defined in customer data, if not load default city
        future: supplierBloc.getCustomer.city == null
            ? CitiesProvider.defaultCity()
            : CitiesProvider.loadCity(supplierBloc.getCustomer.city!),
        builder: (BuildContext context, AsyncSnapshot<CitiesModel?> snapshot) {
          if (snapshot.hasData &&
              _city == null &&
              _states != null &&
              _country != null) {
            _city = snapshot.data;
            supplierBloc.getCustomer.city = snapshot.data!.descripcion;
            supplierBloc.getCustomer.cityCode = snapshot.data!.codigo;
            return _citiesDropdown();
          } else {
            return _citiesDropdown();
          }
        },
      ),
    );
  }

  Widget _payMTypeDropdown() {
    return SizedBox(
      height: dropDownHeight,
      child: DropdownSearch<DropdDownSItem>(
        mode: Mode.BOTTOM_SHEET,

        validator: (item) {
          if (item == null) return 'Campo requerido';
          return null;
        },

        // maxHeight: _size.width * 0.9,
        dialogMaxWidth: _size.width * 0.8,
        isFilteredOnline: true,
        // showClearButton: true,
        showSelectedItems: true,
        compareFn: (item, selectedItem) => item?.name == selectedItem?.name,
        items: supplierPayM.values.toList(),
        selectedItem:
            supplierPayM[supplierBloc.getCustomer.customerPaymentType ?? '1'],
        // selectedItem: _doc,
        dropdownSearchDecoration: InputDecoration(
          labelText: 'Tipo de pago del proveedor :',
          labelStyle: smallTextStyle(context, color: _pc),
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        ),

        autoValidateMode: AutovalidateMode.onUserInteraction,

        onChanged: (data) async {
          supplierBloc.getCustomer.customerPaymentType = data?.value.toString();
        },
        // selectedItem: posBloc.getCustomer,
        popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
        scrollbarProps: ScrollbarProps(
          isAlwaysShown: true,
          thickness: 7,
        ),
      ),
    );
  }

  Widget _countriesDropdown() {
    return DropdownSearch<CountriesModel>(
      searchFieldProps: TextFieldProps(
        controller: _countryController,
        // autofocus: true,
        decoration: InputDecoration(
          labelText: 'País',
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _countryController.clear();
              if (_countryController.text.isNotEmpty) {}
              Navigator.pop(context);
            },
          ),
        ),
      ),
      mode: Mode.BOTTOM_SHEET,
      validator: (item) {
        if (item == null) return 'Campo requerido';
        return null;
      },
      // maxHeight: _size.width * 0.9,
      dialogMaxWidth: _size.width * 0.8,
      isFilteredOnline: true,
      showClearButton: true,
      showSelectedItems: true,
      clearButton: const Icon(Icons.clear_rounded),
      compareFn: (item, selectedItem) => item?.nombre == selectedItem?.nombre,
      showSearchBox: true,
      selectedItem: _country,
      dropdownSearchDecoration: InputDecoration(
        labelText: 'País :',
        labelStyle: smallTextStyle(context, color: _pc),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onFind: (String? filter) => CountriesProvider.loadFromDB(search: filter),
      onChanged: (data) async {
        if (data != null) {
          _country = data;

          _statesDropDownKey.currentState?.changeSelectedItem(null);
          await Future.delayed(const Duration(milliseconds: 500));
          _statesDropDownKey.currentState?.openDropDownSearch();
        } else {
          _country = data;
          _statesDropDownKey.currentState?.changeSelectedItem(null);
        }
        supplierBloc.getCustomer.country = data?.nombre;
      },
      // selectedItem: posBloc.getCustomer,
      popupItemBuilder: _customPopupCountriesItemBuilder,
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget _customPopupCountriesItemBuilder(
    BuildContext context,
    CountriesModel? item,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: pColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(item?.nombre ?? ''),
        // leading: CircleAvatar(
        //   child: Image.asset('assets/images/global.png'),
        // ),
      ),
    );
  }

  Widget _statesDropdown() {
    return DropdownSearch<StatesModel>(
      key: _statesDropDownKey,
      searchFieldProps: TextFieldProps(
        controller: _stateController,
        // autofocus: true,
        decoration: InputDecoration(
          labelText: 'Departamento',
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _stateController.clear();
              if (_stateController.text.isNotEmpty) {
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
      mode: Mode.BOTTOM_SHEET,
      validator: (item) {
        if (item == null) return 'Campo requerido';
        return null;
      },
      // maxHeight: _size.width * 0.9,
      dialogMaxWidth: _size.width * 0.8,
      isFilteredOnline: true,
      showClearButton: true,
      showSelectedItems: true,
      clearButton: const Icon(Icons.clear_rounded),
      compareFn: (item, selectedItem) =>
          item?.departamento == selectedItem?.departamento,
      showSearchBox: true,
      selectedItem: _states,
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Departamento :',
        labelStyle: smallTextStyle(context, color: _pc),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onFind: (String? filter) =>
          StatesProvider.loadFromDB(search: filter, country: _country?.codigo),
      onChanged: (data) async {
        if (data != null) {
          _states = data;

          _citiesDropDownKey.currentState?.changeSelectedItem(null);
          await Future.delayed(const Duration(milliseconds: 500));
          _citiesDropDownKey.currentState?.openDropDownSearch();
        } else {
          _states = data;
          _citiesDropDownKey.currentState?.changeSelectedItem(null);
        }
        supplierBloc.getCustomer.state = data?.departamento;
      },
      // selectedItem: posBloc.getCustomer,
      popupItemBuilder: _customPopupStatesItemBuilder,
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),

      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget _customPopupStatesItemBuilder(
    BuildContext context,
    StatesModel item,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: pColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(item.departamento ?? ''),
        // leading: CircleAvatar(
        //   child: Image.asset('assets/images/map.png'),
        // ),
      ),
    );
  }

  Widget _citiesDropdown() {
    return DropdownSearch<CitiesModel>(
      key: _citiesDropDownKey,
      searchFieldProps: TextFieldProps(
        controller: _cityController,
        // autofocus: true,
        decoration: InputDecoration(
          labelText: 'Ciudad',
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _cityController.clear();
              if (_cityController.text.isNotEmpty) {
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
      mode: Mode.BOTTOM_SHEET,
      validator: (item) {
        if (item == null) return 'Campo requerido';
        return null;
      },
      // maxHeight: _size.width * 0.9,
      dialogMaxWidth: _size.width * 0.8,
      isFilteredOnline: true,
      showClearButton: true,
      showSelectedItems: true,
      clearButton: const Icon(Icons.clear_rounded),
      compareFn: (item, selectedItem) =>
          item?.descripcion == selectedItem?.descripcion,
      showSearchBox: true,
      selectedItem: _city,
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Ciudad :',
        labelStyle: smallTextStyle(context, color: _pc),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onFind: (String? filter) => CitiesProvider.loadFromDB(
        search: filter,
        departament: _states?.coddepartamento,
      ),
      onChanged: (data) async {
        _city = data;
        supplierBloc.getCustomer.city = data?.descripcion;
        supplierBloc.getCustomer.cityCode = data?.codigo;
      },
      // selectedItem: posBloc.getCustomer,
      popupItemBuilder: _customPopupCitiesItemBuilder,
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget _customPopupCitiesItemBuilder(
    BuildContext context,
    CitiesModel? item,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: pColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(item?.descripcion ?? ''),
        // leading: Image.asset('assets/images/city.png')
      ),
    );
  }

  Widget _email() {
    return textFormField(
      context,
      'Correo electrónico',
      (value) {
        supplierBloc.getCustomer.email = value;
      },
      (String? value) {
        if (value == null || value == '') {
          _e.requestFocus();
          return 'El campo es necesario';
        }
        if (!emailRegex.hasMatch(value)) {
          return 'Correo electrónico no valido';
        }
      },
      () {
        _p.requestFocus();
      },
      focus: _e,
      controller: _emailController,
      keyBType: TextInputType.emailAddress,
    ).paddingSymmetric(vertical: 5);
  }

  Widget _phone() {
    return textFormField(
      context,
      'Teléfono',
      (value) {
        supplierBloc.getCustomer.phone = value;
      },
      (String? value) {
        if (value == null || value == '') {
          _p.requestFocus();
          return 'El campo es necesario';
        }
        if (!isNumeric(value)) {
          return 'Teléfono no valido';
        }
      },
      () async {
        if (_formKey.currentState!.validate()) {
          await const NewCustomerData3().launch(context);
        }
      },
      focus: _p,
      controller: _phoneController,
      keyBType: TextInputType.phone,
    ).paddingSymmetric(vertical: 5);
  }

  Widget _address() {
    return textFormField(
      context,
      'Dirección',
      (value) {
        supplierBloc.getCustomer.address = value;
      },
      (String? value) {
        if (value == null || value == '') {
          _d.requestFocus();
          return 'El campo es necesario';
        }
      },
      () {
        final _currentFocus = FocusScope.of(context);
        _currentFocus.unfocus();
      },
      focus: _d,
      controller: _addressController,
    ).paddingSymmetric(vertical: 5);
  }

  Widget _sendNewCustomer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const GoBackBottom(),
        AppButton(
          child: Row(
            children: [
              Text(
                'Siguiente',
                style: buttonsSmallTextStyle(context, color: pColor),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: kIconSize,
                color: pColor,
              ),
            ],
          ),
          enabled: !_loading,
          onTap: () async {
            if (_formKey.currentState!.validate()) {
              await CompaniesProvider.createSupplier(
                context,
                backToHome: widget.backToHome,
              );
            }
          },
          color: Colors.white,
          padding: kButtonPadding,
          disabledColor: _pc,
        ),
      ],
    );
  }
}
