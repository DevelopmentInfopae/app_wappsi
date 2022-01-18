// ignore_for_file: unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/suspended_sale_model.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/screens/sales/components/product_price_dif_alert.dart';
import 'package:pos_wappsi/screens/sales/new_sale.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/functions.dart';

class SuspendedSaleDetails extends StatefulWidget {
  final Map<String, dynamic>? suspSaleInfo;
  SuspendedSaleDetails({Key? key, required this.suspSaleInfo})
      : super(key: key);

  @override
  _SuspendedSaleDetailsState createState() => _SuspendedSaleDetailsState();
}

class _SuspendedSaleDetailsState extends State<SuspendedSaleDetails> {
  late Size _size;
  late List<ProductModel> _products;

  @override
  void initState() {
    super.initState();
    _products = widget.suspSaleInfo?['products_info']['products'] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: appBar(context, 'Detalles',
            leading: _leading(), image: 'assets/images/sleeping.png'),
        body: _body().paddingSymmetric());
  }

  Widget _leading() {
    return AppButton(
        padding: kIconButtonPadding,
        width: 10,
        elevation: 0,
        color: Colors.white,
        shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          FontAwesomeIcons.trashAlt,
          color: Colors.red,
          size: iconSize(context),
        ),
        onTap: () async {
          final choice = await choiceAlert(
              context,
              '¿Desea eliminar esta venta suspendida?',
              'assets/images/alert.png');
          if (choice) {
            await SuspendedSales.deleteSuspSale(
                (widget.suspSaleInfo?['suspended_sale'] ?? 0).toString());
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            );
            NewSale().launch(context);
          }
        });
  }

  Widget _body() {
    final size = MediaQuery.of(context).size;
    final valueT = getFormatedCurrency(widget.suspSaleInfo?['total_value']);
    return Column(
      children: [
        ListView(
          children: [
            customerPhotoAndName(context, widget.suspSaleInfo!['customer']),
            Card(
              child: Container(
                width: double.infinity,
                height: 65,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: size.width * 0.4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          descText('Items', context, fontSizeFactor: 1),
                          descText(
                              widget.suspSaleInfo?['items'].toString() ?? '',
                              context,
                              textStyle: numbersTextStyle(
                                  fontSizeFactor: 1.1, color: greyDarkerColor))
                        ],
                      ),
                      alignment: Alignment.center,
                    ),
                    vDivider(),
                    Container(
                      width: size.width * 0.4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          descText('Total', context, fontSizeFactor: 1),
                          descText(
                              valueT.substring(0, valueT.length - 3), context,
                              textStyle: numbersTextStyle(
                                  fontSizeFactor: 1.1, color: greyDarkerColor)),
                        ],
                      ),
                      alignment: Alignment.center,
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: DataTable(
                  columnSpacing: 25,
                  headingTextStyle: normalTextStyle(context),
                  showCheckboxColumn: true,
                  dividerThickness: 2,
                  columns: _pColumns(),
                  rows: _pRows()),
            ),
          ],
        ).expand(),
        bottom(_buttons(), pColor, _size)
      ],
    );
  }

  List<DataRow> _pRows() {
    final List<ProductModel> products = _products;
    final size = MediaQuery.of(context).size;
    return products.map((p) {
      final price = getFormatedCurrency(p.price);
      return DataRow(cells: <DataCell>[
        DataCell(Text(p.quantity.toString()).withWidth(size.width * 0.1)),
        DataCell(Text(p.name).withWidth(size.width * 0.55)),
        DataCell(Text(price.substring(0, price.length - 3))
            .withWidth(size.width * 0.25))
      ]);
    }).toList();
  }

  List<DataColumn> _pColumns() {
    final size = MediaQuery.of(context).size;
    return [
      DataColumn(
        label: Text(
          'Cant',
          style: TextStyle(fontStyle: FontStyle.italic),
        ).withWidth(size.width * 0.1),
      ),
      DataColumn(
        label: Text(
          'Nombre',
          style: TextStyle(fontStyle: FontStyle.italic),
        ).withWidth(size.width * 0.55),
      ),
      DataColumn(
        label: Text(
          'Precio c/u',
          style: TextStyle(fontStyle: FontStyle.italic),
        ).withWidth(size.width * 0.25),
      ),
    ];
  }

  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [_exitButton(), _loadButton()],
    );
  }

  AppButton _exitButton() {
    return AppButton(
      color: Colors.white,
      padding: kButtonPadding,
      // disabledColor: Colors.white,
      width: _size.width * 0.1,
      onTap: () {
        Navigator.pop(context);
      },
      child: Row(
        children: [
          Icon(
            Icons.arrow_back_ios,
            size: kIconSize,
          ),
          Text(
            'Regresar ',
            style: buttonsSmallTextStyle(context),
          ),
        ],
      ),
    );
  }

  AppButton _loadButton() {
    return AppButton(
      color: Colors.white,
      padding: kButtonPadding,
      // disabledColor: Colors.white,
      width: _size.width * 0.1,
      onTap: () async {
        final dif = widget.suspSaleInfo?['products_info']['dif'] ?? [];
        if (dif.length != 0) {
          await priceDiffAlert(context, dif,
              (widget.suspSaleInfo?['suspended_sale']).toString());
        } else {
          bool load = true;
          if ((posBloc.getProducts?.length ?? 0) > 0) {
            load = await choiceAlert(
                context,
                'Se ha detectado una venta en progreso. \n ¿Desea continuar?',
                'assets/images/alert.png');
          }

          if (load) {
            final res = await posBloc.loadSuspendedSale(
                (widget.suspSaleInfo?['suspended_sale']).toString());

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            );
            NewSale().launch(context);
            if (res.length > 0) {
              listInfoDialog(
                  context, res, 'name', 'inventory', 'Producto', 'Stock',
                  flexCol1: 3,
                  flexCol2: 1,
                  title:
                      'Error al cargar los siguientes productos de la venta:');
            }
          }
        }
      },
      child: Row(
        children: [
          Text(
            'Reanudar venta',
            style: buttonsSmallTextStyle(context),
          ),
          // Icon(Icons.load),
        ],
      ),
    );
  }
}
