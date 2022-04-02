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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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

class OrdersCard extends StatelessWidget {
  final OrderModel order;

  final String action;
  OrdersCard({Key? key, required this.order, required this.action})
      : super(key: key);

  // late Size _size;
  final Map<String, Color> cardColors = {};
  @override
  Widget build(BuildContext context) {
    cardColors.addAll(mapOrderStatusColor(order.saleStatus));
    // _size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
        PrintOrder(
          printData: await order.buildPrintDataMap(),
          back: true,
          exitToNewOrder: false,
        ).launch(context);
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
    final value = getFormatedCurrency(order.grandTotal);

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6, right: 8, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _status(context).paddingSymmetric(horizontal: 8),
          labelContentH('Cliente:', capitalizeText(order.customer), context,
              withInnerPading: false,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2)),
          labelContentH(
              'Fecha:',
              capitalizeText(parseDateStrES(order.registrationDate ?? '') +
                  ' ' +
                  parseTimeStrES(order.registrationDate ?? '')),
              context,
              withInnerPading: false,
              flexCol1: 1,
              flexCol2: 3,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2)),
          labelContentH('Referencia No:', order.referenceNo ?? '', context,
              withInnerPading: false,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2)),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                labelContentH('Items:', (order.totalItems).toString(), context,
                    withInnerPading: false,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2)),
                labelContentH(
                    'Total:', value.substring(0, value.length - 1), context,
                    withInnerPading: false,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2))
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
              borderRadius: BorderRadius.circular(10)),
          child: Text(
            mapOrderStatus(order.saleStatus),
            textAlign: TextAlign.center,
            style: normalTextStyle(context,
                fontWeightDelta: 2, color: cardColors['text']),
          ),
        ),
      ],
    );
  }
}
