// import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
// import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/screens/home/components/bottom_navigation.dart';
import 'package:pos_wappsi/screens/home/components/tab_item.dart';
import 'package:pos_wappsi/screens/home/components/tab_navigator.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/functions.dart';
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
  late Size _size;

  int _bottomIndex = 1;

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
                context, '¿Desea cerrar sesión?', 'assets/images/exit.png');
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
        body: Stack(children: <Widget>[
          _buildOffstageNavigator(TabItem.home),
          _buildOffstageNavigator(TabItem.products),
          _buildOffstageNavigator(TabItem.clients),
          _buildOffstageNavigator(TabItem.settings),
        ]),
        bottomNavigationBar: _bottomWidget(),
      ),
    );
  }

  Widget _bottomWidget() {
    return Container(
        // color: Colors.white,
        // padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(1.0, 0.0), //(x,y)
            blurRadius: 5.0,
          )
        ]),

        // alignment: Alignment.center,
        height: getBottomNavBarHeight(context),
        child: Stack(
          children: [
            _bottomNavBar(_bottomIndex).paddingTop(2),
            syncing ? LinearProgressIndicator() : Container()
          ],
        ));
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
        _bottom()
      ],
    ).paddingTop(2);
  }

  Widget _bottom() {
    // ignore: unnecessary_null_comparison
    return dataBloc.getBillerCompany != null
        ? _companyNameLogo(dataBloc.getBillerCompany!)
        : _futureCompNameLogo();
  }

  FutureBuilder<dynamic> _futureCompNameLogo() {
    return FutureBuilder(
      future: CompanyModel.getCompanyBiller(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          dataBloc.setBillerCompany(snapshot.data);
          return _companyNameLogo(snapshot.data);
        } else {
          return Container();
        }
      },
    );
  }

  Widget _companyNameLogo(CompanyModel company) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          billerThumbNail(company.logoSquare ?? '')
              .paddingRight(4)
              .flexible(flex: 1),
          AutoSizeText(
            capitalizeText(company.name ?? company.company ?? ''),
            style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w900),
            maxLines: 2,
          ).flexible(flex: 3),
        ],
      ).withWidth(_size.width * 0.8),
    );
  }

  /// Change bottom widget to show up on the bottom stack
  void changeBottomIndex(int index) {
    setState(() {
      _bottomIndex = index;
    });
  }

  /// Show or hide floating loader indicator
  void syncLoader(bool status) {
    setState(() {
      syncing = status;
    });
  }

  void selectTab(TabItem tabItem) {
    // print(tabItem);

    if (tabItem == _currentTab) {
      // pop to first route

      _navigatorKeys[tabItem]!.currentState!.popUntil((route) {
        return route.isFirst;
      });
    } else {
      setState(() => _currentTab = tabItem);
    }

    // to change bottomwidget
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
    // print(tabItem);
    return Offstage(
      offstage: _currentTab != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem],
        tabItem: tabItem,
      ),
    );
  }
}
