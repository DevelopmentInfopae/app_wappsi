import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/orders_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/components/product_card_sales_orders.dart';
// import 'package:pos_wappsi/screens/sales/components/product_card.dart';

class ProductsList extends StatelessWidget {
  const ProductsList(
      {Key? key,
      required this.productList,
      required ScrollController scrollController,
      required this.productRequestFocus,
      this.fromOrder = false})
      : _scrollController = scrollController,
        super(key: key);
  final bool fromOrder;
  final Map<String, ProductModel> productList;
  final ScrollController _scrollController;
  final bool productRequestFocus;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: productList.keys.length,
        controller: _scrollController,
        itemBuilder: (context, index) {
          final k = productList.entries.elementAt(index).key;
          dynamic productCard;
          final product = productList.entries.elementAt(index);
          final pCard = ProductCard(
            key: UniqueKey(),
            quantityFocusNode: FocusNode(),
            formKey: GlobalObjectKey<FormState>(k),
            product: product,
            fromOder: fromOrder,
          );

          if (productList.values.elementAt(0) == product.value &&
              dataBloc.settings!['set_focus'] == 1) {
            if (productRequestFocus) {
              FocusScope.of(context).unfocus();
              pCard.quantityFocusNode.requestFocus();
            }
          } else {
            pCard.quantityFocusNode.unfocus();
          }

          productCard = pCard;

          return Dismissible(
              key: Key(k),
              background: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(5)),
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
                } else {
                  posBloc.removeProduct(k);
                }
              },
              child: productCard);
        });
  }
}
