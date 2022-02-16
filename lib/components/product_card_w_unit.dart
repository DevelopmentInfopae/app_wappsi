import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports, unnecessary_import
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/customer_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
// import 'package:pos_wappsi/environment/environment.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/providers/products_provider.dart';
import 'package:pos_wappsi/screens/products/product_details.dart';
import 'package:pos_wappsi/screens/products/product_price_verifier.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

// class to show product indormation in form of a card

class ProductCardWUnit extends StatefulWidget {
  final ProductModel product;
  final UnitsModel? unit;
  final String action;
  final bool searchPrice;

  const ProductCardWUnit(
      {Key? key,
      required this.product,
      required this.action,
      this.searchPrice = true,
      required this.unit})
      : super(key: key);

  @override
  _ProductCardWUnitState createState() => _ProductCardWUnitState();
}

class _ProductCardWUnitState extends State<ProductCardWUnit> {
  // late TextTheme _textTheme;

  @override
  void initState() {
    // setState(() {

    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // _textTheme = Theme.of(context).textTheme;
    return AppButton(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        padding: EdgeInsets.zero,
        elevation: 5,
        child: Row(
          children: [
            productPhoto(widget.product.image == ''
                    ? 'no_image.png'
                    : widget.product.image)
                .flexible(flex: 2),
            _productInfo().flexible(flex: 7)
          ],
        ),
        onTap: () async {
          if (widget.action == 'add_to_cart') {
            final productReq = await ProductsProvider.getProductRequirements(
                context, widget.product);
            if (productReq != {}) {
              final result = await posBloc.addProduct(productReq);
              printConsole(result);
            }

            // Navigator.pop(context);
          } else if (widget.action == 'price_verifier') {
            ProductPriceVerifier(product: widget.product).launch(context);
          } else if (widget.action == 'add_to_favorites') {
            customerBloc.addProductToFav(
                widget.product, widget.product.idCloud.toString());
          } else {
            // null;
            ProductDetails(
              product: widget.product,
              searchPrice: widget.searchPrice,
            ).launch(context);
          }
        });
  }

  Widget _productInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_productName(), _productQttyPrice()],
      ),
    );
  }

  Row _productQttyPrice() {
    double uValue = 0;
    final uValueWidget = FutureBuilder(
      future: _getProductPrice(),
      // initialData: widget.product.price,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          uValue = snapshot.data;
          final value = getFormatedCurrency(uValue);
          return Text(
            'c/u ' + value.substring(0, value.length),
            style: normalTextStyle(context, fontWeightDelta: 2),
          );
        } else {
          return const Text('\$ ');
        }
      },
    );
    final tValue = getFormatedCurrency(
        widget.unit?.unitValue ?? widget.product.quantity * uValue);

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _productCode(),
          Text(
            widget.unit?.name ?? '',
            style: normalTextStyle(context, fontWeightDelta: 2),
          ),
          Text(
            'Cantidad: ${widget.product.quantity}',
            style: normalTextStyle(context),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            tValue.substring(0, tValue.length),
            style: normalTextStyle(context),
          ),
          uValueWidget
        ],
      ),
    ]);
  }

  // Text _productCode() {
  //   return Text(
  //     'Codigo: ' + widget.product.code,
  //     style: normalTextStyle(context),
  //   );
  // }

  Text _productName() {
    return Text(
      capitalizeText(widget.product.name),
      style: buttonsSmallTextStyle(context),
    );
  }

  Future<double> _getProductPrice() async {
    if (widget.action == 'add_to_cart') {
      // get product price for selected costumer
      final p = await ProductsProvider.getProductPrices(widget.product);
      return p.getPriceWithIVA();
    } else {
      return widget.product.getPriceWithIVA();
    }
  }
}
