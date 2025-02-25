// ignore_for_file: implementation_imports, unused_field

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
// import 'package:place_picker/entities/location_result.dart';
// import 'package:place_picker/place_picker.dart';
import 'package:pos_wappsi/bloc/customer_bloc.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/customer_groups_model.dart';
import 'package:pos_wappsi/models/price_groups_model.dart';
import 'package:pos_wappsi/providers/companies_provider.dart';
import 'package:pos_wappsi/providers/customer_groups_provider.dart';
import 'package:pos_wappsi/providers/price_groups_provider.dart';
// import 'package:nb_utils/src/extensions/widget_extensions.dart';

import 'package:pos_wappsi/screens/components/back_app_bar.dart';
import 'package:pos_wappsi/screens/components/go_back_bottom.dart';
// import 'package:pos_wappsi/components/image_file.dart';
import 'package:pos_wappsi/screens/components/image_preview.dart';
import 'package:pos_wappsi/screens/components/widgets.dart';
import 'package:pos_wappsi/screens/customers/add_favorites.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/utils/alerts.dart';

class NewCustomerData3 extends StatefulWidget {
  const NewCustomerData3({Key? key}) : super(key: key);

  @override
  _NewCustomerData3State createState() => _NewCustomerData3State();
}

class _NewCustomerData3State extends State<NewCustomerData3> {
  late Size _size;
  late Color _pc;
  bool _addUser = false;
  bool _addFavorites = false;

  final TextEditingController _customerGroupController =
      TextEditingController();
  final TextEditingController _priceGroupController = TextEditingController();

  CustomerGroupsModel? _customerGroup;
  PriceGroupsModel? _priceGroup;

  final FocusNode _unameFocus = FocusNode();
  final FocusNode _passwdFocus = FocusNode();

  // ignore: prefer_final_fields
  bool _loading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _unameFocus.dispose();
    _passwdFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pc = pColor;
    _size = MediaQuery.of(context).size;
    return Scaffold(appBar: _appBar(), body: _body());
  }

  PreferredSize _appBar() {
    return appBar(
      context,
      'Crear Cliente POS',
      image: 'assets/images/add-user.png',
    );
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
            dataBloc.settings?['prioridad_precios_producto'] == 10
                ? Container()
                : _priceGroups().paddingSymmetric(vertical: 3),
            _customerGroups().paddingSymmetric(vertical: 3),
            _createCustomerUserCheck(),
            _addUser ? _user() : Container(),
            _addUser ? _password() : Container(),
            _addFavoritesCheck(),
            _customerImage().paddingSymmetric(vertical: 3),
            _locationSelector().paddingSymmetric(vertical: 3),
          ],
        ),
      ),
    );
  }

  Widget _customerImage() {
    // String imName = '';
    // if (customerBloc.getImagePath != null) {
    //   final temp = customerBloc.getImagePath!.split('/');
    //   imName = temp.last;
    // }
    return Row(
      children: [
        AppButton(
          // color: ,
          // width: double.infinity,
          padding: kButtonPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: customerBloc.getImagePath == null
                ? [
                    const Icon(
                      Icons.add,
                      // size: kIconSize,
                      color: pColor,
                    ),
                    Text(
                      ' Seleccionar Imagen',
                      style: buttonsSmallTextStyle(context, color: pColor),
                    ),
                  ]
                : [
                    const Icon(
                      Icons.remove_red_eye_outlined,
                      size: kIconSize,
                      color: pColor,
                    ),
                    Text(
                      ' Ver imagen seleccionada',
                      style: buttonsSmallTextStyle(context, color: pColor),
                    ),
                  ],
          ),
          onTap: () async {
            _passwdFocus.unfocus();
            _unameFocus.unfocus();
            if (customerBloc.getImagePath != null) {
              ImagePreview(imagePath: customerBloc.getImagePath!)
                  .launch(context);
            } else {
              final image = await imagePickerDialog(context);
              if (image != null) {
                setState(() {
                  customerBloc.setImage(image.path);
                });
              }
            }
          },
        ).paddingRight(10).expand(),
        Tooltip(
          message: 'Eliminar',
          child: AppButton(
            // color: greyLight,
            enabled: customerBloc.getImagePath != null,
            disabledColor: grey,
            color: cancelColor,
            width: 35,
            child: const Icon(
              Icons.disabled_by_default_outlined,
              // size: kIconSize,
              color: Colors.white,
            ),
            padding: kButtonPadding,
            onTap: () async {
              setState(() {
                customerBloc.setImage(null);
              });
            },
          ),
        ).paddingRight(4),
        Tooltip(
          message: 'Editar',
          child: AppButton(
            // color: greyLight,
            width: 35,
            child: Icon(
              (customerBloc.getImagePath == null
                  ? Icons.add_a_photo_outlined
                  : Icons.edit_outlined),
              // size: kIconSize,
              color: pColor,
            ),
            padding: kButtonPadding,
            onTap: () async {
              final image = await imagePickerDialog(context);
              if (image != null) {
                setState(() {
                  customerBloc.setImage(image.path);
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _locationSelector() {
    return Row(
      children: const [
        // AppButton(
        //   // color: ,
        //   // width: double.infinity,
        //   padding: kButtonPadding,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     children: [
        //       Icon(
        //         customerBloc.getLocation != null
        //             ? Icons.location_on_outlined
        //             : Icons.add_location_outlined,
        //         size: kIconSize,
        //         color: pColor,
        //       ),
        //       Text(
        //         customerBloc.getLocation != null
        //             ? 'Lat: ' +
        //                 roundDouble(customerBloc.getLocation!.latitude, 3)
        //                     .toString() +
        //                 ', Lon: ' +
        //                 roundDouble(customerBloc.getLocation!.longitude, 3)
        //                     .toString()
        //             : ' Añadir localización',
        //         style: buttonsSmallTextStyle(context, color: pColor),
        //       ),
        //     ],
        //   ),
        //   onTap: () async {
        //     _passwdFocus.unfocus();
        //     _unameFocus.unfocus();
        //     await Future.delayed(const Duration(milliseconds: 500));
        //     if (customerBloc.getLocation != null) {
        //       await _getLocation();
        //     } else {
        //       await _getLocation();
        //     }
        //   },
        // ).paddingRight(10).expand(),
        // Tooltip(
        //   message: 'Eliminar',
        //   child: AppButton(
        //     // color: greyLight,
        //     enabled: customerBloc.getLocation != null,
        //     color: cancelColor,
        //     disabledColor: grey,
        //     width: 35,
        //     child: const Icon(
        //       Icons.disabled_by_default_outlined,
        //       // size: kIconSize,
        //       color: Colors.white,
        //     ),
        //     padding: kButtonPadding,
        //     onTap: () async {
        //       // setState(() {
        //       //   customerBloc.setLocation(null);
        //       // });
        //     },
        //   ),
        // ).paddingRight(4),
        // Tooltip(
        //   message: 'Seleccionar localización',
        //   child: AppButton(
        //     // color: greyLight,
        //     width: 35,
        //     child: Icon(
        //       customerBloc.getLocation != null
        //           ? Icons.edit_location_alt_outlined
        //           : Icons.add_location_alt_outlined,
        //       // size: kIconSize,
        //       color: pColor,
        //     ),
        //     padding: kButtonPadding,
        //     onTap: () async {
        //       // if (customerBloc.getLocation != null) {
        //       //   await _getLocation();
        //       // } else {
        //       //   await _getLocation();
        //       // }
        //     },
        //   ),
        // ),
      ],
    );
  }

  Future<void> _getLocation() async {
    // GeoPoint? result = await SearchLocationPage(
    //   geoLoc: customerBloc.getLocation,
    // ).launch(context);
    // if (result != null) {
    //   setState(() {
    //     customerBloc.setLocation(result);
    //   });
    // }
  }

  CheckboxListTile _createCustomerUserCheck() {
    return CheckboxListTile(
      value: _addUser,
      title: Text('Crear usuario', style: normalTextStyle(context)),
      secondary: const Icon(FontAwesomeIcons.userCheck, size: kIconSize),
      onChanged: (value) {
        setState(() {
          _addUser = !_addUser;
          if (!_addUser) _addFavorites = false;
        });
      },
    );
  }

  CheckboxListTile _addFavoritesCheck() {
    return CheckboxListTile(
      // contentPadding:,
      value: _addFavorites,
      title:
          Text('Añadir productos favoritos', style: normalTextStyle(context)),
      secondary: const Icon(FontAwesomeIcons.star, size: kIconSize),
      controlAffinity: ListTileControlAffinity.platform,
      onChanged: (value) {
        setState(() {
          _addFavorites = !_addFavorites;

          _addUser = _addFavorites;
        });
      },
    );
  }

  Widget _customerConfig() {
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
          onTap: _loading
              ? null
              : () async {
                  setState(() {
                    _loading = true;
                  });
                  if (_formKey.currentState?.validate() ?? false) {
                    if (_addFavorites) {
                      final verifyUserN =
                          await customerBloc.verifyUserName(context);
                      if (!verifyUserN) {
                        const AddFavorites().launch(context);
                      }
                    } else {
                      await CompaniesProvider.sendCustomerInfo(context);
                      await dataBloc.refreshToken(context);
                    }
                    setState(() {
                      _loading = false;
                    });
                  } else {
                    setState(() {
                      _loading = false;
                    });
                  }
                },
          color: Colors.white,
          padding: kButtonPadding,
          disabledColor: _pc,
        ),
      ],
    );
  }

  Widget _customerGroups() {
    return FutureBuilder(
      // load customer group if already defined in customerData, if not load default country
      future: customerBloc.getCustomer.customerGroupId == null
          ? null
          : CustomerGroupsProvider.loadCustomerGroup(
              customerBloc.getCustomer.customerGroupId!,
            ),
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
            icon: const Icon(Icons.clear),
            onPressed: () {
              _customerGroupController.clear();
              if (_customerGroupController.text.isNotEmpty) {}
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

      maxHeight: _size.width * 0.9,
      dialogMaxWidth: _size.width * 0.8,
      isFilteredOnline: true,
      showClearButton: true,
      showSelectedItems: true,
      clearButton: const Icon(Icons.clear_rounded),
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
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget _priceGroups() {
    return FutureBuilder(
      // load price group if already defined in customerData, if not load default country
      future: customerBloc.getCustomer.priceGroupId == null
          ? null
          : PriceGroupsProvider.loadPriceGroup(
              customerBloc.getCustomer.priceGroupId!,
            ),
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
            icon: const Icon(Icons.clear),
            onPressed: () {
              _customerGroupController.clear();
              if (_customerGroupController.text.isNotEmpty) {}
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
      maxHeight: _size.width * 0.9,
      dialogMaxWidth: _size.width * 0.8,
      isFilteredOnline: true,
      showClearButton: true,
      showSelectedItems: true,
      clearButton: const Icon(Icons.clear_rounded),
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
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
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
      () {
        _passwdFocus.requestFocus();
      },
      focus: _unameFocus,
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
      () {
        _passwdFocus.unfocus();
      },
      focus: _passwdFocus,
    ).paddingSymmetric(vertical: 5);
  }
}
