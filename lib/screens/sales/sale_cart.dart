// ignore_for_file: unnecessary_statements

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/screens/home/home_screen.dart';
import 'package:pos_wappsi/screens/products/components/widgets.dart';
import 'package:pos_wappsi/screens/sales/components/product_card.dart';

import 'package:pos_wappsi/screens/sales/components/search.dart';
import 'package:pos_wappsi/screens/sales/components/suspend_sale_alert.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos_wappsi/screens/sales/components/widgets.dart';
import 'package:pos_wappsi/screens/sales/new_sale.dart';
import 'package:pos_wappsi/screens/sales/sale_payment.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/barcode_camera_scan.dart';
// import 'package:pos_wappsi/utils/alerts.dart';

class SaleCart extends StatefulWidget {
  SaleCart({Key? key}) : super(key: key);

  @override
  _SaleCartState createState() => _SaleCartState();
}

class _SaleCartState extends State<SaleCart> {
  late final _leadingActions = [
    FloatingSearchBarAction(
      child: Icon(
        Icons.search,
        // color: _pc,
      ).paddingLeft(7),
    )
  ];

  ScrollController _scrollController = new ScrollController();

  late Size _size;
  late Color _pc;
  String _query = '';

  // TO control changes in products and execute focus task
  int _productsCount = 0;
  int _itemsCount = 0;

  late TextTheme _textTheme;

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
    _pc = Theme.of(context).primaryColor;
    _size = MediaQuery.of(context).size;
    _textTheme = Theme.of(context).textTheme;

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
      padding: EdgeInsets.symmetric(horizontal: 5),
      // border: BorderSide(color: _pc, width: 1),
      borderRadius: BorderRadius.circular(10),
      margins: EdgeInsets.zero,
      hint: 'Buscar producto',
      actions: [
        Container(
          width: _size.width * 0.17,
        )
      ],
      openWidth: _size.width,

      height: searchHeight,
      queryStyle: _textTheme.headline6!,
      leadingActions: _leadingActions,
      hintStyle: _textTheme.headline6!,
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
        style: _textTheme.headline6!,
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
            stream: posBloc.productViewStream,
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

                  return ListView.builder(
                      itemCount: snapshot.data!.keys.length,
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        final k = snapshot.data!.entries.elementAt(index).key;
                        final pCard = ProductCard(
                          key: UniqueKey(),
                          quantityFocusNode: FocusNode(),
                          formKey: new GlobalObjectKey<FormState>(k),
                          product: snapshot.data!.entries.elementAt(index),
                        );
                        if (index == 0 &&
                            dataBloc.settings!['set_focus'] == 1) {
                          if (productRequestFocus) {
                            pCard.quantityFocusNode.requestFocus();
                          }
                        } else {
                          pCard.quantityFocusNode.unfocus();
                        }
                        return Dismissible(
                            key: new Key(k),
                            background: Container(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: iconSize(context),
                                    color: Colors.white,
                                  ).paddingOnly(left: 16, right: 8),
                                  Text(
                                    'Quitar elemento',
                                    style: buttonsTextStyle(context,
                                        fontSizeFactor: 1.05),
                                  )
                                ],
                              ),
                            ).paddingSymmetric(vertical: 4),
                            onDismissed: (direction) {
                              posBloc.removeProduct(k);
                            },
                            child: pCard);
                      });
                }
              } else {
                // ignore: unnecessary_null_comparison
                posBloc.setProductView(posBloc.productsAdded);
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
      color: Theme.of(context).primaryColor,
      onTap: () {
        posBloc.getSearchBarController.open();
      },
    );
  }

  Widget _bottom() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _suspendSale().paddingLeft(20),
        AppButton(
          color: pColor,
          elevation: 0,
          padding: EdgeInsets.zero,
          onTap: _send,
          child: Row(
            children: [
              _pay(),
              subTotal(large: _size.width > 450),
            ],
          ),
        ).paddingOnly(left: 16).expand(),
      ],

      // ),
    );
  }

  Widget _pay() {
    return Container(
      padding: kButtonPadding,
      decoration: BoxDecoration(
          color: okColorWappsi, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Text(
            'Pagar',
            style: buttonsSmallTextStyle(context, color: Colors.white),
          ),
          // Icon(Icons.arrow_forward_ios_sharp),
        ],
      ),
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
      res = await ProductModel.findProducts(query, limit: true);
    } else {
      res = await ProductModel.findProducts(query, overselling: false);
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
        _query = query;
        if (query != '') {
          products = ProductModel.fromJsonList(res);
        } else {
          products = [];
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
