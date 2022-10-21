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
import 'package:pos_wappsi/params/print_settings_options.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/environment/environment.dart';
import 'package:pos_wappsi/screens/customers/components/drop_down_s_item.dart';

// import 'package:pos_wappsi/screens/sales/components/widgets.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/blue_print/blue_print.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

class PrintSettings extends StatefulWidget {
  final String print;
  final Map<String, String>? movementInfo;
  final Map<String, String>? registerCloseInfo;
  final Map<dynamic, dynamic>? posPrintData;
  final String? imagePath;

  // ignore: use_key_in_widget_constructors
  /// Receive an string `print` which could be ['settings','movement','pos'], with that, print
  /// different things depending on the `print`, also receive `movementInfo` which is required when trying
  /// to print movement receipt
  const PrintSettings({
    Key? key,
    this.print = 'settings',
    this.movementInfo,
    this.registerCloseInfo,
    this.posPrintData,
    this.imagePath,
  }) : super(key: key);
  @override
  _PrintSettingsState createState() => _PrintSettingsState();
}

class _PrintSettingsState extends State<PrintSettings> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  bool _printing = false;
  bool _connecting = false;
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
        movementInfo: widget.movementInfo,
      );
      initSaveToPath(widget.posPrintData?['company_data'].logo);
    } else if (widget.print == 'order') {
      printFormat = PrintFormat(
        productsList: widget.posPrintData?['products'] ?? [],
        movementInfo: widget.movementInfo,
      );
      initSaveToPath(widget.posPrintData?['company_data'].logo);
    } else if (widget.print == 'quote') {
      printFormat = PrintFormat(
        productsList: widget.posPrintData?['products'] ?? [],
        movementInfo: widget.movementInfo,
      );
      initSaveToPath(widget.posPrintData?['company_data'].logo);
    } else if (widget.print == 'favorites') {
      printFormat = PrintFormat(
        productsList: widget.posPrintData?['products'] ?? [],
        movementInfo: widget.movementInfo,
      );
      initSaveToPath(widget.posPrintData?['company_data'].logo);
    } else if (widget.print == 'movement') {
      String companyLogo = dataBloc.getBillerCompany!.logo!;
      if (companyLogo.substring(companyLogo.length - 4) == '.png') {
        companyLogo = companyLogo.substring(0, companyLogo.length - 4) + '.jpg';
      }

      initSaveToPath(companyLogo);
      printFormat = PrintFormat(movementInfo: widget.movementInfo);
    } else if (widget.print == 'register_close') {
      String companyLogo = dataBloc.getBillerCompany!.logo!;
      if (companyLogo.substring(companyLogo.length - 4) == '.png') {
        companyLogo = companyLogo.substring(0, companyLogo.length - 4) + '.jpg';
      }

      initSaveToPath(companyLogo);
      printFormat = PrintFormat(registerCloseInfo: widget.registerCloseInfo);
    } else {
      printFormat = PrintFormat();
    }
  }

  initSaveToPath(String image) async {
    final filename = image;
    String imgURL = dataBloc.userData!.hostUrl +
        dataBloc.userData!.companyFolder +
        'assets/uploads/logos/' +
        image;

    final img = image;
    //if img is png convert to png
    if (img.substring(img.length - 4) == '.png') {
      imgURL = dataBloc.userData!.hostUrl +
          '/wappsi_apis/utils/pngToJpg?img=' +
          imgURL;
    }

    String dir = (await getApplicationDocumentsDirectory()).path;
    if (!(await io.File('$dir/$filename').exists())) {
      var bytes = await NetworkAssetBundle(Uri.parse(imgURL)).load('');
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
      // printConsole(e);
      await logError(e, from: 'Print initPlatformState');

      isConnected = false;
    }
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      printConsole('Error on getting bluetooth devices');
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
            printConsole(state);
            break;
        }
      });
    } catch (e) {
      await logError(e, from: 'Bluetooth listener');

      // printConsole(e);
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
      appBar: appBar(
        context,
        'Dispositivos',
        image: 'assets/images/printer-settings.png',
      ),
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
        children: [
          _paperSzDropDown().paddingAll(10),
          _devicesDropDown().paddingAll(10),
          _options(),
        ],
      ),
    );
  }

  void _connect() async {
    if (_device == null) {
      _noDeviceSelected('Dispositivo no seleccionado.');
    } else {
      setState(() {
        _connecting = true;
      });
      final res = await bluetooth.isConnected;

      if (!(res ?? true)) {
        try {
          final res = await bluetooth.connect(_device!);
          // .timeout(const Duration(seconds: 3));
          if (res) {
            setState(() {
              _connected = true;
              _connecting = false;
              printerBloc.setPrinterDevice(_device);
            });
          } else {
            setState(() {
              _connected = false;
              _connecting = false;
            });
            confirmDialog(
              context,
              'Error al conectarse al dispositivo',
              'assets/images/warning.png',
            );
          }
        } catch (e) {
          await logError(e, from: 'Connecting to printing device');

          setState(() {
            _connected = false;
            _connecting = false;
          });
          confirmDialog(
            context,
            'Error al conectarse al dispositivo',
            'assets/images/warning.png',
          );
        }
      } else {
        confirmDialog(
          context,
          'Ya se encuentra conectado a un dispositivo',
          'assets/images/warning.png',
        );
      }
    }
  }

  void _disconnect() async {
    try {
      final res = await bluetooth.disconnect();
      printConsole(res);
      setState(() => _connected = false);
    } catch (e) {
      await logError(e, from: 'Disconnect printer');

      // printConsole(e);
    }
  }

  //write to app path
  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return io.File(path).writeAsBytes(
      buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }

  _noDeviceSelected(String message) {
    confirmDialog(context, message, 'assets/images/warning.png');
    // await Future.delayed(Duration())
  }

  Widget _options() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        AppButton(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          // color: _pc,
          onTap: () {
            initPlatformState();
          },
          child: const Text(
            'Recargar',
            style: TextStyle(color: pColor),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        AppButton(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          color: Colors.white,
          enabled: !_connecting,
          onTap: _connected ? _disconnect : _connect,
          child: Text(
            _connected ? 'Desconectar' : 'Conectar',
            style: TextStyle(color: _connected ? Colors.red : pColor),
          ),
        ),
      ],
    );
  }

  Widget _paperSzDropDown() {
    return DropdownSearch<DropdDownSItem>(
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
      compareFn: (item, selectedItem) => item?.name == selectedItem?.name,
      items: (paperSz.values.toList()),
      selectedItem: paperSz[Environment().printerPaperSize],
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Tamaño de papel :',
        labelStyle: TextStyle(color: _pc),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),

      autoValidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (data) async {
        if (data != null) {
          Environment().printerPaperSize = data.value;
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
            Icon(
              selectedItem?.name == 'InnerPrinter'
                  ? Icons.print_outlined
                  : FontAwesomeIcons.bluetooth,
            ).paddingRight(10),
            Text(
              selectedItem?.name == 'InnerPrinter'
                  ? 'Impresora integrada'
                  : (selectedItem?.name ?? ''),
            ),
          ],
        );
      },
      showSelectedItems: true,
      compareFn: (item, selectedItem) => item?.name == selectedItem?.name,
      items: _devices,
      selectedItem: printerBloc.getPrinterDevice,
      emptyBuilder: (context, searchEntry) =>
          const Text('No se encontraron dispositivos').center(),
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
      popupSafeArea: const PopupSafeAreaProps(top: true, bottom: true),

      scrollbarProps: ScrollbarProps(
        isAlwaysShown: true,
        thickness: 7,
      ),
    );
  }

  Widget popupCustomItemBuilder(
    BuildContext context,
    BluetoothDevice? item,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: pColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(
          item?.name == 'InnerPrinter'
              ? 'Impresora integrada'
              : (item?.name ?? ''),
        ),
        subtitle: Text(item?.name ?? ''),
        leading: CircleAvatar(
          child: Icon(
            item?.name == 'InnerPrinter'
                ? FontAwesomeIcons.print
                : FontAwesomeIcons.bluetooth,
          ),
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
          const Icon(
            Icons.arrow_back_ios,
            size: kIconSize,
            color: pColor,
          ),
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

          if ((_connected)) {
            try {
              // just to get an error if pathImage is not initialized
              pathImage += '';
            } catch (e) {
              try {
                await initSaveToPath(widget.posPrintData?['company_data'].logo);
              } catch (e) {
                printConsole(e);
                // await logError(e, from: 'init');
              }
            }
            setState(() {
              // posBloc.setPrintState(true);
              _printing = true;
            });
            if (widget.print == 'settings') {
              printFormat = PrintFormat(productsList: []);
              scaffoldAlert(
                context,
                'Impresión de prueba',
                const Duration(seconds: 2),
              );
              printFormat!.printTest();
              await Future.delayed(const Duration(seconds: 3));
              hideCurrentScaffoldAlert(context);
              setState(() {
                _printing = false;
              });
              // to print movement info
            } else if (widget.print == 'movement' &&
                widget.movementInfo != null) {
              scaffoldAlert(
                context,
                'Imprimiendo comprobante de movimiento',
                const Duration(seconds: 10),
              );

              final result = await printFormat!
                  .printMovement(widget.imagePath ?? pathImage);
              if (result ?? false) {
                await Future.delayed(const Duration(seconds: 3));
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
            } else if (widget.print == 'register_close' &&
                widget.registerCloseInfo != null) {
              scaffoldAlert(
                context,
                'Imprimiendo comprobante cierre de caja',
                const Duration(seconds: 10),
              );

              final result = await printFormat!
                  .printRegisterClose(widget.imagePath ?? pathImage);
              if (result ?? false) {
                await Future.delayed(const Duration(seconds: 3));
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
            } else if (widget.print == 'pos') {
              scaffoldAlert(
                context,
                'Imprimiendo comprobante',
                const Duration(seconds: 2),
              );

              final result = await printFormat!
                  .printPOS(widget.imagePath ?? pathImage, widget.posPrintData);
              if (result ?? false) {
                await Future.delayed(const Duration(seconds: 3));
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
            } else if (widget.print == 'order') {
              scaffoldAlert(
                context,
                'Imprimiendo comprobante',
                const Duration(seconds: 2),
              );

              final result = await printFormat!.printOrder(
                widget.imagePath ?? pathImage,
                widget.posPrintData,
              );
              if (result ?? false) {
                await Future.delayed(const Duration(seconds: 3));
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
            } else if (widget.print == 'quote') {
              scaffoldAlert(
                context,
                'Imprimiendo comprobante',
                const Duration(seconds: 2),
              );

              final result = await printFormat!.printQuote(
                widget.imagePath ?? pathImage,
                widget.posPrintData,
              );
              if (result ?? false) {
                await Future.delayed(const Duration(seconds: 3));
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
            } else if (widget.print == 'favorites') {
              scaffoldAlert(
                context,
                'Imprimiendo favoritos',
                const Duration(seconds: 2),
              );

              final result = await printFormat!.printFavOrder(
                widget.imagePath ?? pathImage,
                widget.posPrintData,
              );
              if (result ?? false) {
                await Future.delayed(const Duration(seconds: 3));
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
            }
          } else {
            confirmDialog(
              context,
              'Impresora no conectada, seleccione una y intente nuevamente',
              'assets/images/alert.png',
            );
          }
        } catch (e) {
          // printConsole(e);
          await logError(e, from: 'Printing ${widget.print}');
        }
      },
      child: Row(
        children: [
          const Icon(
            Icons.print,
            size: kIconSize,
            color: pColor,
          ),
          Text(
            ' Imprimir',
            style: buttonsSmallTextStyle(context, color: pColor),
          ),
        ],
      ),
    );
  }
}
