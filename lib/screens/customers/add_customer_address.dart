// ignore_for_file: implementation_imports, unused_field
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/customer_bloc.dart';

import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/go_back_bottom.dart';
import 'package:pos_wappsi/components/location/location_picker.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/cities_model.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/countries_dart.dart';
import 'package:pos_wappsi/models/documentypes_model.dart';
import 'package:pos_wappsi/models/states_model.dart';
import 'package:pos_wappsi/providers/cities_provider.dart';
import 'package:pos_wappsi/providers/countries_provider.dart';
import 'package:pos_wappsi/providers/customer_addresses_provider.dart';
import 'package:pos_wappsi/providers/states_provider.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';

import '../../utils/text_formating/functions.dart';
// import 'package:pos_wappsi/utils/alerts.dart';

class NewAddress extends StatefulWidget {
  const NewAddress({Key? key, required this.customer}) : super(key: key);
  final CompanyModel customer;
  @override
  _NewAddressState createState() => _NewAddressState();
}

class _NewAddressState extends State<NewAddress> {
  late Size _size;
  late Color _pc;

  final TextEditingController _documentNController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _sucursalController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  CountriesModel? _country;
  StatesModel? _states;
  CitiesModel? _citys;

  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  final _statesDropDownKey = GlobalKey<DropdownSearchState<StatesModel?>>();
  final _citiesDropDownKey = GlobalKey<DropdownSearchState<CitiesModel?>>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final FocusNode _direccionFocus = FocusNode();
  final FocusNode _sucursalFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  GeoPoint? geoLoc;

  DocumentypeModel? _doc;

  bool _loading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _sucursalController.text = customerBloc.getAddress.sucursal ?? '';
    _direccionController.text = customerBloc.getAddress.direccion ?? '';
    _emailController.text = customerBloc.getAddress.email ?? '';
    _phoneController.text = customerBloc.getAddress.phone ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _direccionFocus.dispose();
    _sucursalFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();

    _direccionController.dispose();
    _sucursalController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _documentNController.dispose();

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
      'Crear sucursal',
      back: true,
      image: 'assets/images/locations.png',
    );
  }

  Widget _body() {
    return Column(
      children: [_form().expand(), bottom(_customerConfig(), _pc, _size)],
    );
  }

  Widget _form() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Form(
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: ListView(
          children: [
            _countries().withHeight(75).paddingSymmetric(vertical: 2),
            _state().withHeight(75).paddingSymmetric(vertical: 2),
            _cities().withHeight(75).paddingSymmetric(vertical: 2),
            _locationSelector().paddingSymmetric(vertical: 4),
            _sucursal(),
            _direccion(),
            Row(
              children: [
                _email().flexible(flex: 2),
                _phone().flexible(flex: 1),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _countries() {
    return FutureBuilder<CountriesModel?>(
      // load country if already defined in customerdata, if not load default country
      future: customerBloc.getAddress.country != null
          ? CountriesProvider.loadCountry(customerBloc.getAddress.country!)
          : CountriesProvider.defaultCountry(),

      builder: (BuildContext context, AsyncSnapshot<CountriesModel?> snapshot) {
        if (snapshot.hasData && _country == null) {
          _country = snapshot.data;
          customerBloc.getAddress.country ??= snapshot.data!.nombre;
          return _countriesDropdown();
        } else {
          return _countriesDropdown();
        }
      },
    );
  }

  Widget _state() {
    return FutureBuilder<StatesModel?>(
      //load state if already defined in customer data, if not load default state
      future: customerBloc.getAddress.state != null
          ? StatesProvider.loadState(customerBloc.getAddress.state!)
          : StatesProvider.defaultState(),
      builder: (BuildContext context, AsyncSnapshot<StatesModel?> snapshot) {
        if (snapshot.hasData && _states == null && _country != null) {
          _states = snapshot.data;
          customerBloc.getAddress.state ??= snapshot.data!.departamento;
          return _statesDropdown();
        } else {
          return _statesDropdown();
        }
      },
    );
  }

  Widget _cities() {
    return FutureBuilder<CitiesModel?>(
      //load city if already defined in customer data, if not load default city
      future: customerBloc.getAddress.city != null
          ? CitiesProvider.loadCity(customerBloc.getAddress.city!)
          : CitiesProvider.defaultCity(),
      builder: (BuildContext context, AsyncSnapshot<CitiesModel?> snapshot) {
        if (snapshot.hasData &&
            _citys == null &&
            _states != null &&
            _country != null) {
          _citys = snapshot.data;
          customerBloc.getAddress.city ??= snapshot.data!.descripcion;
          customerBloc.getAddress.cityCode ??= snapshot.data!.codigo;

          return _citiesDropdown();
        } else {
          return _citiesDropdown();
        }
      },
    );
  }

  Widget _locationSelector() {
    return Row(
      children: [
        AppButton(
          // color: ,
          // width: double.infinity,
          padding: kButtonPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                customerBloc.getAddress.geoLocation != null
                    ? Icons.location_on_outlined
                    : Icons.add_location_outlined,
                size: kIconSize,
                color: pColor,
              ),
              Text(
                  customerBloc.getAddress.geoLocation != null
                      ? 'Lat:' +
                          roundDouble(
                                  customerBloc.getAddress.geoLocation!['lon'],
                                  3)
                              .toString() +
                          ', Lon:' +
                          roundDouble(
                                  customerBloc.getAddress.geoLocation!['lon'],
                                  3)
                              .toString()
                      : ' Añadir localización',
                  style: buttonsSmallTextStyle(context, color: pColor)),
            ],
          ),
          onTap: () async {
            _phoneFocus.unfocus();
            _direccionFocus.unfocus();
            _emailFocus.unfocus();
            _sucursalFocus.unfocus();
            await Future.delayed(const Duration(milliseconds: 500));
            await _getLocation();
          },
        ).paddingRight(10).expand(),
        Tooltip(
          message: 'Eliminar',
          child: AppButton(
            // color: greyLight,
            enabled: customerBloc.getAddress.geoLocation != null,
            color: cancelColor,
            disabledColor: grey,
            width: 35,
            child: const Icon(
              Icons.disabled_by_default_outlined,
              // size: kIconSize,
              color: Colors.white,
            ),
            padding: kButtonPadding,
            onTap: () async {
              setState(() {
                customerBloc.getAddress.geoLocation = null;
              });
            },
          ),
        ).paddingRight(4),
        Tooltip(
          message: 'Selecionar localización',
          child: AppButton(
            // color: greyLight,
            width: 35,
            child: Icon(
              customerBloc.getAddress.geoLocation != null
                  ? Icons.edit_location_alt_outlined
                  : Icons.add_location_alt_outlined,
              // size: kIconSize,
              color: pColor,
            ),
            padding: kButtonPadding,
            onTap: () async {
              await _getLocation();
            },
          ),
        ),
      ],
    );
  }

  Future<void> _getLocation() async {
    GeoPoint? result = await SearchLocationPage(
      geoLoc: customerBloc.getAddress.geoLocation != null
          ? GeoPoint.fromMap(customerBloc.getAddress.geoLocation!)
          : null,
    ).launch(context);
    if (result != null) {
      setState(() {
        customerBloc.getAddress.geoLocation = result.toMap();
      });
    }
  }

  Widget _countriesDropdown() {
    return DropdownSearch<CountriesModel>(
      searchFieldProps: TextFieldProps(
        controller: _countryController,
        // autofocus: true,
        decoration: InputDecoration(
          labelText: 'Pais',
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
        if (item == null) return "Campo requerido";
        return null;
      },
      maxHeight: _size.width * 0.9,
      dialogMaxWidth: _size.width * 0.8,
      isFilteredOnline: true,
      showClearButton: true,
      showSelectedItems: true,
      clearButton: const Icon(Icons.clear_rounded),
      compareFn: (item, selectedItem) => item?.nombre == selectedItem?.nombre,
      showSearchBox: true,
      selectedItem: _country,
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Pais :',
        labelStyle: TextStyle(color: _pc),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onFind: (String? filter) => CountriesProvider.loadFromDB(search: filter),
      onChanged: (data) async {
        if (data != null) {
          _statesDropDownKey.currentState?.changeSelectedItem(null);
          await Future.delayed(const Duration(milliseconds: 500));
          _statesDropDownKey.currentState?.openDropDownSearch();
        } else {
          customerBloc.getAddress.state = null;
          _statesDropDownKey.currentState?.changeSelectedItem(null);
        }
        _country = data;
        customerBloc.getAddress.country = _country?.nombre;
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
      BuildContext context, CountriesModel? item, bool isSelected) {
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
        if (item == null) return "Campo requerido";
        return null;
      },
      maxHeight: _size.width * 0.9,
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
        labelStyle: TextStyle(color: _pc),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onFind: (String? filter) =>
          StatesProvider.loadFromDB(search: filter, country: _country?.codigo),
      onChanged: (data) async {
        if (data != null) {
          _citiesDropDownKey.currentState?.changeSelectedItem(null);
          await Future.delayed(const Duration(milliseconds: 500));
          _citiesDropDownKey.currentState?.openDropDownSearch();
        } else {
          customerBloc.getAddress.city = null;
          _citiesDropDownKey.currentState?.changeSelectedItem(null);
        }
        _states = data;

        customerBloc.getAddress.state = _states?.departamento;
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
      BuildContext context, StatesModel item, bool isSelected) {
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
        if (item == null) return "Campo requerido";
        return null;
      },
      maxHeight: _size.width * 0.9,
      dialogMaxWidth: _size.width * 0.8,
      isFilteredOnline: true,
      showClearButton: true,
      showSelectedItems: true,
      clearButton: const Icon(Icons.clear_rounded),
      compareFn: (item, selectedItem) =>
          item?.descripcion == selectedItem?.descripcion,
      showSearchBox: true,
      selectedItem: _citys,
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Ciudad :',
        labelStyle: TextStyle(color: _pc),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onFind: (String? filter) => CitiesProvider.loadFromDB(
          search: filter, departament: _states?.coddepartamento),
      onChanged: (data) {
        _citys = data;
        customerBloc.getAddress.city = _citys?.descripcion;
        customerBloc.getAddress.cityCode = _citys?.codigo;
      },
      // selectedItem: posBloc.getCustomer,
      popupItemBuilder: _customPopupCitysItemBuilder,
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget _customPopupCitysItemBuilder(
      BuildContext context, CitiesModel? item, bool isSelected) {
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

  Widget _direccion() {
    return textFormField(context, 'Dirección', (value) {
      customerBloc.getAddress.direccion = value;
    }, (String? value) {
      if (value == null || value == '') {
        return 'El campo es necesario';
      }
    }, () {
      _emailFocus.requestFocus();
    }, focus: _direccionFocus, controller: _direccionController)
        .paddingSymmetric(vertical: 4);
  }

  Widget _sucursal() {
    return textFormField(context, 'Nombre de sucursal', (value) {
      customerBloc.getAddress.sucursal = value;
    }, (value) {
      if (value == null || value == '') {
        _sucursalFocus.requestFocus();
        return 'El campo es necesario';
      }
    }, () {
      _direccionFocus.requestFocus();
    }, focus: _sucursalFocus, controller: _sucursalController)
        .paddingSymmetric(vertical: 4);
  }

  Widget _phone() {
    return textFormField(
            context,
            'Telefono',
            (value) {
              customerBloc.getAddress.phone = value;
            },
            (String? value) {},
            () {
              _phoneFocus.unfocus();
            },
            focus: _phoneFocus,
            controller: _phoneController,
            keyBType: TextInputType.number)
        .paddingSymmetric(vertical: 4, horizontal: 2);
  }

  Widget _email() {
    return textFormField(
            context,
            'Email',
            (value) {
              customerBloc.getAddress.email = value;
            },
            (value) {},
            () {
              _phoneFocus.requestFocus();
            },
            focus: _emailFocus,
            controller: _emailController,
            keyBType: TextInputType.emailAddress)
        .paddingSymmetric(vertical: 4, horizontal: 2);
  }

  Widget _customerConfig() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const GoBackBottom(),
        AppButton(
          child: Row(
            children: [
              const Icon(
                Icons.add,
                size: kIconSize,
                color: pColor,
              ),
              Text(' Crear',
                  style: buttonsSmallTextStyle(context, color: pColor)),
            ],
          ),
          enabled: !_loading,
          onTap: _loading
              ? null
              : () async {
                  setState(() {
                    _loading = true;
                  });
                  if (_formKey.currentState?.validate() ?? false) {
                    await CustomerAddressesProvider.createAddress(
                        context, widget.customer);
                  }
                  setState(() {
                    _loading = true;
                  });
                },
          color: Colors.white,
          padding: kButtonPadding,
          disabledColor: _pc,
        ),
      ],
    );
  }
}
