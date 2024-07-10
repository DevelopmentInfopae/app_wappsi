// import 'package:badges/badges.dart';
// ignore_for_file: body_might_complete_normally_nullable

import 'package:date_time_picker/date_time_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/purchases_bloc.dart';
import 'package:pos_wappsi/config/documents_types.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/documents_types_model.dart';
// import 'package:pos_wappsi/components/app_bar_leading.dart';
import 'package:pos_wappsi/providers/companies_provider.dart';
import 'package:pos_wappsi/providers/document_types_provider.dart';
import 'package:pos_wappsi/providers/purchase_provider.dart';
import 'package:pos_wappsi/screens/Purchases/purchase_products.dart';
// import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/screens/components/back_app_bar.dart';
import 'package:pos_wappsi/screens/components/basic_widgets.dart';
import 'package:pos_wappsi/screens/components/widgets.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
// import 'package:pos_wappsi/providers/suspended_sales_provider.dart';
import 'package:pos_wappsi/screens/sales/components/widgets.dart';
import 'package:pos_wappsi/screens/suppliers/new_supplier.dart';
// import 'package:pos_wappsi/screens/sales/suspended_sales.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';
// import 'package:pos_wappsi/utils/time_date_pickers/time_picker.dart';

class NewPurchase extends StatefulWidget {
  const NewPurchase({Key? key}) : super(key: key);

  @override
  _NewPurchaseState createState() => _NewPurchaseState();
}

class _NewPurchaseState extends State<NewPurchase> {
  late Size _size;
  late Color _pc;
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _consecutiveController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _customerAddrController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // final _customerDropDownKey = GlobalKey<DropdownSearchState<CompanyModel?>>();

  // final _customerFocusNode = FocusNode();
  @override
  void initState() {
    if (purchaseBloc.isDisposed) {
      purchaseBloc.reload();
    }

    if (purchaseBloc.getDate() != null) {
      _dateController.text = purchaseBloc.getDate()!;
    } else {
      String now = DateFormat('yyyy-MM-dd').format(DateTime.now());
      purchaseBloc.setDate(now);
      printConsole(purchaseBloc.getDate());
      _dateController.text = purchaseBloc.getDate() ?? now;
    }

    super.initState();
  }

  @override
  void dispose() {
    _customerController.dispose();
    _dateController.dispose();
    _customerAddrController.dispose();
    _consecutiveController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  bool refIsVal = false;
  bool cosSupIsVal = false;
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
        // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
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
        _userInfo().paddingBottom(8).expand(),
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
            _dateTimePicker().paddingSymmetric(vertical: 4),
            _supplierSelection().paddingSymmetric(vertical: 4),
            _document().paddingSymmetric(vertical: 4),
            _consecutive().paddingSymmetric(vertical: 4)
          ],
        ),
      ),
    );
  }

  DateTimePicker _dateTimePicker() {
    final now = DateTime.now();
    return DateTimePicker(
      type: DateTimePickerType.dateTime,
      firstDate: DateTime(2000),
      style: normalTextStyle(context),
      controller: _dateController,
      lastDate: DateTime(
        now.year + 1,
      ),
      dateLabelText: 'Fecha:',
      initialValue: null,
      // validator: (value) {
      //   if (value == null || value == '') {
      //     return 'Campo necesario';
      //   }
      // },
      onChanged: (String? value) async {
        if (value != null) {
          // final time = await selectTime(context);
          purchaseBloc.setDate(value);
        }
      },
    );
  }

  Widget _document() {
    return SizedBox(
      height: dropDownHeight,
      child: FutureBuilder(
        future: DocumentsTypesProvider.loadFromDB(module: purchaseDocModule),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<DocumentsTypes>> snapshot,
        ) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            purchaseBloc.setDocumentType(snapshot.data?.first);

            return _documentType(items: snapshot.data!);
          } else {
            return _documentType(items: []);
          }
        },
      ),
    );
  }

  Widget _documentType({List<DocumentsTypes> items = const []}) {
    return DropdownSearch<DocumentsTypes>(
      mode: Mode.BOTTOM_SHEET,
      validator: (item) {
        if (item == null) return 'Campo requerido';
        return null;
      },
      // key: _documentTypeKey,
      maxHeight: _size.width * 0.9,
      dialogMaxWidth: _size.width * 0.8,
      items: items,

      enabled: items.length > 1,
      isFilteredOnline: true,
      showClearButton: true,
      showSelectedItems: true,
      clearButton: const Icon(Icons.clear_rounded),
      compareFn: (item, selectedItem) => item?.nombre == selectedItem?.nombre,
      showSearchBox: false,

      dropdownSearchDecoration: InputDecoration(
        labelText: 'Tipo de documento :',
        labelStyle: const TextStyle(color: pColor),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      emptyBuilder: (context, searchEntry) => const Text(
        'No se encontraron documentos para realizar ventas POS',
        textAlign: TextAlign.center,
      ).center(),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (data) {
        // Environment().env!='DEV'?null:print(data);

        setState(() {
          purchaseBloc.setDocumentType(data);
        });
      },
      // selectedItem: ,
      selectedItem: purchaseBloc.getDocumentType,
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Row _supplierSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(height: dropDownHeight, child: _suppliersDropDown())
            .paddingRight(8)
            .expand(),
        AppButton(
          padding: kButtonPadding,
          shapeBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: BorderSide(color: greyMediumLight),
          ),
          width: 20,
          child: const Icon(
            Icons.add,
            size: kIconSize + 8,
            color: pColor,
          ),
          onTap: () {
            const NewSupplier(
              backToHome: false,
            ).launch(context);
          },
        )
      ],
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

  Widget _consecutive() {
    if (dataBloc.settings?['management_consecutive_suppliers'] == 0) {
      return textFormField(
        context,
        'Numero de referencia',
        (value) async {
          if (value != null && value != '') {
            if (isNumericInt(value)) {
              if (purchaseBloc.getSupplier?.idCloud != null && value != null) {
                final valRef = await PurchaseProvider.validateReference(
                  purchaseBloc.getDocumentType!.salesPrefix + '-' + value,
                  int.parse(purchaseBloc.getSupplier!.idCloud!),
                );
                setState(() {
                  refIsVal = valRef;
                });
                if (refIsVal) {
                  purchaseBloc.getPurchase?.referenceNo = value;
                }
              }
            } else {
              return 'Valor no valido';
            }
          }
        },
        (value) {
          if (value != null && value != '' && !isNumericInt(value)) {
            return 'El numero de referencia ingresado no es valido';
          }
          if (!refIsVal &&
              value != null &&
              value != '' &&
              purchaseBloc.getSupplier?.idCloud != null) {
            return 'El numero de referencia ya se encuentra uso';
          }
        },
        (value) {},
      );
    } else {
      return textFormField(
        context,
        'Consecutivo de proveedor',
        (value) async {
          if (value != null && value != '') {
            if (purchaseBloc.getSupplier?.idCloud != null) {
              final valRef = await PurchaseProvider.validateConsecutive(
                value,
                int.parse(purchaseBloc.getSupplier!.idCloud!),
              );
              setState(() {
                cosSupIsVal = valRef;
              });
              if (cosSupIsVal) {
                purchaseBloc.getPurchase?.consecutiveSupplier = value;
              }
            }
          } else {
            return 'Debe suministrar un valor valido';
          }
        },
        (value) {
          if (value == null || value == '') {
            return 'Debe ingresar el consecutivo del proveedor';
          }
          if (!cosSupIsVal && purchaseBloc.getSupplier?.idCloud != null) {
            return 'El consecutivo de proveedor ya se encuentra uso';
          }
        },
        (value) {},
      );
    }
  }

  PreferredSize _appBar() {
    return appBar(
      context,
      'Agregar compra',
      image: 'assets/images/cargo.png',
      // leading: _appBarLeading(),
      onPop: () {
        dataBloc.homeKey?.currentState?.changeBottomIndex(1);
        Navigator.pop(context);
      },
    );
  }

  Widget _suppliersDropDown() {
    return DropdownSearch<CompanyModel>(
      // key: _customerDropDownKey,
      // focusNode: _customerFocusNode,
      searchFieldProps: TextFieldProps(
        controller: _customerController,

        // autofocus: true,
        decoration: InputDecoration(
          labelText: 'Proveedor',
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _customerController.clear();
              if (_customerController.text.isEmpty) {
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
        labelText: 'Proveedor :',
        labelStyle: TextStyle(color: _pc),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onFind: (String? filter) => CompaniesProvider.getSuppliers(filter),
      onChanged: _customerSelection,
      selectedItem: purchaseBloc.getSupplier,
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
      purchaseBloc.setCustomer(data);
      purchaseBloc.getPurchase?.referenceNo = null;
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {});
    } else {
      purchaseBloc.setCustomer(null);
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
          // width: _size.width,
          padding: kButtonPadding,
          onTap: () async {
            if (_formKey.currentState?.validate() ?? false) {
              const PurchaseProducts().launch(context);
            }

            // await CompaniesProvider.selectDefaultCustomer(
            //     fromOrderCreation: true);
            // await CustomerAddressesProvider.selectDefaultAddrs(
            //     fromOrderCreation: true);
            // if (purchaseBloc.getSupplier != null) {
            // }
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
