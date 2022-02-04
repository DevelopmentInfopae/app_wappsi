// ignore_for_file: unnecessary_statements

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/product_list.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/products_provider.dart';
// import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/screens/home/home_screen.dart';
import 'package:pos_wappsi/screens/products/components/widgets.dart';
// import 'package:pos_wappsi/screens/sales/components/sale_product_list_widget.dart';

import 'package:pos_wappsi/screens/sales/components/search.dart';
// import 'package:pos_wappsi/screens/sales/components/select_product_unit_alert.dart';
import 'package:pos_wappsi/screens/sales/components/suspend_sale_alert.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos_wappsi/screens/sales/components/widgets.dart';
import 'package:pos_wappsi/screens/sales/new_sale.dart';
import 'package:pos_wappsi/screens/sales/sale_payment.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/barcode_camera/barcode_camera_scan.dart';
// import 'package:pos_wappsi/utils/alerts.dart';

class SaleCart extends StatefulWidget {
  SaleCart({Key? key}) : super(key: key);

  @override
  _SaleCartState createState() => _SaleCartState();
}

class _SaleCartState extends State<SaleCart> {


  ScrollController _scrollController = new ScrollController();

  late Size _size;
  String _query = '';

  // TO control changes in products and execute focus task
  int _productsCount = 0;
  int _itemsCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    posBloc.disposeSearchController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    // _textTheme = Theme.of(context).textTheme;

    // initialize search controller
    posBloc.setSearchController(new FloatingSearchBarController());
    return Scaffold(
        appBar: appBar(context, 'Venta POS',
            elevation: false,
            radius: 0,
            image: 'assets/images/add-to-cart.png'),
        body: _searchbar());
  }

  Widget _searchbar() {
    return Stack(
      children: [
        _searchHeight(),
        _searchField().paddingOnly(left: 5, right: 5, top: 1),
        barCode(context, () async {
          posBloc.getSearchBarController.open();
          final res = await scanBarcodeNormal();
          posBloc.getSearchBarController.query = res ?? '';
          // posBloc.getSearchBarController.hide();
        }),
      ],
    );
  }

  Container _searchHeight() {
    return Container(
      height: searchHeight + 8,
      width: _size.width,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
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
      // padding: EdgeInsets.symmetric(horizontal: 8),
      // border: BorderSide(color: _pc, width: 1),
      borderRadius: BorderRadius.circular(10),
      margins: EdgeInsets.zero,
      hint: 'Buscar producto',
      actions: [
        FloatingSearchBarAction.searchToClear(
          
        ),
        Container(
          width: _size.width * 0.15,
        )
      ],
      openWidth: _size.width,

      height: searchHeight,
      queryStyle:  buttonsSmallTextStyle(context),
      // leadingActions: _leadingActions,
      hintStyle:  buttonsSmallTextStyle(context),
      automaticallyImplyBackButton: false,
      controller: posBloc.getSearchBarController,
      body: _body(),
      onSubmitted: (_) {
        posBloc.getSearchBarController.close();
      },
      backgroundColor: Colors.grey[200],
      backdropColor: Colors.white30,
      transitionCurve: Curves.easeInOutCubic,
      transition: CircularFloatingSearchBarTransition(),
      physics: const BouncingScrollPhysics(),
      builder: (context, _) => buildBody(),
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
        padding: EdgeInsets.only(top: 15),
        child: StreamBuilder<Map<String, ProductModel>>(
            stream: posBloc.productsStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (posBloc.getItemsCount() == 0) {
                  _searchBarFocusManagement();
                  _productsCount = 0;
                  _itemsCount = 0;
                  return _empty(context).center();
                } else {
                  _productsCount += 1;
                  _itemsCount += 1;
                  bool productRequestFocus = false;
                  if (_productsCount == snapshot.data!.length ||
                      _itemsCount == posBloc.getItemsCount()) {
                    if (_scrollController.hasClients) {
                      _scrollController
                          .jumpTo(_scrollController.position.minScrollExtent);
                    }
                    // final xd = posBloc.settings['set_focus'];
                    // print();
                    productRequestFocus = _searchBarFocusManagement();
                  } else if (_productsCount - 2 == snapshot.data!.length) {
                    // Nothing to do when items are removed from cart
                  } else {
                    // _searchBarFocusManagement();
                    _productsCount = snapshot.data!.length;
                    _itemsCount = posBloc.getItemsCount();
                  }
                  Map<String, ProductModel> saleProductsList = snapshot.data!;
                  return ProductsList(
                      productList: saleProductsList,
                      scrollController: _scrollController,
                      productRequestFocus: productRequestFocus);
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
        // posBloc.getSearchBarController.close();
        if (posBloc.getSearchBarController.isOpen) {
          posBloc.getSearchBarController.query = '';
        } else {
          posBloc.getSearchBarController.open();
        }
      });
      return false;
    } else if (dataBloc.settings!['set_focus'] == 1) {
      posBloc.getSearchBarController.close();
      return true;
    }
  }

  Widget _empty(BuildContext context) {
    return AppButton(
      padding: kButtonPadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
      color: pColor,
      onTap: () {
        posBloc.getSearchBarController.open();
      },
    );
  }

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

              subTotal(large: false, color: pColor, defaultValue: posBloc.getSubTotal()),
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
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: pColor)),
      width: 10,
      onTap: () async {
        if ((posBloc.getProducts?.length ?? 0) > 0) {
          posBloc.getSearchBarController.close();
          await showCupertinoDialog(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return SuspendSaleAlertDialog();
              });
          // check if empty products then reload view
          if (posBloc.getProducts == {} ||
              posBloc.getProducts == null ||
              posBloc.getProducts?.length == 0) {
            posBloc.getSearchBarController.close();
            WidgetsBinding.instance!.addPostFrameCallback((_) async {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => HomeScreen(),
                ),
                (route) => false,
              );
              await NewSale().launch(context);
            });
          }
        }
      },
      // child: Icon(FontAwesomeIcons.pause),
      child: Text('Suspender',
          style: buttonsSmallTextStyle(context, color: pColor)),
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
    // print('xd');
    if (res != null) {
      if (res.length == 0) {
        if ((query.length - _query.length > 1)) {
          posBloc.getSearchBarController.clear();
          // posBloc.getSearchBarController.query='';
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
            final result = await posBloc.addProduct(productReq);
            if(result){
              scaffoldAlert(context, 'Producto ${temp.name} añadido', Duration(seconds: 1));
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
    posBloc.setProductSearchData(products);
  }

  void _send() {
    if ((posBloc.getProducts?.keys.length ?? 0) > 0) {
      SalePayment().launch(context);
    } else {
      confirmDialog(
          context,
          "Debe seleccionar productos antes de continuar al pago",
          "assets/images/alert.png");
    }
  }
}
