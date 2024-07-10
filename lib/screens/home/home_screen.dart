import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/screens/components/components.dart';
import 'package:pos_wappsi/screens/home/components/grid_items.dart';
import 'package:pos_wappsi/screens/home/components/home_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Application createState() => Application();
}

class Application extends State<HomeScreen> {
  List<Map<String, dynamic>> sliderList = [
    {
      'icon': 'assets/images/banner1.png',
    },
    {
      'icon': 'assets/images/banner2.png',
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
    return CustomSingleChildScrollView(
      physics: AppConstants.scrollPhysics,
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
      _size,
    );
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
            .paddingOnly(top: 3, bottom: 4, right: 2, left: 8),
      ],
    ).withWidth(_size.width * 0.8);
  }

  // show notification icon and shows notification's page
  Widget _notifications() {
    return AppBarLeading(
      onTap: () {
        // select home bottomBar
        // dataBloc.homeKey?.currentState?.changeBottomIndex(0);
        // NotificationScreen().launch(context);
      },
      borderSideColor: Colors.white,
      widget: Icon(FontAwesomeIcons.bell, size: leadingIconSize, color: pColor),
    );
  }

  // message above app options
  Widget _optionsMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Text(
        'Menú principal',
        style: Theme.of(context).textTheme.bodyLarge?.apply(
              fontWeightDelta: 5,
              fontSizeFactor: 1.1,
              color: greyDarkerColor,
            ),
      ),
    );
  }

  // application functions
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
}
