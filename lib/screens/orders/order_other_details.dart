// ignore_for_file: unnecessary_null_comparison

// import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/orders_bloc.dart';
// import 'package:pos_wappsi/bloc/sync_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/input_decoration.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/config/documents_types.dart';

import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/global_form_const.dart';
import 'package:pos_wappsi/models/documents_types_model.dart';
import 'package:pos_wappsi/providers/document_types_provider.dart';
import 'package:pos_wappsi/providers/orders_provider.dart';
import 'package:pos_wappsi/screens/customers/components/drop_down_s_item.dart';

// import 'package:pos_wappsi/providers/sync_db_provider.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/screens/home/home_screen.dart';
import 'package:pos_wappsi/screens/orders/print_order.dart';
// import 'package:pos_wappsi/screens/db_sync/components/sync_popup.dart';
// import 'package:pos_wappsi/screens/home/home_screen.dart';
import 'package:pos_wappsi/screens/sales/components/widgets.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
import 'package:pos_wappsi/utils/sale_functions/percent_formating.dart';
import 'package:pos_wappsi/utils/text_formating/currency_formater.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

class OrderOtherDetails extends StatefulWidget {
  const OrderOtherDetails({Key? key}) : super(key: key);

  @override
  _OrderOtherDetailsState createState() => _OrderOtherDetailsState();
}

class _OrderOtherDetailsState extends State<OrderOtherDetails> {
  // to disable paybutton when awaiting for response
  bool _sending = false;
  // TextEditingController _paymentDocumentController =
  //     TextEditingController();

  // form key to valitations
  final GlobalKey<FormState> _inputsKey = GlobalKey<FormState>();

  late Size _size;
  // final TextEditingController _paymentMethodController =
  //     TextEditingController();

  String _discountTSelected = '';

  final TextEditingController _internalNController = TextEditingController();
  final TextEditingController _orderNController = TextEditingController();
  final TextEditingController _orderDController = TextEditingController();
  @override
  void initState() {
    final discountVal = getFormatedCurrency(orderBloc.getOrderDiscount);
    _orderDController.text = orderBloc.getOrderDiscount != 0.0
        ? discountVal.substring(0, discountVal.length)
        : '';
    if (orderBloc.getInternalNote != null) {
      _internalNController.text = orderBloc.getInternalNote!;
    }
    if (orderBloc.getOrderNote != null) {
      _orderNController.text = orderBloc.getOrderNote!;
    }
    super.initState();
  }

  @override
  void dispose() {
    _internalNController.dispose();
    _orderNController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;

    return Scaffold(
      appBar:
          appBar(context, 'Agregar pedido', image: 'assets/images/cargo.png'),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        _form().expand(),
        bottom(_sendAndPrint(), pColor, _size),
      ],
    );
  }

  Widget _form() {
    return Form(
      key: _inputsKey,
      child: ListView(
        children: [
          _productsInfo().paddingSymmetric(vertical: 6),
          // _paymentMethod().paddingSymmetric(vertical: 6),
          _orderDocumentType().paddingSymmetric(vertical: 6),
          dataBloc.userData!.allowDiscount == 1
              ? _orderDiscount().paddingSymmetric(vertical: 6)
              : Container(),
          _invoiceNote().paddingSymmetric(vertical: 6),
          _dispatchNote().paddingSymmetric(vertical: 6)
        ],
      ).paddingOnly(left: 16, right: 16, top: 6),
    );
  }

  Widget _productsInfo() {
    final totalBeforeDisc = getFormatedCurrency(
        orderBloc.getSubTotalWithoutDiscount(),
        decimals: 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(
            'Cantidad de items: ',
            style: buttonsTextStyle(context, color: pColor),
          ),
          const Spacer(),
          Text('${orderBloc.getItemsCount()}', style: numbersTextStyle())
        ]
            // style: textTheme,
            ),
        Row(children: [
          Text(
            'Subtotal: ',
            style: buttonsTextStyle(context, color: pColor),
          ),
          const Spacer(),
          Text(totalBeforeDisc, style: numbersTextStyle())
        ]),
        StreamBuilder<double?>(
            stream: orderBloc.orderDiscountStream,
            builder: (context, snapshot) {
              return Row(
                children: [
                  Text(
                    'Descuento: ',
                    style: buttonsTextStyle(context, color: pColor),

                    // style: textTheme,
                  ),
                  const Spacer(),
                  Text(getFormatedCurrency(snapshot.data ?? 0),
                      style: numbersTextStyle())
                ],
              );
            }),
        StreamBuilder<double?>(
            stream: orderBloc.subTotalStream,
            initialData: orderBloc.getSubTotalWithoutDiscount(),
            builder: (context, snapshot) {
              return Row(
                children: [
                  Text(
                    'Total: ',
                    style: buttonsTextStyle(context, color: pColor),

                    // style: textTheme,
                  ),
                  const Spacer(),
                  Text(getFormatedCurrency(snapshot.data ?? 0),
                      style: numbersTextStyle())
                ],
              );
            }),

        // RichText(
        //   text: TextSpan(
        //       text: 'Numero de productos: ',hostUrl
        //       style: buttonsTextStyle(context, color: pColor),
        //       children: [
        //         TextSpan(
        //             text: '${orderBloc.getProductsCount()}',
        //             style: numbersTextStyle())
        //       ]),
        //   // style: textTheme,
        // ),
      ],
    );
  }

  Widget _orderDocumentType() {
    return FutureBuilder(
      future: DocumentsTypesProvider.loadFromDB(module: orderModule),
      builder:
          (BuildContext context, AsyncSnapshot<List<DocumentsTypes>> snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          orderBloc.setOrderDocumentType(snapshot.data?.first);
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
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (data) {
        // Environment().env!='DEV'?null:print(data);

        setState(() {
          orderBloc.setOrderDocumentType(data);
        });
      },
      // selectedItem: ,
      selectedItem: orderBloc.getOrderDocumentType,
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget _orderDiscount() {
    return Row(
      children: [
        _discountTSelector().withWidth(190).paddingRight(8),
        _discountValue().expand()
      ],
    );
  }

  AppTextField _discountValue() {
    return AppTextField(
      controller: _orderDController,
      inputFormatters:
          _discountTSelected == '1' ? [CurrencyInputFormatter()] : null,
      decoration: InputDecorations.authInputDecoration(
          hintText: '', labelText: 'Descuento'),

      textFieldType: TextFieldType.PHONE,
      textStyle: Theme.of(context).textTheme.subtitle1,
      autoFocus: false,
      isValidationRequired: true,
      validator: (value) {
        if (_discountTSelected == '1') {
          try {
            if (value != '') {
              double.parse(value!.replaceAll('\$', '').replaceAll(',', ''));
            }
          } catch (e) {
            return 'El valor suministrado no es valido';
          }
        } else if (_discountTSelected == '2') {
          try {
            if (value != '') {
              final v = double.tryParse(value!);
              if (v! > 100) {
                return 'El valor suministrado no es valido';
              }
            }
          } catch (e) {
            printConsole(e);
            return 'El valor suministrado no es valido';
          }
        }
        return null;
      },
      // textStyle: const TextStyle(fontSize: 20),
      onChanged: (value) {
        if (_discountTSelected == '1') {
          // setState(() {
          if (value != '') {
            if (value == '\$') {
              _orderDController.text = '';
              orderBloc.setOrderDiscount(0);
            }
            try {
              final valueD = double.parse((value == '' ? '0' : value)
                  .replaceAll('\$', '')
                  .replaceAll(',', '')
                  .replaceAll('.', ''));
              orderBloc.setOrderDiscount(valueD);
            } catch (e) {
              // orderBloc.setOrderDiscount(0);
            }
          } else {
            _orderDController.text = '';
            orderBloc.setOrderDiscount(0);
            orderBloc.getSubTotal();
          }
          // });
        } else if (_discountTSelected == '2') {
          double? percent = double.tryParse(value);
          if (percent != null) {
            percent = getFormatedPercent(percent);

            final oDiscount = orderBloc.getTotalWithNoIVA() * percent;

            orderBloc.setOrderDiscount(oDiscount);

            // ubdate subtotal

          }
        }
        orderBloc.getSubTotal();
      },
    );
  }

  DropdownSearch<DropdDownSItem> _discountTSelector() {
    return DropdownSearch<DropdDownSItem>(
      mode: Mode.MENU,
      // validator: (item) {
      //   if (item == null) return "Campo requerido";
      // },

      // popupShape: RoundedRectangleBorder(
      //     // borderRadius: BorderRadius.circular(10),
      //     side: const BorderSide(color: pColor)),
      maxHeight: 140,

      // dialogMaxWidth: 100,
      // showClearButton: true,
      compareFn: (item, selectedItem) => item?.name == selectedItem?.name,
      items: (discountType.values.toList()),
      selectedItem: discountType[_discountTSelected],
      dropdownSearchDecoration: InputDecorations.outlineInputDecoration(
        hintText: 'Tipo descuento',
        labelText: 'Tipo descuento',
      ),

      autoValidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (data) async {
        if (data != null) {
          setState(() {
            _discountTSelected = data.value;
            _orderDController.text = '';
            orderBloc.setOrderDiscount(0);
            orderBloc.getSubTotal();
          });
        }
      },
      // selectedItem: orderBloc.getCustomer,
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget _invoiceNote() {
    return textFormField(context, 'Nota de venta', (String value) {
      orderBloc.setOrderNote(value);
    }, (String value) {}, () {}, controller: _internalNController, maxLines: 4);
  }

  Widget _dispatchNote() {
    return textFormField(context, 'Nota interna', (String value) {
      orderBloc.setInternalNote(value);
    }, (String value) {}, () {}, controller: _orderNController, maxLines: 4);
  }

  Widget _sendAndPrint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        subTotal(
                stream: orderBloc.subTotalStream,
                large: true,
                color: Colors.white,
                defaultValue: orderBloc.getSubTotal())
            .paddingLeft(8)
            .expand(),
        sendButton().flexible(),
      ],
    );
  }

  AppButton sendButton() {
    // bool enabled = true;
    return AppButton(
      padding: kButtonPadding,
      color: Colors.white,
      disabledColor: Colors.grey[300],
      enabled: !_sending,
      onTap: _sending
          ? null
          : () async {
              if (_inputsKey.currentState?.validate() ?? false) {
                final res = await OrdersProvider.sendOrderData(context);

                if (res) {
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
                    final printData = orderBloc.getPrintData!;
                    orderBloc.reload(disposeFirst: true);
                    await PrintOrder(
                      printData: printData,
                    ).launch(context);
                  });
                  setState(() {
                    _sending = false;
                  });
                } else {
                  setState(() {
                    _sending = false;
                  });
                }
              }
            },
      child: Text('Finalizar pedido',
          style: buttonsSmallTextStyle(context,
              color: !_sending ? pColor : greyColor)),
    );
  }
}
