// ignore_for_file: unnecessary_statements

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/entities/PriceSettings.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/local_settings_provider.dart';
import 'package:pos_wappsi/providers/products_provider.dart';
import 'package:pos_wappsi/screens/components/appbar_leading.dart';
import 'package:pos_wappsi/screens/components/back_app_bar.dart';
import 'package:pos_wappsi/screens/components/favorites_search_selection.dart';
import 'package:pos_wappsi/screens/components/products/product_list.dart';
// import 'package:pos_wappsi/screens/sales/components/sale_product_list_widget.dart';

import 'package:pos_wappsi/screens/components/search_products.dart';
import 'package:pos_wappsi/screens/components/widgets.dart';
// import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/screens/home/home_screen.dart';
import 'package:pos_wappsi/screens/products/components/widgets.dart';
// import 'package:pos_wappsi/screens/sales/components/select_product_unit_alert.dart';
import 'package:pos_wappsi/screens/sales/components/suspend_sale_alert.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos_wappsi/screens/sales/components/widgets.dart';
import 'package:pos_wappsi/screens/sales/new_sale.dart';
import 'package:pos_wappsi/screens/sales/sale_payment.dart';
import 'package:pos_wappsi/services/barcode_camera_scan.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
// import 'package:pos_wappsi/utils/alerts.dart';

class SaleCart extends StatefulWidget {
  const SaleCart({Key? key}) : super(key: key);

  @override
  _SaleCartState createState() => _SaleCartState();
}

class _SaleCartState extends State<SaleCart> {
  final ScrollController _scrollController = ScrollController();

  late Size _size;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _queryLen = 0;
  final _searchController = FloatingSearchBarController();

  // TO control changes in products and execute focus task
  int _productsCount = 0;

  final pListKey = UniqueKey();

  bool _initOpenSearch = false;
  // int _itemsCount = 0;

  int index = 0;
  final pageController = PageController();

  @override
  void initState() {
    if (posBloc.getProducts?.isNotEmpty ?? false) {
      _productsCount = posBloc.getProducts!.length;
    }
    pageController.addListener(() {
      if (pageController.hasClients) {
        if (pageController.page?.round() != index) {
          _updateIndex();
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (pageController.hasClients) {
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  double checkCurrentPage() {
    if (pageController.hasClients) {
      return pageController.page ?? 1;
    } else {
      return 1;
    }
  }

  void _updateIndex() {
    setState(() {
      index = (pageController.page ?? 0).floor();
    });
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    // _textTheme = Theme.of(context).textTheme;

    // initialize search controller

    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _appBar(context),
        body: Column(
          children: [
            PageView(
              controller: pageController,
              children: [_searchbar(), buildFloatingSearchBar()],
            ).expand(),
            bottom(_bottom(), pColor, _size),
          ],
        ),
      ),
      onWillPop: () async {
        bool pop = false;

        if (index == 1) {
          _goToPage(0);
        } else {
          if (_searchController.isOpen) {
            _searchController.close();
          } else {
            pop = true;
          }
        }

        return pop;
      },
    );
  }

  PreferredSize _appBar(BuildContext context) {
    return appBar(
      context,
      'Venta POS',
      elevation: false,
      radius: 0,
      leading: Tooltip(
        message: 'Favoritos',
        child: AppBarLeading(
          widget: Icon(
            Icons.favorite,
            size: leadingIconSize,
            color: index == 1 ? Colors.white : favColor,
          ),
          backgroundColor: index == 0 ? Colors.white : favColor,
          onTap: () {
            // FocusScope.of(context).unfocus();
            if ((pageController.page ?? 0) == 0) {
              _searchController.close();
              _goToPage(1);
            } else {
              _goToPage(0);
            }
            _updateIndex();
          },
        ),
      ),
      onPop: () {
        // FocusScope.of(context).unfocus();
        if (index == 1) {
          _goToPage(0);
        } else {
          if (_searchController.isOpen) {
            _searchController.close();
          } else {
            Navigator.pop(context);
          }
          _updateIndex();
        }
      },
      image: 'assets/images/add-to-cart.png',
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
      toSale: true,
      isPortrait: isPortrait,
      context: _scaffoldKey.currentContext ?? context,
    );
  }

  Container _searchHeight() {
    return Container(
      height: searchHeight + 8,
      width: _size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 2.0,
          ),
        ],
      ),
    );
  }

  FloatingSearchBar _searchField() {
    if (!_initOpenSearch) {
      Timer(const Duration(milliseconds: 600), () {
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
      clearQueryOnClose: true,
      onFocusChanged: (value) {
        // FocusScope.of(context).unfocus();
      },
      axisAlignment: 0,

      elevation: 0,
      // padding: EdgeInsets.symmetric(horizontal: 8),
      // border: BorderSide(color: _pc, width: 1),
      borderRadius: BorderRadius.circular(radius2),
      margins: EdgeInsets.zero,
      hint: 'Buscar producto',
      actions: [
        FloatingSearchBarAction.searchToClear(),
        Container(
          width: _size.width * 0.15,
        ),
      ],
      openWidth: _size.width,

      height: searchHeight,
      queryStyle: buttonsSmallTextStyle(context),
      // leadingActions: _leadingActions,
      hintStyle: buttonsSmallTextStyle(context),
      automaticallyImplyBackButton: false,
      controller: _searchController,
      body: _products(),
      onSubmitted: (_) {
        _searchController.close();
      },
      backgroundColor: Colors.grey[200],
      backdropColor: Colors.white30,
      transitionCurve: Curves.easeInOutCubic,
      transition: CircularFloatingSearchBarTransition(),
      physics: const BouncingScrollPhysics(),
      builder: (context, _) =>
          buildBody(stream: posBloc.productSearchStream, action: 'add_to_cart'),
      title: Text(
        'Buscar producto',
        style: buttonsSmallTextStyle(context),
      ),

      // width: _size.width * 0.84,
      onQueryChanged: _onQueryChanged,
    );
  }

  Widget _products() {
    return Container(
      // height:_size.height*0.78,
      // to avoid overlap with floatingSearchBar
      margin: EdgeInsets.only(top: _size.height * 0.078, bottom: 8),
      padding: const EdgeInsets.only(top: 15),
      child: StreamBuilder<Map<String, ProductModel>>(
        stream: posBloc.productsStream,
        builder: (context, snapshot) {
          bool productRequestFocus = _productFocus();

          if (_productsCount + 1 == snapshot.data?.length) {
            _productsCount += 1;
            _searchBarFocusManagement();
          }

          if (snapshot.hasData &&
              _searchController.isClosed &&
              _productsCount == (posBloc.getProducts?.length ?? 0)) {
            // _searchController.close();

            // _productsCount += 1;
            // _itemsCount += 1;
            if (_productsCount == snapshot.data!.length) {
              if (_scrollController.hasClients) {
                _scrollController
                    .jumpTo(_scrollController.position.minScrollExtent);
              }
              // final xd = posBloc.settings['set_focus'];
              // printConsole();
            } else if (_productsCount - 2 == snapshot.data!.length) {
              // Nothing to do when items are removed from cart
            } else {
              // _searchBarFocusManagement();
              _productsCount = snapshot.data!.length;
              // _itemsCount = posBloc.getItemsCount();
            }

            Map<String, ProductModel> saleProductsList = snapshot.data!;
            final pCard = ProductsList(
              key: pListKey,
              productList: saleProductsList,
              scrollController: _scrollController,
              productRequestFocus: productRequestFocus,
            );
            productRequestFocus = false;
            return pCard;
          } else if (posBloc.getProducts?.isNotEmpty ?? false) {
            return ProductsList(
              key: pListKey,
              productList: posBloc.getProducts ?? {},
              scrollController: _scrollController,
              productRequestFocus: false,
              fromOrder: false,
            );
          } else if (snapshot.hasData && _searchController.isOpen) {
            return Container();
          } else {
            // ignore: unnecessary_null_comparison
            _productsCount = 0;
            return Container();

            // return _empty(context).center();
          }
        },
      ),
    );
  }

  _searchBarFocusManagement() {
    if (dataBloc.settings!['set_focus'] == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // _searchController.close();
        _searchController.query = '';
        if (_searchController.isClosed) {
          if (index == 0) {
            _searchController.open();
          }
        }
      });
    } else {
      _searchController.close();
    }
  }

  _productFocus() {
    if (dataBloc.settings?['set_focus'] == 1 &&
        index == 0 &&
        (_productsCount + 1) == posBloc.getProducts?.length) {
      if ((posBloc.getProducts ?? {}).isEmpty) {
        return false;
      } else {
        if (_searchController.isOpen) {
          _searchController.close();
        }
        if (index == 1) {
          return false;
        }
        return true;
      }
    } else {
      return false;
    }
  }

  // Widget _empty(BuildContext context) {
  //   return AppButton(
  //     padding: kButtonPadding,
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
        _suspendSale(),
        AppButton(
          color: Colors.white,
          elevation: 0,
          padding: kButtonPadding,
          onTap: _send,
          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Text(
                'Pagar',
                style: buttonsSmallTextStyle(context, color: pColor),
              ),
              // Icon(Icons.arrow_forward_ios_sharp),

              subTotal(
                large: false,
                color: pColor,
                defaultValue: posBloc.getSubTotal(),
              ),
            ],
          ),
        ),
      ],

      // ),
    );
  }

  Widget _suspendSale() {
    return AppButton(
      padding: kButtonPadding,
      color: Colors.white,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius2),
        side: const BorderSide(color: pColor),
      ),
      width: 10,
      onTap: () async {
        if ((posBloc.getProducts?.length ?? 0) > 0) {
          _searchController.close();
          await showCupertinoDialog(
            barrierDismissible: true,
            context: context,
            useRootNavigator: false,
            builder: (context) {
              return const SuspendSaleAlertDialog();
            },
          );
          // check if empty products then reload view
          if (posBloc.getProducts == {} || posBloc.getProducts == null) {
            _searchController.close();
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const HomeScreen(),
                ),
                (route) => false,
              );
              await const NewSale().launch(context);
            });
          }
        }
      },
      // child: Icon(FontAwesomeIcons.pause),
      child: Text(
        'Suspender',
        style: buttonsSmallTextStyle(context, color: pColor),
      ),
    );
  }

  // funcion para setear el listado de productos en la venta
  _onQueryChanged(String query) async {
    List<ProductModel> products = [];
    final settings = await dataBloc.getSettings();

    int? defaultPriceGroupId;
    try {
      final localSettings = await LocalSettingsProvider.getPriceSettings();
      if (localSettings.politica == PoliticaPrecios.app &&
          localSettings.defaultPriceList != null) {
        defaultPriceGroupId = localSettings.defaultPriceList.toInt();
        posBloc.setVerifyPrices(0);
      } else {
        defaultPriceGroupId = settings['price_group'];
      }
    } catch (e) {
      printConsole(e);
    }
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
          scaffoldAlert(
            context,
            'Producto ' + query + ' no encontrado',
            const Duration(seconds: 1, milliseconds: 500),
            backGroundColor: Colors.red,
          );
          // _searchController.query='';
          _searchController.open();
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
            final result = await posBloc.addProduct(productReq);
            if (result) {
              scaffoldAlert(
                context,
                'Producto ${temp.name} añadido',
                const Duration(seconds: 1),
              );
            }
          }

          products = [];
        } else {
          _queryLen = query.length;
          if (query != '') {
            products = ProductModel.fromJsonList(
              res,
              defaultPriceGroupId: defaultPriceGroupId,
            );
            // [PRACTIPASTA, PAPAS 500G, VERDURAS, FRASCO MAYONESA 4K, FRASCO MOSTAZA 4K, FRASCO TOMATE 1K, FRASCO TOMATE 4K, COSTILLITAS AHUMADAS, ALITAS ADOBADAS PIMPOLLO]
          } else {
            products = [];
          }
        }
      }
    } else {
      products = [];
    }
    posBloc.setProductSearchData(products);
  }

  void _send() {
    if ((posBloc.getProducts?.keys.length ?? 0) > 0) {
      const SalePayment().launch(context);
    } else {
      confirmDialog(
        context,
        'Debe seleccionar productos antes de continuar al pago',
        'assets/images/alert.png',
      );
    }
  }
}
