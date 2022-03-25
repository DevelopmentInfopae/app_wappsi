import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/orders_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/bloc/quotes_bloc.dart';
import 'package:pos_wappsi/components/products/product_card_info.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/wishlist_provider.dart';

class FavoritesOrderSelection extends StatefulWidget {
  const FavoritesOrderSelection({
    Key? key,
    required this.isPortrait,
    this.toOrder = false,
    this.toSale = false,
    this.toQuote = false,
    required this.context,
  }) : super(key: key);

  final bool isPortrait;
  final bool toOrder;
  final bool toSale;
  final bool toQuote;
  final BuildContext context;

  @override
  State<FavoritesOrderSelection> createState() =>
      _FavoritesOrderSelectionState();
}

class _FavoritesOrderSelectionState extends State<FavoritesOrderSelection> {
  List<ProductModel> _favorites = [];
  bool _reloadFavsingFavs = false;

  late CompanyModel customer;

  late String action;

  @override
  void initState() {
    if (widget.toOrder) {
      customer = orderBloc.getCustomer!;
      action = 'add_to_order';
    }
    if (widget.toSale) {
      customer = posBloc.getCustomer!;
      action = 'add_to_cart';
    }
    if (widget.toQuote) {
      customer = quoteBloc.getCustomer!;
      action = 'add_to_quote';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.toOrder) {
      customer = orderBloc.getCustomer!;
      action = 'add_to_order';
    }
    if (widget.toSale) {
      customer = posBloc.getCustomer!;
      action = 'add_to_cart';
    }
    if (widget.toQuote) {
      customer = quoteBloc.getCustomer!;
      action = 'add_to_quote';
    }
    return Column(
      children: [
        _searchBarBackground(_searchBar(context)),
        RefreshIndicator(
                displacement: 0,
                onRefresh: () async {
                  await _reloadFavs(context);
                },
                child: _products())
            .expand()
      ],
    );
  }

  Container _searchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: FloatingSearchAppBar(
        hint: 'Buscar favorito',
        clearQueryOnClose: true,
        // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        height: searchHeight,
        hintStyle: buttonsSmallTextStyle(context),
        color: Colors.grey[200],

        hideKeyboardOnDownScroll: true,
        transitionDuration: const Duration(milliseconds: 800),
        transitionCurve: Curves.easeInOut,

        automaticallyImplyBackButton: false,

        debounceDelay: const Duration(milliseconds: 500),
        onQueryChanged: (query) {
          // Call your model, bloc, controller here.
        },
        // Specify a custom transition to be used for
        // animating between opened and closed stated.
        body: null,
        // transition: CircularFloatingSearchBarTransition(),
        actions: [
          FloatingSearchBarAction.searchToClear(
              // showIfClosed: false,
              ),
          _reloadFavoritesIcon(context),
        ],
      ),
    );
  }

  Widget _reloadFavoritesIcon(BuildContext context) {
    return SizedBox(
      width: 40,
      child: FloatingSearchBarAction(
        showIfOpened: false,
        child: CircularButton(
          icon: _reloadFavsingFavs
              ? FittedBox(
                  child: Loader(
                    decoration: const BoxDecoration(),
                  ),
                )
              : Icon(
                  Icons.refresh,
                  size: leadingIconSize,
                  color: pColor,
                ),
          onPressed: () async {
            await _reloadFavs(context);
          },
        ),
      ),
    );
  }

  Container _searchBarBackground(Widget child) {
    return Container(
      height: searchHeight + 8,
      padding: const EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 6),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.grey,
          offset: Offset(0.0, 1.0), //(x,y)
          blurRadius: 2.0,
        )
      ]),
      child: child,
    );
  }

  Future<void> _reloadFavs(BuildContext context) async {
    setState(() {
      _reloadFavsingFavs = true;
    });

    await WishlistProvider.reloadCustomerFavs(context, customer);
    final pFav = await WishlistProvider.loadCustomerFavorites(customer);

    setState(() {
      _favorites = pFav;
      _reloadFavsingFavs = false;
    });
  }

  Widget _products() {
    return Container(
        padding: const EdgeInsets.only(top: 4),
        // margin: EdgeInsets.o,
        child: FutureBuilder<List<ProductModel>?>(
            future:
                WishlistProvider.loadCustomerFavorites(customer),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // setState(() {
                //   _favorites = snapshot.data!;
                // });
                if (snapshot.data!.isNotEmpty) {
                  _favorites = snapshot.data!;
                  return _favoritesList(context);
                } else {
                  return _empty(context).center();
                }
              } else {
                // ignore: unnecessary_null_comparison
                return _empty(context).center();
              }
            }));
  }

  // _onQueryChanged(String? query) async {
  //   _searchParams['search'] = query;
  //   if (query == '' || query == null) {
  //     final res = await ProductsProvider.getAllProducts();
  //     if (res != null) {
  //       _productsStream.sink.add(ProductModel.fromJsonList(res,
  //           loadInitialQtty: true, qttyKey: 'quantity'));
  //     }
  //   } else {
  //     final res = await ProductsProvider.findProducts(query);
  //     if (res != null) {
  //       _productsStream.sink.add(ProductModel.fromJsonList(res));
  //     }
  //   }
  // }

  Widget _favoritesList(BuildContext context) {
    return ListView.builder(
        itemCount: _favorites.length,
        itemBuilder: (BuildContext context, int index) {
          return ProductCard(
              action: action,
              product: _favorites[index],
              showAllwaysUnitAlert: true);
        });
  }

  Widget _empty(BuildContext context) {
    return AppButton(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
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
      enabled: !_reloadFavsingFavs,
      color: pColor,
      onTap: () async {
        await _reloadFavs(context);
      },
    );
  }
}
