import 'package:flutter/material.dart';

import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/orders_bloc.dart';
import 'package:pos_wappsi/components/appbar_leading.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/products_provider.dart';
import 'package:pos_wappsi/components/product_list.dart';
import 'package:pos_wappsi/screens/orders/components/favorites_search_selection.dart';
import 'package:pos_wappsi/screens/orders/order_other_details.dart';
// import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/screens/products/components/widgets.dart';

import 'package:pos_wappsi/screens/sales/components/search.dart';

// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos_wappsi/screens/sales/components/widgets.dart';

import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/barcode_camera/barcode_camera_scan.dart';
// import 'package:pos_wappsi/utils/alerts.dart';

class OrderProducts extends StatefulWidget {
  const OrderProducts({Key? key}) : super(key: key);

  @override
  _OrderProductsState createState() => _OrderProductsState();
}

class _OrderProductsState extends State<OrderProducts> {
  int index = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final _searchController = FloatingSearchBarController();

  late Size _size;
  String _query = '';

  // TO control changes in products and execute focus task
  int _productsCount = 0;
  int _itemsCount = 0;

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
            body: IndexedStack(
              index: index,
              children: [
                _searchbar(),
                Hero(
                    tag: 'order_favorite_search',
                    child: buildFloatingSearchBar())
              ],
            )),
        onWillPop: () async {
          bool pop = false;
          setState(() {
            if (index == 1) {
              index = 0;
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
      'Agregar pedido',
      elevation: false,
      radius: 0,
      image: 'assets/images/cargo.png',
      onPop: () {
        setState(() {
          if (index == 1) {
            index = 0;
          } else {
            Navigator.pop(context);
          }
        });
      },
      leading: Hero(
        tag: 'order_favorite_search',
        child: Tooltip(
            message: "Favoritos",
            child: AppBarLeading(
                widget: Icon(
                  index == 1 ? Icons.favorite : Icons.favorite_border_outlined,
                  size: leadingIconSize,
                  color: pColor,
                ),
                onTap: () {
                  setState(() {
                    if (index == 0) {
                      _searchController.close();
                      index = 1;
                    } else {
                      index = 0;
                    }
                  });
                })),
      ),
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
    return FloatingSearchBar(
      clearQueryOnClose: true,
      axisAlignment: -1,
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
          stream: orderBloc.productSearchStream, action: 'add_to_order'),
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
        child: StreamBuilder<Map<String, ProductModel>>(
            stream: orderBloc.productsStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (orderBloc.getItemsCount() == 0) {
                  _searchBarFocusManagement();
                  _productsCount = 0;
                  _itemsCount = 0;
                  return _empty(context).center();
                } else {
                  _productsCount += 1;
                  _itemsCount += 1;
                  bool productRequestFocus = false;
                  if (_productsCount == snapshot.data!.length ||
                      _itemsCount == orderBloc.getItemsCount()) {
                    if (_scrollController.hasClients) {
                      _scrollController
                          .jumpTo(_scrollController.position.minScrollExtent);
                    }
                    // final xd = orderBloc.settings['set_focus'];
                    // printConsole();
                    productRequestFocus = _searchBarFocusManagement();
                  } else if (_productsCount - 2 == snapshot.data!.length) {
                    // Nothing to do when items are removed from cart
                  } else {
                    // _searchBarFocusManagement();
                    _productsCount = snapshot.data!.length;
                    _itemsCount = orderBloc.getItemsCount();
                  }
                  Map<String, ProductModel> saleProductsList = snapshot.data!;
                  return ProductsList(
                    productList: saleProductsList,
                    scrollController: _scrollController,
                    productRequestFocus: productRequestFocus,
                    fromOrder: true,
                  );
                }
              } else {
                // ignore: unnecessary_null_comparison

                return _empty(context).center();
              }
            }));
  }

  _searchBarFocusManagement() {
    if (dataBloc.settings!['set_focus'] == 0) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        // _searchController.close();
        if (_searchController.isOpen) {
          _searchController.query = '';
        } else {
          if (index == 0) {
            _searchController.open();
          }
        }
      });
      return false;
    } else if (dataBloc.settings!['set_focus'] == 1) {
      _searchController.close();
      return true;
    }
  }

  Widget _empty(BuildContext context) {
    return AppButton(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.add,
            color: Colors.white,
          ),
          Text(
            'Añadir productos',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      padding: kButtonPadding,
      color: pColor,
      onTap: () {
        _searchController.open();
      },
    );
  }

  Widget _bottom() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        subTotal(
            large: true,
            stream: orderBloc.subTotalStream,
            defaultValue: orderBloc.getSubTotal(),
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
        if ((query.length - _query.length > 1)) {
          _searchController.clear();
          // _searchController.query='';
          _query = '';
        } else {
          _query = query;
        }
      } else {
        if (res.length == 1) {
          final temp = ProductModel.fromJson(res.first);
          final productReq =
              await ProductsProvider.getProductRequirements(context, temp);
          if (productReq != {}) {
            final result = await orderBloc.addProduct(productReq);
            if (result) {
              scaffoldAlert(context, 'Producto ${temp.name} añadido',
                  const Duration(seconds: 1));
            }
          }

          products = [];
        } else {
          _query = query;
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
    orderBloc.setProductSearchData(products);
  }

  void _send() {
    if ((orderBloc.getProducts?.keys.length ?? 0) > 0) {
      // SalePayment().launch(context);
      const OrderOtherDetails().launch(context);
    } else {
      confirmDialog(context, "Debe seleccionar productos antes de continuar",
          "assets/images/alert.png");
    }
  }
}
