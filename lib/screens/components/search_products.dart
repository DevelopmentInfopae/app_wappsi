// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/screens/components/products/product_card_info.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

Widget buildBody({
  String action = 'add_to_cart',
  Stream<List<ProductModel>>? stream,
}) {
  final time = DateTime.now();
  printConsole('BuildBody at ${time.second}:${time.millisecond}');
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
        },
      ),
    ),
  );
}
