// ignore_for_file: unnecessary_null_comparison

// import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/orders_bloc.dart';
// import 'package:pos_wappsi/bloc/sync_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/widgets.dart';

import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/payment_methods_model.dart';
import 'package:pos_wappsi/providers/payment_methods_provider.dart';

// import 'package:pos_wappsi/providers/sync_db_provider.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
// import 'package:pos_wappsi/screens/db_sync/components/sync_popup.dart';
// import 'package:pos_wappsi/screens/home/home_screen.dart';
import 'package:pos_wappsi/screens/sales/components/widgets.dart';


class OrderOtherDetails extends StatefulWidget {
  OrderOtherDetails({Key? key}) : super(key: key);

  @override
  _OrderOtherDetailsState createState() => _OrderOtherDetailsState();
}

class _OrderOtherDetailsState extends State<OrderOtherDetails> {
  // to disable paybutton when awaiting for response
  bool _sending = false;
  // TextEditingController _paymentDocumentController =
  //     new TextEditingController();

  late Size _size;
  TextEditingController _paymentMethodController = new TextEditingController();
  
  TextEditingController _internalNController = new TextEditingController();
  TextEditingController _orderNController = new TextEditingController();
  @override
  void initState() {
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
    return ListView(
        children: [
          _paymentMethod().paddingSymmetric(vertical: 6),
          _invoiceNote().paddingSymmetric(vertical: 6),
          _dispatchNote().paddingSymmetric(vertical: 6)
        ],
      
    ).paddingOnly(left: 16, right: 16,top: 6);
  }
  Widget _paymentMethod() {
    return FutureBuilder(
      future: PaymentMethodsProvider.loadDefaultPaymentMethod(fromPOSSale:false),
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
            icon: Icon(Icons.clear),
            onPressed: () {
              if (_paymentMethodController.text.length == 0)
                Navigator.pop(context);
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
      clearButton: Icon(Icons.clear_rounded),
      compareFn: (item, selectedItem) => item?.name == selectedItem?.name,
      showSearchBox: true,

      dropdownSearchDecoration: InputDecoration(
        labelText: 'Forma de pago :',
        labelStyle: TextStyle(color: pColor),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      autoValidateMode: AutovalidateMode.onUserInteraction,

      onFind: (String? filter) =>
          PaymentMethodsProvider.getPaymentMethods(filter),
      onChanged: (data) {
        print(data);

        setState(() {
          orderBloc.setPaymentMethod(data);
        });
        
        
      },
      // selectedItem: ,
      selectedItem: orderBloc.getPaymentMethod,
      popupSafeArea: PopupSafeAreaProps(top: true, bottom: true),
      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget _invoiceNote() {
    return textFormField(context, 'Nota de venta', (String value) {
      orderBloc.setInternalNote(value);
    }, (String value) {}, () {}, controller: _internalNController,maxLines: 4);
  }

  Widget _dispatchNote() {
    return textFormField(context, 'Nota interna', (String value) {
      orderBloc.setOrderNote(value);
    }, (String value) {}, () {}, controller: _orderNController,maxLines: 4);
  }

  Widget _sendAndPrint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        subTotal(large: true,color:Colors.white, defaultValue: orderBloc.getSubTotal()).paddingLeft(8).expand(),
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
      onTap: _sending ? null : () async {},
      child: Text('Finalizar pedido',
          style: buttonsSmallTextStyle(context,
              color: !_sending ? pColor : greyColor)),
    );
  }

}
