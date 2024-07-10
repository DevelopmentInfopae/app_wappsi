import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/orders_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/bloc/purchases_bloc.dart';
import 'package:pos_wappsi/bloc/quotes_bloc.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/screens/Purchases/components/product_card_cost_editable.dart';
import 'package:pos_wappsi/screens/components/products/product_card_qtty_editing.dart';
// import 'package:pos_wappsi/utils/print_errors.dart';
// import 'package:pos_wappsi/screens/sales/components/product_card.dart';

class ProductsList extends StatelessWidget {
  const ProductsList({
    Key? key,
    required this.productList,
    required ScrollController scrollController,
    required this.productRequestFocus,
    this.fromQuote = false,
    this.fromPurchase = false,
    this.fromOrder = false,
  })  : _scrollController = scrollController,
        super(key: key);
  final bool fromOrder;
  final bool fromPurchase;
  final bool fromQuote;
  final Map<String, ProductModel> productList;
  final ScrollController _scrollController;
  final bool productRequestFocus;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: productList.keys.length,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      controller: _scrollController,
      itemBuilder: (context, index) {
        final k = productList.entries.elementAt(index).key;
        dynamic productCard;
        final product = productList.entries.elementAt(index);

        Function getQtty;
        Function(double) editQtty;
        Function addQtty;
        Function rmQtty;
        Function delete;
        UnitsModel? unit;
        String prefsText = '';

        bool requestFocus = false;
        if (productRequestFocus) {
          if (product.key == productList.entries.first.key) {
            requestFocus = true;
          }
        }

        if (fromOrder) {
          prefsText = orderBloc.getProductPrefsTextWithoutTags(product.key);
          delete = () => orderBloc.removeProduct(product.key);
          getQtty = () => orderBloc.getProductData(product.key)?.quantity ?? 1;

          unit = orderBloc.getProductUnits?[product.key];
          final uOperator = unit?.operationValue ?? 1;
          addQtty = () async {
            final pQtty = orderBloc.getProductData(product.key)!.quantity;
            final res = await orderBloc.addProductQuantity(
              product.key,
              pQtty + (uOperator),
            );

            return res;
          };
          editQtty = (double qttyVal) async {
            return await orderBloc.addProductQuantity(product.key, qttyVal);
          };
          rmQtty = () {
            if (orderBloc.getProductData(product.key)!.quantity > uOperator) {
              // setState(() {
              orderBloc.getProductData(product.key)!.quantity -= uOperator;
              orderBloc.getSubTotal();
            }
          };
        } else if (fromQuote) {
          prefsText = quoteBloc.prefsText(product.key);
          delete = () => quoteBloc.removeProduct(product.key);
          getQtty = () => quoteBloc.getProductData(product.key)?.quantity ?? 1;
          unit = quoteBloc.getProductUnits?[product.key];
          final uOperator = unit?.operationValue ?? 1;
          addQtty = () async {
            final pQtty = quoteBloc.getProductData(product.key)!.quantity;
            final res = await quoteBloc.addProductQuantity(
              product.key,
              pQtty + (uOperator),
            );

            return res;
          };
          editQtty = (double qttyVal) async {
            return await quoteBloc.addProductQuantity(product.key, qttyVal);
          };
          rmQtty = () {
            if (quoteBloc.getProductData(product.key)!.quantity > uOperator) {
              // setState(() {
              quoteBloc.getProductData(product.key)!.quantity -= uOperator;
              quoteBloc.getSubTotal();
            }
          };
        } else {
          prefsText = posBloc.prefsText(product.key);
          delete = () => posBloc.removeProduct(product.key);
          getQtty = () => posBloc.getProductData(product.key)?.quantity ?? 1;
          unit = posBloc.getProductUnits?[product.key];
          final uOperator = unit?.operationValue ?? 1;
          addQtty = () async {
            final pQtty = posBloc.getProductData(product.key)!.quantity;
            final res = await posBloc.addProductQuantity(
              product.key,
              pQtty + (uOperator),
            );

            return res;
          };
          editQtty = (double qttyVal) async {
            return await posBloc.addProductQuantity(product.key, qttyVal);
          };

          rmQtty = () {
            if (posBloc.getProductData(product.key)!.quantity > uOperator) {
              // setState(() {
              posBloc.getProductData(product.key)!.quantity -= uOperator;
              posBloc.setSubTotal(posBloc.getSubTotal());
            }
          };
        }

        if (fromPurchase) {
          productCard = ProductCardCostEditable(
            key: UniqueKey(),
            quantityFocusNode: FocusNode(),
            formKey: GlobalObjectKey<FormState>(k),
            productKey: product.key,
            requestFocus: requestFocus,
          );
        } else {
          productCard = ProductCard(
            key: UniqueKey(),
            quantityFocusNode: FocusNode(),
            formKey: GlobalObjectKey<FormState>(k),
            requestFocus: requestFocus,
            product: product.value,
            getQtty: getQtty,
            editQtty: editQtty,
            addQtty: addQtty,
            prefsSelection: prefsText,
            rmQtty: rmQtty,
            delete: delete,
            unit: unit,
          );
        }

        if (!(productList.values.first == product.value &&
            dataBloc.settings?['set_focus'] == 1)) {
          productCard.quantityFocusNode.unfocus();
        }

        // productCard = pCard;

        return Dismissible(
          key: Key(k),
          background: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.delete,
                  size: iconSize(context),
                  color: Colors.white,
                ).paddingOnly(left: 16, right: 8),
                Text(
                  'Quitar elemento',
                  style: buttonsTextStyle(context, fontSizeFactor: 1.05),
                )
              ],
            ),
          ).paddingSymmetric(vertical: 4),
          onDismissed: (direction) {
            if (fromOrder) {
              orderBloc.removeProduct(k);
            } else if (fromQuote) {
              quoteBloc.removeProduct(k);
            } else if (fromPurchase) {
              purchaseBloc.removeProduct(k);
            } else {
              posBloc.removeProduct(k);
            }
          },
          child: productCard,
        );
      },
    );
  }
}
