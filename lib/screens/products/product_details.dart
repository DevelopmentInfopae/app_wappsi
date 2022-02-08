import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/products_provider.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/screens/products/components/widgets.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

class ProductDetails extends StatelessWidget {
  const ProductDetails(
      {required this.product, Key? key, this.searchPrice = true})
      : super(key: key);
  final bool searchPrice;
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, 'Detalle de producto',
          image: 'assets/images/box.png'),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [_photoAndName(context, _size), _productDetails().expand()],
      ),
    );
  }

  Widget _photoAndName(BuildContext context, Size _size) {
    return Card(
      elevation: 1,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            productPhoto(product.image == '' ? 'no_image.png' : product.image)
                .withWidth(_size.width * 0.3),
            productInfo(context).expand()
          ]),
    );
  }

  Widget productInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(height: 8,),
          _productName(context).paddingSymmetric(vertical: 1),
          _category(),
          _subCategory(),
          _productCode(context).paddingSymmetric(vertical: 1),
        ],
      ),
    );
  }

  Widget _productCode(BuildContext context) {
    return descRichText(
      // ignore: unnecessary_null_comparison
      'Codigo: ',
      (product.code ?? ''),
      context,
    );
  }

  Widget _productName(BuildContext context) {
    return descText(
        // ignore: unnecessary_null_comparison
        capitalizeText(product.name),
        context,
        fweigth: 4,
        maxLines: 2,
        fontSizeFactor: 1.2);
  }

  Widget _subCategory() {
    return FutureBuilder(
      future: ProductsProvider.findProductCategory(product.subCategoryId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return descRichText(
          // ignore: unnecessary_null_comparison
          'Subcategoria: ',
          capitalizeText((snapshot.data?['name'] ?? '')),
          context,
        ).paddingSymmetric(vertical: 1);
      },
    );
  }

  Widget _category() {
    return FutureBuilder(
      future: ProductsProvider.findProductCategory(product.categoryId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return descRichText(
                // ignore: unnecessary_null_comparison
                'Categoria: ',
                capitalizeText((snapshot.data?['name'] ?? '')),
                context)
            .paddingSymmetric(vertical: 1);
      },
    );
  }

  Widget _productDetails() {
    return Card(
      elevation: 8,
      child: FutureBuilder<Map?>(
          future: ProductsProvider.findProductDetails(product.idCloud),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: [
                  // hDivider(),
                  futureLabelContent(
                      DBProvider.db.findBrand(product.brand), 'name', 'Marca'),
                  hDivider(),
                  futureLabelContent(
                      ProductsProvider.findProductUnit(product.unit.toString()),
                      'name',
                      'Unidad'),
                  hDivider(),
                  _pPrice(
                      context,
                      getFormatedCurrency(double.parse((searchPrice
                              ? snapshot.data!['price']
                              : product.price)
                          .toString()))),
                  hDivider(),
                  // labelContent('Codigo/PLU: : ', product.code),
                  // hDivider(),

                  labelContent('Metodo de impuesto',
                      product.taxMethod == 0 ? 'Incluido' : 'No incluido'),
                  hDivider(),
                  futureLabelContent(
                      DBProvider.db.findTableFieldsById(
                          'sma_tax_rates', product.taxRateId.toString()),
                      'name',
                      'Tasa de impuestos '),
                  hDivider(),
                  _qtty(context),
                  hDivider(),
                ],
              );
            } else {
              return Loader();
            }
          }),
    );
  }

  Row _qtty(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        labelContent('Cantidad ', product.quantity.toString()),
        buttonTextIcon(() async {
          final res = await ProductsProvider.findProductQuantities(
              product.idCloud.toString());
          if (res != null) {
            listInfoDialog(context, res, 'name', 'quantity', 'Bodega', 'Cant.');
          } else {
            confirmDialog(context, 'No se encontraron datos',
                'assets/images/warning.png');
          }
        }).paddingRight(20)
      ],
    );
  }

  Row _pPrice(BuildContext context, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        labelContent('Precio ', price),
        buttonTextIcon(() async {
          final res = await ProductsProvider.findProductPrices(
              product.idCloud.toString());
          if (res != null) {
            listInfoDialog(context, res, 'name', 'price', 'Grupo', 'Precio',
                isPrice: true);
          } else {
            confirmDialog(context, 'No se encontraron datos',
                'assets/images/warning.png');
          }
        }).paddingRight(20)
      ],
    );
  }
}
