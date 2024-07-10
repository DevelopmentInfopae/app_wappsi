// ignore_for_file: unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/screens/components/appbar_leading.dart';
import 'package:pos_wappsi/screens/components/back_app_bar.dart';
import 'package:pos_wappsi/screens/components/products/product_card_info.dart';
import 'package:pos_wappsi/screens/components/products/product_card_w_unit.dart';
import 'package:pos_wappsi/screens/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/providers/suspended_sales_provider.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/screens/sales/components/product_price_dif_alert.dart';
import 'package:pos_wappsi/screens/sales/new_sale.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

class SuspendedSaleDetails extends StatefulWidget {
  final Map<String, dynamic>? suspSaleInfo;
  const SuspendedSaleDetails({Key? key, required this.suspSaleInfo})
      : super(key: key);

  @override
  _SuspendedSaleDetailsState createState() => _SuspendedSaleDetailsState();
}

class _SuspendedSaleDetailsState extends State<SuspendedSaleDetails> {
  late Size _size;
  late List<ProductModel> _products;
  late List<UnitsModel?> _units;

  @override
  void initState() {
    super.initState();
    _products = widget.suspSaleInfo?['products_info']['products'] ?? [];
    _units = widget.suspSaleInfo?['products_info']['products_unit'] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: appBar(
        context,
        'Detalles',
        leading: _leading(),
        image: 'assets/images/sleeping.png',
      ),
      body: _body(),
    );
  }

  Widget _leading() {
    return AppBarLeading(
      widget: Icon(
        FontAwesomeIcons.trashCan,
        color: Colors.red,
        size: leadingIconSize - 4,
      ),
      onTap: () async {
        final choice = await choiceAlert(
          context,
          '¿Desea eliminar esta venta suspendida?',
          'assets/images/alert.png',
        );
        if (choice) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
          );
          const NewSale().launch(context);
        }
      },
    );
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
              child: SizedBox(
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
                          descText(
                            'Items',
                            context,
                            fontSizeFactor: 1,
                          ),
                          descText(
                            widget.suspSaleInfo?['items'].toString() ?? '',
                            context,
                            textStyle: numbersTextStyle(
                              fontSizeFactor: 1.1,
                              color: pColor,
                            ),
                          )
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
                            valueT.substring(0, valueT.length),
                            context,
                            textStyle: numbersTextStyle(
                              fontSizeFactor: 1.1,
                              color: pColor,
                            ),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                    ),
                  ],
                ),
              ),
            ),
            _productList()
          ],
        ).expand(),
        bottom(_buttons(), pColor, _size)
      ],
    );
  }

  Widget _productList() {
    List<Widget> _pCards = [];
    for (int i = 0; i < _products.length; i++) {
      if (_units.isNotEmpty) {
        _products[i].unit = _units[i]?.idCloud ?? _products[i].unit;
        _pCards.add(
          ProductCardWUnit(
            product: _products[i],
            action: 'product_details',
            unit: _units[i],
            searchPrice: false,
          ),
        );
      } else {
        _products[i].inventory = _products[i].quantity;
        _pCards.add(
          ProductCard(
            product: _products[i],
            action: 'prodouct_details',
            searchPrice: false,
          ),
        );
      }
    }
    return SingleChildScrollView(
      child: Column(
        children: _pCards,
      ),
    );
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
          const Icon(
            Icons.arrow_back_ios,
            size: kIconSize,
            color: pColor,
          ),
          Text(
            'Regresar ',
            style: buttonsSmallTextStyle(context, color: pColor),
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
        bool load = true;
        if ((posBloc.getProducts?.length ?? 0) > 0) {
          load = await choiceAlert(
            context,
            'Se ha detectado una venta en progreso. \n ¿Desea continuar?',
            'assets/images/alert.png',
          );
        }

        if (load) {
          final dif = widget.suspSaleInfo?['products_info']['dif'] ?? [];
          if (dif?.length != 0) {
            await priceDiffAlert(
              context,
              dif,
              (widget.suspSaleInfo?['suspended_sale']).toString(),
            );
          } else {
            final res = await posBloc.loadSuspendedSale(
              (widget.suspSaleInfo?['suspended_sale']).toString(),
            );

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            );
            const NewSale().launch(context);
            if (res.isNotEmpty) {
              listInfoDialog(
                context,
                res,
                'name',
                'inventory',
                'Producto',
                'Stock',
                flexCol1: 3,
                flexCol2: 1,
                title: 'Error al cargar los siguientes productos de la venta:',
              );
            } else {
              // confirmDialog(context, 'Venta suspendida cargada correctamente',
              //     'assets/images/success.png');
              scaffoldAlert(
                context,
                'Venta suspendida cargada correctamente',
                const Duration(milliseconds: 500),
              );
            }
          }
        }
      },
      child: Row(
        children: [
          Text(
            'Reanudar venta',
            style: buttonsSmallTextStyle(context, color: pColor),
          ),
          // Icon(Icons.load),
        ],
      ),
    );
  }
}
