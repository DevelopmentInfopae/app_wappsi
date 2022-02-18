import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/orders_bloc.dart';
// ignore: implementation_imports
// import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/screens/products/product_details.dart';
import 'package:pos_wappsi/utils/alerts.dart';
// import 'package:pos_wappsi/providers/register_form_provider.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

// class to show product indormation in form of a card

class ProductCard extends StatefulWidget {
  const ProductCard(
      {Key? key,
      required this.product,
      required this.formKey,
      required this.quantityFocusNode,
      this.fromOder = false,
      this.requestFocus = false})
      : super(key: key);
  final bool fromOder;
  final bool requestFocus;
  final FocusNode quantityFocusNode;
  final GlobalObjectKey<FormState> formKey;
  final MapEntry<String, ProductModel> product;

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // final FocusNode quantityFocusNode = FocusNode();

  // final widget.formKey = GlobalKey<FormState>();

  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    widget.quantityFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _updateQuantityValue();

    super.initState();
  }

  Widget _productTile() {
    String unitInfo = '';
    UnitsModel? unit;
    ProductModel? product;
    if (widget.fromOder) {
      unit = orderBloc.getProductUnits?[widget.product.key];
      product = orderBloc.getProducts?[widget.product.key];
    } else {
      unit = posBloc.getProductUnits?[widget.product.key];
      product = posBloc.getProducts?[widget.product.key];
    }
    if (unit != null) {
      final unitQtty = product!.quantity / (unit.operationValue);
      unitInfo += unitQtty.floor().toString() + ' ';
    }
    unitInfo += unit?.name ?? '';
    return Column(
      verticalDirection: VerticalDirection.down,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _productDesc().paddingOnly(top: 5, left: 10).expand(),
            _delete().paddingOnly(right: 5)
          ],
        ),
        const Divider(
          height: 1,
          color: Colors.black12,
          thickness: 1,
        ).paddingSymmetric(horizontal: 10),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              productPhoto(widget.product.value.image == ''
                      ? 'no_image.png'
                      : widget.product.value.image)
                  .withSize(width: 92, height: 92),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: ,
                children: [_unitInfo(unit, unitInfo), _baseUnitQtty(unit)],
              ).paddingTop(4).expand(),
            ]),
      ],
    );
  }

  Row _baseUnitQtty(UnitsModel? unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _qty().paddingOnly(bottom: 4),
        (unit != null ? _baseUnitPrice(unit) : _prices())
            .paddingOnly(right: 8, bottom: 4)
            .expand()
      ],
    );
  }

  Widget _unitInfo(UnitsModel? unit, String unitInfo) {
    return unit != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                unitInfo,
                // textAlign: TextAlign.,
                style: normalTextStyle(context,
                    fontWeightDelta: 2, fontSizeFactor: 1.2),
              ).flexible(flex: 3),
              _productPriceTotal().flexible(flex: 3)
            ],
          ).paddingOnly(right: 8, top: 4)
        : Container();
  }

  Widget _productDesc() {
    return descText(widget.product.value.name, context,
        maxLines: 2, fontSizeFactor: 1, fweigth: 2);
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
      width: 40,
      height: 40,
      child: TextFormField(
        onEditingComplete: () {
          widget.quantityFocusNode.unfocus();
          widget.fromOder ? null : posBloc.getSearchBarController.open();
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

          double productInt = double.tryParse(value) ?? 0.0;
          if (productInt == 0) {
            if (value == '') {
              bool res;
              if (widget.fromOder) {
                res = await orderBloc.addProductQuantity(widget.product.key, 1);
              } else {
                res = await posBloc.addProductQuantity(widget.product.key, 1);
              }
              if (!res) {
                _stockAlert();

                _updateQuantityValue();
              } else {
                _updateQuantityValue();
              }
            } else {
              confirmDialog(context, 'Cantidad de producto no valida',
                  'assets/images/alert.png');
            }
          } else {
            bool res;
            if (widget.fromOder) {
              res = await orderBloc.addProductQuantity(
                  widget.product.key, productInt);
            } else {
              res = await posBloc.addProductQuantity(
                  widget.product.key, productInt);
            }
            // printConsole(res);
            if (!res) {
              _stockAlert();

              _updateQuantityValue();
            } else {
              _updateQuantityValue(query: value);
            }
          }
        },
        validator: (value) {
          if (value!.isNotEmpty) {
            return isNumeric(value) ? null : 'El valor ingresado no es valido';
          } else {
            // setState(() {
            //   posBloc.getProductData(widget.product.key)!.quantity = 1;
            // });
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
        if (widget.fromOder) {
          final uOperator =
              orderBloc.getProductUnits?[widget.product.key]?.operationValue ??
                  1;
          if (orderBloc.getProductData(widget.product.key)!.quantity >
              uOperator) {
            setState(() {
              orderBloc.getProductData(widget.product.key)!.quantity -=
                  uOperator;
              _updateQuantityValue();
              // orderBloc.addProductQuantity(widget.product.key,
              //     orderBloc.getProductData(widget.product.key)!.quantity);
            });
          }
        } else {
          final uOperator =
              (posBloc.getProductUnits?[widget.product.key]?.operationValue ??
                  1);
          if (posBloc.getProductData(widget.product.key)!.quantity >
              uOperator) {
            setState(() {
              posBloc.getProductData(widget.product.key)!.quantity -= uOperator;
              _updateQuantityValue();
            });
          }
        }
        // quantityFocusNode.requestFocus();
      },
      child: const Icon(
        Icons.remove,
        color: Colors.black,
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
        // posBloc.getProductData(widget.product.key)!.quantity += 1;
        bool res;
        if (widget.fromOder) {
          final pQtty = orderBloc.getProductData(widget.product.key)!.quantity;
          final uOperator =
              orderBloc.getProductUnits?[widget.product.key]?.operationValue;
          res = await orderBloc.addProductQuantity(
              widget.product.key, pQtty + (uOperator ?? 1));
        } else {
          final pQtty = posBloc.getProductData(widget.product.key)!.quantity;
          final uOperator =
              posBloc.getProductUnits?[widget.product.key]?.operationValue;
          res = await posBloc.addProductQuantity(
              widget.product.key, pQtty + (uOperator ?? 1));
        }

        _updateQuantityValue();

        if (!res) {
          confirmDialog(
              context,
              'El producto ${widget.product.value.name} no tiene suficiente stock. Stock actual ${widget.product.value.inventory}',
              'assets/images/out-of-stock.png');
        }
      },
      child: const Icon(
        Icons.add,
        color: Colors.red,
      ),
    );
  }

  Widget _delete() {
    // Delete a prodcut from sales's cart (bloc_sale)
    return AppButton(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      margin: EdgeInsets.zero,
      elevation: 0,
      shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(color: Colors.black26)),
      width: 30,
      onTap: () {
        if (widget.fromOder) {
          orderBloc.removeProduct(widget.product.key);
        } else {
          posBloc.removeProduct(widget.product.key);
        }
      },
      child: const Icon(
        Icons.delete,
        size: 30,
        color: Colors.redAccent,
      ),
    );
  }

  Widget _prices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [_productPrice(), _productPriceTotal()],
    );
  }

  Widget _baseUnitPrice(UnitsModel unit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // if selected unit is base unit
        unit.baseUnit == null
            ? Text(
                unit.code,
                style: normalTextStyle(context,
                    fontWeightDelta: 2, fontSizeFactor: 1.2),
              )
            : FutureBuilder<UnitsModel?>(
                future: UnitsProvider.getUnitInfo(unit.baseUnit!),
                builder: (BuildContext context,
                    AsyncSnapshot<UnitsModel?> snapshot) {
                  return Text(
                    snapshot.data?.code ?? '',
                    style: normalTextStyle(context,
                        fontWeightDelta: 2, fontSizeFactor: 1.2),
                  );
                },
              ),
        _productPrice()
      ],
    );
  }

  Widget _productPrice() {
    return Text(widget.product.value.getFormatedPriceIVA(),
        style: numbersTextStyle(fontWeight: FontWeight.normal));
  }

  void _stockAlert() {
    confirmDialog(
        context,
        'El producto ${widget.product.value.name} no tiene suficiente stock. Stock actual ${widget.product.value.inventory}',
        'assets/images/out-of-stock.png');
    if (widget.fromOder) {
      orderBloc.getProductData(widget.product.key)!.quantity =
          orderBloc.getProductData(widget.product.key)!.quantity;
    } else {
      posBloc.getProductData(widget.product.key)!.quantity =
          posBloc.getProductData(widget.product.key)!.quantity;
    }
  }

  Widget _productPriceTotal() {
    return Text(
      (getFormatedCurrency(
        widget.product.value.getPriceWithIVA() * widget.product.value.quantity,
      )).toString(),
      style: numbersTextStyle(fontWeight: FontWeight.bold),
    );
  }

  _updateQuantityValue({String? query}) {
    double value;
    // double? operator;
    if (widget.fromOder) {
      value = orderBloc.getProductData(widget.product.key)!.quantity;
      // operator = orderBloc.getProductUnits?[widget.product.key]!.operationValue;
    } else {
      value = posBloc.getProductData(widget.product.key)!.quantity;
      // operator = posBloc.getProductUnits?[widget.product.key]!.operationValue;
    }
    // printConsole(_quantityController.text);
    if (value.toString().endsWith('.0')) {
      if (query ==
          posBloc.getProductData(widget.product.key)!.quantity.toString()) {
        _quantityController.text = (value).toString();
      } else {
        _quantityController.text = (value).toInt().toString();
      }
      // to show product unit in terms of base unit 1
    } else {
      // to show product unit in terms of base unit 1
      _quantityController.text = (value).toInt().toString();
    }

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
    if (widget.fromOder) {
      setState(() {
        orderBloc.getProductData(widget.product.key)!.quantity =
            orderBloc.getProductData(widget.product.key)!.quantity;
      });
    } else {
      setState(() {
        posBloc.getProductData(widget.product.key)!.quantity =
            posBloc.getProductData(widget.product.key)!.quantity;
      });
    }
    return Card(
      elevation: 10,
      child: GestureDetector(
          onTap: () {
            widget.quantityFocusNode.unfocus();
            ProductDetails(
              product: widget.product.value,
            ).launch(context);
          },
          child: _productTile()),
    );
  }
}
