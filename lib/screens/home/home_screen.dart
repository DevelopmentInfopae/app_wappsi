// ignore: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/components/appBar.dart';
import 'package:pos_wappsi/screens/Notifications/notification_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/screens/home/components/grid_items.dart';
import 'package:pos_wappsi/screens/home/components/home_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> sliderList = [
    {
      "icon": 'assets/images/banner1.png',
    },
    {
      "icon": 'assets/images/banner2.png',
    }
  ];
  PageController pageController = PageController(initialPage: 0);
  late Size _size;
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: _body(),
        appBar: _appBar(),
      ),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _optionsMessage().center(),
          _options(),
          // _newsMessage(),
          // _news(),
        ],
      ),
    );
  }

  // appbar widgets
  PreferredSize _appBar() {
    return boxAppBar(
        Row(
          children: [
            // imgTumbnail().withWidth(_size.width*0.16).paddingSymmetric(horizontal: 10),

            _wappsi().paddingOnly(left: 15, right: 15).expand(),
            // Spacer(),
            // _cash(),

            _notifications().paddingRight(10)
          ],
        ).withHeight(_size.height * 0.11 > 70 ? _size.height * 0.11 : 70),
        _size);
  }

  // display information about user in system
  Widget _wappsi() {
    return Row(
      children: [
        Image.asset('assets/images/wappsi.png').withHeight(
            _size.height * 0.048 > 30
                ? (_size.height * 0.04 > 35 ? 35 : _size.height * 0.04)
                : 30),
        Image.asset(
          'assets/images/wappsi_pos_movil.png',
          width: _size.width * 0.55 > 270
              ? 270
              : (_size.width * 0.5 > 280 ? 280 : _size.width * 0.55),
        )
      ],
    );
  }

  // show notification icon and shows notification's page
  Widget _notifications() {
    return Container(
        height: (_size.height * 0.05 > 35
            ? (_size.height * 0.05 > 40 ? 40 : _size.height * 0.05)
            : 35),
        // width: _size.width * 0.08 > 60 ?_size.width * 0.08: 60,
        padding: EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Theme.of(context).primaryTextTheme.bodyText2!.color,
          // color:Colors.red
        ),
        child: Center(
          child: GestureDetector(
            onTap: () {
              // select home bottomBar
              dataBloc.homeKey.currentState?.changeBottomIndex(0);
              NotificationScreen().launch(context);
            },
            child: Image.asset('assets/images/notifications.png').paddingAll(4),
          ),
        ));
  }

  // message above app options
  Widget _optionsMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Text(
        'Menú principal',
        style: Theme.of(context)
            .textTheme
            .headline6
            ?.apply(fontWeightDelta: 5, fontSizeFactor: 1.1),
      ),
    );
  }

  // aplciation functions
  Widget _options() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Wrap(
        // physics: NeverScrollableScrollPhysics(),
        // shrinkWrap: true,
        // childAspectRatio: 1.3,
        // crossAxisCount: 3,
        children: List.generate(
          freeIcons.length,
          (index) => FittedBox(
            fit: BoxFit.fitHeight,
            child: HomeGridCards(
              gridItems: freeIcons[index],
            ).paddingSymmetric(vertical: 8, horizontal: 10),
          ),
        ),
      ),
    );
  }

  // // mesage above news
  // Widget _newsMessage() {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Row(
  //       children: [
  //         SizedBox(
  //           width: 10.0,
  //         ),
  //         Text(
  //           'Novedades',
  //           style: GoogleFonts.poppins(
  //             color: Colors.black,
  //             fontWeight: FontWeight.bold,
  //             fontSize: 20.0,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // // display some news and novelties
  // Widget _news() {
  //   return Container(
  //     height: 150,
  //     width: 320,
  //     child: PageView.builder(
  //       pageSnapping: true,
  //       itemCount: sliderList.length,
  //       controller: pageController,
  //       onPageChanged: (int index) {},
  //       itemBuilder: (_, index) {
  //         return Row(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             Image.asset(
  //               sliderList[index]['icon'],
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }
}
