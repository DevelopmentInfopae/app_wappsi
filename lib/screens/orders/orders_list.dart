import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/constant.dart';
// import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/order_model.dart';
import 'package:pos_wappsi/providers/local_orders_provider.dart';
import 'package:pos_wappsi/screens/orders/components/order_card_list.dart';

class OrdersList extends StatefulWidget {
  const OrdersList({Key? key}) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<OrdersList> {
  List<CompanyModel> products = [];
  final _ordersListStream = StreamController<List<OrderModel>>.broadcast();

  late Size _size;
  // late Color _pc;
  final Map<String, dynamic> _searchParams = {};

  @override
  void dispose() {
    _ordersListStream.close();
    super.dispose();
  }

  // late ThemeData _theme;
  @override
  Widget build(BuildContext context) {
    // avoid errors related to unstability of scaffold with no key
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    // _theme = Theme.of(context);
    _size = MediaQuery.of(context).size;
    // _pc = pColor;

    return WillPopScope(
      onWillPop: () async {
        dataBloc.homeKey.currentState?.changeBottomIndex(1);
        // printConsole('here i am');
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: appBar(context, 'Listado de pedidos',
            elevation: false,
            radius: 0,
            image: 'assets/images/order-list.png', onPop: () {
          dataBloc.homeKey.currentState?.changeBottomIndex(1);
          Navigator.pop(context);
        }),
        body: _body(),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [_searchBar().paddingBottom(5), _ordersList().expand()],
    );
  }

  Widget _searchBar() {
    return Stack(
      children: [
        _searchBarBackground(),
        _searchField().paddingSymmetric(horizontal: 7),
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
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: FloatingSearchAppBar(
          hint: ' Buscar pedido',
          transitionDuration: const Duration(milliseconds: 800),
          clearQueryOnClose: true,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          // alwaysOpened: true,
          titleStyle: buttonsSmallTextStyle(context),
          hintStyle: buttonsSmallTextStyle(context),
          hideKeyboardOnDownScroll: true,
          onQueryChanged: _onQueryChanged,
          // height: _size.height * 0.078 < 55 ? 55 : _size.height * 0.078,
          elevation: 0,
          actions: [
            FloatingSearchBarAction.searchToClear(
                // showIfClosed: false,
                ),
          ],
          automaticallyImplyBackButton: false,
          color: Colors.grey[200],
          body: null),
    );
  }

  Widget _ordersList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: FutureBuilder<List<OrderModel>?>(
          future: LocalOrdersProvider.listLocalOrders(),
          builder: (BuildContext context,
              AsyncSnapshot<List<OrderModel>?> snapshot) {
            if (snapshot.hasData) {
              return StreamBuilder<List<OrderModel>>(
                  stream: _ordersListStream.stream,
                  builder:
                      (context, AsyncSnapshot<List<OrderModel>> snapshot2) {
                    if (snapshot2.hasData) {
                      return OrdersCardList(
                          orders: snapshot2.data!, searchParams: _searchParams);
                    } else {
                      _ordersListStream.sink.add(snapshot.data!);

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
          }),
    );
  }

  _onQueryChanged(String? query) async {
    _searchParams['search'] = query;
    if (query == '' || query == null) {
      final res = await LocalOrdersProvider.listLocalOrders();
      // ignore: unnecessary_null_comparison
      if (res != null) {
        _ordersListStream.sink.add(res);
      }
    } else {
      final res = await LocalOrdersProvider.listLocalOrders(search: query);
      if (res != null) {
        _ordersListStream.sink.add(res);
      }
    }
  }
}
