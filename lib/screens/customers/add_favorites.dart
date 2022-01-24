// ignore_for_file: unnecessary_statements

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:pos_wappsi/bloc/customer_bloc.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/product_card.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/companies_provider.dart';
import 'package:pos_wappsi/providers/products_provider.dart';
import 'package:pos_wappsi/screens/products/components/widgets.dart';

import 'package:pos_wappsi/screens/sales/components/search.dart';

import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/utils/barcode_camera/barcode_camera_scan.dart';
import 'package:pos_wappsi/utils/nav_utils.dart';
// import 'package:pos_wappsi/utils/alerts.dart';

class AddFavorites extends StatefulWidget {
  final String currentAction;
  final CompanyModel? customer;
  AddFavorites(
      {Key? key, this.currentAction = 'creating_customer', this.customer})
      : super(key: key);

  @override
  _AddFavoritesState createState() => _AddFavoritesState();
}

class _AddFavoritesState extends State<AddFavorites> {
  late final _leadingActions = [
    FloatingSearchBarAction(
      child: Icon(
        Icons.search,
        // color: _pc,
      ).paddingLeft(7),
    )
  ];

  late Size _size;
  late Color _pc;
  bool _loading = false;
  String _query = '';
  final _searchController = FloatingSearchBarController();
  StreamController<List<ProductModel>> _searchStream =
      StreamController<List<ProductModel>>();

  late TextTheme _textTheme;

  @override
  void initState() {
    super.initState();
    if (customerBloc.getProducts() != null &&
        customerBloc.getProducts() != {}) {}
  }

  @override
  void dispose() {
    _searchController.close();
    _searchStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pc = Theme.of(context).primaryColor;
    _size = MediaQuery.of(context).size;
    _textTheme = Theme.of(context).textTheme;

    // initialize search controller
    return Scaffold(
        appBar: appBar(context, 'Favoritos',
            elevation: false, radius: 0, image: 'assets/images/favorite.png'),
        body: _searchbar());
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
      builder: (context, _) =>
          buildBody(action: 'add_to_favorites', stream: _searchStream.stream),
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
      children: [_products().expand(), bottom(_bottom(), _pc, _size)],
    );
  }

  Widget _products() {
    return Container(
        // height:_size.height*0.78,
        // to avoid overlap with floatingSearchBar
        margin: EdgeInsets.only(top: _size.height * 0.078, bottom: 8),
        padding: EdgeInsets.only(top: 15),
        child: StreamBuilder<Map<String, ProductModel>>(
            stream: customerBloc.favoritesStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // return Container();
                if (!_searchController.isClosed) {
                  // _searchController.hide();
                  _searchController.close();
                }
                return ListView(
                  children: snapshot.data!.keys.map((String k) {
                    return Dismissible(
                      key: new Key(k),
                      onDismissed: (direction) {
                        customerBloc.removeProductFromFav(k);
                      },
                      background: Container(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10)),
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
                      ).paddingSymmetric(vertical: 8),
                      child: ProductCard(
                        action: 'details',
                        product: snapshot.data![k]!,
                      ),
                    );
                  }).toList(),
                );
              } else {
                // ignore: unnecessary_null_comparison
                return _empty(context).center();
              }
            }));
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
            'Añadir productos favoritos',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      color: Theme.of(context).primaryColor,
      onTap: () {
        _searchController.open();
      },
    );
  }

  Widget _bottom() {
    return AppButton(
      child: Text('Siguiente', style: buttonsTextStyle(context)),
      enabled: !_loading,
      onTap: _loading
          ? null
          : () async {
              if (widget.currentAction == 'creating_customer') {
                await dataBloc.refreshToken(context);
                await CompaniesProvider.sendCustomerInfo(context);
              } else if (widget.currentAction == 'adding_fav_to_customer') {
                await dataBloc.refreshToken(context);
                await CompaniesProvider.addCompanyFavs(
                    context, widget.customer!);
                gobackTwoTimes(context);
              }
            },
      color: _pc,
      disabledColor: _pc,
    ).withSize(width: _size.width);
  }

  _onQueryChanged(String query) async {
    List<ProductModel> products = [];
    List<Map>? res;
    res = await ProductsProvider.findProducts(query, limit: true);

    // print('xd');
    if (res != null) {
      if (res.length == 0) {
        if ((query.length - _query.length > 1)) {
          _searchController.clear();
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
    _searchStream.sink.add(products);
  }
}
