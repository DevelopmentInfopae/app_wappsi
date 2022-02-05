import 'package:flutter/material.dart';
import 'package:pos_wappsi/screens/customers/customers.dart';
// import 'package:pos_wappsi/screens/Authentication/login_form.dart';
import 'package:pos_wappsi/screens/home/components/tab_item.dart';
import 'package:pos_wappsi/screens/home/home_screen.dart';
import 'package:pos_wappsi/screens/products/price_verifier.dart';
import 'package:pos_wappsi/screens/settings/settings_screen.dart';
// import 'package:pos_wappsi/screens/products/products.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  // static const String root = '/';
}

class TabNavigator extends StatelessWidget {
  const TabNavigator({Key? key, required this.navigatorKey, required this.tabItem}) : super(key: key);
  final GlobalKey<NavigatorState>? navigatorKey;
  final TabItem tabItem;

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    Map<String, Widget Function(BuildContext)> routes ={};
    if (tabName[tabItem] == 'Inicio') {
      routes = {
        TabNavigatorRoutes.root: (context) => const HomeScreen(),
      };
    } else if (tabName[tabItem] == 'Precios') {
      routes = {
        TabNavigatorRoutes.root: (context) => const ProductPrice(),
      };
    } else if (tabName[tabItem] == 'Clientes') {
      routes = {
        TabNavigatorRoutes.root: (context) => const Customers(),
      };
    } else if (tabName[tabItem] == 'Ajustes') {
      routes = {
        TabNavigatorRoutes.root: (context) => const SettingsScreen(),
      };
    }
    return routes;
  }

  @override
  Widget build(BuildContext context) {
    final routeBuilders = _routeBuilders(context);
    return Navigator(
      key: navigatorKey,
      initialRoute: TabNavigatorRoutes.root,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => routeBuilders[routeSettings.name!]!(context),
        );
      },
    );
  }
}
