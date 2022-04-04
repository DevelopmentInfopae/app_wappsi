import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
// import 'package:nb_utils/src/extensions/widget_extensions.dart';

import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/screens/products/product_details.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
// import 'package:pos_wappsi/providers/register_form_provider.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

// class to show product indormation in form of a card

class ProductCard extends StatefulWidget {
  const ProductCard(
      {Key? key,
      required this.formKey,
      required this.quantityFocusNode,
      required this.unit,
      required this.product,
      required this.getQtty,
      required this.editQtty,
      required this.addQtty,
      required this.rmQtty,
      required this.delete,
      this.requestFocus = false})
      : super(key: key);
  final Function getQtty;
  final Function(double) editQtty;
  final Function addQtty;
  final Function rmQtty;
  final Function delete;
  final bool requestFocus;
  final ProductModel? product;
  final UnitsModel? unit;
  final FocusNode quantityFocusNode;
  final GlobalObjectKey<FormState> formKey;

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // final FocusNode quantityFocusNode = FocusNode();

  // final widget.formKey = GlobalKey<FormState>();

  final _quantityController = TextEditingController();

  ProductModel? product;
  String unitInfo = '';

  @override
  void dispose() {
    _quantityController.dispose();
    widget.quantityFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    product = widget.product;

    if (widget.unit != null) {
      final unitQtty = product!.quantity / (widget.unit!.operationValue);
      if (unitInfo == '') {
        unitInfo += getRoundedQtty(unitQtty) + ' ';
      }
    }
    if (widget.requestFocus) {
      widget.quantityFocusNode.requestFocus();
    } else {
      widget.quantityFocusNode.unfocus();
    }

    _updateQuantityValue(value: product?.quantity);

    super.initState();
  }

  Widget _productTile() {
    if (widget.unit != null) {
      final unitQtty = product!.quantity / (widget.unit?.operationValue ?? 1);
      unitInfo = getRoundedQtty(unitQtty) + ' ';
    }

    unitInfo += widget.unit?.name ?? '';
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      productPhoto(
              (product?.image ?? '') == '' ? 'no_image.png' : product!.image)
          .withSize(width: 94, height: 100),
      vDivider(width: 1, heigh: 90),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        // mainAxisAlignment: ,
        children: [
          _productDesc().paddingSymmetric(horizontal: 8, vertical: 2),
          Divider(
            height: 1,
            color: greyMediumLight,
            thickness: 1,
          ).paddingSymmetric(horizontal: 10),
          // _unitInfo(widget.unit, unitInfo).paddingOnly(
          //   left: 10,
          // ),
          widget.unit != null
              ? _unitDetails().paddingOnly(left: 10, right: 14, top: 4)
              : _productWoutInfoPrice()
                  .paddingOnly(left: 10, right: 14, top: 4),
          _baseUnitQtty(widget.unit)
        ],
      ).paddingTop(4).expand(),
    ]);
  }

  Row _productWoutInfoPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Precio Unitario ',
          maxLines: 1,
          style: normalTextStyle(context),
        ),
        _productPrice(),
      ],
    );
  }

  Row _unitDetails() {
    return Row(
      children: [
        Text(capitalizeText(widget.unit!.name),
                style: normalTextStyle(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)
            .expand(),
        _baseUnitPrice(widget.unit!)
      ],
    );
  }

  Row _baseUnitQtty(UnitsModel? unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _qty().paddingOnly(bottom: 4, right: 4),
        Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: greyMediumLight),
                child: _productPriceTotal())
            .paddingOnly(right: 10)
            .expand()
      ],
    );
  }

  // Widget _unitInfo(UnitsModel? unit, String unitInfo) {
  //   return unit != null
  //       ? Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             // Text(
  //             //   capitalizeText(unitInfo),
  //             //   // textAlign: TextAlign.,
  //             //   maxLines: 1,
  //             //   style: normalTextStyle(context,
  //             //       fontWeightDelta: 2, fontSizeFactor: 1.1),
  //             // ).flexible(flex: 3),
  //             // (widget.unit != null ? _baseUnitPrice(unit) : _prices())
  //             //     .paddingOnly(right: 8, bottom: 4)
  //             //     .expand()
  //           ],
  //         ).paddingOnly(right: 8, top: 4)
  //       : Container();
  // }

  Widget _productDesc() {
    return descText(capitalizeText(product?.name ?? ''), context,
        maxLines: 2, fontSizeFactor: 0.9, fweigth: 2);
  }

  Widget _qty() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: [_rmQty(), _textQty(), _addQty()],
    );
  }

  Widget _textQty() {
    return SizedBox(
      width: 55,
      height: 35,
      child: TextFormField(
        onEditingComplete: () {
          widget.quantityFocusNode.unfocus();
        },
        maxLines: 1,
        // maxLength: 5,
        scrollPadding: EdgeInsets.zero,
        key: widget.formKey,
        focusNode: widget.quantityFocusNode,
        controller: _quantityController,
        // autofocus: true,
        // focusNode: quantityFocusNode,
        // textFieldType: TextFieldType.PHONE,5
        keyboardType: TextInputType.number,
        style: Theme.of(context).textTheme.headline6,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          // fillColor: Colors.red,
          contentPadding: EdgeInsets.zero,
          hintText: '1',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),

        textAlign: TextAlign.center,
        onChanged: (String value) async {
          // quantityFocusNode.requestFocus();
          if (!value.endsWith('.')) {
            if (!value.endsWith('.0')) {
              double productQtty = double.tryParse(value) ?? 0.0;
              if (productQtty != product!.quantity) {
                if (productQtty == 0.0) {
                  if (value == '') {
                    bool res = await widget.editQtty(1);
                    if (!res) {
                      _stockAlert();

                      setState(() {
                        _updateQuantityValue();
                      });
                    } else {
                      setState(() {
                        _updateQuantityValue();
                      });
                    }
                  } else {
                    confirmDialog(context, 'Cantidad de producto no valida',
                        'assets/images/alert.png');
                  }
                } else {
                  bool res = await widget.editQtty(productQtty);
                  // printConsole(res);
                  if (!res) {
                    _stockAlert();

                    setState(() {
                      _updateQuantityValue();
                    });
                  } else {
                    setState(() {
                      _updateQuantityValue(query: value);
                    });
                  }
                }
              }
            }
          }
        },
      ),
    );
  }

  Widget _rmQty() {
    return AppButton(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      margin: EdgeInsets.zero,
      color: Colors.grey[100],
      width: 10,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      onTap: () {
        widget.rmQtty();
        setState(() {
          _updateQuantityValue();
        });
        // quantityFocusNode.requestFocus();
      },
      child: Icon(
        Icons.remove,
        color: greyColor,
      ),
    );
  }

  Widget _addQty() {
    return AppButton(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      color: Colors.grey[100],
      margin: EdgeInsets.zero,
      width: 10,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      onTap: () async {
        // posBloc.getProductData(widget.productKey)!.quantity += 1;
        bool res = await widget.addQtty();

        setState(() {
          _updateQuantityValue();
        });

        if (!res) {
          confirmDialog(
              context,
              "El producto ${product?.name ?? ''} no tiene suficiente stock. Stock actual ${product?.inventory ?? ''}",
              'assets/images/out-of-stock.png');
        }
      },
      child: const Icon(
        Icons.add,
        color: Colors.green,
      ),
    );
  }

  // Widget _delete() {
  //   // Delete a prodcut from sales's cart (bloc_sale)
  //   return AppButton(
  //     padding: const EdgeInsets.symmetric(horizontal: 5),
  //     margin: EdgeInsets.zero,
  //     elevation: 0,
  //     shapeBorder: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(5),
  //         side: const BorderSide(color: Colors.black26)),
  //     width: 30,
  //     onTap: () {
  //       widget.delete();
  //     },
  //     child: const Icon(
  //       Icons.delete,
  //       size: 30,
  //       color: Colors.redAccent,
  //     ),
  //   );
  // }

  Widget _baseUnitPrice(UnitsModel unit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // if selected unit is base unit
        (unit.baseUnit == null
                ? Text(
                    capitalizeText(unit.code),
                    style: normalTextStyle(context, fontWeightDelta: 2),
                  )
                : FutureBuilder<UnitsModel?>(
                    future: UnitsProvider.getUnitInfo(unit.baseUnit!),
                    builder: (BuildContext context,
                        AsyncSnapshot<UnitsModel?> snapshot) {
                      return Text(
                        capitalizeText(snapshot.data?.code ?? ''),
                        style: normalTextStyle(context, fontWeightDelta: 2),
                      );
                    },
                  ))
            .paddingRight(4),
        _productPrice()
      ],
    );
  }

  Widget _productPrice() {
    return Text(
      product?.getFormatedPriceIVA(decimals: 1) ?? '',
      style: normalTextStyle(context),
      overflow: TextOverflow.ellipsis,
    );
  }

  void _stockAlert() {
    confirmDialog(
        context,
        'El producto ${product?.name} no tiene suficiente stock. Stock actual ${product?.inventory}',
        'assets/images/out-of-stock.png');
  }

  Widget _productPriceTotal() {
    return Text(
      (getFormatedCurrency(
        (product?.getPriceWithIVA() ?? 1) * (product?.quantity ?? 1),
      )).toString(),
      style:
          numbersTextStyle(fontWeight: FontWeight.bold, color: greyDarkerColor),
      overflow: TextOverflow.ellipsis,
    );
  }

  _updateQuantityValue({double? value, String? query}) {
    value ??= widget.getQtty();
    value ??= 1;
    if (query != null) {
      if (query.endsWith('.')) {
        _quantityController.text = query;
      } else {
        _quantityController.text = getRoundedQtty(value);
      }
    } else {
      if (value == value.toInt().toDouble()) {
        _quantityController.text = getRoundedQtty(value);
      } else {
        _quantityController.text = getRoundedQtty(value);
      }
    }

    printConsole(_quantityController.text);

    if (value == 1.0) {
      _quantityController.selection = TextSelection(
          baseOffset: 0, extentOffset: _quantityController.text.length);
    } else {
      _quantityController.selection = TextSelection.fromPosition(
          TextPosition(offset: _quantityController.text.length));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: GestureDetector(
          onTap: () {
            widget.quantityFocusNode.unfocus();
            ProductDetails(
              product: product!,
            ).launch(context);
          },
          child: _productTile()),
    );
  }
}
