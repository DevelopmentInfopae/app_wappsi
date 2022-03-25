import 'dart:async';

import 'package:flutter/material.dart';

import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/purchases_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/products_provider.dart';
import 'package:pos_wappsi/components/products/product_list.dart';
import 'package:pos_wappsi/screens/Quotes/quote_other_data.dart';
import 'package:pos_wappsi/components/favorites_search_selection.dart';
// import 'package:pos_wappsi/screens/orders/order_other_details.dart';
// import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/screens/products/components/widgets.dart';

import 'package:pos_wappsi/components/search_products.dart';

// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos_wappsi/screens/sales/components/widgets.dart';

import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/services/barcode_camera_scan.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
// import 'package:pos_wappsi/utils/alerts.dart';

class PurchaseProducts extends StatefulWidget {
  const PurchaseProducts({Key? key}) : super(key: key);

  @override
  _PurchaseProductsState createState() => _PurchaseProductsState();
}

class _PurchaseProductsState extends State<PurchaseProducts> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final _searchController = FloatingSearchBarController();

  late Size _size;
  int _queryLen = 0;
  final pListKey = UniqueKey();

  // TO control changes in products and execute focus task
  int _productsCount = 0;
  bool _initOpenSearch = false;
  // int _itemsCount = 0;

  // late TextTheme _textTheme;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    // _textTheme = Theme.of(context).textTheme;

    // initialize search controller

    return WillPopScope(
        child: Scaffold(
          key: _scaffoldKey,
          appBar: buildAppBar(context),
          body: _searchbar(),
        ),
        onWillPop: () async {
          bool pop = false;
          setState(() {
            if (_searchController.isOpen) {
              _searchController.close();
            } else {
              pop = true;
            }
          });

          return pop;
        });
  }

  PreferredSize buildAppBar(BuildContext context) {
    return appBar(
      context,
      'Agregar compra',
      elevation: false,
      radius: 0,
      image: 'assets/images/add-quote.png',
      onPop: () {
        setState(() {
          if (_searchController.isOpen) {
            _searchController.close();
          } else {
            Navigator.pop(context);
          }
        });
      },
    );
  }

  Widget _searchbar() {
    return Stack(
      children: [
        _searchHeight(),
        _searchField().paddingOnly(left: 5, right: 5, top: 1),
        barCode(context, () async {
          _searchController.open();
          final res = await scanBarcodeNormal();
          _searchController.query = res ?? '';
          // _searchController.hide();
        }),
      ],
    );
  }

  Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FavoritesOrderSelection(
        isPortrait: isPortrait,
        // toOrder: false,
        toQuote: true,
        context: _scaffoldKey.currentContext ?? context);
  }

  Container _searchHeight() {
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

  FloatingSearchBar _searchField() {
    if (!_initOpenSearch) {
      Timer(const Duration(milliseconds: 00), () {
        try {
          _searchController.open();
          // setState(() {
          _initOpenSearch = true;
          // });
        } catch (e) {
          printConsole(e);
        }
      });
    }
    return FloatingSearchBar(
      axisAlignment: 0,
      elevation: 0,
      // padding: EdgeInsets.symmetric(horizontal: 5),
      // border: BorderSide(color: _pc, width: 1),
      borderRadius: BorderRadius.circular(10),

      margins: EdgeInsets.zero,
      hint: 'Buscar producto',
      actions: [
        FloatingSearchBarAction.searchToClear(
            // showIfClosed: false,
            ),
        Container(
          width: _size.width * 0.17,
        ),
      ],
      openWidth: _size.width,

      height: searchHeight,
      queryStyle: buttonsSmallTextStyle(context),

      hintStyle: buttonsSmallTextStyle(context),
      automaticallyImplyBackButton: false,
      controller: _searchController,
      body: _body(),
      onSubmitted: (_) {
        _searchController.close();
      },
      backgroundColor: Colors.grey[200],
      backdropColor: Colors.white30,
      transitionCurve: Curves.easeInOutCubic,
      transition: CircularFloatingSearchBarTransition(),
      physics: const BouncingScrollPhysics(),
      builder: (context, _) => buildBody(
          stream: purchaseBloc.productSearchStream, action: 'add_to_purchase'),
      title: Text(
        'Buscar producto',
        style: buttonsSmallTextStyle(context),
      ),

      // width: _size.width * 0.84,
      onQueryChanged: _onQueryChanged,
    );
  }

  Widget _body() {
    // ignore: unnecessary_null_comparison
    return Column(
      children: [_products().expand(), bottom(_bottom(), pColor, _size)],
    );
  }

  Widget _products() {
    return Container(
        // height:_size.height*0.78,
        // to avoid overlap with floatingSearchBar
        margin: EdgeInsets.only(top: _size.height * 0.078, bottom: 8),
        padding: const EdgeInsets.only(top: 15),
        child: _productsStream());
  }

  StreamBuilder<Map<String, ProductModel>> _productsStream() {
    return StreamBuilder<Map<String, ProductModel>>(
        stream: purchaseBloc.productsStream,
        builder: (context, snapshot) {
          // _searchBarFocusManagement();
          if (_productsCount + 1 == snapshot.data?.length) {
            _productsCount += 1;
            _searchBarFocusManagement();
          }
          if (snapshot.hasData &&
              _searchController.isClosed &&
              _productsCount == (purchaseBloc.getProducts?.length ?? 0)) {
            bool productRequestFocus = false;
            if (purchaseBloc.getItemsCount() == 0) {
              _productsCount = 0;
              // _itemsCount = 0;
              return Container();
              //
              // return _empty(context).center();
            } else {
              // _itemsCount += 1;

              if (_productsCount == snapshot.data!.length) {
                if (_scrollController.hasClients) {
                  _scrollController
                      .jumpTo(_scrollController.position.minScrollExtent);
                }
                // final xd = purchaseBloc.settings['set_focus'];
                // printConsole();

                productRequestFocus = _productFocus();
              } else if (_productsCount - 2 == snapshot.data!.length) {
                // Nothing to do when items are removed from cart
              } else {
                // _searchBarFocusManagement();
                _productsCount = snapshot.data!.length;
                // _itemsCount = purchaseBloc.getItemsCount();
              }
            }
            Map<String, ProductModel> saleProductsList = snapshot.data!;
            return ProductsList(
              key: pListKey,
              productList: saleProductsList,
              scrollController: _scrollController,
              productRequestFocus: productRequestFocus,
              fromPurchase: true,
            );
          } else if (purchaseBloc.getProducts?.isNotEmpty ?? false) {
            return ProductsList(
              key: pListKey,
              productList: purchaseBloc.getProducts!,
              scrollController: _scrollController,
              productRequestFocus: false,
              fromPurchase: true,
            );
          } else if (snapshot.hasData && _searchController.isOpen) {
            return Container();
          } else {
            // ignore: unnecessary_null_comparison
            return Container();

            // return _empty(context).center();
          }
        });
  }

  _searchBarFocusManagement() {
    if (dataBloc.settings!['set_focus'] == 0) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        // _searchController.close();
        if (_searchController.isOpen) {
          _searchController.query = '';
        } else {
          _searchController.open();
        }
      });
    } else {
      _searchController.close();
    }
  }

  _productFocus() {
    if (dataBloc.settings!['set_focus'] == 1) {
      if ((purchaseBloc.getProducts ?? {}).isEmpty) {
        return true;
      } else {
        _searchController.close();
        return true;
      }
    } else {
      return false;
    }
  }

  // Widget _empty(BuildContext context) {
  //   return AppButton(
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: const [
  //         Icon(
  //           Icons.add,
  //           color: Colors.white,
  //         ),
  //         Text(
  //           'Añadir productos',
  //           style: TextStyle(color: Colors.white),
  //         ),
  //       ],
  //     ),
  //     padding: kButtonPadding,
  //     color: pColor,
  //     onTap: () {
  //       _searchController.open();
  //     },
  //   );
  // }

  Widget _bottom() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        subTotal(
            large: true,
            stream: purchaseBloc.subTotalStream,
            defaultValue: purchaseBloc.getSubTotal(),
            color: Colors.white),
        _sendOrder(),
      ],

      // ),
    );
  }

  Widget _sendOrder() {
    return AppButton(
      padding: kButtonPadding,
      color: Colors.white,
      shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: pColor)),
      width: 10,
      onTap: () async {
        _send();
      },
      // child: Icon(FontAwesomeIcons.pause),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: kIconSize,
            color: pColor,
          ),
          Text('Siguiente',
              style: buttonsSmallTextStyle(context, color: pColor)),
        ],
      ),
    );
  }

  _onQueryChanged(String query) async {
    if (query != '') {
      List<ProductModel> products = [];
      final settings = await dataBloc.getSettings();
      List<Map>? res;
      if (settings['overselling'] == 1) {
        res = await ProductsProvider.findProducts(query, limit: true);
      } else {
        res = await ProductsProvider.findProducts(query, overselling: false);
      }
      // printConsole('xd');
      if (res != null) {
        if (res.isEmpty) {
          if ((query.length - _queryLen > 1)) {
            _searchController.clear();
            scaffoldAlert(context, 'Producto ' + query + ' no encontrado',
                const Duration(seconds: 1, milliseconds: 500),
                backGroundColor: Colors.red);

            // _searchController.query='';
            _queryLen = 0;
          } else {
            _queryLen = query.length;
          }
        } else {
          if (res.length == 1) {
            final temp = ProductModel.fromJson(res.first);
            final productReq =
                await ProductsProvider.getProductRequirements(context, temp);
            if (productReq != {}) {
              final result = await purchaseBloc.addProduct(productReq);
              if (result) {
                scaffoldAlert(context, 'Producto ${temp.name} añadido',
                    const Duration(seconds: 1));
              }
            }

            products = [];
          } else {
            _queryLen = query.length;
            if (query != '') {
              products = ProductModel.fromJsonList(res);
            } else {
              products = [];
            }
          }
        }
      } else {
        products = [];
      }
      purchaseBloc.setProductSearchData(products);
    }
  }

  void _send() {
    if ((purchaseBloc.getProducts?.keys.length ?? 0) > 0) {
      const QuoteOtherData().launch(context);
    } else {
      confirmDialog(context, "Debe seleccionar productos antes de continuar",
          "assets/images/alert.png");
    }
  }
}
