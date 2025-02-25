import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/products_provider.dart';
import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/screens/components/back_app_bar.dart';
import 'package:pos_wappsi/screens/components/widgets.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

class ProductPriceVerifier extends StatelessWidget {
  const ProductPriceVerifier({required this.product, Key? key})
      : super(key: key);

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          appBar(context, 'Verificador', image: 'assets/images/give-money.png'),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 10),
      child: _productDetails(context),
    );
  }

  Widget _productDetails(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FutureBuilder<Map?>(
      future: ProductsProvider.findProductDetails(product.idCloud),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final price = getFormatedCurrency(product.price + 0.0);
          return SingleChildScrollView(
            child: Card(
              child: Column(
                children: [
                  Column(
                    children: [
                      productPhoto(product.image).paddingTop(4).expand(),
                      Column(
                        children: [
                          _productName(context)
                              .paddingOnly(left: 40, right: 40)
                              .center()
                              .withHeight(size.height * 0.076),
                          descText(
                            price.substring(0, price.length),
                            context,
                            color: pColor,
                            fweigth: 4,
                            textStyle: numbersTextStyle(
                              fontSizeFactor: 2,
                              color: pColor,
                            ),
                          ).paddingTop(4),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              descText(
                                'Lista PVP',
                                context,
                                fontSizeFactor: 1,
                                fweigth: 1,
                                color: greyColor,
                              ),
                              _taxInfo(),
                            ],
                          ),
                        ],
                      ).center(),
                    ],
                  ).withHeight(size.height * 0.4),
                  _pricesAndQuantities(size).paddingSymmetric(vertical: 16),
                ],
              ),
            ),
          );
        } else {
          return Loader();
        }
      },
    );
  }

  Widget _taxInfo() {
    return FutureBuilder(
      future: DBProvider.db
          .findTableFieldsById('sma_tax_rates', product.taxRateId.toString()),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        String tax = product.taxMethod == 0 ? 'Incluido' : 'No incluido';
        if (snapshot.hasData) {
          tax = snapshot.data['name'] +
              ' ' +
              (product.taxMethod == 0 ? 'Incluido' : 'No incluido');
        } else {}
        return descText(tax, context, fontSizeFactor: 1, color: greyColor)
            .center();
      },
    );
  }

  Row _pricesAndQuantities(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _prices(size),
        _quantities(size),
      ],
    );
  }

  Widget _quantities(Size size) {
    return FutureBuilder<List<Map>?>(
      future:
          ProductsProvider.findProductQuantities(product.idCloud.toString()),
      builder: (BuildContext context, AsyncSnapshot<List<Map>?> snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: snapshot.data!.map((e) {
              return Column(
                children: [
                  descText(
                    (e['quantity'] ?? product.price).toString(),
                    context,
                    textStyle: numbersTextStyle(
                      color: greyDarkerColor,
                      fontSizeFactor: 1.3,
                    ),
                  ),
                  descText(
                    e['name'] ?? '',
                    context,
                    fontSizeFactor: 0.9,
                    fweigth: 2,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    color: greyColor,
                  ).paddingBottom(8),
                ],
              );
            }).toList(),
          ).withWidth(size.width * 0.45);
        } else {
          return Container();
        }
      },
    );
  }

  Widget _prices(Size size) {
    return FutureBuilder<List<Map>?>(
      future: dataBloc.settings?['prioridad_precios_producto'] == 10
          ? UnitsProvider.getProductUnitsRaw(
              product.idCloud.toString(),
              '',
            )
          : ProductsProvider.findProductPrices(product.idCloud.toString()),
      builder: (BuildContext context, AsyncSnapshot<List<Map>?> snapshot) {
        if (snapshot.hasData && (snapshot.data?.length ?? 0) > 0) {
          return Column(
            children: snapshot.data!.map((e) {
              final price = getFormatedCurrency(
                (e['price'] ?? e['valor_unitario'] ?? product.price) + 0.0,
              );
              return Column(
                children: [
                  descText(
                    price.substring(0, price.length),
                    context,
                    textStyle: numbersTextStyle(
                      color: greyDarkerColor,
                      fontSizeFactor: 1.2,
                    ),
                  ),
                  descText(
                    e['name'] ?? e['name'] ?? '',
                    context,
                    fontSizeFactor: 0.9,
                    fweigth: 2,
                    color: greyColor,
                  ).paddingBottom(8),
                ],
              );
            }).toList(),
          ).withWidth(size.width * 0.45);
        } else {
          return Container();
        }
      },
    );
  }

  Widget _productName(BuildContext context) {
    return descText(
      // ignore: unnecessary_null_comparison
      capitalizeText(product.name),
      context,
      maxLines: 2,
      fweigth: 4,
      textAlign: TextAlign.center,
      color: greyDarkerColor,
      fontSizeFactor: 1.1,
    );
  }
}
