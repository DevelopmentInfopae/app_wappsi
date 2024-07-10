// ignore_for_file: unnecessary_null_comparison

// import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/orders_bloc.dart';
import 'package:pos_wappsi/config/documents_types.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/global_form_const.dart';
import 'package:pos_wappsi/models/delivery_time_model.dart';
import 'package:pos_wappsi/models/documents_types_model.dart';
import 'package:pos_wappsi/providers/customer_addresses_provider.dart';
import 'package:pos_wappsi/providers/delivery_time_provider.dart';
import 'package:pos_wappsi/providers/document_types_provider.dart';
import 'package:pos_wappsi/providers/orders_provider.dart';
// import 'package:pos_wappsi/bloc/sync_bloc.dart';
import 'package:pos_wappsi/screens/components/back_app_bar.dart';
import 'package:pos_wappsi/screens/components/input_decoration.dart';
import 'package:pos_wappsi/screens/components/widgets.dart';
import 'package:pos_wappsi/screens/customers/components/add_address_zone_subzone.dart';
import 'package:pos_wappsi/screens/customers/components/drop_down_s_item.dart';
// import 'package:pos_wappsi/providers/sync_db_provider.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/screens/home/home_screen.dart';
import 'package:pos_wappsi/screens/orders/print_order.dart';
// import 'package:pos_wappsi/screens/db_sync/components/sync_popup.dart';
// import 'package:pos_wappsi/screens/home/home_screen.dart';
import 'package:pos_wappsi/screens/sales/components/widgets.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
import 'package:pos_wappsi/utils/sale_functions/percent_formating.dart';
import 'package:pos_wappsi/utils/text_formating/currency_formatter.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class OrderOtherDetails extends StatefulWidget {
  const OrderOtherDetails({Key? key}) : super(key: key);

  @override
  Validations createState() => Validations();
}

class Validations extends State<OrderOtherDetails> {
  // to disable payButton when awaiting for response
  bool sending = false;
  // TextEditingController _paymentDocumentController =
  //     TextEditingController();

  // form key to validations
  final GlobalKey<FormState> _inputsKey = GlobalKey<FormState>();

  /// to control send order button
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  late Size _size;
  // final TextEditingController _paymentMethodController =
  //     TextEditingController();

  String _discountTSelected = '';

  final TextEditingController _internalNController = TextEditingController();
  final TextEditingController _orderNController = TextEditingController();
  final TextEditingController _orderDController = TextEditingController();
  // final TextEditingController _dateController = TextEditingController();

  List<DeliveryTime> deliveryTimes = [];
  bool deliveryTimeRequired = false;

  DeliveryTime? selectedDeliveryTime;

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

    selectedDeliveryTime = orderBloc.getDeliveryTime;
    super.initState();
  }

  @override
  void dispose() {
    _internalNController.dispose();
    _orderNController.dispose();
    // _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: appBar(
        context,
        'Agregar pedido',
        image: 'assets/images/add-order.png',
      ),
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
          dataBloc.settings!['management_order_sale_delivery_time'] == 1
              ? Column(
                  children: [
                    _datePicker().paddingSymmetric(horizontal: 4),
                    _timePicker().paddingSymmetric(horizontal: 4),
                  ],
                )
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
      decimals: 1,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Cantidad de items: ',
              style: buttonsTextStyle(context, color: pColor),
            ),
            const Spacer(),
            Text('${orderBloc.getItemsCount()}', style: numbersTextStyle())
          ],
          // style: textTheme,
        ),
        Row(
          children: [
            Text(
              'Subtotal: ',
              style: buttonsTextStyle(context, color: pColor),
            ),
            const Spacer(),
            Text(totalBeforeDisc, style: numbersTextStyle())
          ],
        ),
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
                Text(
                  getFormatedCurrency(snapshot.data ?? 0),
                  style: numbersTextStyle(),
                )
              ],
            );
          },
        ),
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
                Text(
                  getFormatedCurrency(snapshot.data ?? 0),
                  style: numbersTextStyle(),
                )
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _orderDocumentType() {
    return FutureBuilder(
      future: DocumentsTypesProvider.loadFromDB(module: orderModule),
      builder:
          (BuildContext context, AsyncSnapshot<List<DocumentsTypes>> snapshot) {
        if (snapshot.hasData &&
            snapshot.data!.isNotEmpty &&
            !orderBloc.isDisposed) {
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
        hintText: '',
        labelText: 'Descuento',
      ),

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
              final valueD = double.parse(
                (value == '' ? '0' : value)
                    .replaceAll('\$', '')
                    .replaceAll(',', '')
                    .replaceAll('.', ''),
              );
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

            // update subtotal

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
      //     // borderRadius: BorderRadius.circular(radius2),
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

  Widget _datePicker() {
    final now = DateTime.now();
    return Container(
      // height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius2),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 2.0,
          )
        ],
      ),
      padding: kButtonHPadding2,
      child: DateTimePicker(
        type: DateTimePickerType.date,
        firstDate: DateTime.now(),
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: 'Fecha de entrega',
        ),
        style: normalTextStyle(context),
        // controller: _dateController,
        // dateHintText: "Fe",
        // inputFormatters: [
        //   Formatter()
        // ],
        // locale: const Locale('ES'),
        lastDate: DateTime(
          now.year + 1,
        ),
        dateLabelText: 'Fecha:',
        initialValue: orderBloc.getDeliveryDate,
        onChanged: (String? value) async {
          if (value != null) {
            // final time = await selectTime(context);
            // purchaseBloc.setDate(value);
            if (value != null) {
              // set new date
              orderBloc.setDeliveryDate(value);
              // reset deliveryTime value
              _updateDeliveryTime(null);
              if (orderBloc.getCustomerAddresses!.location != null) {
                // get deliveryTimes available for selected delivery date
                await loadDeliveryTimes(value);
              } else {
                await confirmDialog(
                  context,
                  'No se encontró zona configurada para la sucursal de cliente seleccionada.',
                  'assets/images/dizzy-robot.png',
                );
                // if (orderBloc.getCustomerAddresses != null) {
                final reloadAddress = await showDialog<Map<String, dynamic>?>(
                  barrierDismissible: false,
                  // useRootNavigator: false,
                  context: context,
                  builder: (context) {
                    return ZoneSZoneSelection(
                      address: orderBloc.getCustomerAddresses!,
                    );
                  },
                );
                if (reloadAddress?['reload_address'] == true) {
                  final reloadedAddres =
                      await CustomerAddressesProvider.loadCustomerAddress(
                    (orderBloc.getCustomerAddresses?.idCloud ?? '').toString(),
                  );
                  orderBloc.setCustomerAddresses(reloadedAddres);
                  await loadDeliveryTimes(value);
                }
                // }
              }
            }
          }
        },
      ),
    );
  }

  Future<void> loadDeliveryTimes(String value) async {
    deliveryTimes = await DeliveryTimeProvider.getAvailableDeliveryTimes(
      context,
      value,
      orderBloc.getCustomerAddresses!.location,
    );
    if (deliveryTimes.isEmpty) {
      await confirmDialog(
        context,
        'No se encontraron franjas horarias para la zona de sucursal de cliente.',
        'assets/images/dizzy-robot.png',
      );
    } else {
      setState(() {});
    }
  }

  Widget _timePicker() {
    // final now = DateTime.now();

    // String timeText = '--:-- A --:--';

    // if (selectedDeliveryTime != null) {
    //   timeText = selectedDeliveryTime!.getDeliveryTimeText();
    // }

    List<Widget> widgets = [];
    for (var deliveryTime in deliveryTimes) {
      final bool isSelected = selectedDeliveryTime?.id == deliveryTime.id;
      final choiceCard = AppButton(
        onTap: () async {
          orderBloc.setDeliveryTime(deliveryTime);
          selectedDeliveryTime = deliveryTime;
          setState(() {});
        },
        width: 0,
        height: 0,
        shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius1),
        ),
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius1),
            border: isSelected ? Border.all(color: pColor) : null,
            // color: isSelected ? primary : Colors.white
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          width: 90,
          height: 80,
          child: Text(
            (deliveryTime.toString()),
            style: normalTextStyle(
              context,
              // color: !isSelected ? null : Colors.white,
              fontWeightDelta: !isSelected ? 1 : 2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );

      widgets.add(choiceCard);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widgets,
      ),
    );
    // return deliveryTimes.isEmpty
    //     ? Container(
    //         decoration: BoxDecoration(
    //             color: Colors.white,
    //             border: deliveryTimeRequired ? Border.all(color: errorColor) : null,
    //             borderRadius: BorderRadius.circular(normalBorderRadius)),
    //         child: labelContent('Franja Horaria', timeText,
    //             capitalize: false, labelColor: pColor, labelBold: false))
    //     : DropdownButton<DeliveryTime?>(
    //         value: selectedDeliveryTime,
    //         items: deliveryTimes.map((e) {
    //           return DropdownMenuItem<DeliveryTime?>(
    //             child: labelContent('Franja Horaria', timeText,
    //                 capitalize: false, labelColor: pColor, labelBold: false),
    //           );
    //         }).toList(),
    //         // selectedItemBuilder: ,

    //         onChanged: (value) {
    //           orderBloc.setDeliveryTime(value);
    //         });

    // return AppButton(
    //   padding: EdgeInsets.zero,
    //   // width: double.infinity,
    //   // height: 60,

    //   child: Container(
    //       decoration: BoxDecoration(
    //           color: Colors.white,
    //           border: deliveryTimeRequired ? Border.all(color: errorColor) : null,
    //           borderRadius: BorderRadius.circular(normalBorderRadius)),
    //       child: labelContent('Franja Horaria', timeText,
    //           capitalize: false, labelColor: pColor, labelBold: false)),
    //   onTap: () async {
    //     final time = await showCustomTimePicker(
    //         context: context,
    //         // It is a must if you provide selectableTimePredicate
    //         onFailValidation: (context) => confirmDialog(context,
    //             'Franja horaria no disponible.', 'assets/images/warning.png'),
    //         initialTime: const TimeOfDay(hour: 6, minute: 0),
    //         selectableTimePredicate: (time) {
    //           // return true;
    //           return deliveryTimes.where((element) {
    //             return element.time1 == time;
    //           }).isNotEmpty;
    //           //   _availableHours.indexOf(time.hour) != -1 &&
    //           //     time.minute % 15 == 0).then(
    //           // (time) => setState(() => selectedTime = time?.format(context))
    //         });
    //     _updateDeliveryTime(time);
    //   },
    //   enabled: deliveryTimes.isNotEmpty,
    // );
  }

  void _updateDeliveryTime(TimeOfDay? time) {
    setState(() {
      if (time != null) {
        deliveryTimeRequired = false;
        selectedDeliveryTime = deliveryTimes.where((element) {
          return element.time1 == time;
        }).first;
      } else {
        selectedDeliveryTime = null;
      }
    });
    orderBloc.setDeliveryTime(selectedDeliveryTime);
  }

  Widget _invoiceNote() {
    return textFormField(
      context,
      'Nota de venta',
      (String value) {
        orderBloc.setOrderNote(value);
      },
      (String value) {},
      () {},
      controller: _internalNController,
      maxLines: 4,
    );
  }

  Widget _dispatchNote() {
    return textFormField(
      context,
      'Nota interna',
      (String value) {
        orderBloc.setInternalNote(value);
      },
      (String value) {},
      () {},
      controller: _orderNController,
      maxLines: 4,
    );
  }

  Widget _sendAndPrint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        subTotal(
          stream: orderBloc.subTotalStream,
          large: true,
          color: Colors.white,
          defaultValue: orderBloc.getSubTotal(),
        ).paddingLeft(8).expand(),
        sendButton().flexible(),
      ],
    );
  }

  RoundedLoadingButton sendButton() {
    // bool enabled = true;
    return RoundedLoadingButton(
      color: pColor,
      // disabledColor: Colors.grey[300],
      controller: _btnController,
      borderRadius: radius3,
      onPressed: () async {
        _btnController.start();
        // await Future.delayed(Duration(seconds: 5));
        if ((_inputsKey.currentState?.validate() ?? false) &&
            orderBloc.getDeliveryTime != null &&
            !sending) {
          final res = await OrdersProvider.sendOrderData(context);
          if (res) {
            /// update JWT token
            await dataBloc.refreshToken(context);
            _btnController.success();
            final printData = orderBloc.getPrintData!;
            orderBloc.reload(disposeFirst: true);
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const HomeScreen(),
                ),
                (route) => false,
              );

              await PrintOrder(
                printData: printData,
              ).launch(context);
            });
          } else {
            await _errorAnimation();
          }
        } else if (orderBloc.getDeliveryTime == null) {
          setState(() {
            deliveryTimeRequired = true;
          });
          scaffoldAlert(
            context,
            'Debe seleccionar una franja horaria para la entrega del pedido',
            const Duration(seconds: 1),
            backGroundColor: errorColor,
          );
          await _errorAnimation();
        } else {
          await _errorAnimation();
        }

        // _btnController.error();
        // await Future.delayed(Duration(seconds: 1));

        // _btnController.reset();
      },
      child: Container(
        width: 165,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius3),
        ),
        child: Text(
          'Finalizar pedido',
          style: buttonsSmallTextStyle(
            context,
            color: !sending ? pColor : greyColor,
          ),
        ),
      ),
      width: 145,
      errorColor: errorColor,
      successColor: okColorWappsi,
      valueColor: Colors.white,
    );
  }

  Future<void> _errorAnimation() async {
    _btnController.error();
    await Future.delayed(const Duration(seconds: 2));
    _btnController.reset();
  }
}
