// ignore_for_file: unnecessary_statements

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:pos_wappsi/bloc/customer_bloc.dart';
import 'package:pos_wappsi/components/app_bar_leading.dart';

import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/go_back_bottom.dart';
import 'package:pos_wappsi/components/product_card.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/screens/customers/add_favorites.dart';

import 'package:nb_utils/nb_utils.dart';
// import 'package:pos_wappsi/utils/alerts.dart';

class ListFavorites extends StatefulWidget {
  final CompanyModel customer;
  ListFavorites({Key? key, required this.customer}) : super(key: key);

  @override
  _ListFavoritesState createState() => _ListFavoritesState();
}

class _ListFavoritesState extends State<ListFavorites> {
  late Size _size;
  late Color _pc;
  List<ProductModel> favorites = [];

  @override
  void initState() {
    super.initState();
    if (customerBloc.getProducts() != null &&
        customerBloc.getProducts() != {}) {}
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pc = Theme.of(context).primaryColor;
    _size = MediaQuery.of(context).size;

    // initialize search controller
    return Scaffold(appBar: _buildAppBar(context), body: _body());
  }

  PreferredSize _buildAppBar(BuildContext context) {
    return appBar(context, 'Favoritos',
        elevation: false,
        radius: 0,
        image: 'assets/images/star.png',
        leading: AppBarLeading(
          onTap: () async{
            await ProductModel.reloadCustomerFavs(context, widget.customer);
          },
          widget: Icon(
            Icons.refresh,
            size: leadingIconSize,
            color: pColor,
          ),
        ));
  }

  Widget _body() {
    // ignore: unnecessary_null_comparison
    return Column(
      children: [_products().expand(), bottom(_bottom(), _pc, _size)],
    );
  }

  Widget _products() {
    return Container(
        padding: EdgeInsets.only(top: 15),
        child: FutureBuilder<List<ProductModel>?>(
            future: ProductModel.loadCustomerFavorites(widget.customer),
            builder: (context, snapshot) {
              if (snapshot.hasData && (snapshot.data?.length ?? 0) > 0) {
                // return Container();

                return ListView(
                  children: snapshot.data!.map((ProductModel p) {
                    return Dismissible(
                      key: new Key(p.id.toString()),
                      onDismissed: (direction) {},
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
                        product: p,
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
          Text(
            'Recargar ',
            style: TextStyle(color: Colors.white),
          ),
          Icon(
            Icons.refresh,
            color: Colors.white,
          ),
        ],
      ),
      color: Theme.of(context).primaryColor,
      onTap: () async {},
    );
  }

  Widget _bottom() {
    return bottom(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GoBackBottom(),
            _addFavorites(context),
          ],
        ),
        _pc,
        _size);
  }

  AppButton _addFavorites(BuildContext context) {
    return AppButton(
      onTap: () async {
        AddFavorites().launch(context);
      },
      color: Colors.white,
      padding: kButtonPadding,
      // disabledColor: Colors.white,

      margin: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Agregar ',
            style: buttonsSmallTextStyle(context),
          ),
          Icon(Icons.add, size: kIconSize),
        ],
      ),
    );
  }
}
