import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/components/go_back_bottom.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/config/documents_types.dart';
import 'package:pos_wappsi/params/register_movements.dart';

import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/documents_types_model.dart';
import 'package:pos_wappsi/models/payment_methods_model.dart';
import 'package:pos_wappsi/providers/document_types_provider.dart';
import 'package:pos_wappsi/providers/payment_methods_provider.dart';
import 'package:pos_wappsi/providers/register_form_provider.dart';
import 'package:pos_wappsi/screens/cash_accounting/components/functions.dart';
import 'package:pos_wappsi/screens/cash_accounting/components/widgets.dart';
import 'package:pos_wappsi/screens/cash_accounting/print_movement.dart';
import 'package:pos_wappsi/screens/customers/components/drop_down_s_item.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/screens/home/home_screen.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
// import 'package:pos_wappsi/utils/alerts.dart';
import 'package:provider/provider.dart';

class RegisterMovementsForm extends StatefulWidget {
  const RegisterMovementsForm({Key? key}) : super(key: key);

  @override
  _RegisterMovementsFormType createState() => _RegisterMovementsFormType();
}

class _RegisterMovementsFormType extends State<RegisterMovementsForm> {
  late Size _size;

  late FocusNode _valueFocus;

  final _movementController = TextEditingController();

  // final _paymentOrigin = GlobalKey<DropdownSearchState<PaymentMethods?>>();
  // final _paymentDestiny = GlobalKey<DropdownSearchState<PaymentMethods?>>();
  // final _movementTypeKey = GlobalKey<DropdownSearchState>();
  // final _documentTypeKey = GlobalKey<DropdownSearchState<DocumentsTypes?>>();

  DocumentsTypes? documentMov;

  bool _sending = false;
  bool _originPaymentStatus = true;
  bool _destinyPaymentStatus = true;
  late RegisterFormProvider registerFormProvider;

  // ignore: prefer_final_fields
  TextEditingController _paymentMethodController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _valueFocus = FocusNode();
  }

  @override
  void dispose() {
    _valueFocus.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  // String _selectedMovement = '2';
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return _body();
  }

  Widget _body() {
    registerFormProvider = Provider.of<RegisterFormProvider>(context);
    return Column(
      children: [_form().expand(), _bottom()],
    );
  }

  Widget _form() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _registerMovementType()
              .paddingOnly(top: 10, left: 15, right: 15, bottom: 5),
          _documentMovement().paddingOnly(left: 15, right: 15, bottom: 5),
          _paymentMethodOrigin().paddingOnly(left: 15, right: 15, bottom: 5),
          _paymentMethodDestiny().paddingOnly(left: 15, right: 15),
          Form(
            key: registerFormProvider.formKey,
            child: registerInput(context, registerFormProvider, _valueFocus,
                action: 'movement',
                textAlign: TextAlign.left,
                label: 'Valor',
                autoFocus: false),
          ),
          _movementNote().paddingOnly(left: 15, right: 15, bottom: 5),
        ],
      ),
    );
  }

  Widget _registerMovementType() {
    return DropdownSearch<DropdDownSItem>(
      mode: Mode.BOTTOM_SHEET,
      validator: (item) {
        if (item == null) return "Campo requerido";
        return null;
      },
      // maxHeight: _size.height * 0.9,

      // dialogMaxWidth: _size.width * 0.8,
      isFilteredOnline: true,
      showClearButton: true,
      showSelectedItems: true,
      // key: _movementTypeKey,
      compareFn: (item, selectedItem) => item?.name == selectedItem?.name,
      items: registerMovements,
      // selectedItem: registerMovements
      //     .where(
      //         (element) => element.value == registerFormProvider.movementType)
      //     .first??null,
      // selectedItem: _doc,
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Tipo de movimiento :',
        labelStyle: const TextStyle(color: pColor),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),

      autoValidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (data) async {
        if (data != null) {
          final temp =
              await PaymentMethodsProvider.getPaymentMethods('efectivo');

          setState(() {
            registerFormProvider.movementType = data.value;
            if (data.value == '2' || data.value == '3') {
              registerFormProvider.paymentOrigin = temp.first;
              registerFormProvider.paymentDestiny = null;
              _originPaymentStatus = false;
              _destinyPaymentStatus = true;
              // _paymentDestiny.currentState?.changeSelectedItem(null);
            } else {
              registerFormProvider.paymentDestiny = temp.first;
              registerFormProvider.paymentOrigin = null;
              _originPaymentStatus = true;
              _destinyPaymentStatus = false;
              // _paymentOrigin.currentState?.changeSelectedItem(null);
            }
          });
        } else {
          setState(() {
            registerFormProvider.paymentOrigin = null;
            registerFormProvider.paymentDestiny = null;
            // _paymentOrigin.currentState?.changeSelectedItem(null);
            // _paymentDestiny.currentState?.changeSelectedItem(null);
          });
        }
      },
      // selectedItem: posBloc.getCustomer,
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget _paymentMethodOrigin() {
    return DropdownSearch<PaymentMethods>(
      searchFieldProps: TextFieldProps(
        controller: _paymentMethodController,
        decoration: InputDecoration(
          labelText: 'Forma de pago de origen',
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              if (_paymentMethodController.text.isNotEmpty) {
                Navigator.pop(context);
              }
              _paymentMethodController.clear();
            },
          ),
        ),
      ),
      // key: _paymentOrigin,
      enabled: _originPaymentStatus,
      mode: Mode.BOTTOM_SHEET,
      validator: (item) {
        if (item == null) return "Campo requerido";
        return null;
      },

      maxHeight: _size.width * 0.9,
      dialogMaxWidth: _size.width * 0.8,
      selectedItem: registerFormProvider.paymentOrigin,
      isFilteredOnline: true,
      showClearButton: true,
      showSelectedItems: true,
      clearButton: const Icon(Icons.clear_rounded),
      compareFn: (item, selectedItem) => item?.name == selectedItem?.name,
      showSearchBox: true,

      dropdownSearchDecoration: InputDecoration(
        labelText: 'Forma de pago de origen',
        labelStyle: const TextStyle(color: pColor),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      autoValidateMode: AutovalidateMode.onUserInteraction,

      onFind: (String? filter) =>
          PaymentMethodsProvider.getPaymentMethods(filter),
      onChanged: (data) {
        printConsole(data);

        setState(() {
          // posBloc.setPaymentMethod(data);
          registerFormProvider.paymentOrigin = data;
        });
      },
      // selectedItem: ,
      // selectedItem: posBloc.getPaymentMethod,
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget _paymentMethodDestiny() {
    return DropdownSearch<PaymentMethods>(
      searchFieldProps: TextFieldProps(
        controller: _paymentMethodController,
        decoration: InputDecoration(
          labelText: 'Forma de pago de destino',
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              if (_paymentMethodController.text.isNotEmpty) {
                Navigator.pop(context);
              }
              _paymentMethodController.clear();
            },
          ),
        ),
      ),
      mode: Mode.BOTTOM_SHEET,
      validator: (item) {
        if (item == null) return "Campo requerido";
        return null;
      },
      // key: _paymentDestiny,
      enabled: _destinyPaymentStatus,
      selectedItem: registerFormProvider.paymentDestiny,
      maxHeight: _size.width * 0.9,
      dialogMaxWidth: _size.width * 0.8,

      isFilteredOnline: true,
      showClearButton: true,
      showSelectedItems: true,
      clearButton: const Icon(Icons.clear_rounded),
      compareFn: (item, selectedItem) => item?.name == selectedItem?.name,
      showSearchBox: true,
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Forma de pago de destino',
        labelStyle: const TextStyle(color: pColor),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      autoValidateMode: AutovalidateMode.onUserInteraction,

      onFind: (String? filter) =>
          PaymentMethodsProvider.getPaymentMethods(filter),
      onChanged: (data) {
        printConsole(data);

        setState(() {
          registerFormProvider.paymentDestiny = data;
        });
      },
      // selectedItem: ,
      // selectedItem: posBloc.getPaymentMethod,
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget _documentMovement() {
    return FutureBuilder(
      future: DocumentsTypesProvider.loadFromDB(module: registerMovModule),
      builder:
          (BuildContext context, AsyncSnapshot<List<DocumentsTypes>> snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          documentMov = snapshot.data?.first;
          registerFormProvider.documentType = documentMov!.idCloud;
          if (snapshot.data!.length > 1) {
            return _documentType(registerFormProvider, items: snapshot.data!);
          } else {
            return Container();
          }
        } else {
          return _documentType(registerFormProvider, items: []);
        }
      },
    );
  }

  Widget _documentType(RegisterFormProvider registerFormProvider,
      {List<DocumentsTypes> items = const []}) {
    return DropdownSearch<DocumentsTypes>(
      mode: Mode.BOTTOM_SHEET,
      validator: (item) {
        if (item == null) return "Campo requerido";
        return null;
      },
      // key: _documentTypeKey,
      maxHeight: _size.width * 0.9,
      dialogMaxWidth: _size.width * 0.8,
      items: items,
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
        'No se encontraron documentos para realizar movimientos de caja',
        textAlign: TextAlign.center,
      ).center(),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (data) {
        // printConsole(data);

        setState(() {
          registerFormProvider.documentType = data!.idCloud;
        });
      },
      // selectedItem: ,
      selectedItem: documentMov,
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget _movementNote() {
    return textFormField(context, 'Nota de movimiento', (String value) {
      registerFormProvider.movementNote = value;
    }, () {}, () {}, controller: _movementController);
  }

  Map<String, dynamic> _validateFields() {
    if (registerFormProvider.movementType == '') {
      return {
        'error': true,
        'message': 'Debe seleccionar el tipo de movimiento'
      };
    } else if (registerFormProvider.documentType == '') {
      return {
        'error': true,
        'message': 'Debe seleccionar el tipo de documento para el movimiento'
      };
    } else if (registerFormProvider.paymentDestiny == null) {
      return {
        'error': true,
        'message': 'Debe seleccionar la forma de pago de destino'
      };
    } else if (registerFormProvider.paymentOrigin == null) {
      return {
        'error': true,
        'message': 'Debe seleccionar la forma de pago de origen'
      };
    } else {
      return {'error': false};
    }
  }

  Widget _bottom() => bottom(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const GoBackBottom(),
          AppButton(
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: kIconSize,
                  color: pColor,
                ),
                Text(
                  'Realizar movimiento',
                  style: buttonsSmallTextStyle(context, color: pColor),
                ),
              ],
            ),
            // color: ,
            padding: kButtonPadding,
            enabled: !_sending,
            onTap: () async {
              final temp = _validateFields();
              if (temp['error']) {
                confirmDialog(
                    context, temp['message'], 'assets/images/warning.png');
              } else {
                setState(() {
                  _sending = true;
                });
                final res = await sendRegisterAction(
                    context, registerFormProvider, _valueFocus,
                    action: 'movement');
                if (res != null) {
                  // Navigator.pop(context);
                  /// update JWT token
                  await dataBloc.refreshToken(context);

                  final Map<String, String> movementData = {
                    'date': res['date']??'',
                    'reference_no': res['reference_no']??'',
                    'biller_name': dataBloc.userData!.billerName,
                    'movement_type': registerMovements
                        .where((element) =>
                            element.value == registerFormProvider.movementType)
                        .first
                        .name,
                    'value': registerFormProvider.value,
                    'movement_note': registerFormProvider.movementNote ?? '',
                    'user_name': (dataBloc.userData?.firstName ?? '') +
                        (dataBloc.userData?.lastName ?? '')
                  };
                  WidgetsBinding.instance!.addPostFrameCallback((_) async {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                    await PrintMovement(
                      movementInfo: movementData,
                    ).launch(context);
                  });
                } else {
                  setState(() {
                    _sending = false;
                  });
                }
              }
            },
          ),
        ],
      ),
      pColor,
      _size);
}
