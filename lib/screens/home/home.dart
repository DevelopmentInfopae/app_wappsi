// import 'package:auto_size_text_pk/auto_size_text_pk.dart';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/screens/home/components/bottom_navigation.dart';
import 'package:pos_wappsi/screens/home/components/tab_item.dart';
import 'package:pos_wappsi/screens/home/components/tab_navigator.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:restart_app/restart_app.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  var _currentTab = TabItem.home;
  final _navigatorKeys = {
    TabItem.home: GlobalKey<NavigatorState>(),
    TabItem.products: GlobalKey<NavigatorState>(),
    TabItem.settings: GlobalKey<NavigatorState>(),
    TabItem.clients: GlobalKey<NavigatorState>(),
  };
  @override
  void initState() {
    super.initState();
  }

  late Size _size;

  int _bottomIndex = 1;

  bool resizeToAvoidBottomInset = true;

  bool syncing = false;

  @override
  Widget build(BuildContext context) {
    // dataBloc.setTabNAvKeys(_navigatorKeys);
    _size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        bool _close = false;

        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_currentTab]!.currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          // if not on the 'main' tab
          if (_currentTab != TabItem.home) {
            // select 'main' tab
            selectTab(TabItem.home);
            // back button handled by app
            _close = false;
          } else {
            _close = await choiceAlert(
              context,
              '¿Desea cerrar sesión?',
              'assets/images/logout.png',
            );
          }
        }

        if (_close) {
          // with this we restart application
          final res = await dataBloc.logout();
          if (res['status']) {
            Restart.restartApp(webOrigin: '/loginForm');
          } else {
            simpleAlert(context, res['body']['message']);
          }
        }

        return _close;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: Stack(
          children: <Widget>[
            _buildOffstageNavigator(TabItem.home),
            _buildOffstageNavigator(TabItem.products),
            _buildOffstageNavigator(TabItem.clients),
            _buildOffstageNavigator(TabItem.settings),
          ],
        ),
        bottomNavigationBar: _bottomWidget(),
      ),
    );
  }

  Widget _bottomWidget() {
    return Container(
      // color: Colors.white,
      // padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(1.0, 0.0), //(x,y)
            blurRadius: 5.0,
          ),
        ],
      ),

      // alignment: Alignment.center,
      height: getBottomNavBarHeight(context),
      child: Stack(
        children: [
          _bottomNavBar(_bottomIndex).paddingTop(2),
          syncing ? const LinearProgressIndicator() : Container(),
        ],
      ),
    );
  }

  Widget _bottomNavBar(int index) {
    return IndexedStack(
      index: index,
      children: [
        BottomNavigation(
          currentTab: _currentTab,
          onSelectTab: selectTab,
        ),
        // bottom(_bottom(), Colors.white, _size,elevation: true)
        _bottom(),
      ],
    );
  }

  Widget _bottom() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // imgThumbnail().withWidth(_size.width*0.16).paddingSymmetric(horizontal: 10),

          _wappsi().paddingOnly(left: 15, right: 15),
          // Spacer(),
          // _cash(),

          // _notifications().withSize(height: 55, width: 55).paddingRight(10)
        ],
      ),
    );
    // ignore: unnecessary_null_comparison
  }

  // display information about user in system
  Widget _wappsi() {
    return Row(
      children: [
        Image.asset('assets/images/wappsi.png').withHeight(
          _size.height * 0.048 > 30
              ? (_size.height * 0.04 > 35 ? 35 : _size.height * 0.04)
              : 30,
        ),
        Image.asset(
          'assets/images/wappsi_pos_movil.png',
          width: _size.width * 0.55 > 270
              ? 270
              : (_size.width * 0.5 > 280 ? 280 : _size.width * 0.55),
        ),
      ],
    );
  }

  /// Change bottom widget to show up on the bottom stack
  void changeBottomIndex(int index) {
    setState(() {
      _bottomIndex = index;
    });
  }

  /// Change resizeToAvoidBottomInset
  void changeResizeToAvoidBottomInset({bool value = true}) {
    setState(() {
      resizeToAvoidBottomInset = value;
    });
  }

  /// Show or hide floating loader indicator
  void syncLoader(bool status) {
    setState(() {
      syncing = status;
    });
  }

  TabItem get selectedTab {
    return _currentTab;
  }

  void selectTab(TabItem tabItem) {
    // printConsole(tabItem);

    if (tabItem == _currentTab) {
      // pop to first route

      _navigatorKeys[tabItem]!.currentState!.popUntil((route) {
        return route.isFirst;
      });
    } else {
      setState(() => _currentTab = tabItem);
    }

    // to change bottomWidget
    if (tabItem == TabItem.home) {
      //verify if are in home root /
      if (_navigatorKeys[TabItem.home]!.currentState?.canPop() ?? false) {
        changeBottomIndex(0);
      } else {
        changeBottomIndex(1);
      }
    } else {
      setState(() {
        changeBottomIndex(0);
      });
    }
  }

  Widget _buildOffstageNavigator(TabItem tabItem) {
    // printConsole(tabItem);
    return Offstage(
      offstage: _currentTab != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem],
        tabItem: tabItem,
      ),
    );
  }
}
