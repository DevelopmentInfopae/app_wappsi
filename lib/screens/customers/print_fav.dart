import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:pos_wappsi/bloc/data_bloc.dart';

import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/go_back_bottom.dart';
import 'package:pos_wappsi/components/preview_print/preview_widgets.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/config/img_dir.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/providers/customer_addresses_provider.dart';
import 'package:pos_wappsi/screens/customers/components/select_customer_add_alert.dart';
// import 'package:pos_wappsi/providers/sync_db_provider.dart';

import 'package:pos_wappsi/screens/settings/print_settings.dart';
// import 'package:pos_wappsi/screens/sales/components/widgets.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/blue_print/blue_print.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
// import 'package:pos_wappsi/utils/local_files.dart';

class PrintFav extends StatefulWidget {
  final bool back;
  final String image;
  final bool exitToNewOrder;
  final Map<dynamic, dynamic> printData;
  const PrintFav({
    Key? key,
    required this.printData,
    this.back = false,
    this.exitToNewOrder = true,
    this.image = 'assets/images/printer.png',
  }) : super(key: key);
  @override
  _PrintFavState createState() => _PrintFavState();
}

class _PrintFavState extends State<PrintFav> {
  late Color _pc;
  late Size _size;
  bool _printing = false;

  //bluetooth setup
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  late PrintFormat printFormat;

  @override
  void initState() {
    printFormat = PrintFormat(productsList: widget.printData['products']);
    // initSaveToPath();
    // initPlatformState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _pc = pColor;
    return WillPopScope(
      onWillPop: () async {
        // To control pop from nav keys on device

        // final syncDB = SyncDBProvider();
        // await Future.wait([
        //   syncDB.syncOption(context, 'Precios de Productos'),
        //   syncDB.syncOption(context, 'Productos de Sucursales'),
        // ]);
        return true;
      },
      child: Scaffold(
        appBar: appBar(
          context,
          'Imprimir favoritos',
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Card(
          child: Column(
            children: [
              billerImage(widget.printData['company_data'].logo)
                  .paddingSymmetric(horizontal: 40)
                  .withHeight(
                    _size.height * 0.09 > 60 ? _size.height * 0.09 : 60,
                  ),
              legalInformation(textTheme, widget.printData),
              emptyLine(),
              emptyLine(),
              headerData(textTheme, widget.printData)
                  .withWidth(_size.width * 0.75)
                  .paddingSymmetric(horizontal: 10),
              emptyLine(),

              productsFavorites(widget.printData).withWidth(_size.width * 0.75),
              emptyLine(),
              emptyLine(),

              emptyLine(),

              wappsiSpam(textTheme, widget.printData)
                  .paddingSymmetric(horizontal: 10),
              // emptyLine(),
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
        const GoBackBottom(),
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
        final addresses = await CustomerAddressesProvider.loadCustomerAddresses(
          widget.printData['customer']['id_cloud'].toString(),
        );
        // printConsole(addresses);
        if (addresses.length > 1) {
          final address = await showCupertinoDialog<CustomerAddressesModel?>(
            barrierDismissible: true,
            context: context,
            useRootNavigator: false,
            builder: (context) {
              return SelectCustomerAddressAlert(
                customer: CompanyModel.fromJson(widget.printData['customer']),
                addresses: addresses,
              );
            },
          );
          widget.printData['customer_address'] = address?.toJson();
        }
        bool isConnected;

        try {
          // final xd = await bluetooth.isOn;
          isConnected = await bluetooth.isConnected ?? false;
        } catch (e) {
          printConsole(e);
          isConnected = false;
        }
        // if ((isConnected)) {
        if ((isConnected)) {
          setState(() {
            // posBloc.setPrintState(true);
            _printing = true;
          });

          scaffoldAlert(
            context,
            'Imprimiendo favoritos',
            const Duration(seconds: 3),
          );
          String companyLogo = widget.printData['company_data'].logo;
          if (companyLogo.substring(companyLogo.length - 4) == '.png') {
            companyLogo =
                companyLogo.substring(0, companyLogo.length - 4) + '.jpg';
          }
          final result = await printFormat.printFavOrder(
            dataBloc.dirPath! + billerImgDir + companyLogo,
            widget.printData,
          );
          if (result ?? false) {
            await Future.delayed(const Duration(seconds: 1));
            hideCurrentScaffoldAlert(context);
            setState(() {
              _printing = false;
            });
          } else {
            scaffoldAlert(
              context,
              'Error al imprimir',
              const Duration(seconds: 3),
            );
          }
        } else {
          PrintSettings(
            print: 'favorites',
            posPrintData: widget.printData,
          ).launch(context);
        }
      },
      child: Row(
        children: [
          const Icon(Icons.print, size: kIconSize, color: pColor),
          Text(
            'Imprimir ',
            style: buttonsSmallTextStyle(context, color: pColor),
          ),
        ],
      ),
    );
  }
}
