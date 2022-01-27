import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports, unnecessary_import
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/customer_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/screens/products/product_details.dart';
import 'package:pos_wappsi/screens/products/product_price_verifier.dart';
import 'package:pos_wappsi/screens/sales/components/select_product_unit_alert.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

// class to show product indormation in form of a card

class ProductCard extends StatefulWidget {
  final ProductModel product;

  final String action;

  ProductCard({Key? key, required this.product, required this.action})
      : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
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
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
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
            final res = await posBloc.addProduct(widget.product);
            if (res == 'select_product_unit') {
              final units = await UnitsProvider.getProductUnits(
                  widget.product.idCloud.toString(),posBloc.getCustomer!.priceGroupId.toString());
              if(units.length>1){
                await showCupertinoDialog(
                  // to make selection of product unit required
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return SelectProductUnitDialog(product: widget.product,units: units,);
                  });
              }else{

                final res = await posBloc.addProduct(widget.product);
                if(res==true){
                  
                }
              }
              print('here');
            }

            // Navigator.pop(context);
          } else if (widget.action == 'price_verifier') {
            ProductPriceVerifier(product: widget.product).launch(context);
          } else if (widget.action == 'add_to_favorites') {
            customerBloc.addProductToFav(
                widget.product, widget.product.idCloud.toString());
          } else {
            // null;
            ProductDetails(product: widget.product).launch(context);
          }
        });
  }

  Widget _productInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_productName(), _productCode(), _productQttyPrice()],
      ),
    );
  }

  Row _productQttyPrice() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
        'Cantidad: ${widget.product.inventory}',
        style: normalTextStyle(context),
      ),
      FutureBuilder(
        future: _getProductPrice(),
        // initialData: widget.product.price,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Text(
              '${getFormatedCurrency(snapshot.data)}',
              style: normalTextStyle(context, fontWeightDelta: 2),
            );
          } else {
            return Text('\$ ');
          }
        },
      ),
    ]);
  }

  Text _productCode() {
    return Text(
      'Codigo: ' + widget.product.code,
      style: normalTextStyle(context),
    );
  }

  Text _productName() {
    return Text(
      capitalizeText(widget.product.name),
      style: buttonsSmallTextStyle(context),
    );
  }

  Future<double> _getProductPrice() async {
    if (widget.action == 'add_to_cart') {
      // get product price for selected costumer
      final p =
          await posBloc.getProductPrices(widget.product, defaultPrice: true);
      return p.getPriceWithIVA();
    } else {
      return widget.product.getPriceWithIVA();
    }
  }
}
