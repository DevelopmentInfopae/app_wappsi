import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';

import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:pos_wappsi/bloc/pos_bloc.dart';

import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/config/img_dir.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/screens/cash_accounting/components/widgets.dart';
import 'package:pos_wappsi/screens/home/home_screen.dart';
import 'package:pos_wappsi/screens/sales/components/preview_widgets.dart';
// import 'package:pos_wappsi/screens/sales/new_sale.dart';
import 'package:pos_wappsi/screens/settings/print_settings.dart';
// import 'package:pos_wappsi/screens/sales/components/widgets.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/blue_print/blue_print.dart';
// import 'package:pos_wappsi/utils/local_files.dart';

class PrintMovement extends StatefulWidget {
  final Map<String, String> movementInfo;
  PrintMovement({Key? key, required this.movementInfo});
  @override
  _PrintMovementState createState() => new _PrintMovementState();
}

class _PrintMovementState extends State<PrintMovement> {
  late Color _pc;
  late Size _size;
  // String pathImage = '';
  bool _printing = false;

  //bluetooth setup
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  late PrintFormat printFormat;

  @override
  void initState() {
    printFormat = PrintFormat(movementInfo: widget.movementInfo);
    // initSavetoPath();
    // initPlatformState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _pc = pColor;
    return WillPopScope(
      onWillPop: () async {
        dataBloc.homeKey.currentState?.changeBottomIndex(1);
        // print('here i am');
        return true;
      },
      child: Scaffold(
        appBar: appBar(context, 'Movimientos',
            back: true, image: 'assets/images/cash-register.png', onPop: () {
          dataBloc.homeKey.currentState?.changeBottomIndex(1);
          Navigator.pop(context);
        }),
        body: _body(),
      ),
    );
  }

  Widget _body() {
    return Column(
      // mainAxisAlignment: ,
      children: <Widget>[
        _preview().expand(),
        // movementDetails(context, widget.movementInfo),
        bottom(_buttons(), _pc, _size),
      ],
    );
  }

  Widget _preview() {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: _size.width * 0.9,
      // padding: EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Card(
          child: Column(
            children: [
              billerImage(dataBloc.getBillerCompany!.logo!)
                  .paddingSymmetric(horizontal: 40)
                  .withHeight(
                      _size.height * 0.08 > 60 ? _size.height * 0.08 : 60),
              socialReason(dataBloc.settings?['razon_social'], textTheme),
              emptyLine(),
              movementDetails(context, widget.movementInfo),
              emptyLine(),
              emptyLine(),
              emptyLine(),
              emptyLine(),
              emptyLine(),
              emptyLine(),
              _signatureStamp(),
              emptyLine(),
            ],
          ).paddingSymmetric(horizontal: 20),
        ),
      ),
    );
  }

  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _printButton(),
        _exitButton(),
      ],
    );
  }

  AppButton _printButton() {
    return AppButton(
      color: Colors.white,
      //padding: kButtonPadding,
      disabledColor: Colors.grey[350],
      width: _size.width * 0.1,
      enabled: !_printing,
      onTap: () async {
        bool isConnected;
        try {
          // final xd = await bluetooth.isOn;
          isConnected = await bluetooth.isConnected ?? false;
        } catch (e) {
          print(e);
          isConnected = false;
        }
        // if ((isConnected)) {
        if ((isConnected)) {
          setState(() {
            // posBloc.setPrintState(true);
            _printing = true;
          });

          scaffoldAlert(context, 'Imprimiendo comprobante de movimiento',
              Duration(seconds: 3));
          String companyLogo = dataBloc.getBillerCompany!.logo!;
          if (companyLogo.substring(companyLogo.length - 4) == '.png') {
            companyLogo =
                companyLogo.substring(0, companyLogo.length - 4) + '.jpg';
          }
          final result = await printFormat
              .printMovement(dataBloc.dirPath! + billerImgDir + companyLogo);
          if (result ?? false) {
            await Future.delayed(Duration(seconds: 3));
            hideCurrentScaffoldAlert(context);
            setState(() {
              _printing = false;
            });
          } else {
            scaffoldAlert(context, 'Error al imprimir', Duration(seconds: 3));
          }
        } else {
          PrintSettings(
            print: 'movement',
          ).launch(context);
        }
      },
      child: Row(
        children: [
          Text(
            'Imprimir ',
            style: buttonsSmallTextStyle(context),
          ),
          Icon(Icons.print)
        ],
      ),
    );
  }

  AppButton _exitButton() {
    return AppButton(
      color: Colors.white,
      //padding: kButtonPadding,
      // disabledColor: Colors.white,
      width: _size.width * 0.1,
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen(),
          ),
          (route) => false,
        );
        dataBloc.homeKey.currentState?.changeBottomIndex(1);
      },
      child: Row(
        children: [
          Text(
            'Salir ',
            style: buttonsSmallTextStyle(context),
          ),
          Icon(Icons.exit_to_app)
        ],
      ),
    );
  }

  Widget _signatureStamp() {
    return Column(
      children: [
        Text('____________________________________',
            style: normalTextStyle(context)),
        Text('Firma y sello', style: normalTextStyle(context))
      ],
    );
  }
}
