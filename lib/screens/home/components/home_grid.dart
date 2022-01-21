import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/providers/register_form_provider.dart';
import 'package:pos_wappsi/screens/cash_accounting/components/open_register_alert.dart';
import 'package:pos_wappsi/screens/cash_accounting/register_options.dart';
import 'package:pos_wappsi/screens/customers/new_customer.dart';
import 'package:pos_wappsi/screens/db_sync/sync_elements_screen.dart';
import 'package:pos_wappsi/screens/home/components/grid_items.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/screens/home/components/tab_item.dart';
import 'package:pos_wappsi/screens/products/products.dart';
import 'package:pos_wappsi/screens/sales/new_sale.dart';
import 'package:pos_wappsi/screens/sales/sales_screen.dart';
import 'package:pos_wappsi/screens/user/profile_sreen.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';

class HomeGridCards extends StatelessWidget {
  const HomeGridCards({Key? key, required this.gridItems}) : super(key: key);
  final GridItems gridItems;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      padding: EdgeInsets.all(2),
      // margin: EdgeInsets.zero,

      elevation: 5,
      onTap: () async {
        await _navigation(context);
      },
      child: _elements(context),
    );
  }

  Widget _elements(BuildContext context) {
    final size = gridItemSize(context);
    return Column(
      children: [
        _image().paddingTop(4).flexible(flex: 7),
        Container(
          child: _text(context).paddingOnly(bottom: 2, left: 2, right: 2),
          decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5.0),
                  bottomRight: Radius.circular(5.0))),
        ).flexible(flex: 5),
      ],
    ).withSize(width: size.width, height: size.height);
  }

  Widget _text(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1),
      alignment: Alignment.center,
      child: Text(
        gridItems.title.toString(),
        maxLines: 2,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.subtitle1,
      ),
    );
  }

  Widget _image() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Image(
        fit: BoxFit.fitWidth,
        image: AssetImage(
          gridItems.icon.toString(),
        ),
      ),
    );
  }

  Future<void> _navigation(BuildContext context) async {
    if (gridItems.route == 'sales') {
      // to show or hide home bottombar
      await _newSale(context);
      await dataBloc.refreshToken(context);
    } else if (gridItems.route == 'products') {
      Products().launch(context);
      dataBloc.homeKey.currentState?.changeBottomIndex(0);
    } else if (gridItems.route == 'customers') {
      dataBloc.homeKey.currentState?.selectTab(TabItem.clients);
      dataBloc.homeKey.currentState?.changeBottomIndex(0);
    } else if (gridItems.route == 'syncElements') {
      SyncElementsScreen().launch(context);
      dataBloc.homeKey.currentState?.changeBottomIndex(0);
    } else if (gridItems.route == 'logout') {
      await _logout(context);
    } else if (gridItems.route == 'priceVerifier') {
      dataBloc.homeKey.currentState?.selectTab(TabItem.products);
    } else if (gridItems.route == 'addCustomer') {
      // dataBloc.homeKey.currentState?.selectTab(TabItem.clients);
      // await Future.delayed(Duration(seconds: 1));
      NewCustomer().launch(context);
      dataBloc.homeKey.currentState?.changeBottomIndex(0);
      await dataBloc.refreshToken(context);
      // dataBloc.homeKey.currentState?.changeBottomIndex(0);
    } else if (gridItems.route == 'register') {
      dataBloc.homeKey.currentState?.changeBottomIndex(0);
      RegisterOptions().launch(context);
    } else if (gridItems.route == 'list_sales') {
      dataBloc.homeKey.currentState?.changeBottomIndex(0);
      SalesList().launch(context);
    } else if (gridItems.route == 'settings') {
      dataBloc.homeKey.currentState?.selectTab(TabItem.settings);
    }
    if (gridItems.route == 'profile') {
      dataBloc.homeKey.currentState?.changeBottomIndex(0);
      ProfileScreen().launch(context);
    }
  }

  Future<void> _newSale(BuildContext context) async {
    if (dataBloc.registerData.status == 'open') {
      dataBloc.homeKey.currentState?.changeBottomIndex(0);
      NewSale().launch(context);
    } else {
      await showCupertinoDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return ChangeNotifierProvider(
                create: (_) => RegisterFormProvider(),
                child: RegisterAlertDialog(
                  action: 'open',
                ));
          });
      if (dataBloc.registerData.status == 'open') {
        dataBloc.homeKey.currentState?.changeBottomIndex(0);
        NewSale().launch(context);
      } else {
        confirmDialog(context, 'Error al abrir caja, intente nuevamente',
            'assets/images/warning.png');
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    bool _close = false;
    _close = await choiceAlert(
        context, '¿Desea cerrar sesión?', 'assets/images/exit.png');
    if (_close) {
      // with this we restart application
      await posBloc.suspendSale();
      final res = await dataBloc.logout();
      if (res['status'] ?? true) {
        Restart.restartApp(webOrigin: '/loginForm');
      } else {
        simpleAlert(context, res['body']['message']);
      }
    }
  }
}
