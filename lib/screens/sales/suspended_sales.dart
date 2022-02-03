import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/widgets.dart';
// import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/suspended_sale_model.dart';
import 'package:pos_wappsi/providers/suspended_sales_provider.dart';
import 'package:pos_wappsi/screens/sales/suspended_sale_details.dart';
import 'package:pos_wappsi/utils/date_to_text.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

class SuspendedSalesScreen extends StatefulWidget {
  final List<SuspendedSales>? suspendedSales;
  SuspendedSalesScreen({Key? key, required this.suspendedSales})
      : super(key: key);

  @override
  _SuspendedSalesScreenState createState() => _SuspendedSalesScreenState();
}

class _SuspendedSalesScreenState extends State<SuspendedSalesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          appBar(context, 'Suspendidas', image: 'assets/images/sleeping.png'),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        SingleChildScrollView(
          child: widget.suspendedSales != null
              ? _suspendedSales().paddingSymmetric(horizontal: 8, vertical: 4)
              : _emptySuspendedSales(context),
        ).expand()
        // bottom(_buttons(), pColor, _size)
      ],
    );
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
    return Center(
      child: Wrap(
        // alignment: WrapAlignment.center,
        // runAlignment: WrapAlignment.center,
        // crossAxisAlignment: WrapCrossAlignment.center,
        
          children: widget.suspendedSales!.map((e) {
        final valueT = getFormatedCurrency(e.totalValue);
        return AppButton(
          elevation: 2,
          
          padding: EdgeInsets.zero,
          shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(
                        color: pColor.withOpacity(0.5),
                        width: 1)),
          child: Container(
            width: 170,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                    e.keyWord!=null?Text(
                      capitalizeText(e.keyWord!),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: normalTextStyle(context, fontWeightDelta: 5, fontSizeFactor: 1.1),
                    ):Container(),
                    hDivider(padding: EdgeInsets.symmetric(vertical: 4), height: 0.6),
                    Text(
                      capitalizeText(e.customerName),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: normalTextStyle(context,fontWeightDelta: 5, ),
                    ),
                    Row(
                      children: [
                        Text(
                      'Articulos: ' ,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: normalTextStyle(context),
                    ),
                    Spacer(),
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
                    Spacer(),
                    Text(
                     capitalizeText(valueT.substring(0, valueT.length - 3)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: normalTextStyle(context),
                    ),
                      ],
                    ),
                    Text(
                     capitalizeText(e.sellerName??''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: normalTextStyle(context),
                      textAlign: TextAlign.center,
                    ),
                    hDivider(padding: EdgeInsets.symmetric(vertical: 4), height: 0.4),
                    Text(
                      capitalizeText(parseDateStrES(e.createdDate)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: normalTextStyle(context),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      capitalizeText(parseTimeStrES(e.createdDate)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: normalTextStyle(context),
                      textAlign: TextAlign.center,
                    ),
                    

              ],
            ).paddingSymmetric(horizontal: 8, vertical: 8),
          ),
          onTap: () async {
            SuspendedSaleDetails(
              suspSaleInfo: await SuspendedSalesProvider.suspSaleInfo(
                  e.id.toString(), e.keyWord ?? '', e.totalValue, e.items),
            ).launch(context);
          },
        ).paddingSymmetric(vertical: 4, horizontal: 8);
      }).toList()),
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
  //     //padding: kButtonPadding,
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
