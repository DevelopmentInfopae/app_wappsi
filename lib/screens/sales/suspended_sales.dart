import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
import 'package:pos_wappsi/components/back_app_bar.dart';
// import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/suspended_sale_model.dart';
import 'package:pos_wappsi/screens/sales/suspended_sale_details.dart';
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
        )
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

  Wrap _suspendedSales() {
    return Wrap(
        children: widget.suspendedSales!.map((e) {
      final valueT = getFormatedCurrency(e.totalValue);
      return AppButton(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _labeledDesc2('Palabra clave: ', e.keyWord ?? ''),
            _labeledDesc2('Cliente: ', e.customerName),
            _labeledDesc2('Numero de items: ', e.items.toString()),
            _labeledDesc2(
                'Valor total: ', valueT.substring(0, valueT.length - 3)),
            _labeledDesc2('Fecha de creación: ', e.createdDate),
            // labelContent('Cliente',e.customerName,padding: false),
            // Text('Numero de items: ${e.items}'),
          ],
        ).paddingSymmetric(horizontal: 10, vertical: 10),
        onTap: () async {
          SuspendedSaleDetails(
            suspSaleInfo: await SuspendedSales.suspSaleInfo(
                e.id.toString(), e.keyWord ?? '', e.totalValue, e.items),
          ).launch(context);
        },
      ).paddingSymmetric(vertical: 4);
    }).toList());
  }

  Widget _labeledDesc2(String label, String desc) {
    final size = MediaQuery.of(context).size;
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          label,
          style: normalTextStyle(context, fontWeightDelta: 5),
        ),
        Spacer(),
        Text(
          capitalizeText(desc),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: normalTextStyle(context),
        ).withWidth(size.width * 0.5)
      ],
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
