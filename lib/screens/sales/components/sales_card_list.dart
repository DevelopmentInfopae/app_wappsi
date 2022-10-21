import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/models/local_sales_model.dart';
import 'package:pos_wappsi/providers/local_sales_provider.dart';
import 'package:pos_wappsi/screens/sales/print_sale.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

import '../../../constant.dart';

class SalesCardList extends StatefulWidget {
  const SalesCardList({
    Key? key,
    required this.sales,
    required this.searchParams,
  }) : super(key: key);
  final List<SalesModel> sales;
  final Map searchParams;

  @override
  State<SalesCardList> createState() => _SalesCardListState();
}

class _SalesCardListState extends State<SalesCardList> {
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.zero,
          itemCount: widget.sales.length + (_allLoaded ? 1 : 0),
          physics: const ClampingScrollPhysics(),
          separatorBuilder: (context, index) => const Divider(
            height: 5,
          ),
          itemBuilder: (context, index) {
            if (index < widget.sales.length) {
              return SalesCard(
                sale: widget.sales[index],
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
      final res = await LocalSalesProvider.listLocalSales(
        search: widget.searchParams['search'] ?? '',
        offset: true,
        limit: 30,
        offsetValue: _page * 30,
      );
      if (res != null) {
        if (res.isNotEmpty) {
          setState(() {
            // widget.products.clear();
            widget.sales.addAll(res);
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

class SalesCard extends StatelessWidget {
  final SalesModel sale;

  final String action;
  const SalesCard({Key? key, required this.sale, required this.action})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // _size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
        PrintSale(
          printData: await sale.buildPrintDataMap(),
          back: true,
          exitToNewSale: false,
        ).launch(context);
      },
      child: Card(
        // color: Color.fromRGBO(245, 245, 245, 1),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        elevation: 5,
        child: _description(context),
      ),
    );
  }

  Widget _description(var context) {
    final value = getFormatedCurrency(sale.grandTotal);
    // final valuePaid = getFormatedCurrency(sale.paid);
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6, right: 8, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labelContentH(
            'Cliente:',
            capitalizeText(sale.customer),
            context,
            withInnerPadding: false,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
          labelContentH(
            'Fecha:',
            sale.registrationDate ?? '',
            context,
            withInnerPadding: false,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
          labelContentH(
            'Numero:',
            sale.referenceNo ?? '',
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
                Row(
                  children: [
                    labelContentH(
                      'Plazo de pagos:',
                      (sale.paymentTerm == 0 ? '--' : sale.paymentTerm)
                          .toString(),
                      context,
                      withInnerPadding: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                    ).flexible(flex: 2),
                    labelContentH(
                      'Items:',
                      (sale.totalItems).toString(),
                      context,
                      withInnerPadding: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                    ).flexible(flex: 2),
                  ],
                ),
                Row(
                  children: [
                    labelContentH(
                      'Total:',
                      value.substring(0, value.length),
                      context,
                      withInnerPadding: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                    ).flexible(flex: 2),
                    labelContentH(
                      'Pagado:',
                      value.substring(0, value.length),
                      context,
                      withInnerPadding: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                    ).flexible(flex: 2),
                  ],
                ),
              ],
            ),
          ),

          // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

          // ]),
        ],
      ),
    );
  }
}
