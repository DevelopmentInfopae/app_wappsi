// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/config/bd_sync.dart';
import 'package:pos_wappsi/constant.dart';
// import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/order_model.dart';
import 'package:pos_wappsi/providers/local_orders_provider.dart';
import 'package:pos_wappsi/providers/sync_db_provider.dart';
import 'package:pos_wappsi/screens/orders/components/order_card_list.dart';
import 'package:pos_wappsi/utils/text_formating/order_status_mapping.dart';

import '../../providers/orders_provider.dart';

class OrdersList extends StatefulWidget {
  const OrdersList({Key? key}) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<OrdersList> {
  List<CompanyModel> products = [];
  final _ordersListStream = StreamController<List<OrderModel>>.broadcast();

  late Size _size;
  bool showFilters = false;

  final List<String> _filters = [];
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
        dataBloc.homeKey?.currentState?.changeBottomIndex(1);
        // printConsole('here i am');
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: appBar(context, 'Listado de pedidos',
            elevation: false,
            radius: 0,
            image: 'assets/images/order-list.png', onPop: () {
          dataBloc.homeKey?.currentState?.changeBottomIndex(1);
          Navigator.pop(context);
        }),
        body: _body(),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [
        _searchBar(),
        AnimatedCrossFade(
            firstChild: _filterList(),
            secondChild: SizedBox(),
            crossFadeState: showFilters
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: Duration(milliseconds: 200)),
        // _ordersList(),

        // showFilters ? _filterList() : const SizedBox(),
        GestureDetector(
          child: RefreshIndicator(
              displacement: 0,
              onRefresh: () async {
                /// sync sma_order_sales
                final dbProvider = SyncDBProvider();

                final result = await dbProvider.syncOption(
                    context, tableNamesToSyncOpt['sma_order_sales']!);
                if (result['error'] == false) {
                  final orders = await LocalOrdersProvider.listLocalOrders(
                      search: _searchParams['search'] ?? '', filters: _filters);
                  _ordersListStream.sink.add(orders);
                }
              },
              child: _ordersList()),
          onVerticalDragStart: (val) {
            if (showFilters) {
              setState(() {
                showFilters = false;
              });
            }
          },
          onTap: () {
            if (showFilters) {
              setState(() {
                showFilters = false;
              });
            }
          },
        ).paddingTop(8).expand()
      ],
    );
  }

  Widget _filterList() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.grey,
          offset: Offset(0.0, 1.0), //(x,y)
          blurRadius: 2.0,
        )
      ]),
      width: double.infinity,
      child: FutureBuilder(
        future: LocalOrdersProvider.orderStatus(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.length == 1) {
              // setState(() {
              if (_filters.where((s) => s == snapshot.data!.first).isEmpty) {
                _filters.add(snapshot.data!.first);
              }
              // });
            }
            return Wrap(
              children: snapshot.data!.map((e) {
                return FilterChip(
                  label: Text(
                    mapStatusText(e),
                    style: normalTextStyle(context),
                  ),
                  selected:
                      _filters.where((element) => element == e).isNotEmpty,
                  onSelected: (bool value) {
                    if (_filters.where((element) => element == e).isEmpty) {
                      setState(() {
                        _filters.add(e);
                      });
                    } else {
                      setState(() {
                        _filters.remove(e);
                      });
                    }
                  },
                ).paddingSymmetric(horizontal: 8);
              }).toList(),
            );
          } else {
            return const SizedBox(
              height: 0,
            );
          }
        },
      ),
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
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: showFilters
              ? null
              : [
                  const BoxShadow(
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
          borderRadius: const BorderRadius.all(Radius.circular(radius2))),
      child: FloatingSearchAppBar(
          hint: 'Buscar pedido',
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
            FloatingSearchBarAction.icon(
                showIfOpened: true,
                icon: showFilters
                    ? Icons.filter_alt_rounded
                    : Icons.filter_alt_outlined,
                onTap: () {
                  setState(() {
                    showFilters = !showFilters;
                  });
                })
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
          future: LocalOrdersProvider.listLocalOrders(filters: _filters),
          builder: (BuildContext context,
              AsyncSnapshot<List<OrderModel>?> snapshot) {
            if (snapshot.hasData) {
              return StreamBuilder<List<OrderModel>>(
                  stream: _ordersListStream.stream,
                  builder:
                      (context, AsyncSnapshot<List<OrderModel>> snapshot2) {
                    if (snapshot2.hasData) {
                      return OrdersCardList(
                          orders: snapshot2.data!,
                          searchParams: _searchParams,
                          filters: _filters);
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

    List<OrderModel> res = await LocalOrdersProvider.listLocalOrders(
        search: query ?? '', filters: _filters);
    if(res.length<30){
      final findNewInServer = await OrdersProvider.getOrdersFromServer(
          context,
          search:query??"",
          filters: _filters,
        );
        if (findNewInServer) {
          // _page =0;
         res = await LocalOrdersProvider.listLocalOrders(
          search: query ?? '', filters: _filters);
         
        }else{
         
        }
    }
      _ordersListStream.sink.add(res);
    // if (res.isNotEmpty) {
    // }
  }
}
