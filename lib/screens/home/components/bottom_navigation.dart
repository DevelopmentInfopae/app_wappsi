import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// ignore: implementation_imports

import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/screens/home/components/tab_item.dart';
// import 'package:pos_wappsi/screens/home/home.dart';
// import 'package:pos_wappsi/screens/home/home_screen.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({Key? key, required this.currentTab, required this.onSelectTab}) : super(key: key);
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // currentTab == TabItem.home?_home():

        buildBottomNavigationBar(context),
      ],
    );
  }

  BottomNavigationBar buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      // key: GlobalKey().,
      backgroundColor: Colors.white,
      iconSize: bottomBarIconSize(context),
      type: BottomNavigationBarType.fixed,
      items: [
        _buildItem(TabItem.home, const Icon(Icons.home_outlined)),
        _buildItem(TabItem.products, const Icon(Icons.price_change_outlined)),
        _buildItem(TabItem.clients, const Icon(Icons.people_outline_rounded)),
        _buildItem(TabItem.settings, const Icon(Icons.app_settings_alt_outlined)),
      ],
      onTap: (index) {
        onSelectTab(TabItem.values[index]);
        // printConsole(TabItem.values[index]);
        // printConsole(onSelectTab.toString());
      },
      currentIndex: currentTab.index,
    );
  }

  BottomNavigationBarItem _buildItem(TabItem tabItem, Icon icon) {
    return BottomNavigationBarItem(
      icon: icon,
      label: tabName[tabItem],
    );
  }
}
