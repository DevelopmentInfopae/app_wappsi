import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/products_provider.dart';
import 'package:pos_wappsi/screens/products/components/product_card_list.dart';
import 'package:pos_wappsi/screens/products/components/widgets.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/services/barcode_camera_scan.dart';

class Products extends StatefulWidget {
  const Products({Key? key}) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  List<ProductModel> products = [];
  // final _searchFocusNode = FocusNode();
  final _productsStream = StreamController<List<ProductModel>>.broadcast();
  final _searchController = FloatingSearchBarController();

  late Size _size;
  int _queryLen = 0;
  bool _initOpenSearch = false;

  // FloatingSearchBarController _controller = FloatingSearchBarController();
  final Map<String, dynamic> _searchParams = {};

  @override
  void initState() {
    _searchController.open();
    super.initState();
  }

  @override
  void dispose() {
    // _controller.dispose();

    _productsStream.close();
    super.dispose();
  }

  bool showFilters = false;

  @override
  Widget build(BuildContext context) {
    // avoid errors related to unstability of scaffold with no key
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    _size = MediaQuery.of(context).size;
    // _pc = pColor;

    return WillPopScope(
      onWillPop: () async {
        dataBloc.homeKey?.currentState?.changeBottomIndex(1);
        // printConsole('here i am');
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: appBar(context, 'Productos',
            elevation: false,
            radius: 0,
            image: 'assets/images/box.png', onPop: () {
          dataBloc.homeKey?.currentState?.changeBottomIndex(1);
          Navigator.pop(context);
        }),
        body: _body(),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [_searchBar().paddingBottom(5), _productsList().expand()],
    );
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
    if (!_initOpenSearch) {
      try {
        Timer(const Duration(milliseconds: 00), () {
          _searchController.open();
          // setState(() {
          _initOpenSearch = true;
          // });
        });
      } catch (e) {
        // printConsole(e);
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: FloatingSearchAppBar(
          controller: _searchController,
          hint: ' Buscar producto',
          titleStyle: buttonsSmallTextStyle(context),
          transitionDuration: const Duration(milliseconds: 800),
          clearQueryOnClose: true,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          // alwaysOpened: true,

          hintStyle: buttonsSmallTextStyle(context),
          hideKeyboardOnDownScroll: true,
          onQueryChanged: _onQueryChanged,
          // height: _size.height * 0.078 < 55 ? 55 : _size.height * 0.078,
          elevation: 0,
          actions: [
            FloatingSearchBarAction.searchToClear(
                // showIfClosed: false,
                ),
            FloatingSearchBarAction.icon(
                showIfOpened: true,
                icon: showFilters
                    ? Icons.filter_alt_rounded
                    : Icons.filter_alt_outlined,
                onTap: () {
                  // setState(() {
                  showFilters = !showFilters;
                  // });
                }),
            Container(width: _size.width * 0.15)
          ],
          // leadingActions: [Icon(Icons.search)],
          automaticallyImplyBackButton: false,
          color: Colors.grey[200],
          body: null),
    );
  }

  Widget _productsList() {
    return FutureBuilder<List<Map>?>(
        future: ProductsProvider.getAllProducts(offset: true, offsetValue: 1),
        builder: (BuildContext context, AsyncSnapshot<List<Map>?> snapshot) {
          if (snapshot.hasData) {
            return StreamBuilder<List<ProductModel>?>(
                stream: _productsStream.stream,
                builder:
                    (context, AsyncSnapshot<List<ProductModel>?> snapshot2) {
                  if (snapshot2.hasData) {
                    return ProductCardList(
                        products: snapshot2.data!, searchParams: _searchParams);
                  } else {
                    _productsStream.sink.add(ProductModel.fromJsonList(
                        snapshot.data!,
                        loadInitialQtty: true,
                        qttyKey: 'quantity'));

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                });
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  _onQueryChanged(String? query) async {
    _searchParams['search'] = query;
    if (query == '' || query == null) {
      final res = await ProductsProvider.getAllProducts();
      if (res != null) {
        _productsStream.sink.add(ProductModel.fromJsonList(res,
            loadInitialQtty: true, qttyKey: 'quantity'));
      }
    } else {
      final res = await ProductsProvider.findProducts(query);
      if (res?.isNotEmpty ?? false) {
        _productsStream.sink.add(ProductModel.fromJsonList(res!));
      } else {
        if (query.length - _queryLen > 1) {
          _searchController.clear();
          _searchController.close();
          scaffoldAlert(context, 'Producto ' + query + ' no encontrado',
              const Duration(seconds: 1, milliseconds: 500),
              backGroundColor: Colors.red);
          await Future.delayed(const Duration(milliseconds: 500));
          _searchController.open();
          _queryLen = 0;
        } else {
          _queryLen = query.length;
        }
      }
    }
  }
}
