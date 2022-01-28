import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/customer_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/components/product_card.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/screens/products/product_details.dart';
import 'package:pos_wappsi/screens/products/product_price_verifier.dart';
import 'package:pos_wappsi/screens/sales/components/select_product_unit_alert.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:provider/provider.dart';

Widget buildBody(
    {String action = 'add_to_cart', Stream<List<ProductModel>>? stream}) {
  final time = DateTime.now();
  print('BuildBody at ${time.second}:${time.millisecond}');
  return _productos(action, stream);
}

Widget _productos(String action, Stream<List<ProductModel>>? stream) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Material(
      child: StreamBuilder<List<ProductModel>>(
          stream: stream ?? posBloc.productSearchStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: snapshot.data!.map((e) {
                  return ProductCard(
                    product: e,
                    action: action,
                  );
                }).toList(),
              );
            } else {
              return Container();
            }
          }),
    ),
  );
}
