// ignore_for_file: unnecessary_statements

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:pos_wappsi/bloc/customer_bloc.dart';
import 'package:pos_wappsi/components/app_bar_leading.dart';

import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/product_card.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/user_provider.dart';
import 'package:pos_wappsi/providers/wishlist_provider.dart';
import 'package:pos_wappsi/screens/customers/add_favorites.dart';

import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/screens/customers/components/create_user_alert.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/manage_server_resp.dart';
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
  bool _reloading = false;
  List<ProductModel> favoritesToDelete = [];

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
    _pc = pColor;
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
          onTap: () async {
            await _reload(context);
          },
          enabled: !_reloading,
          padding: _reloading ? EdgeInsets.all(8) : kIconButtonPadding,
          widget: _reloading
              ? FittedBox(
                  child: Loader(
                    decoration: BoxDecoration(),
                  ),
                )
              : Icon(
                  Icons.refresh,
                  size: leadingIconSize,
                  color: pColor,
                ),
        ));
  }

  Future<void> _reload(BuildContext context) async {
    setState(() {
      _reloading = true;
    });
    await WishlistProvider.reloadCustomerFavs(context, widget.customer);
    final pFav = await WishlistProvider.loadCustomerFavorites(widget.customer);

    setState(() {
      favorites = pFav;
      _reloading = false;
    });
  }

  Widget _body() {
    // ignore: unnecessary_null_comparison
    return Column(
      children: [_products().expand(), bottom(_bottom(), _pc, _size)],
    );
  }

  Widget _products() {
    return Container(
        padding: EdgeInsets.only(top: 4),
        child: FutureBuilder<List<ProductModel>?>(
            future: WishlistProvider.loadCustomerFavorites(widget.customer),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // setState(() {
                if (favoritesToDelete.length == 0) {
                  favorites = snapshot.data!;
                }
                // });
                if (favorites.length > 0) {
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

  ListView _favoritesList(BuildContext context) {
    return ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: new UniqueKey(),
            onDismissed: (direction) {
              favoritesToDelete.add(favorites[index]);
              setState(() {
                favorites.removeWhere((element) => element == favorites[index]);
              });
            },
            background: Container(
              padding: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(
                    Icons.delete,
                    size: iconSize(context),
                    color: Colors.white,
                  ).paddingOnly(left: 16, right: 8),
                  Text(
                    'Remover favorito',
                    style: buttonsTextStyle(context, fontSizeFactor: 1.05),
                  )
                ],
              ),
            ).paddingSymmetric(vertical: 8),
            child: ProductCard(
              action: 'details',
              product: favorites[index],
            ),
          );
        });
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
      color: pColor,
      onTap: () async {},
    );
  }

  Widget _bottom() {
    return bottom(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _printFavorites(context),
            _saveChanges(context),
            _addFavorites(context),
          ],
        ),
        _pc,
        _size);
  }

  AppButton _addFavorites(BuildContext context) {
    return AppButton(
      onTap: () async {
        final verifyUserE = await UserProvider.verifyIfCompanyHaveUser(
            context, widget.customer.idCloud.toString());
        if (!verifyUserE) {
          AddFavorites(
                  currentAction: 'adding_fav_to_customer',
                  customer: widget.customer)
              .launch(context);
        } else {
          final choice = await showCupertinoDialog(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return CreateUserAlertDialog(
                  customer: widget.customer,
                );
              });
          if (choice) {
            AddFavorites(
              currentAction: 'adding_fav_to_customer',
              customer: widget.customer,
            ).launch(context);
          }
        }
      },
      color: Colors.white,
      padding: kButtonPadding,
      // disabledColor: Colors.white,

      margin: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Agregar',
            style: buttonsSmallTextStyle(context),
          ),
          Icon(Icons.add, size: kIconSize),
        ],
      ),
    );
  }

  AppButton _saveChanges(BuildContext context) {
    return AppButton(
      onTap: () async {
        if (favoritesToDelete.length > 0) {
          final List<Map> temp = [];
          favoritesToDelete.forEach((ProductModel p) {
            temp.add(p.toJson());
          });
          final choice = await listInfoDialogChoice(
              context, temp, 'code', 'name', 'Codigo', 'Nombre',
              title: 'Los siguientes productos se eliminaran de favoritos: ',
              flexCol1: 1,
              flexCol2: 4);
          if (choice) {
            // Get favorites Ids of favoristesToDelete
            final favoritesIds = await WishlistProvider.getFavoritesId(
                widget.customer, favoritesToDelete);
            // Delete them locally and return it's cloud_id to delete it in server
            final favServerIds = await WishlistProvider.deleteLocalFav(
                widget.customer, favoritesIds);
            final res = await WishlistProvider.deleteCustomerFavsOnServer(
                widget.customer.idCloud.toString(), favServerIds);
            manageResponseAlerts(res, context);
            if (!res['error']) {
              // Navigator.pop(context);
              favoritesToDelete = [];
              confirmDialog(
                  context, res['body']['message'], 'assets/images/success.png');
            } else {
              await _reload(context);
            }
          }
        } else {
          Navigator.pop(context);
        }
      },
      color: Colors.white,
      padding: kButtonPadding,
      // disabledColor: Colors.white,

      margin: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Guardar',
            style: buttonsSmallTextStyle(context),
          ),
          Icon(Icons.save_outlined, size: kIconSize),
        ],
      ),
    );
  }

  AppButton _printFavorites(BuildContext context) {
    return AppButton(
      onTap: () async {},
      color: Colors.white,
      padding: kButtonPadding,
      // disabledColor: Colors.white,

      margin: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Imprimir',
            style: buttonsSmallTextStyle(context),
          ),
          Icon(Icons.print_outlined, size: kIconSize),
        ],
      ),
    );
  }
}
