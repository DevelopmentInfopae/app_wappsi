// import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/products_provider.dart';
import 'package:pos_wappsi/screens/components/products/product_card_info.dart';
import 'package:pos_wappsi/screens/components/widgets.dart';
import 'package:pos_wappsi/utils/alerts.dart';

class ProductCardList extends StatefulWidget {
  const ProductCardList({
    Key? key,
    required this.products,
    required this.searchParams,
  }) : super(key: key);
  final List<ProductModel> products;
  final Map searchParams;

  @override
  State<ProductCardList> createState() => _ProductCardListState();
}

class _ProductCardListState extends State<ProductCardList> {
  late ScrollController _controller;
  late Size _size;
  bool _loading = false;
  bool _allLoaded = false;
  int _page = 1;
  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(infinityScrollListener);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Stack(
      children: [
        ListView.separated(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          controller: _controller,
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 8,
          ),
          addAutomaticKeepAlives: false,
          physics: AppConstants.scrollPhysics,
          itemCount: widget.products.length + (_allLoaded ? 1 : 0),
          separatorBuilder: (context, index) => const Divider(
            height: 5,
          ),
          itemBuilder: (context, index) {
            if (index < widget.products.length) {
              return ProductCard(
                product: widget.products[index],
                action: 'product_details',
              );
            } else {
              return Container(
                width: _size.width,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Text('Sin elementos que mostrar').center(),
              );
            }

            // return Container();
          },
        ),
        if (_loading) ...[loadingIndicator(_size.width)],
      ],
    );
  }

  void infinityScrollListener() async {
    // printConsole(_controller.position.extentAfter);
    if (_controller.position.pixels >= _controller.position.maxScrollExtent &&
        !_loading) {
      setState(() {
        _loading = true;
      });

      _loading = true;
      final res = await ProductsProvider.findProducts(
        widget.searchParams['search'] ?? '',
        offset: true,
        offsetValue: _page * 30,
      );
      if (res != null) {
        if (res.isNotEmpty) {
          setState(() {
            // widget.products.clear();
            widget.products.addAll(ProductModel.fromJsonList(res));
            _page += 1;
            _loading = false;
          });
        } else {
          setState(() {
            _allLoaded = true;
            _loading = false;
          });
        }
      } else {
        await confirmDialog(
          context,
          'Error al cargar datos',
          'assets/images/dizzy-robot.png',
        );
        setState(() {
          _loading = false;
        });
      }
    }
  }
}
