// ignore_for_file: unnecessary_null_comparison

// import 'dart:io';

import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/config/documents_types.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/entities/paymentEntryEntity.dart';
import 'package:pos_wappsi/models/documents_types_model.dart';
// import 'package:pos_wappsi/models/documents_types_model.dart';
import 'package:pos_wappsi/models/payment_methods_model.dart';
import 'package:pos_wappsi/params/pos_params.dart';
import 'package:pos_wappsi/providers/document_types_provider.dart';
import 'package:pos_wappsi/providers/payment_methods_provider.dart';
import 'package:pos_wappsi/providers/sale_provider.dart';
// import 'package:pos_wappsi/bloc/sync_bloc.dart';
import 'package:pos_wappsi/screens/components/back_app_bar.dart';
import 'package:pos_wappsi/screens/components/input_decoration.dart';
import 'package:pos_wappsi/screens/components/widgets.dart';
// import 'package:pos_wappsi/providers/sync_db_provider.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
// import 'package:pos_wappsi/screens/db_sync/components/sync_popup.dart';

import 'package:pos_wappsi/screens/home/home_screen.dart';
// import 'package:pos_wappsi/screens/home/home_screen.dart';
import 'package:pos_wappsi/screens/sales/components/widgets.dart';
import 'package:pos_wappsi/screens/sales/print_sale.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
import 'package:pos_wappsi/utils/text_formating/currency_formatter.dart';
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
  final List<PaymentEntry> _payments = [PaymentEntry()];
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  // PaymentMethods? _payment;
  // DocumentsTypes? _pDoc;

  int _count50000 = 0;
  int _count5000 = 0;
  int _count10000 = 0;
  int _count20000 = 0;

  // to disable payButton when awaiting for response
  bool _sending = false;

  final TextEditingController _paymentMethodController =
      TextEditingController();
  // TextEditingController _paymentDocumentController =
  //     TextEditingController();

  late Size _size;

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
      _valuePController.text =
          posBloc.getPaymentValue == 0 ? '' : value.substring(0, value.length);

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
    for (var p in _payments) {
      p.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _pc = pColor;
    _textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
    final isCredito = _payments.any((p) =>
        p.selectedPaymentMethod?.code == 'Credito' ||
        p.selectedPaymentMethod?.code == 'credito');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        autovalidateMode: AutovalidateMode.disabled,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification &&
                notification.dragDetails == null) {
              return true;
            }
            return false;
          },
          child: ListView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const ClampingScrollPhysics(), // ← agrega esto
            // Esto evita que Flutter haga scroll automático hacia campos con foco/error
            cacheExtent: 9999,
            children: [
              _productsInfo().paddingSymmetric(vertical: 6),
              // _paymentMethod().paddingSymmetric(vertical: 6),
              _documentPOS().paddingSymmetric(vertical: 6),
              // _inputs(),
              ...List.generate(
                _payments.length,
                (index) => Column(
                  key: ValueKey(_payments[index]),
                  children: [
                    _paymentMethod(index).paddingSymmetric(vertical: 6),
                    _inputs(index)
                        .paddingSymmetric(vertical: 6), // cada uno con su index
                  ],
                ),
              ),

              if (!isCredito)
                ElevatedButton.icon(
                  focusNode: FocusNode(skipTraversal: true),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _payments.add(PaymentEntry());
                    });
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(
                          // jumpTo en lugar de animateTo
                          _scrollController.position.maxScrollExtent,
                        );
                      }
                    });
                  },

                  // Opcional: si quieres cambiar el color por defecto del ElevatedButton
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400, // Fondo verde
                    foregroundColor: Colors.white, // Texto/Ícono blanco
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar más pagos'),
                ),

              if (_payments.length > 1)
                ElevatedButton.icon(
                  focusNode: FocusNode(skipTraversal: true),
                  onPressed: () {
                    setState(() {
                      _payments.last.dispose();
                      _payments.removeLast();
                      // Recalcula el total sin el último entry
                      final total =
                          _payments.fold<int>(0, (sum, e) => sum + e.valueP);
                      posBloc.setPaymentValue(total);
                    });
                  },
                  // 🔽 CONFIGURACIÓN DEL ESTILO EN ROJO
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .red.shade400, // Fondo rojo para alertar eliminación
                    foregroundColor: Colors
                        .white, // Texto e ícono en blanco para buen contraste
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          8), // Bordes redondeados iguales al anterior
                    ),
                  ),
                  icon: const Icon(
                      Icons.remove_circle_outline), // Limpiado el color manual
                  label:
                      const Text('Eliminar pago'), // Limpiado el style manual
                ),
              const SizedBox(
                height: 20,
              ),
              _invoiceNote().paddingSymmetric(vertical: 6),
              _dispatchNote().paddingSymmetric(vertical: 6),
            ],
          ),
        ),
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
            style: buttonsSmallTextStyle(context).apply(color: _pc),
            children: [
              TextSpan(
                text: '${posBloc.getProductsCount()}',
                style: _textTheme.headlineSmall,
              ),
            ],
          ),
          // style: textTheme,
        ),
        RichText(
          text: TextSpan(
            text: 'Numero de items: ',
            style: buttonsSmallTextStyle(context).apply(color: _pc),
            children: [
              TextSpan(
                text: '${posBloc.getItemsCount()}',
                style: _textTheme.headlineSmall,
              ),
            ],
          ),
          // style: textTheme,
        ),
      ],
    );
  }

  Widget _paymentMethod(int index) {
    return FutureBuilder(
      future: PaymentMethodsProvider.loadDefaultPaymentMethod(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return _paymentMethodDropDown(index);
      },
    );
  }

  Widget _paymentMethodDropDown(int index) {
    final entry = _payments[index];

    return DropdownSearch<PaymentMethods>(
      searchFieldProps: TextFieldProps(
        controller: entry.paymentMethodController, // ← controller del index
        decoration: InputDecoration(
          labelText: 'Forma de pago',
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              if (entry.paymentMethodController.text.isNotEmpty) {
                Navigator.pop(context);
              }
              entry.paymentMethodController.clear();
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
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Forma de pago :',
        labelStyle: TextStyle(color: _pc),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      // autoValidateMode: AutovalidateMode.onUserInteraction,
      autoValidateMode: AutovalidateMode.disabled,
      onFind: (String? filter) =>
          PaymentMethodsProvider.getPaymentMethods(filter),
      onChanged: (data) {
        setState(() {
          entry.selectedPaymentMethod =
              data; // ← guarda en el entry, no en posBloc global
        });

        if (data?.code == 'Credito' || data?.code == 'credito') {
          posBloc.setPaymentMethod(data);
        }

        if (data?.code != 'Credito' && data?.code != 'credito') {
          posBloc.setPaymentTerm(null);
          entry.paymentMethodController.text = '';
          if (data?.code != 'cash') {
            entry.valuePController.text =
                index == 0 ? getFormatedCurrency(posBloc.getSubTotal()) : '';
          }
        } else {
          entry.valuePController.text = '';
        }
      },
      selectedItem: entry.selectedPaymentMethod, // ← selected del entry
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
        if (snapshot.hasData && (snapshot.data?.isNotEmpty ?? false)) {
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          posBloc.setPaymentDocument(snapshot.data?.first);
          // });

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
        if (item == null) return 'Campo requerido';
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
        'No se encontraron documentos para realizar ventas POS',
        textAlign: TextAlign.center,
      ).center(),
      // autoValidateMode: AutovalidateMode.onUserInteraction,
      autoValidateMode: AutovalidateMode.disabled,
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

  Widget _inputs(int index) {
    final entry = _payments[index];

    if (_paymentM != 1)
      return const SizedBox.shrink(); // Reemplazo limpio para Container()

    return Column(
      children: [
        if (entry.selectedPaymentMethod?.code == 'cash')
          _defaultValues(index).paddingSymmetric(vertical: 6),
        if (entry.selectedPaymentMethod?.code != 'Credito' &&
            entry.selectedPaymentMethod?.code != 'credito')
          _value(index).paddingSymmetric(vertical: 6),
        if (entry.selectedPaymentMethod?.code == 'Credito') _paymentTerm(index),
      ],
    );
  }

  Widget _paymentTerm(int index) {
    final entry = _payments[index];

    return AppTextField(
      controller: entry.paymentTermController, // ← controller del entry
      decoration: InputDecorations.authInputDecoration(
        hintText: '',
        labelText: 'Plazo de pago (Dias)',
      ),
      enabled: entry.selectedPaymentMethod?.code == 'Credito',
      textFieldType: TextFieldType.PHONE,
      textStyle: Theme.of(context).textTheme.labelMedium,
      autoFocus: false,
      isValidationRequired: true,
      validator: (value) {
        if (value == null || value == '') {
          return 'Debe suministrar un valor valido';
        }
        try {
          int.parse(value.replaceAll(',', ''));
        } catch (e) {
          return 'El valor suministrado no es valido';
        }
        return null;
      },
      onChanged: (value) {
        try {
          final val = int.parse(value.replaceAll(',', ''));
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
    return textFormField(
      context,
      'Nota de factura',
      (String value) {
        posBloc.setInvoiceNote(value);
      },
      (value) {},
      () {},
      controller: _invoiceNController,
    );
  }

  Widget _dispatchNote() {
    return textFormField(
      context,
      'Nota interna',
      (String value) {
        posBloc.setDispatchNote(value);
      },
      (value) {},
      () {},
      controller: _dispatchNController,
    );
  }

  Widget _value(int index) {
    final entry = _payments[index];

    return Row(
      children: [
        AppTextField(
          controller: entry.valuePController, // ← controller del entry
          inputFormatters: [CurrencyInputFormatter()],
          decoration: InputDecorations.authInputDecoration(
            hintText: '',
            labelText: 'Valor',
          ),
          enabled: (entry.selectedPaymentMethod?.code != 'Credito' ||
              entry.selectedPaymentMethod?.code != 'credito'),
          textFieldType: TextFieldType.PHONE,
          textStyle: Theme.of(context).textTheme.labelMedium,
          autoFocus: false,
          isValidationRequired: true,
          validator: (value) {
            if (value == null || value == '') {
              return 'Debe suministrar un valor';
            }
            return null;
          },
          onChanged: (value) {
            print('value 545 $value ');
            setState(() {
              entry.resetCounts();
              if (value != '') {
                try {
                  entry.valueP = int.parse(
                    value
                        .replaceAll('\$', '')
                        .replaceAll(',', '')
                        .replaceAll('.', ''),
                  );
                  // Si quieres sumar todos los pagos al bloc:
                  final total =
                      _payments.fold<int>(0, (sum, e) => sum + e.valueP);

                  print('total $total');
                  posBloc.setPaymentValue(total);
                } catch (e) {
                  entry.valueP = 0;
                }
              } else {
                entry.valueP = 0;
                final total =
                    _payments.fold<int>(0, (sum, e) => sum + e.valueP);
                posBloc.setPaymentValue(total);
              }
            });
          },
        ).expand(),
        AppButton(
          shapeBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(Icons.delete, color: Colors.red),
          padding: EdgeInsets.zero,
          width: 35,
          onTap: () {
            setState(() {
              entry.resetCounts();
              entry.valueP = 0;
              entry.valuePController.text = '';
              final total = _payments.fold<int>(0, (sum, e) => sum + e.valueP);
              posBloc.setPaymentValue(total);
            });
          },
        ),
      ],
    );
  }

  Widget _defaultValues(int index) {
    final entry = _payments[index];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _defaultValuesWidget(entry.count5000, 5000, index),
        _defaultValuesWidget(entry.count10000, 10000, index),
        _defaultValuesWidget(entry.count20000, 20000, index),
        _defaultValuesWidget(entry.count50000, 50000, index),
      ],
    );
  }

  AppButton _defaultValuesWidget(int counter, int value, int index) {
    final entry = _payments[index];
    final valueString = getFormatedCurrency(value.toDouble(), decimals: 0);

    return AppButton(
      color: Colors.white,
      padding: kButtonPadding,
      width: 20,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius2),
        side: BorderSide(color: counter != 0 ? _pc : Colors.white, width: 1),
      ),
      onTap: () {
        setState(() {
          if (entry.selectedPaymentMethod?.code != 'Credito' &&
              entry.selectedPaymentMethod?.code != 'credito') {
            entry.valueP += value;

            // Actualiza el contador correcto del entry
            if (value == 5000)
              entry.count5000 += 1;
            else if (value == 10000)
              entry.count10000 += 1;
            else if (value == 20000)
              entry.count20000 += 1;
            else if (value == 50000) entry.count50000 += 1;

            final tempValue = getFormatedCurrency(entry.valueP.toDouble());
            entry.valuePController.text =
                tempValue.substring(0, tempValue.length - 3);

            // Suma todos los pagos al bloc
            final total = _payments.fold<int>(0, (sum, e) => sum + e.valueP);
            posBloc.setPaymentValue(total);
          }
        });
      },
      child: RichText(
        text: TextSpan(
          text: valueString.substring(0, valueString.length),
          style: _textTheme.bodyLarge!.apply(color: Colors.black),
          children: [
            TextSpan(
              text: (counter == 0 ? '' : 'x$counter'),
              style: _textTheme.bodyLarge!
                  .apply(color: Colors.black87, fontSizeFactor: 0.95),
            ),
          ],
        ),
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
    final currentValue = posBloc.getPaymentValue ?? 0;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 2.5,
            spreadRadius: 0.0,
            offset: Offset(2.0, 2.0), // shadow direction: bottom right
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              const Text('Total entregado: '),
              Text(
                getFormatedCurrency(currentValue.toDouble()),
                style: buttonsSmallTextStyle(context).apply(color: _pc),
              ),
            ],
          ).withWidth(_size.width * 0.45),
          vDivider(),
          Column(
            children: [
              const Text('Cambio: '),
              Text(
                getFormatedCurrency(currentValue - posBloc.getSubTotal()),
                style: buttonsSmallTextStyle(context).apply(color: _pc),
              ),
            ],
          ).withWidth(_size.width * 0.45),
        ],
      ),
    );
  }

  Widget _sendAndPrint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        subTotal(
          large: true,
          color: Colors.white,
          defaultValue: posBloc.getSubTotal(),
        ).paddingLeft(8).expand(),
        sendButton().flexible(),
      ],
    );
  }

  AppButton sendButton() {
    return AppButton(
      padding: kButtonPadding,
      color: Colors.white,
      disabledColor: Colors.grey[300],
      onTap: _sending
          ? null
          : () async {
              final subTotal = posBloc.getSubTotal();
              final paid = _payments.fold<int>(0, (sum, e) => sum + e.valueP);
              if ((_formKey.currentState?.validate() ?? false)) {
                setState(() {
                  _sending = true;
                });
                scaffoldAlert(
                  context,
                  'Registrando venta',
                  const Duration(seconds: 5),
                );
                final result =
                    await SalesProvider.sendPosData(context, _payments);
                if (result) {
                  // 1. Obtén datos antes de disponer el bloc
                  final printData = posBloc.getPrintData!;
                  await posBloc.dispose();

                  // 2. Sincroniza en background sin await
                  dataBloc.syncElements(
                    ['Precios de Productos', 'Productos de Sucursales'],
                  );

                  // 3. Refresca token
                  await dataBloc.refreshToken(context);

                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    // 4. Primero imprime con el context aún válido
                    await PrintSale(
                      printData: printData,
                    ).launch(context);

                    // 5. Navega al home después de imprimir
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  });
                } else {
                  setState(() {
                    _sending = false;
                  });
                }
                // PrintSale().launch(context);
              }
            },
      child: Text(
        'Finalizar venta',
        style: buttonsSmallTextStyle(context, color: pColor),
      ),
    );
  }
}
