// ignore_for_file: implementation_imports, unused_field
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
// import 'package:pos_wappsi/bloc/customer_bloc.dart';
// import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/suplier_bloc.dart';

import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/go_back_bottom.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/params/provider_form_params.dart';
import 'package:pos_wappsi/params/regimen_person_type_form_params.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/documentypes_model.dart';
import 'package:pos_wappsi/providers/companies_provider.dart';
import 'package:pos_wappsi/providers/documenttypes_provider.dart';
import 'package:pos_wappsi/screens/customers/components/drop_down_s_item.dart';
import 'package:pos_wappsi/screens/customers/components/functions.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/screens/suppliers/new_supplier_page2.dart';
// import 'package:pos_wappsi/screens/customers/new_costumer_data2.dart';
// import 'package:pos_wappsi/utils/alerts.dart';

class NewSupplier extends StatefulWidget {
  const NewSupplier({Key? key, this.backToHome = true}) : super(key: key);
  final bool backToHome;
  @override
  _NewSupplierState createState() => _NewSupplierState();
}

class _NewSupplierState extends State<NewSupplier> {
  late Size _size;
  late Color _pc;
  final TextEditingController _documentypeController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  final TextEditingController _documentNController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _name2Controller = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _lastName2Controller = TextEditingController();
  final TextEditingController _comercialNameController =
      TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final FocusNode _d = FocusNode();
  final FocusNode _n1 = FocusNode();
  final FocusNode _n2 = FocusNode();
  final FocusNode _ln1 = FocusNode();
  final FocusNode _ln2 = FocusNode();
  final FocusNode _cN = FocusNode();

  DocumentypeModel? _doc;

  String? _docNumError;

  final bool _loading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (supplierBloc.disposed) {
      supplierBloc.reload();
    }

    super.initState();
    supplierBloc.getCustomer.typePerson =
        supplierBloc.getCustomer.typePerson ?? personT['1']?.value;
    supplierBloc.getCustomer.supplierType =
        supplierBloc.getCustomer.supplierType ?? supplierType['1']?.value;
    supplierBloc.getCustomer.tipoRegimen =
        supplierBloc.getCustomer.tipoRegimen ?? regimenT['1']?.value;
    _nameController.text = supplierBloc.getCustomer.firstName ?? '';
    _name2Controller.text = supplierBloc.getCustomer.secondName ?? '';
    _lastNameController.text = supplierBloc.getCustomer.firstLastname ?? '';
    _lastName2Controller.text = supplierBloc.getCustomer.secondLastname ?? '';
    // _documentypeController.text = ;
    _documentNController.text = supplierBloc.getCustomer.vatNo ?? '';
    _comercialNameController.text = supplierBloc.getCustomer.company ?? '';
    _verificationCodeController.text =
        (getVerificationCode(_documentNController.text))['value'];
  }

  @override
  void dispose() {
    _d.dispose();
    _n1.dispose();
    _n2.dispose();
    _ln1.dispose();
    _ln2.dispose();
    _cN.dispose();
    _verificationCodeController.dispose();
    _nameController.dispose();
    _name2Controller.dispose();
    _lastNameController.dispose();
    _lastName2Controller.dispose();
    _documentNController.dispose();
    _documentypeController.dispose();
    _comercialNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pc = pColor;
    _size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        final _currentFocus = FocusScope.of(context);
        _currentFocus.unfocus();
        return true;
      },
      child: Scaffold(appBar: _appBar(), key: _scaffoldKey, body: _body()),
    );
  }

  PreferredSize _appBar() {
    return appBar(
      context,
      'Agregar Proveedor',
      back: true,
      image: 'assets/images/add-user.png',
      onPop: () {
        if (widget.backToHome) {
          dataBloc.homeKey?.currentState?.changeBottomIndex(1);
        }
        Navigator.pop(context);
      },
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
            _supplierType().paddingSymmetric(vertical: 3),
            _personTypeDropdown().paddingSymmetric(vertical: 3),
            _regimenTypeDropdown().paddingSymmetric(vertical: 3),
            _documents().paddingSymmetric(vertical: 3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _docNum().paddingRight(_doc?.nombre == 'NIT' ? 10 : 0).expand(),
                _doc?.nombre == 'NIT'
                    ? _verificationCode().withWidth(160)
                    : Container(),
              ],
            ).paddingSymmetric(vertical: 3),
            _comercialName(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _nameFirst().paddingRight(10).flexible(flex: 1),
                _nameSecond().flexible(flex: 1),
              ],
            ).paddingSymmetric(vertical: 3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _lastNm1().paddingRight(10).flexible(flex: 1),
                _lastNm2().flexible(flex: 1),
              ],
            ).paddingSymmetric(vertical: 3),
            // _lastNm1().paddingSymmetric(vertical: 3),
            // _lastNm2().paddingSymmetric(vertical: 3),
          ],
        ),
      ),
    );
  }

  Widget _personTypeDropdown() {
    return SizedBox(
      height: dropDownHeight,
      child: DropdownSearch<DropdDownSItem>(
        mode: Mode.BOTTOM_SHEET,
        validator: (item) {
          if (item == null) return 'Campo requerido';
          return null;
        },
        maxHeight: _size.width * 0.9,
        dialogMaxWidth: _size.width * 0.8,
        isFilteredOnline: true,
        // showClearButton: true,
        showSelectedItems: true,
        compareFn: (item, selectedItem) => item?.name == selectedItem?.name,
        items: (personT.values.toList()),
        selectedItem: personT[supplierBloc.getCustomer.typePerson ?? '1'],
        dropdownSearchDecoration: InputDecoration(
          labelText: 'Tipo de persona :',
          labelStyle: TextStyle(color: _pc),
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        ),

        autoValidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (data) async {
          setState(() {
            supplierBloc.getCustomer.typePerson = data?.value;
            // printConsole('here');
          });
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

  Widget _regimenTypeDropdown() {
    return SizedBox(
      height: 75,
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
        items: regimenT.values.toList(),
        selectedItem: regimenT[supplierBloc.getCustomer.tipoRegimen ?? '1'],
        // selectedItem: _doc,
        dropdownSearchDecoration: InputDecoration(
          labelText: 'Tipo de regimen :',
          labelStyle: TextStyle(color: _pc),
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        ),

        autoValidateMode: AutovalidateMode.onUserInteraction,

        onChanged: (data) async {
          supplierBloc.getCustomer.tipoRegimen = data?.value.toString();
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

  Widget _supplierType() {
    return SizedBox(
      height: dropDownHeight,
      child: DropdownSearch<DropdDownSItem>(
        mode: Mode.BOTTOM_SHEET,
        validator: (item) {
          if (item == null) return 'Campo requerido';
          return null;
        },
        maxHeight: _size.width * 0.9,
        dialogMaxWidth: _size.width * 0.8,
        isFilteredOnline: true,
        // showClearButton: true,
        showSelectedItems: true,
        compareFn: (item, selectedItem) => item?.name == selectedItem?.name,
        items: (supplierType.values.toList()),
        selectedItem:
            supplierType[supplierBloc.getCustomer.supplierType ?? '1'],
        dropdownSearchDecoration: InputDecoration(
          labelText: 'Tipo de proveedor:',
          labelStyle: TextStyle(color: _pc),
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        ),

        autoValidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (data) async {
          setState(() {
            supplierBloc.getCustomer.supplierType = data?.value;
            // printConsole('here');
          });
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

  Widget _nameFirst() {
    return textFormField(
      context,
      'Primer nombre',
      (value) {
        setState(() {
          supplierBloc.getCustomer.firstName = value;
        });
      },
      (String? value) {
        if (value == null || value == '') {
          _n1.requestFocus();
          return 'El campo es necesario';
        }
      },
      () {
        _n2.requestFocus();
      },
      focus: _n1,
      controller: _nameController,
      keyBType: TextInputType.name,
    ).paddingSymmetric(vertical: 5);
  }

  Widget _docNum() {
    return textFormField(
      context,
      'NIT/CC',
      (value) async {
        _docNumError = await _validateDocNum(value);

        final res = getVerificationCode(value);
        if (res['error']) {
          _documentNController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _documentNController.text.length,
          );
          _verificationCodeController.text = '';
        } else {
          setState(() {
            _verificationCodeController.text = res['value'];
            supplierBloc.getCustomer.vatNo = value;
            if (_doc?.nombre == 'NIT') {
              supplierBloc.getCustomer.digitoVerificacion = res['value'] ?? '';
            } else {
              supplierBloc.getCustomer.digitoVerificacion = '';
            }
          });
        }
      },
      (String? value) {
        try {
          int.parse(value!);
        } catch (e) {
          _d.requestFocus();
          return 'El valor suministrado no es valido';
        }
        if (_docNumError != null) {
          return _docNumError;
        }
      },
      () {
        _n1.requestFocus();
      },
      keyBType: TextInputType.number,
      focus: _d,
      controller: _documentNController,
    ).paddingSymmetric(vertical: 5);
  }

  Future<String?> _validateDocNum(String? value) async {
    if (value != null) {
      final res = await CompaniesProvider.verifyDocNum(value);
      if (res != null) {
        if (res['status'] == 0) {
          return 'Numero de documento registrado en cliente suspendido';
        } else {
          return 'Numero de documento registrado';
        }
      }
    }
    return null;
  }

  Widget _nameSecond() {
    return textFormField(
      context,
      'Segundo nombre',
      (value) {
        setState(() {
          supplierBloc.getCustomer.secondName = value;
        });
      },
      (value) {
        // if (value == null || value == '') {
        //   _n2.requestFocus();
        //   return 'El campo es necesario';
        // }
      },
      () {
        _ln1.requestFocus();
      },
      focus: _n2,
      controller: _name2Controller,
      keyBType: TextInputType.name,
    ).paddingSymmetric(vertical: 5);
  }

  Widget _verificationCode() {
    return textFormField(
      context,
      'Dígito verificación',
      (value) {},
      (value) {},
      () {},
      controller: _verificationCodeController,
      readOnly: true,
    ).paddingSymmetric(vertical: 5);
  }

  Widget _comercialName() {
    return textFormField(
      context,
      'Nombre comercial',
      (value) {
        setState(() {
          supplierBloc.getCustomer.company = value;
        });
      },
      (String? value) {
        if (value == null || value == '') {
          _cN.requestFocus();
          return 'El campo es necesario';
        }
      },
      () {
        _cN.requestFocus();
      },
      focus: _cN,
      controller: _comercialNameController,
    ).paddingSymmetric(vertical: 5);
  }

  Widget _lastNm1() {
    return textFormField(
      context,
      'Primer Apellido',
      (value) {
        setState(() {
          supplierBloc.getCustomer.firstLastname = value;
        });
      },
      (String? value) {
        if (value == null || value == '') {
          _ln1.requestFocus();
          return 'El campo es necesario';
        }
      },
      () {
        _ln2.requestFocus();
      },
      focus: _ln1,
      controller: _lastNameController,
      keyBType: TextInputType.name,
    ).paddingSymmetric(vertical: 5);
  }

  Widget _lastNm2() {
    return textFormField(
      context,
      'Segundo Apellido',
      (value) {
        setState(() {
          supplierBloc.getCustomer.secondLastname = value;
        });
      },
      (value) {
        // if (value == null || value == '') {
        //   _ln2.requestFocus();
        //   return 'El campo es necesario';
        // }
      },
      () {
        if (_formKey.currentState?.validate() ?? false) {
          // const NewSupplierData2().launch(context);
        }
      },
      focus: _ln2,
      controller: _lastName2Controller,
      keyBType: TextInputType.name,
    ).paddingSymmetric(vertical: 5);
  }

  Widget _documents() {
    return SizedBox(
      height: dropDownHeight,
      child: FutureBuilder(
        future: supplierBloc.getCustomer.tipoDocumento == null
            ? DocumentTypesProvider.defaultDocument()
            : DocumentTypesProvider.loadDocument(
                supplierBloc.getCustomer.tipoDocumento!,
              ),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && _doc == null) {
            _doc = snapshot.data;
            supplierBloc.getCustomer.tipoDocumento =
                snapshot.data.idCloud.toString();
            supplierBloc.getCustomer.documentCode =
                snapshot.data.codigoDoc.toString();
            return _documentDropdown();
          } else {
            return _documentDropdown();
          }
        },
      ),
    );
  }

  Widget _documentDropdown() {
    return DropdownSearch<DocumentypeModel>(
      searchFieldProps: TextFieldProps(
        controller: _documentypeController,
        // autofocus: true,
        decoration: InputDecoration(
          labelText: 'Tipo de documento',
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _documentypeController.clear();
              if (_documentypeController.text.isNotEmpty) {
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
      maxHeight: _size.width * 0.9,
      dialogMaxWidth: _size.width * 0.8,
      isFilteredOnline: true,
      // showClearButton: true,
      showSelectedItems: true,
      clearButton: const Icon(Icons.clear_rounded),
      compareFn: (item, selectedItem) => item?.nombre == selectedItem?.nombre,
      showSearchBox: true,
      selectedItem: _doc,
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Tipo de documento :',
        labelStyle: TextStyle(color: _pc),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onFind: (String? filter) =>
          DocumentTypesProvider.loadFromDB(search: filter),
      onChanged: (data) async {
        supplierBloc.getCustomer.tipoDocumento = data?.idCloud.toString();
        supplierBloc.getCustomer.documentCode = data?.codigoDoc.toString();

        setState(() {
          _doc = data;
        });
      },
      popupItemBuilder: _customPopupCustomerItemBuilder,
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget _customPopupCustomerItemBuilder(
    BuildContext context,
    DocumentypeModel? item,
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
        // leading: Image.asset('assets/images/id-card.png').paddingAll(5),
      ),
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
              : () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    NewSupplierPage2(backToHome: widget.backToHome)
                        .launch(context);
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
