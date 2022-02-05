// ignore_for_file: unnecessary_null_comparison

// import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
// import 'package:pos_wappsi/bloc/sync_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/input_decoration.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/config/pos_params.dart';
import 'package:pos_wappsi/config/documents_types.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/documents_types_model.dart';
// import 'package:pos_wappsi/models/documents_types_model.dart';
import 'package:pos_wappsi/models/payment_methods_model.dart';
import 'package:pos_wappsi/providers/pos_sale_provider.dart';
import 'package:pos_wappsi/providers/document_types_provider.dart';
import 'package:pos_wappsi/providers/payment_methods_provider.dart';
// import 'package:pos_wappsi/providers/sync_db_provider.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
// import 'package:pos_wappsi/screens/db_sync/components/sync_popup.dart';

import 'package:pos_wappsi/screens/home/home_screen.dart';
// import 'package:pos_wappsi/screens/home/home_screen.dart';
import 'package:pos_wappsi/screens/sales/components/widgets.dart';
import 'package:pos_wappsi/screens/sales/print_sale.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
import 'package:pos_wappsi/utils/text_formating/currency_formater.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

class SalePayment extends StatefulWidget {
  const SalePayment({Key? key}) : super(key: key);

  @override
  _SalePaymentState createState() => _SalePaymentState();
}

class _SalePaymentState extends State<SalePayment> {
  late Color _pc;
  late TextTheme _textTheme;
  final int _paymentM = 1;
  int _valueP = 0;
  // PaymentMethods? _payment;
  // DocumentsTypes? _pDoc;

  int _count50000 = 0;
  int _count5000 = 0;
  int _count10000 = 0;
  int _count20000 = 0;

  // to disable paybutton when awaiting for response
  bool _sending = false;

  final TextEditingController _paymentMethodController = TextEditingController();
  // TextEditingController _paymentDocumentController =
  //     TextEditingController();

  late Size _size;

  final GlobalKey<FormState> _inputsKey = GlobalKey<FormState>();

  final TextEditingController _valuePController = TextEditingController();
  final TextEditingController _paymentTermController = TextEditingController();
  final TextEditingController _invoiceNController = TextEditingController();
  final TextEditingController _dispatchNController = TextEditingController();
  @override
  void initState() {
    //load info if has value
    if (posBloc.getPaymentValue != null) {
      final value =
          getFormatedCurrency(posBloc.getPaymentValue?.toDouble() ?? 0.0);
      _valuePController.text = posBloc.getPaymentValue == 0
          ? ''
          : value.substring(0, value.length - 3);

      _paymentTermController.text = (posBloc.getPaymentTerm ?? '').toString();
      _valueP = posBloc.getPaymentValue!;
    }

    if (posBloc.getPaymentDocument != null) {
      // _pDoc = posBloc.getPaymentDocument;
    }

    if (posBloc.getInvoiceNote != null) {
      _invoiceNController.text = posBloc.getInvoiceNote!;
    }
    if (posBloc.getDispatchNote != null) {
      _dispatchNController.text = posBloc.getDispatchNote!;
    }
    super.initState();
  }

  @override
  void dispose() {
    _paymentMethodController.dispose();
    _valuePController.dispose();
    _invoiceNController.dispose();
    _dispatchNController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _pc = pColor;
    _textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar:
          appBar(context, 'Venta POS', image: 'assets/images/add-to-cart.png'),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        _form().expand(),
        _moneyBack(),
        bottom(_sendAndPrint(), _pc, _size),
      ],
    );
  }

  Widget _form() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: [
          _productsInfo().paddingSymmetric(vertical: 6),
          _paymentMethod().paddingSymmetric(vertical: 6),
          _documentPOS().paddingSymmetric(vertical: 6),
          _inputs(),
          _invoiceNote().paddingSymmetric(vertical: 6),
          _dispatchNote().paddingSymmetric(vertical: 6)
        ],
      ),
    );
  }

  Widget _productsInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: 'Numero de productos: ',
              style:  buttonsSmallTextStyle(context).apply(color: _pc),
              children: [
                TextSpan(
                    text: '${posBloc.getProductsCount()}',
                    style: _textTheme.headline6)
              ]),
          // style: textTheme,
        ),
        RichText(
          text: TextSpan(
              text: 'Numero de items: ',
              style:  buttonsSmallTextStyle(context).apply(color: _pc),
              children: [
                TextSpan(
                    text: '${posBloc.getItemsCount()}',
                    style: _textTheme.headline6)
              ]),
          // style: textTheme,
        ),
      ],
    );
  }

  Widget _paymentMethod() {
    return FutureBuilder(
      future: PaymentMethodsProvider.loadDefaultPaymentMethod(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return _paymentMethodDropDown();
        } else {
          return _paymentMethodDropDown();
        }
      },
    );
  }

  Widget _paymentMethodDropDown() {
    return DropdownSearch<PaymentMethods>(
      searchFieldProps: TextFieldProps(
        controller: _paymentMethodController,
        decoration: InputDecoration(
          labelText: 'Forma de pago',
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
      },

      maxHeight: _size.width * 0.9,
      dialogMaxWidth: _size.width * 0.8,

      isFilteredOnline: true,
      showClearButton: true,
      showSelectedItems: true,
      clearButton: const Icon(Icons.clear_rounded),
      compareFn: (item, selectedItem) => item?.name == selectedItem?.name,
      showSearchBox: true,

      dropdownSearchDecoration: InputDecoration(
        labelText: 'Forma de pago :',
        labelStyle: TextStyle(color: _pc),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      autoValidateMode: AutovalidateMode.onUserInteraction,

      onFind: (String? filter) =>
          PaymentMethodsProvider.getPaymentMethods(filter),
      onChanged: (data) {
        printConsole(data);

        setState(() {
          posBloc.setPaymentMethod(data);
        });
        if (posBloc.getPaymentMethod?.code != 'Credito' &&
            posBloc.getPaymentMethod?.code != 'credito') {
          posBloc.setPaymentTerm(null);
          _paymentTermController.text = '';
          if (posBloc.getPaymentMethod?.code != 'cash') {
            posBloc.setPaymentValue(posBloc.getSubTotal().toInt());

            _valueP = posBloc.getSubTotal().toInt();
            _valuePController.text =
                getFormatedCurrency(posBloc.getSubTotal(), decimals: 1);
          }
        } else {
          posBloc.setPaymentValue(0);
          _valuePController.text = '';
        }
      },
      // selectedItem: ,
      selectedItem: posBloc.getPaymentMethod,
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget _documentPOS() {
    return FutureBuilder(
      future: DocumentsTypesProvider.loadFromDB(module: posDocModule),
      builder:
          (BuildContext context, AsyncSnapshot<List<DocumentsTypes>> snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          posBloc.setPaymentDocument(snapshot.data?.first);
          if (snapshot.data!.length > 1) {
            return _documentType(items: snapshot.data!);
          } else {
            return Container();
          }
        } else {
          return _documentType(items: []);
        }
      },
    );
  }

  Widget _documentType({List<DocumentsTypes> items = const []}) {
    return DropdownSearch<DocumentsTypes>(
      mode: Mode.BOTTOM_SHEET,
      validator: (item) {
        if (item == null) return "Campo requerido";
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
        'No se encontraron documentos para realizar ventas POS',
        textAlign: TextAlign.center,
      ).center(),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (data) {
        // Environment().env!='DEV'?null:print(data);

        setState(() {
          posBloc.setPaymentDocument(data);
        });
      },
      // selectedItem: ,
      selectedItem: posBloc.getPaymentDocument,
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget _inputs() {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _inputsKey,
      child: Column(
        children: _paymentM == 1
            ? [
                (posBloc.getPaymentMethod?.code == 'cash' ||
                        DEFPAYMENTM == 'cash')
                    ? _defaultValues().paddingSymmetric(vertical: 6)
                    : Container(),
                (posBloc.getPaymentMethod?.code != 'Credito' &&
                        posBloc.getPaymentMethod?.code != 'credito')
                    ? _value().paddingSymmetric(vertical: 6)
                    : Container(),
                posBloc.getPaymentMethod?.code == 'Credito'
                    ? _paymentTerm()
                    : Container()
              ]
            : [Container()],
      ),
    );
  }

  AppTextField _paymentTerm() {
    return AppTextField(
      controller: _paymentTermController,
      decoration: InputDecorations.authInputDecoration(
          hintText: '', labelText: 'Plazo de pago (dias)'),
      enabled: posBloc.getPaymentMethod?.code == 'Credito',
      textFieldType: TextFieldType.PHONE,
      textStyle: Theme.of(context).textTheme.subtitle1,
      autoFocus: false,
      isValidationRequired: true,
      validator: (value) {
        try {
          int.parse(value!.replaceAll(',', ''));
        } catch (e) {
          return 'El valor suministrado no es valido';
        }
      },
      // textStyle: const TextStyle(fontSize: 20),
      onChanged: (value) {
        int val;
        try {
          val = int.parse(value.replaceAll(',', ''));
          setState(() {
            posBloc.setPaymentTerm(val);
          });
        } catch (e) {
          printConsole(e);
        }
      },
    );
  }

  Widget _invoiceNote() {
    return textFormField(context, 'Nota de despacho', (String value) {
      posBloc.setInvoiceNote(value);
    }, () {}, () {}, controller: _invoiceNController);
  }

  Widget _dispatchNote() {
    return textFormField(context, 'Nota de despacho', (String value) {
      posBloc.setDispatchNote(value);
    }, () {}, () {}, controller: _dispatchNController);
  }

  Widget _value() {
    return Row(
      children: [
        AppTextField(
          controller: _valuePController,
          inputFormatters: [CurrencyInputFormatter()],
          decoration: InputDecorations.authInputDecoration(
              hintText: '', labelText: 'Valor'),
          enabled: (posBloc.getPaymentMethod?.code != 'Credito' ||
              posBloc.getPaymentMethod?.code != 'credito'),
          textFieldType: TextFieldType.PHONE,
          textStyle: Theme.of(context).textTheme.subtitle1,
          autoFocus: false,
          isValidationRequired: true,
          validator: (value) {
            try {
              int.parse(value!
                  .replaceAll('\$', '')
                  .replaceAll(',', '')
                  .replaceAll('.', ''));
            } catch (e) {
              return 'El valor suministrado no es valido';
            }
          },
          // textStyle: const TextStyle(fontSize: 20),
          onChanged: (value) {
            setState(() {
              _updateCounts(zero: true);
              if (value != '') {
                try {
                  _valueP = int.parse(value
                      .replaceAll('\$', '')
                      .replaceAll(',', '')
                      .replaceAll('.', ''));
                  posBloc.setPaymentValue(_valueP);
                } catch (e) {
                  _valueP = 0;
                }
              } else {
                posBloc.setPaymentValue(0);
                _valueP = 0;
              }
            });
          },
        ).expand(),
        AppButton(
          shapeBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          padding: EdgeInsets.zero,
          // margin: EdgeInsets.only(right: 10),
          width: 35,
          onTap: () {
            setState(() {
              _updateCounts(zero: true);
              _valueP = 0;
            });
            posBloc.setPaymentValue(0);
            _valuePController.text = '';
          },
        ),
      ],
    );
  }

  Widget _defaultValues() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _defaultValuesWidget(_count5000, 5000),
        _defaultValuesWidget(_count10000, 10000),
        _defaultValuesWidget(_count20000, 20000),
        _defaultValuesWidget(_count50000, 50000)
      ],
    );
  }

  AppButton _defaultValuesWidget(int counter, int value) {
    final valueString = getFormatedCurrency(value.toDouble());
    return AppButton(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 13),
      onTap: () {
        setState(() {
          if (posBloc.getPaymentMethod?.code != 'Credito' &&
              posBloc.getPaymentMethod?.code != 'credito') {
            if (counter == 0) {
              _valueP += value;
              _updateCounts(value: value);
              // counter;
            } else {
              _valueP += value;
              counter += 1;
              _updateCounts(value: value);
            }
            // this is to format currency, it dindt work with inputformaters in textField because
            // here we are modifing its value directly
            final tempValue = getFormatedCurrency((_valueP.toDouble()));
            _valuePController.text =
                tempValue.substring(0, tempValue.length - 3);
            posBloc.setPaymentValue(_valueP);
          }
        });
      },
      child: RichText(
        text: TextSpan(
            text: valueString.substring(0, valueString.length - 3),
            style: _textTheme.bodyText1!.apply(color: Colors.black),
            children: [
              TextSpan(
                  text: (counter == 0 ? '' : 'x $counter'),
                  style: _textTheme.bodyText1!
                      .apply(color: Colors.black87, fontSizeFactor: 0.85))
            ]),
      ),
    );
  }

  void _updateCounts({int? value, bool zero = false}) {
    if (!zero) {
      if (value == 50000) {
        _count50000 += 1;
      } else if (value == 20000) {
        _count20000 += 1;
      } else if (value == 10000) {
        _count10000 += 1;
      } else {
        _count5000 += 1;
      }
    } else {
      _count5000 = 0;
      _count10000 = 0;
      _count20000 = 0;
      _count50000 = 0;
    }
  }

  Widget _moneyBack() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 2.5,
            spreadRadius: 0.0,
            offset: Offset(2.0, 2.0), // shadow direction: bottom right
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              const Text('Total entregado: '),
              Text(
                getFormatedCurrency(_valueP.toDouble()),
                style:  buttonsSmallTextStyle(context).apply(color: _pc),
              ),
            ],
          ).withWidth(_size.width * 0.45),
          vDivider(),
          Column(
            children: [
              const Text('Cambio: '),
              Text(
                getFormatedCurrency(_valueP - posBloc.getSubTotal()),
                style:  buttonsSmallTextStyle(context).apply(color: _pc),
              ),
            ],
          ).withWidth(_size.width * 0.45)
        ],
      ),
    );
  }

  Widget _sendAndPrint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        subTotal(large: true,color: Colors.white, defaultValue: posBloc.getSubTotal()).paddingLeft(8).expand(),
        sendButton().flexible(),
      ],
    );
  }

  AppButton sendButton() {
    bool enabled = false;
    if ((posBloc.getPaymentMethod?.code != 'Credito' &&
            posBloc.getPaymentMethod?.code != 'credito') &&
        _valueP >= posBloc.getSubTotal()) {
      enabled = true;
    } else if ((posBloc.getPaymentMethod?.code == 'Credito' ||
            posBloc.getPaymentMethod?.code == 'credito') &&
        (posBloc.getPaymentTerm ?? 0) != 0) {
      enabled = true;
    }
    return AppButton(
      padding: kButtonPadding,
      color: Colors.white,
      disabledColor: Colors.grey[300],
      enabled: enabled,
      onTap: _sending
          ? null
          : () async {
              if (_inputsKey.currentState?.validate() ?? false) {
                setState(() {
                  _sending = true;
                });
                scaffoldAlert(
                    context, 'Registrando venta', const Duration(seconds: 5));
                final result = await POSSaleProvider.sendPosData(context);
                if (result) {
                  // to let message be readed
                  // await Future.delayed(Duration(seconds: 1));
                  // hideCurrentScaffoldAlert(context);

                  await dataBloc.syncElements(
                      ['Precios de Productos', 'Productos de Sucursales'],
                      context);

                  /// update JWT token
                  await dataBloc.refreshToken(context);

                  WidgetsBinding.instance!.addPostFrameCallback((_) async {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                    await PrintSale(
                      printData: posBloc.getPrintData!,
                    ).launch(context);
                    posBloc.dispose();
                  });
                  setState(() {
                    _sending = false;
                  });
                } else {
                  setState(() {
                    _sending = false;
                  });
                }
                // PrintSale().launch(context);
              }
            },
      child: Text('Finalizar venta',
          style: buttonsSmallTextStyle(context,
              color: enabled ? pColor:greyColor)),
    );
  }
}
