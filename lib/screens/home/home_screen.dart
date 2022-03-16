// ignore: import_of_legacy_library_into_null_safe

// import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/components/appbar.dart';
import 'package:pos_wappsi/components/appbar_leading.dart';
// import 'package:pos_wappsi/screens/Notifications/notification_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/screens/home/components/grid_items.dart';
import 'package:pos_wappsi/screens/home/components/home_grid.dart';
// import 'package:pos_wappsi/utils/text_formating/functions.dart';

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            (dataBloc.getBillerCompany != null
                ? _companyNameLogo(dataBloc.getBillerCompany!)
                : _futureCompNameLogo()),
            _notifications()
          ],
        ).paddingSymmetric(horizontal: 8),
        _size);
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 50,
        ),
        billerThumbNail(company.logo ?? '')
            .paddingOnly(top: 5, bottom: 8, right: 2, left: 8),
        // AutoSizeText(
        //   capitalizeText(company.company ??company.name ??  ''),
        //   style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w900,color: greyDarkerColor),
        //   maxLines: 1,
        //   // overflow: TextOverflow.fade,
        // ).flexible(flex: 3),
      ],
    ).withWidth(_size.width * 0.8);
  }

  // show notification icon and shows notification's page
  Widget _notifications() {
    return AppBarLeading(
        onTap: () {
          // select home bottomBar
          // dataBloc.homeKey.currentState?.changeBottomIndex(0);
          // NotificationScreen().launch(context);
        },
        borderSideColor: Colors.white,
        widget:
            Icon(FontAwesomeIcons.bell, size: leadingIconSize, color: pColor));
    // return AppButton(
    //     padding: EdgeInsets.zero,
    //     elevation: 0,
    //     onTap: () {
    //       // select home bottomBar
    //       // dataBloc.homeKey.currentState?.changeBottomIndex(0);
    //       // NotificationScreen().launch(context);
    //     },
    //     child: Container(
    //       height: (_size.height * 0.05 > 35
    //           ? (_size.height * 0.05 > 40 ? 40 : _size.height * 0.05)
    //           : 35),
    //       // width: _size.width * 0.08 > 60 ?_size.width * 0.08: 60,
    //       // padding: EdgeInsets.only(right: 15),
    //       decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(10.0),
    //         color: Theme.of(context).primaryTextTheme.bodyText2!.color,
    //         // color:Colors.red
    //       ),
    //       child: Image.asset('assets/images/notifications.png').paddingAll(4),
    //     ));
  }

  // message above app options
  Widget _optionsMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Text(
        'Menú principal',
        style: Theme.of(context).textTheme.headline6?.apply(
            fontWeightDelta: 5, fontSizeFactor: 1.1, color: greyDarkerColor),
      ),
    );
  }

  // aplciation functions
  Widget _options() {
    final gridItems = gridItemsForPermissions();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Wrap(
        // physics: NeverScrollableScrollPhysics(),
        // shrinkWrap: true,
        // childAspectRatio: 1.3,
        // crossAxisCount: 3,
        children: List.generate(
          gridItems.length,
          (index) => FittedBox(
            fit: BoxFit.fitHeight,
            child: HomeGridCards(
              gridItems: gridItems[index],
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
