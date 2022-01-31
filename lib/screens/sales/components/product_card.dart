import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nb_utils/nb_utils.dart';
// ignore: implementation_imports
// import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/screens/products/product_details.dart';
import 'package:pos_wappsi/utils/alerts.dart';
// import 'package:pos_wappsi/providers/register_form_provider.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

// class to show product indormation in form of a card

class ProductCard extends StatefulWidget {
  ProductCard(
      {Key? key,
      required this.product,
      required this.formKey,
      required this.quantityFocusNode})
      : super(key: key);
  final FocusNode quantityFocusNode;
  final GlobalObjectKey<FormState> formKey;
  final MapEntry<String, ProductModel> product;

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // final FocusNode quantityFocusNode = new FocusNode();

  // final widget.formKey = new GlobalKey<FormState>();

  final _quantityController = new TextEditingController();

  late Size _size;

  @override
  void dispose() {
    _quantityController.dispose();
    widget.quantityFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // _quantityController.text =
    //     posBloc.getProductData(widget.product.key)!.quantity.toString();
    // posBloc.getProductData(widget.product.key)!.quantityController.text = posBloc.getProductData(widget.product.key)!.quantity.toString();
    _updateQuantityValue();

    super.initState();
  }

  Widget _productTile() {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // crossAxisAlignment: CrossAxisAlignment,
      // textBaseline: TextBaseline.alphabetic,
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
        Divider(
          height: 1,
          color: Colors.black12,
          thickness: 1,
        ).paddingSymmetric(horizontal: 10),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              productPhoto(widget.product.value.image).withSize(
                  width: _size.width * 0.23,
                  height: _size.height * 0.1 > 70 ? _size.height * 0.1 : 70),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    posBloc.getProductUnits?[widget.product.key]?.name ?? '',
                    textAlign: TextAlign.end,
                    style: normalTextStyle(context),
                  ).paddingRight(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _qty().paddingOnly(left: 5, top: 5, bottom: 8),
                      _prices().paddingOnly(right: 8, bottom: 8)
                    ],
                  )
                ],
              ).expand(),
            ]),
      ],
    );
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
    return Container(
      width: 55,
      child: TextFormField(
        onEditingComplete: () {
          widget.quantityFocusNode.unfocus();
          posBloc.getSearchBarController.open();
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
              double productInt = double.tryParse(value) ?? 0.0;
              if (productInt == 0) {
                if (value == '') {
                  final res =
                      await posBloc.addProductQuantity(widget.product.key, 1);
                  if (!res) {
                    _stockAlert();

                    _updateQuantityValue();
                  } else {
                    _updateQuantityValue();
                  }
                } else {
                  confirmDialog(context, 'Cantidad de producto no valida',
                      'assets/images/alert.png');
                  // setState(() {
                  //   _updateQuantityValue();
                  // });
                }
              } else {
                final res = await posBloc.addProductQuantity(
                    widget.product.key, productInt);
                // print(res);
                if (!res) {
                  _stockAlert();

                  _updateQuantityValue();
                } else {
                  _updateQuantityValue();
                }
              }
            }
          }
        },
        validator: (value) {
          if (value!.length > 0) {
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
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 8),
      margin: EdgeInsets.zero,
      color: Colors.grey[100],
      width: 10,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      onTap: () {
        // quantityFocusNode.requestFocus();
        setState(() {
          if (posBloc.getProductData(widget.product.key)!.quantity > 1) {
            posBloc.getProductData(widget.product.key)!.quantity -= 1;
            _updateQuantityValue();
            // posBloc.addProductQuantity(widget.product.key,
            //     posBloc.getProductData(widget.product.key)!.quantity);
          }
        });
      },
      child: Icon(
        Icons.remove,
        color: Colors.black,
      ),
    );
  }

  Widget _addQty() {
    return AppButton(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 8),
      color: Colors.grey[100],
      margin: EdgeInsets.zero,
      width: 10,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      onTap: () async {
        // posBloc.getProductData(widget.product.key)!.quantity += 1;
        final res = await posBloc.addProductQuantity(widget.product.key,
            posBloc.getProductData(widget.product.key)!.quantity += 1);

        _updateQuantityValue();

        if (!res) {
          confirmDialog(
              context,
              'El producto ${widget.product.value.name} no tiene suficiente stock. Stock actual ${widget.product.value.inventory}',
              'assets/images/out-of-stock.png');
        }
      },
      child: Icon(
        Icons.add,
        color: Colors.red,
      ),
    );
  }

  Widget _delete() {
    // Delete a prodcut from sales's cart (bloc_sale)
    return AppButton(
      padding: EdgeInsets.symmetric(horizontal: 5),
      margin: EdgeInsets.zero,
      elevation: 0,
      shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: Colors.black26)),
      width: 30,
      onTap: () {
        // setState(() {
        posBloc.removeProduct(widget.product.key);
        // });
      },
      child: Icon(
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

  Widget _productPrice() {
    return Text('c/u ${widget.product.value.getFormatedPriceIVA()}',
        style: numbersTextStyle(
            fontSizeFactor: 0.9, fontWeight: FontWeight.normal));
  }

  void _stockAlert() {
    confirmDialog(
        context,
        'El producto ${widget.product.value.name} no tiene suficiente stock. Stock actual ${widget.product.value.inventory}',
        'assets/images/out-of-stock.png');
    posBloc.getProductData(widget.product.key)!.quantity =
        posBloc.getProductData(widget.product.key)!.quantity;
  }

  Widget _productPriceTotal() {
    return Text(
      (getFormatedCurrency(widget.product.value.getPriceWithIVA() *
              widget.product.value.quantity))
          .toString(),
      style:
          numbersTextStyle(fontSizeFactor: 0.9, fontWeight: FontWeight.normal),
    );
  }

  _updateQuantityValue() {
    final value = posBloc.getProductData(widget.product.key)!.quantity;

    // print(_quantityController.text);
    if (value.toString().endsWith('.0')) {
      _quantityController.text = value.toInt().toString();
    } else {
      _quantityController.text = value.toString();
      // print(_quantityController.text);
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
    setState(() {
      posBloc.getProductData(widget.product.key)!.quantity =
          posBloc.getProductData(widget.product.key)!.quantity;
    });
    _size = MediaQuery.of(context).size;
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
