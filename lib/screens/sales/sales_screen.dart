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
import 'package:pos_wappsi/models/local_sales_model.dart';
import 'package:pos_wappsi/screens/sales/components/sales_card_list.dart';

class SalesList extends StatefulWidget {
  const SalesList({Key? key}) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<SalesList> {
  List<CompanyModel> products = [];
  final _salesListStream = StreamController<List<SalesModel>>.broadcast();

  late Size _size;
  // late Color _pc;
  late TextTheme _theme;

  final Map<String, dynamic> _searchParams = {};

  @override
  void dispose() {
    _salesListStream.close();
    super.dispose();
  }

  // late ThemeData _theme;
  @override
  Widget build(BuildContext context) {
    // avoid errors related to unstability of scaffold with no key
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    // _theme = Theme.of(context);
    _size = MediaQuery.of(context).size;
    _theme = Theme.of(context).textTheme;
    // _pc = pColor;

    return WillPopScope(
      onWillPop: () async {
        dataBloc.homeKey.currentState?.changeBottomIndex(1);
        // printConsole('here i am');
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: appBar(context, 'Lista de Ventas',
            elevation: false,
            radius: 0,
            image: 'assets/images/shopping-list.png', onPop: () {
          dataBloc.homeKey.currentState?.changeBottomIndex(1);
          Navigator.pop(context);
        }),
        body: _body(),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [_searchBar().paddingBottom(5), _salesList().expand()],
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
          hint: ' Buscar venta',
          transitionDuration: const Duration(milliseconds: 800),
          clearQueryOnClose: true,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          // alwaysOpened: true,
          titleStyle: _theme.headline6!,
          hintStyle: _theme.headline6!,
          hideKeyboardOnDownScroll: true,
          onQueryChanged: _onQueryChanged,
          // height: _size.height * 0.078 < 55 ? 55 : _size.height * 0.078,
          elevation: 0,
          actions: [Container()],
          leadingActions: const [Icon(Icons.search)],
          automaticallyImplyBackButton: false,
          color: Colors.grey[100],
          body: null),
    );
  }

  Widget _salesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: FutureBuilder<List<SalesModel>?>(
          future: SalesModel.listSales(),
          builder: (BuildContext context,
              AsyncSnapshot<List<SalesModel>?> snapshot) {
            if (snapshot.hasData) {
              return StreamBuilder<List<SalesModel>>(
                  stream: _salesListStream.stream,
                  builder:
                      (context, AsyncSnapshot<List<SalesModel>> snapshot2) {
                    if (snapshot2.hasData) {
                      return SalesCardList(
                          sales: snapshot2.data!, searchParams: _searchParams);
                    } else {
                      _salesListStream.sink.add(snapshot.data!);

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
      final res = await SalesModel.listSales();
      // ignore: unnecessary_null_comparison
      if (res != null) {
        _salesListStream.sink.add(res);
      }
    } else {
      final res = await SalesModel.listSales(search: query);
      if (res != null) {
        _salesListStream.sink.add(res);
      }
    }
  }
}
