import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/components/customer_card.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/providers/companies_provider.dart';
import 'package:pos_wappsi/utils/alerts.dart';

class CustomerCardList extends StatefulWidget {
  const CustomerCardList(
      {Key? key, required this.customer, required this.searchParams})
      : super(key: key);
  final List<CompanyModel> customer;
  final Map searchParams;

  @override
  State<CustomerCardList> createState() => _CustomerCardListState();
}

class _CustomerCardListState extends State<CustomerCardList> {
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
          itemCount: widget.customer.length + (_allLoaded ? 1 : 0),
          physics: const AlwaysScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const Divider(
            height: 5,
          ),
          itemBuilder: (context, index) {
            if (index < widget.customer.length) {
              return CustomerCard(
                customer: widget.customer[index],
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
      final res = await CompaniesProvider.findCustomer(
          widget.searchParams['search'] ?? '',
          offset: true,
          limit: 30,
          offsetValue: _page * 30);
      if (res != null) {
        if (res.isNotEmpty) {
          setState(() {
            // widget.products.clear();
            widget.customer.addAll(CompanyModel.fromJsonList(res));
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
