import 'dart:io' as io;
// import 'dart:typed_data';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/printer_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';

// import 'package:pos_wappsi/screens/sales/components/widgets.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/blue_print/blue_print.dart';

class PrintSettings extends StatefulWidget {
  final String print;
  final Map<String, String>? movementInfo;
  final Map<dynamic, dynamic>? posPrintData;

  /// Receive an string `print` wich could be ['settings','movement','pos'], with that, print
  /// diferent things depending on the `print`, also receive `movementInfo` wich is required when tryint
  /// to print movement receipt
  PrintSettings(
      {this.print = 'settings', this.movementInfo, this.posPrintData});
  @override
  _PrintSettingsState createState() => new _PrintSettingsState();
}

class _PrintSettingsState extends State<PrintSettings> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  bool _printing = false;
  bool _conecting = false;
  late String pathImage;
  late PrintFormat? printFormat;
  late Color _pc;
  late Size _size;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    if (widget.print == 'pos') {
      printFormat = PrintFormat(
          productsList: widget.posPrintData?['products'] ?? [],
          movementInfo: widget.movementInfo);
      initSavetoPath(widget.posPrintData?['company_data'].logo);
    } else if (widget.print == 'movement') {
      String companyLogo = dataBloc.getBillerCompany!.logo!;
      if (companyLogo.substring(companyLogo.length - 4) == '.png') {
        companyLogo = companyLogo.substring(0, companyLogo.length - 4) + '.jpg';
      }

      initSavetoPath(companyLogo);
      printFormat = PrintFormat(movementInfo: widget.movementInfo);
    } else {
      printFormat = PrintFormat();
    }
  }

  initSavetoPath(String image) async {
    final filename = image;
    String imgURL = dataBloc.userData!.hostUrl +
        dataBloc.userData!.companyFolder +
        'assets/uploads/logos/' +
        image;

    final img = image;
    //if img is png convert to png
    if (img.substring(img.length - 4) == '.png') {
      imgURL = "https://wappsi281.com" +
          "/wappsi_apis/public/utils/pngToJpg?img=" +
          imgURL;
    }

    String dir = (await getApplicationDocumentsDirectory()).path;
    if (!(await io.File('$dir/$filename').exists())) {
      var bytes = await NetworkAssetBundle(Uri.parse(imgURL)).load("");
      writeToFile(bytes, '$dir/$filename');
      setState(() {
        pathImage = '$dir/$filename';
      });
    } else {
      setState(() {
        pathImage = '$dir/$filename';
      });
    }
  }

  Future<void> initPlatformState() async {
    bool? isConnected;
    try {
      isConnected = await bluetooth.isConnected;
    } catch (e) {
      print(e);
      isConnected = false;
    }
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      print('Error on getting bluetooth devices');
    }

    try {
      // Adding listener to bluetooth
      bluetooth.onStateChanged().listen((state) {
        switch (state) {
          case BlueThermalPrinter.CONNECTED:
            setState(() {
              _connected = true;
            });
            break;
          case BlueThermalPrinter.DISCONNECTED:
            setState(() {
              _connected = false;
            });
            break;
          default:
            print(state);
            break;
        }
      });
    } catch (e) {
      print(e);
    }

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected ?? false) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _pc = pColor;
    return Scaffold(
      appBar: appBar(context, 'Dispositivos',
          image: 'assets/images/printer-settings.png'),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      // mainAxisAlignment: ,
      children: <Widget>[
        _deviceSetup().paddingSymmetric(vertical: 5, horizontal: 20).expand(),
        bottom(_buttons(), _pc, _size),
      ],
    );
  }

  Widget _deviceSetup() {
    return Card(
      child: ListView(
        children: [_devicesDropDown().paddingAll(10), _options()],
      ),
    );
  }

  void _connect() async {
    if (_device == null) {
      _noDeviceSelected('Dispositivo no seleccionado.');
    } else {
      setState(() {
        _conecting = true;
      });
      final res = await bluetooth.isConnected;

      if (!(res ?? true)) {
        try {
          final res = await bluetooth.connect(_device!);
          // .timeout(const Duration(seconds: 3));
          if (res) {
            setState(() {
              _connected = true;
              _conecting = false;
              printerBloc.setPrinterDevice(_device);
            });
          } else {
            setState(() {
              _connected = false;
              _conecting = false;
            });
            confirmDialog(context, 'Error al conectarse al dispositivo',
                'assets/images/warning.png');
          }
        } catch (e) {
          setState(() {
            _connected = false;
            _conecting = false;
          });
          confirmDialog(context, 'Error al conectarse al dispositivo',
              'assets/images/warning.png');
        }
      } else {
        confirmDialog(context, 'Ya se encuentra conectado a un dispositivo',
            'assets/images/warning.png');
      }
    }
  }

  void _disconnect() async {
    try {
      final res = await bluetooth.disconnect();
      print(res);
      setState(() => _connected = false);
    } catch (e) {
      print(e);
    }
  }

  //write to app path
  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new io.File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  _noDeviceSelected(String message) {
    confirmDialog(context, message, 'assets/images/warning.png');
    // await new Future.delayed(new Duration())
  }

  Widget _options() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        AppButton(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          // color: _pc,
          onTap: () {
            initPlatformState();
          },
          child: Text(
            'Recargar',
            style: TextStyle(color: pColor),
          ),
        ),
        SizedBox(
          width: 20,
        ),
        AppButton(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          color: _connected ? Colors.red : Colors.white,
          enabled: !_conecting,
          onTap: _connected ? _disconnect : _connect,
          child: Text(
            _connected ? 'Desconectar' : 'Conectar',
            style: TextStyle(color: _connected ? Colors.red : pColor),
          ),
        ),
      ],
    );
  }

  Widget _devicesDropDown() {
    return DropdownSearch<BluetoothDevice>(
      mode: Mode.BOTTOM_SHEET,
      maxHeight: _size.width * 0.9,
      dialogMaxWidth: _size.width * 0.8,
      isFilteredOnline: true,
      showClearButton: true,
      dropdownBuilder: (context, selectedItem) {
        return Row(
          children: [
            Icon(selectedItem?.name == "InnerPrinter"
                    ? Icons.print_outlined
                    : FontAwesomeIcons.bluetooth)
                .paddingRight(10),
            Text(selectedItem?.name == "InnerPrinter"
                ? 'Impresora integrada'
                : (selectedItem?.name ?? '')),
          ],
        );
      },
      showSelectedItems: true,
      compareFn: (item, selectedItem) => item?.name == selectedItem?.name,
      items: _devices,
      selectedItem: printerBloc.getPrinterDevice,
      emptyBuilder: (context, searchEntry) =>
          Text('No se encontraron dispositivos').center(),
      dropdownSearchDecoration: InputDecoration(
        // errorText: 'Seleccione un dispositivo',
        helperText: 'Impresora POS Bluetooth ',
        // semanticCounterText: 'xd',
        labelText: 'Dispositivos',
        labelStyle: TextStyle(color: _pc),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),

      autoValidateMode: AutovalidateMode.onUserInteraction,
      popupItemBuilder: popupCustomItemBuilder,
      onChanged: (value) {
        setState(() => _device = value);
      },
      // selectedItem: posBloc.getCustomer,
      popupSafeArea: PopupSafeAreaProps(top: true, bottom: true),

      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget popupCustomItemBuilder(
      BuildContext context, BluetoothDevice? item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: pColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(item?.name == "InnerPrinter"
            ? 'Impresora integrada'
            : (item?.name ?? '')),
        subtitle: Text(item?.name ?? ''),
        leading: CircleAvatar(
          child: Icon(item?.name == "InnerPrinter"
              ? FontAwesomeIcons.print
              : FontAwesomeIcons.bluetooth),
        ),
      ),
    );
  }

  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [_backButton(), _printButton()],
    );
  }

  AppButton _backButton() {
    return AppButton(
      padding: kButtonPadding,
      onTap: () {
        Navigator.pop(context);
      },
      child: Row(
        children: [
          Icon(Icons.arrow_back_ios, size: kIconSize, color: pColor,),
          Text(
            'Regresar',
            style: buttonsSmallTextStyle(context, color: pColor),
          ),
        ],
      ),
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
        try {
          // setState(() async {
          _connected = await bluetooth.isConnected ?? false;
          // });
        } catch (e) {
          print(e);
        }
        if ((_connected)) {
          setState(() {
            // posBloc.setPrintState(true);
            _printing = true;
          });
          if (widget.print == 'settings') {
            printFormat = new PrintFormat(productsList: []);
            scaffoldAlert(context, 'Impresión de prueba', Duration(seconds: 2));
            printFormat!.printTest();
            await Future.delayed(Duration(seconds: 3));
            hideCurrentScaffoldAlert(context);
            setState(() {
              _printing = false;
            });
            // to print movement info
          } else if (widget.print == 'movement' &&
              widget.movementInfo != null) {
            scaffoldAlert(context, 'Imprimiendo comprobante de movimiento',
                Duration(seconds: 10));

            final result = await printFormat!.printMovement(pathImage);
            if (result ?? false) {
              await Future.delayed(Duration(seconds: 3));
              hideCurrentScaffoldAlert(context);
              setState(() {
                _printing = false;
              });
            } else {
              scaffoldAlert(context, 'Error al imprimir', Duration(seconds: 3));
            }
          } else if (widget.print == 'pos') {
            scaffoldAlert(
                context, 'Imprimiendo comprobante', Duration(seconds: 2));

            final result =
                await printFormat!.printPOS(pathImage, widget.posPrintData);
            if (result ?? false) {
              await Future.delayed(Duration(seconds: 3));
              hideCurrentScaffoldAlert(context);
              setState(() {
                _printing = false;
              });
            } else {
              scaffoldAlert(context, 'Error al imprimir', Duration(seconds: 3));
            }
          }
        } else {
          confirmDialog(
              context,
              'Impresora no conectada, seleccione una y intente nuevamente',
              'assets/images/alert.png');
        }
      },
      child: Row(
        children: [
          Icon(Icons.print, size: kIconSize, color: pColor,),
          Text(
            ' Imprimir',
            style: buttonsSmallTextStyle(context, color: pColor),
          ),
        ],
      ),
    );
  }
}
