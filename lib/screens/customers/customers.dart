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
import 'package:pos_wappsi/providers/companies_provider.dart';
import 'package:pos_wappsi/screens/customers/components/customers_card_list.dart';
import 'package:pos_wappsi/screens/customers/new_customer.dart';
import 'package:pos_wappsi/screens/home/components/tab_item.dart';
import 'package:pos_wappsi/components/appbar_leading.dart';

class Customers extends StatefulWidget {
  const Customers({Key? key}) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Customers> {
  List<CompanyModel> products = [];
  final _customersStream = StreamController<List<CompanyModel>>.broadcast();

  late Size _size;
  final _searchController = FloatingSearchBarController();

  final Map<String, dynamic> _searchParams = {};

  @override
  void dispose() {
    _customersStream.close();
    super.dispose();
    _searchController.dispose();
  }

  // late ThemeData _theme;
  @override
  Widget build(BuildContext context) {
    // avoid errors related to unstability of scaffold with no key

    // _theme = Theme.of(context);
    _size = MediaQuery.of(context).size;
    // _pc = pColor;

    return Scaffold(
      appBar: _appBar(context),
      body: _body(),
    );
  }

  PreferredSize _appBar(BuildContext context) {
    return appBar(context, 'Clientes',
        elevation: false,
        radius: 0,
        image: 'assets/images/enterprise.png', onPop: () {
      dataBloc.homeKey.currentState?.selectTab(TabItem.home);
      _searchController.close();
    },
        leading: AppBarLeading(
            widget: Icon(Icons.add, size: leadingIconSize, color: pColor),
            onTap: () async {
              const NewCustomer().launch(context);
              await dataBloc.refreshToken(context);
            }));
  }

  Widget _body() {
    return Column(
      children: [_searchBar().paddingBottom(5), _customersList().expand()],
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
          hint: 'Buscar cliente',
          controller: _searchController,
          transitionDuration: const Duration(milliseconds: 800),
          clearQueryOnClose: true,
          // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          // alwaysOpened: true,
          titleStyle: buttonsSmallTextStyle(context),
          hintStyle: buttonsSmallTextStyle(context),
          hideKeyboardOnDownScroll: true,
          onQueryChanged: _onQueryChanged,
          // height: _size.height * 0.078 < 55 ? 55 : _size.height * 0.078,
          elevation: 0,
          actions: [FloatingSearchBarAction.searchToClear()],
          automaticallyImplyBackButton: false,
          color: Colors.grey[200],
          body: null),
    );
  }

  Widget _customersList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FutureBuilder<List<Map>?>(
          future: CompaniesProvider.getAllCustomers(limit: 50),
          builder: (BuildContext context, AsyncSnapshot<List<Map>?> snapshot) {
            if (snapshot.hasData) {
              return StreamBuilder<List<CompanyModel>?>(
                  stream: _customersStream.stream,
                  builder:
                      (context, AsyncSnapshot<List<CompanyModel>?> snapshot2) {
                    if (snapshot2.hasData) {
                      return RefreshIndicator(
                          onRefresh: ()async{
                            final res = await CompaniesProvider.getAllCustomers(limit: 50);
                            _customersStream.sink.add(CompanyModel.fromJsonList(res!));
                          },
                          child: CustomerCardList(
                            customer: snapshot2.data!,
                            searchParams: _searchParams,
                          ),
                        );
                    } else {
                      _customersStream.sink
                          .add(CompanyModel.fromJsonList(snapshot.data!));

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
      final res = await CompaniesProvider.getAllCustomers();
      if (res != null) {
        _customersStream.sink.add(CompanyModel.fromJsonList(res));
      }
    } else {
      final res = await CompaniesProvider.findCustomer(query);
      if (res != null) {
        _customersStream.sink.add(CompanyModel.fromJsonList(res));
      }
    }
  }
}
