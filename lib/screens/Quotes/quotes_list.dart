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
import 'package:pos_wappsi/models/quotes_model.dart';
import 'package:pos_wappsi/providers/quotes_provider.dart';
import 'package:pos_wappsi/providers/sync_db_provider.dart';
import 'package:pos_wappsi/screens/Quotes/components/quotes_card_list.dart';

class QuotesList extends StatefulWidget {
  const QuotesList({Key? key}) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<QuotesList> {
  List<CompanyModel> products = [];
  final _quotesListStream = StreamController<List<QuoteModel>>.broadcast();

  late Size _size;

  final List<String> _filters = [];
  // late Color _pc;
  final Map<String, dynamic> _searchParams = {};

  @override
  void dispose() {
    _quotesListStream.close();
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
        appBar: appBar(context, 'Cotizaciones',
            elevation: false,
            radius: 0,
            image: 'assets/images/quotation.png', onPop: () {
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
        // _QuotesList(),
        RefreshIndicator(
          displacement: 0,
          onRefresh: () async {
            /// sync sma_quotes
            final dbProvider = SyncDBProvider();

            final result = await dbProvider.syncOption(
                context, tableNamesToSyncOpt['sma_quotes']!);
            if (result['error'] == false) {
              final orders = await QuotesProvider.listLocalQuotes(
                  search: _searchParams['search'] ?? '', filters: _filters);
              _quotesListStream.sink.add(orders ?? []);
            }
          },
          child: _quotesList(),
        ).paddingTop(8).expand()
      ],
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
          ],
          automaticallyImplyBackButton: false,
          color: Colors.grey[200],
          body: null),
    );
  }

  Widget _quotesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: FutureBuilder<List<QuoteModel>?>(
          future: QuotesProvider.listLocalQuotes(filters: _filters),
          builder: (BuildContext context,
              AsyncSnapshot<List<QuoteModel>?> snapshot) {
            if (snapshot.hasData) {
              return StreamBuilder<List<QuoteModel>>(
                  stream: _quotesListStream.stream,
                  builder:
                      (context, AsyncSnapshot<List<QuoteModel>> snapshot2) {
                    if (snapshot2.hasData) {
                      return QuotesCardList(
                          quotes: snapshot2.data!,
                          searchParams: _searchParams,
                          filters: _filters);
                    } else {
                      _quotesListStream.sink.add(snapshot.data!);

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

    final res = await QuotesProvider.listLocalQuotes(
        search: query ?? '', filters: _filters);
    if (res != null) {
      _quotesListStream.sink.add(res);
    }
  }
}
