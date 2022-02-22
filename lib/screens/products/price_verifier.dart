import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/product_card.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/products_provider.dart';

import 'package:pos_wappsi/screens/home/components/tab_item.dart';
import 'package:pos_wappsi/screens/products/components/widgets.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/barcode_camera/barcode_camera_scan.dart';

// import '../../constant.dart';

class ProductPrice extends StatefulWidget {
  const ProductPrice({Key? key}) : super(key: key);

  @override
  _ProductPriceState createState() => _ProductPriceState();
}

class _ProductPriceState extends State<ProductPrice> {
  final _productsStream = StreamController<List<Map>?>.broadcast();
  // final _searchController = TextEditingController();
  // final _searchFocusNode = FocusNode();
  late Size _size;
  final _searchController = FloatingSearchBarController();

  int _currentQueryLen = 0;
  // late Color _pc;

  @override
  void initState() {
    super.initState();

    /// To request focus from
    // SchedulerBinding.instance?.addPostFrameCallback((Duration _) {
    // FocusScope.of(context).requestFocus(_searchFocusNode);
    //   _searchController.close();
    // });
  }

  @override
  void dispose() {
    _productsStream.close();
    // _searchController.dispose();
    _searchController.dispose();
    // _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    // _pc = pColor;
    return Scaffold(
      appBar: appBar(context, 'Verificador',
          elevation: false, image: 'assets/images/give-money.png', onPop: () {
        dataBloc.homeKey.currentState?.selectTab(TabItem.home);
        // _searchFocusNode.unfocus();
        _searchController.close();
      }),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [_searchBar(), products()],
    );
  }

  Widget products() {
    return StreamBuilder<List<Map>?>(
        stream: _productsStream.stream,
        builder: (BuildContext context, AsyncSnapshot<List<Map>?> snapshot) {
          if (snapshot.hasData) {
            return ListView(
                    children:
                        ProductModel.fromJsonList(snapshot.data!).map((e) {
              return ProductCard(
                product: e,
                action: 'price_verifier',
              );
            }).toList())
                .expand();
          } else {
            return Container();
          }
        });
  }

  Widget _searchBar() {
    return Stack(
      children: [
        _searchBarBackground(),
        _searchField().paddingLeft(7),
        barCode(context, () async {
          _searchController.open();
          final res = await scanBarcodeNormal();

          _searchController.query = res ?? '';
          _searchController.hide();
          // _searchController.hide();
        }),
      ],
    );
  }

  Container _searchBarBackground() {
    return Container(
      height: searchHeight + 8,
      width: _size.width,
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.grey,
          offset: Offset(0.0, 1.0), //(x,y)
          blurRadius: 2.0,
        )
      ]),
    );
  }

  Widget _searchField() {
    return Container(
      // alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: FloatingSearchAppBar(
          // color: _theme.primar,
          // color: Colors.black12,

          controller: _searchController,
          hint: 'Buscar producto',
          transitionDuration: const Duration(milliseconds: 800),
          clearQueryOnClose: true,
          // alwaysOpened: true,
          hideKeyboardOnDownScroll: true,
          onQueryChanged: _onQueryChanged,
          // height: _size.height * 0.078<55?55:_size.height * 0.078,
          padding: const EdgeInsets.all(8),
          elevation: 0,
          actions: [Container(width: _size.width * 0.15)],
          leadingActions: const [Icon(Icons.search)],
          automaticallyImplyBackButton: false,
          color: Colors.grey[100],
          // colorOnScroll: _theme.primaryColor,
          // iconColor: Colors.white,

          body: null),
    );
  }

  _onQueryChanged(query) async {
    if (query == '') {
      _productsStream.sink.add(null);
      // _searchFocusNode.requestFocus();

    } else {
      final res = await ProductsProvider.findProducts(query);
      if ((res??[]).isEmpty) {
        if ((query.length - _currentQueryLen > 1)) {
          _searchController.clear();
          scaffoldAlert(context, 'Producto ' + query + ' no encontrado',
              const Duration(seconds: 1, milliseconds: 500),
              backGroundColor: Colors.red);
          // posBloc.getSearchBarController.query='';
          _currentQueryLen = 0;
        } else {
          _currentQueryLen = query.length;
        }
      }
      _productsStream.sink.add(res);
    }
  }
}
