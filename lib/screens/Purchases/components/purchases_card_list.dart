import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/purchase_model.dart';
import 'package:pos_wappsi/providers/purchase_provider.dart';
import 'package:pos_wappsi/screens/components/widgets.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/text_formating/date_to_text.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';
import 'package:pos_wappsi/utils/text_formating/order_status_mapping.dart';

class PurchasesCardList extends StatefulWidget {
  const PurchasesCardList({
    Key? key,
    required this.purchases,
    required this.searchParams,
    this.filters = const [],
  }) : super(key: key);
  final List<PurchaseModel> purchases;
  final List<String> filters;
  final Map searchParams;

  @override
  State<PurchasesCardList> createState() => _PurchasesCardListState();
}

class _PurchasesCardListState extends State<PurchasesCardList> {
  late ScrollController _controller;
  late Size _size;
  bool _loading = false;
  bool _allLoaded = false;
  int _page = 1;
  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(infinityScrollListener);
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Stack(
      children: [
        ListView.separated(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          controller: _controller,
          padding: EdgeInsets.zero,
          itemCount: widget.purchases.length + (_allLoaded ? 1 : 0),
          physics: const AlwaysScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const Divider(
            height: 5,
          ),
          itemBuilder: (context, index) {
            if (index < widget.purchases.length) {
              return PurchaseCard(
                purchase: widget.purchases[index],
                action: 'customer_details',
              );
            } else {
              return Container(
                width: _size.width,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Text('Sin elementos que mostrar').center(),
              );
            }
            // return Container();
          },
        ),
        if (_loading) ...[loadingIndicator(_size.width)]
      ],
    );
  }

  void infinityScrollListener() async {
    // printConsole(_controller.position.extentAfter);
    if (_controller.position.pixels >= _controller.position.maxScrollExtent &&
        !_loading) {
      setState(() {
        _loading = true;
      });

      _loading = true;
      final res = await PurchaseProvider.listLocalPurchases(
        search: widget.searchParams['search'] ?? '',
        filters: widget.filters,
        offset: true,
        limit: 30,
        offsetValue: _page * 30,
      );
      if (res != null) {
        if (res.isNotEmpty) {
          setState(() {
            // widget.products.clear();
            widget.purchases.addAll(res);
            _page += 1;
            _loading = false;
          });
        } else {
          setState(() {
            _allLoaded = true;
            _loading = false;
          });
        }
      } else {
        await confirmDialog(
          context,
          'Error al cargar datos',
          'assets/images/dizzy-robot.png',
        );
        setState(() {
          _loading = false;
        });
      }
    }
  }
}

// class to show customer information in form of a card

class PurchaseCard extends StatelessWidget {
  final PurchaseModel purchase;

  final String action;
  PurchaseCard({Key? key, required this.purchase, required this.action})
      : super(key: key);

  // late Size _size;
  final Map<String, Color> cardColors = {};
  @override
  Widget build(BuildContext context) {
    cardColors.addAll(mapStatusColor(purchase.status ?? ''));
    // _size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
        // PrintPurchase(
        //   printData: await purchase.buildPrintDataMap(),
        //   back: true,
        //   exitToNewPurchase: false,
        // ).launch(context);
      },
      child: Card(
        // color: Color.fromRGBO(245, 245, 245, 1),
        shadowColor: cardColors['background'],
        margin: const EdgeInsets.symmetric(horizontal: 4),
        elevation: 5,
        child: _description(context),
      ),
    );
  }

  Widget _description(var context) {
    final value = getFormatedCurrency(purchase.grandTotal ?? 0.0);

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6, right: 8, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _status(context).paddingSymmetric(horizontal: 8),
          labelContentH(
            'Proveedor:',
            capitalizeText(purchase.supplier ?? ''),
            context,
            withInnerPadding: false,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
          labelContentH(
            'Fecha:',
            capitalizeText(
              parseDateStrES(purchase.registrationDate ?? '') +
                  ' ' +
                  parseTimeStrES(purchase.registrationDate ?? ''),
            ),
            context,
            withInnerPadding: false,
            flexCol1: 1,
            flexCol2: 3,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
          labelContentH(
            'Referencia No:',
            purchase.referenceNo ?? '',
            context,
            withInnerPadding: false,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(radius2),
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                // labelContentH(
                //     'Items:', (purchase.).toString(), context,
                //     withInnerPadding: false,
                //     padding:
                //         const EdgeInsets.symmetric(horizontal: 8, vertical: 2)),
                labelContentH(
                  'Total:',
                  value.substring(0, value.length - 1),
                  context,
                  withInnerPadding: false,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                )
              ],
            ),
          ),

          // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

          // ]),
        ],
      ),
    );
  }

  Widget _status(var context) {
    return Row(
      children: [
        Text(
          'Estado:',
          style: normalTextStyle(context, fontWeightDelta: 2),
        ),
        const Spacer(),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 6),
          width: 110,
          decoration: BoxDecoration(
            color: cardColors['background'],
            borderRadius: BorderRadius.circular(radius2),
          ),
          child: Text(
            mapStatusText(purchase.status ?? ''),
            textAlign: TextAlign.center,
            style: normalTextStyle(
              context,
              fontWeightDelta: 2,
              color: cardColors['text'],
            ),
          ),
        ),
      ],
    );
  }
}
