import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/order_model.dart';
import 'package:pos_wappsi/providers/local_orders_provider.dart';
import 'package:pos_wappsi/screens/orders/print_order.dart';

import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/text_formating/date_to_text.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';
import 'package:pos_wappsi/utils/text_formating/order_status_mapping.dart';

class OrdersCardList extends StatefulWidget {
  const OrdersCardList(
      {Key? key,
      required this.orders,
      required this.searchParams,
      this.filters = const []})
      : super(key: key);
  final List<OrderModel> orders;
  final List<String> filters;
  final Map searchParams;

  @override
  State<OrdersCardList> createState() => _OrdersCardListState();
}

class _OrdersCardListState extends State<OrdersCardList> {
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
          controller: _controller,
          padding: EdgeInsets.zero,
          itemCount: widget.orders.length + (_allLoaded ? 1 : 0),
          physics: const AlwaysScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const Divider(
            height: 5,
          ),
          itemBuilder: (context, index) {
            if (index < widget.orders.length) {
              return OrdersCard(
                order: widget.orders[index],
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
      final res = await LocalOrdersProvider.listLocalOrders(
          search: widget.searchParams['search'] ?? '',
          filters: widget.filters,
          offset: true,
          limit: 30,
          offsetValue: _page * 30);
      if (res != null) {
        if (res.isNotEmpty) {
          setState(() {
            // widget.products.clear();
            widget.orders.addAll(res);
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
            context, 'Error al cargar datos', 'assets/images/dizzy-robot.png');
        setState(() {
          _loading = false;
        });
      }
    }
  }
}

// class to show customer indormation in form of a card

class OrdersCard extends StatefulWidget {
  final OrderModel order;

  final String action;
  const OrdersCard({Key? key, required this.order, required this.action})
      : super(key: key);

  @override
  _OrdersCardState createState() => _OrdersCardState();
}

class _OrdersCardState extends State<OrdersCard> {
  // late Size _size;
  Map<String, Color> cardColors = {};
  @override
  Widget build(BuildContext context) {
    cardColors = mapOrderStatusColor(widget.order.saleStatus);
    // _size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
        PrintOrder(
          printData: await widget.order.buildPrintDataMap(),
          back: true,
          exitToNewOrder: false,
        ).launch(context);
      },
      child: Card(
        // color: Color.fromRGBO(245, 245, 245, 1),
        shadowColor: cardColors['background'],
        margin: const EdgeInsets.symmetric(horizontal: 4),
        elevation: 5,
        child: _description(),
      ),
    );
  }

  Widget _description() {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6, right: 8, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _status().paddingSymmetric(horizontal: 8),
          _customer(),
          _date(),
          _reference(),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                // Row(
                //   children: [
                //     _status().flexible(flex: 2),
                //     _items().flexible(flex: 2),
                //   ],
                // ),
                // _total(),
                // _discount(),
                _items(),
                _grandTotal()
              ],
            ),
          ),

          // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

          // ]),
        ],
      ),
    );
  }

  Widget _customer() {
    return labelContentH(
        'Cliente:', capitalizeText(widget.order.customer), context,
        withInnerPading: false,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2));
  }

  Widget _date() {
    return labelContentH(
        'Fecha:',
        capitalizeText(parseDateStrES(widget.order.registrationDate ?? '') +
            ' ' +
            parseTimeStrES(widget.order.registrationDate ?? '')),
        context,
        withInnerPading: false,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2));
  }

  Widget _reference() {
    return labelContentH(
        'Referencia No:', widget.order.referenceNo ?? '', context,
        withInnerPading: false,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2));
  }

  Widget _items() {
    return labelContentH(
        'Items:', (widget.order.totalItems).toString(), context,
        withInnerPading: false,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2));
  }

  Widget _status() {
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
              borderRadius: BorderRadius.circular(10)),
          child: Text(
            mapOrderStatus(widget.order.saleStatus),
            textAlign: TextAlign.center,
            style: normalTextStyle(context,
                fontWeightDelta: 2, color: cardColors['text']),
          ),
        ),
      ],
    );
  }

  // Widget _total() {
  //   final value = getFormatedCurrency(
  //       widget.order.total ?? widget.order.grandTotal,
  //       decimals: 1);
  //   return labelContentH(
  //       'Subtotal:', value.substring(0, value.length - 1), context,
  //       withInnerPading: false,
  //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2));
  // }

  // Widget _discount() {
  //   final value = getFormatedCurrency(widget.order.orderDiscount);
  //   return labelContentH(
  //       'Descuento:', value.substring(0, value.length - 1), context,
  //       withInnerPading: false,
  //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2));
  // }

  Widget _grandTotal() {
    final value = getFormatedCurrency(widget.order.grandTotal);
    return labelContentH(
        'Total:', value.substring(0, value.length - 1), context,
        withInnerPading: false,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2));
  }
}
