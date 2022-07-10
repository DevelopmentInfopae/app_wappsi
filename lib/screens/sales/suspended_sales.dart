import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/widgets.dart';
// import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/suspended_sale_model.dart';
import 'package:pos_wappsi/providers/suspended_sales_provider.dart';
import 'package:pos_wappsi/screens/sales/suspended_sale_details.dart';
import 'package:pos_wappsi/utils/text_formating/date_to_text.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

class SuspendedSalesScreen extends StatefulWidget {
  final List<SuspendedSales>? suspendedSales;
  const SuspendedSalesScreen({Key? key, required this.suspendedSales})
      : super(key: key);

  @override
  _SuspendedSalesScreenState createState() => _SuspendedSalesScreenState();
}

class _SuspendedSalesScreenState extends State<SuspendedSalesScreen> {
  final _suspSalesStream = StreamController<List<SuspendedSales>>.broadcast();
  final _searchController = FloatingSearchBarController();

  @override
  void dispose() {
    _suspSalesStream.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, 'Suspendidas',
          image: 'assets/images/sleeping.png', elevation: false),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        _searchBar(),
        SingleChildScrollView(
                child: _suspendedSales()
                    .paddingSymmetric(horizontal: 8, vertical: 4))
            .expand()
        // bottom(_buttons(), pColor, _size)
      ],
    );
  }

  Widget _searchBar() {
    return Stack(
      children: [
        _searchBarBackground(),
        _searchField().paddingSymmetric(horizontal: 7),
      ],
    );
  }

  Container _searchBarBackground() {
    return Container(
      height: searchHeight + 8,
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.grey,
          offset: Offset(0.0, 1.0), //(x,y)
          blurRadius: 2.0,
        )
      ]),
    );
  }

  Widget _searchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.all(Radius.circular(radius2))),
      child: FloatingSearchAppBar(
          hint: 'Buscar venta suspendida',
          controller: _searchController,
          transitionDuration: const Duration(milliseconds: 800),
          clearQueryOnClose: true,
          // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          // alwaysOpened: true,
          titleStyle: buttonsSmallTextStyle(context),
          hintStyle: buttonsSmallTextStyle(context),
          hideKeyboardOnDownScroll: true,
          onQueryChanged: _onQueryChanged,
          // height: _size.height * 0.078 < 55 ? 55 : _size.height * 0.078,
          elevation: 0,
          actions: [FloatingSearchBarAction.searchToClear()],
          automaticallyImplyBackButton: false,
          color: Colors.grey[200],
          body: null),
    );
  }

  _onQueryChanged(String? query) async {
    if (query == '' || query == null) {
      final res = await SuspendedSalesProvider.loadAllSSales();
      // if (res != null) {
      _suspSalesStream.sink.add(res);
      // }
    } else {
      final res = await SuspendedSalesProvider.findSuspSale(query);

      _suspSalesStream.sink.add(res);
    }
  }

  Center _emptySuspendedSales(BuildContext context) {
    return Center(
      child: Text(
        'Sin ventas suspendidas',
        style: normalTextStyle(context),
      ),
    );
  }

  Widget _suspendedSales() {
    return StreamBuilder(
      stream: _suspSalesStream.stream,
      initialData: widget.suspendedSales,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return SuspendedSalesListCard(
              suspSales: snapshot.data, context: context);
        } else {
          return _emptySuspendedSales(context);
        }
      },
    );
  }

  // Widget _buttons() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       _exitButton(),
  //       Container(
  //         width: _size.width * 0.3,
  //       )
  //     ],
  //   );
  // }

  // AppButton _exitButton() {
  //   return AppButton(
  //     color: Colors.white,
  //     padding: kButtonPadding,
  //     // disabledColor: Colors.white,
  //     width: _size.width * 0.1,
  //     onTap: () {
  //       Navigator.pop(context);
  //     },
  //     child: Row(
  //       children: [
  //         Icon(Icons.arrow_back_ios),
  //         Text(
  //           'Regresar ',
  //           style: buttonsSmallTextStyle(context),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class SuspendedSalesListCard extends StatelessWidget {
  const SuspendedSalesListCard(
      {Key? key, required this.suspSales, required this.context})
      : super(key: key);

  final List<SuspendedSales> suspSales;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Wrap(
        // alignment: WrapAlignment.center,
        // runAlignment: WrapAlignment.center,
        // crossAxisAlignment: WrapCrossAlignment.s,
        runAlignment: WrapAlignment.start,
        children: suspSales.map((e) {
          final valueT = getFormatedCurrency(e.totalValue);
          return AppButton(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(color: pColor.withOpacity(0.5), width: 1)),
            child: SizedBox(
              width: 175,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  e.keyWord != null
                      ? Text(
                          capitalizeText(e.keyWord!),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: normalTextStyle(context,
                              fontWeightDelta: 5, fontSizeFactor: 1.1),
                        )
                      : Container(),
                  hDivider(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      height: 0.6),
                  Text(
                    capitalizeText(e.customerName),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: normalTextStyle(
                      context,
                      fontWeightDelta: 5,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Articulos: ',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: normalTextStyle(context),
                      ),
                      const Spacer(),
                      Text(
                        capitalizeText(e.items.toString()),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: normalTextStyle(context),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Total: ',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: normalTextStyle(context),
                      ),
                      const Spacer(),
                      Text(
                        capitalizeText(valueT.substring(0, valueT.length)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: normalTextStyle(context),
                      ),
                    ],
                  ),
                  Text(
                    capitalizeText(e.sellerName ?? ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: normalTextStyle(context),
                    textAlign: TextAlign.center,
                  ),
                  hDivider(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      height: 0.5),
                  Text(
                    capitalizeText(parseDateStrES(e.createdDate)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: normalTextStyle(context),
                    textAlign: TextAlign.center,
                  ),
                  // Text(
                  //   capitalizeText(parseTimeStrES(e.createdDate)),
                  //   maxLines: 2,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: normalTextStyle(context),
                  //   textAlign: TextAlign.center,
                  // ),
                ],
              ).paddingSymmetric(horizontal: 8, vertical: 8),
            ),
            onTap: () async {
              SuspendedSaleDetails(
                suspSaleInfo: await SuspendedSalesProvider.suspSaleInfo(
                    e.id.toString(), e.keyWord ?? '', e.totalValue, e.items),
              ).launch(context);
            },
          ).paddingSymmetric(vertical: 6, horizontal: 6);
        }).toList());
  }
}
