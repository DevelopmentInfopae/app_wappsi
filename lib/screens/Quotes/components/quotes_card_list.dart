import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
// import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/quotes_model.dart';
import 'package:pos_wappsi/providers/quotes_provider.dart';
import 'package:pos_wappsi/screens/Quotes/print_quotes.dart';
import 'package:pos_wappsi/screens/components/widgets.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/text_formating/date_to_text.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

import '../../../constant.dart';

class QuotesCardList extends StatefulWidget {
  const QuotesCardList({
    Key? key,
    required this.quotes,
    required this.searchParams,
    this.filters = const [],
  }) : super(key: key);
  final List<QuoteModel> quotes;
  final List<String> filters;
  final Map searchParams;

  @override
  State<QuotesCardList> createState() => _QuotesCardListState();
}

class _QuotesCardListState extends State<QuotesCardList> {
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
          itemCount: widget.quotes.length + (_allLoaded ? 1 : 0),
          physics: const AlwaysScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const Divider(
            height: 5,
          ),
          itemBuilder: (context, index) {
            if (index < widget.quotes.length) {
              return QuotesCard(
                quote: widget.quotes[index],
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
      final res = await QuotesProvider.listLocalQuotes(
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
            widget.quotes.addAll(res);
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

// ignore: must_be_immutable
class QuotesCard extends StatelessWidget {
  final QuoteModel quote;

  final String action;
  QuotesCard({Key? key, required this.quote, required this.action})
      : super(key: key);

  // late Size _size;
  Map<String, Color> cardColors = {};
  @override
  Widget build(BuildContext context) {
    // _size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
        PrintQuote(
          printData: await quote.buildPrintDataMap(),
          back: true,
          exitToNewQuote: false,
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

  Widget _description(BuildContext context) {
    final value = getFormatedCurrency(quote.grandTotal);

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6, right: 8, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _status().paddingSymmetric(horizontal: 8),
          labelContentH(
            'Cliente:',
            capitalizeText(quote.customer.toString()),
            context,
            withInnerPadding: false,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),

          labelContentH(
            'Fecha:',
            capitalizeText(
              parseDateStrES(quote.date ?? '') +
                  ' ' +
                  parseTimeStrES(quote.date ?? ''),
            ),
            context,
            withInnerPadding: false,
            flexCol1: 1,
            flexCol2: 3,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
          labelContentH(
            'Referencia No:',
            quote.referenceNo ?? '',
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
        ],
      ),
    );
  }
}
