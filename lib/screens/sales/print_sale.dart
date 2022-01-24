import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';

import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:pos_wappsi/bloc/data_bloc.dart';

import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/config/img_dir.dart';
import 'package:pos_wappsi/constant.dart';
// import 'package:pos_wappsi/providers/sync_db_provider.dart';
import 'package:pos_wappsi/screens/home/home_screen.dart';
import 'package:pos_wappsi/screens/sales/components/preview_widgets.dart';
import 'package:pos_wappsi/screens/sales/new_sale.dart';
import 'package:pos_wappsi/screens/settings/print_settings.dart';
// import 'package:pos_wappsi/screens/sales/components/widgets.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/blue_print/blue_print.dart';
// import 'package:pos_wappsi/utils/local_files.dart';

class PrintSale extends StatefulWidget {
  final bool back;
  final String image;
  final bool exitToNewSale;
  final Map<dynamic, dynamic> printData;
  const PrintSale(
      {Key? key,
      required this.printData,
      this.back = false,
      this.exitToNewSale = true,
      this.image = 'assets/images/printer.png'});
  @override
  _PrintSaleState createState() => new _PrintSaleState();
}

class _PrintSaleState extends State<PrintSale> {
  late Color _pc;
  late Size _size;
  bool _printing = false;

  //bluetooth setup
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  late PrintFormat printFormat;

  @override
  void initState() {
    printFormat = PrintFormat(productsList: widget.printData['products']);
    // initSavetoPath();
    // initPlatformState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _pc = Theme.of(context).primaryColor;
    return WillPopScope(
      onWillPop: () async {
        // To control pop from nav keys on device

        // final syncDB = new SyncDBProvider();
        // await Future.wait([
        //   syncDB.syncOption(context, 'Precios de Productos'),
        //   syncDB.syncOption(context, 'Productos de Sucursales'),
        // ]);
        return true;
      },
      child: Scaffold(
        appBar: appBar(
          context,
          'Imprimir venta POS',
          back: widget.back,
          image: widget.image,
        ),
        body: _body(),
      ),
    );
  }

  Widget _body() {
    return Column(
      // mainAxisAlignment: ,
      children: <Widget>[
        _preview().expand(),
        bottom(_buttons(), _pc, _size),
      ],
    );
  }

  Widget _preview() {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: _size.width * 0.9,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Card(
          child: Column(
            children: [
              billerImage(widget.printData['company_data'].logo)
                  .paddingSymmetric(horizontal: 40)
                  .withHeight(
                      _size.height * 0.09 > 60 ? _size.height * 0.09 : 60),
              legalInformation(textTheme, widget.printData),
              emptyLine(),
              invoiceRef(textTheme, widget.printData),
              emptyLine(),
              billerData(textTheme, widget.printData)
                  .withWidth(_size.width * 0.75)
                  .paddingSymmetric(horizontal: 10),
              emptyLine(),
              products(widget.printData).withWidth(_size.width * 0.75),
              emptyLine(),
              paymentDetails(textTheme, widget.printData)
                  .withWidth(_size.width * 0.75)
                  .paddingSymmetric(horizontal: 10),
              emptyLine(),
              taxRatesValues(textTheme, widget.printData)
                  .withWidth(_size.width * 0.75),
              emptyLine(),
              posNote(textTheme, widget.printData),
              resolution(textTheme, widget.printData)
                  .paddingSymmetric(horizontal: 10)
                  .center(),
              // emptyLine(),
              wappsiSpam(textTheme, widget.printData)
                  .paddingSymmetric(horizontal: 10),
              emptyLine(),
              emptyLine(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _exitButton(),
        _printButton(),
      ],
    );
  }

  AppButton _printButton() {
    return AppButton(
      color: Colors.white,
      padding: kButtonPadding,
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

          scaffoldAlert(
              context, 'Imprimiendo comprobante', Duration(seconds: 3));
          String companyLogo = widget.printData['company_data'].logo;
          if (companyLogo.substring(companyLogo.length - 4) == '.png') {
            companyLogo =
                companyLogo.substring(0, companyLogo.length - 4) + '.jpg';
          }
          final result = await printFormat.printPOS(
              dataBloc.dirPath! + billerImgDir + companyLogo, widget.printData);
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
            print: 'pos',
            posPrintData: widget.printData,
          ).launch(context);
        }
      },
      child: Row(
        children: [
          Text(
            'Imprimir ',
            style: buttonsSmallTextStyle(context),
          ),
          Icon(Icons.print, size: kIconSize)
        ],
      ),
    );
  }

  AppButton _exitButton() {
    return AppButton(
      color: Colors.white,
      padding: kButtonPadding,
      // disabledColor: Colors.white,
      width: _size.width * 0.1,
      onTap: () async {
        // final syncDB = new SyncDBProvider();
        // final res = await Future.wait([
        //   syncDB.syncOption(context, 'Precios de Productos'),
        //   syncDB.syncOption(context, 'Productos de Sucursales'),
        // ]);

        // print(res);

        if (widget.exitToNewSale) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => HomeScreen(),
            ),
            (route) => false,
          );
          NewSale().launch(context);
        } else {
          Navigator.pop(context);
        }
      },
      child: Row(
        children: [
          Text(
            'Salir ',
            style: buttonsSmallTextStyle(context),
          ),
          Icon(Icons.exit_to_app, size: kIconSize)
        ],
      ),
    );
  }
}
