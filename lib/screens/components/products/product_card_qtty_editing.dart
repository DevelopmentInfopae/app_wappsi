import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/entities/PriceSettings.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/providers/local_settings_provider.dart';
import 'package:pos_wappsi/providers/products_provider.dart';
import 'package:pos_wappsi/providers/units_provider.dart';
// ignore: implementation_imports
// import 'package:nb_utils/src/extensions/widget_extensions.dart';

import 'package:pos_wappsi/screens/components/widgets.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/screens/products/product_details.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
// import 'package:pos_wappsi/providers/register_form_provider.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

import '../../../entities/price_groups.dart';

// class to show product information in form of a card

class ProductCard extends StatefulWidget {
  const ProductCard({
    Key? key,
    required this.formKey,
    required this.quantityFocusNode,
    required this.unit,
    required this.product,
    required this.getQtty,
    required this.editQtty,
    required this.editPrice,
    required this.addQtty,
    required this.rmQtty,
    required this.prefsSelection,
    required this.delete,
    this.requestFocus = false,
  }) : super(key: key);
  final Function getQtty;
  final Function(double) editQtty;
  final Function(double) editPrice;
  final Function addQtty;
  final Function rmQtty;
  final Function delete;
  final bool requestFocus;
  final ProductModel? product;
  final String prefsSelection;
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
  final _priceController = TextEditingController();
  final _priceFocusNode = FocusNode();

  ProductModel? product;
  String unitInfo = '';

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _priceFocusNode.dispose();
    widget.quantityFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    product = widget.product;

    _priceController.text = getFormatedCurrency(
      (product?.getPriceWithIVA() ?? 1) * (product?.quantity ?? 1),
    ).toString();

    _priceFocusNode.addListener(() {
      if (_priceFocusNode.hasFocus) {
        _priceController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _priceController.text.length,
        );
      }
    });

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        productPhoto(
          (product?.image ?? '') == '' ? 'no_image.png' : product!.image,
        ).withSize(width: 94, height: 100),
        vDivider(width: 1, heigh: 90),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          // mainAxisAlignment: ,
          children: [
            _productDesc().paddingSymmetric(horizontal: 8, vertical: 1),
            _productPrefs().paddingOnly(left: 8, right: 8, bottom: 3),
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
                : _productWithoutInfoPrice()
                    .paddingOnly(left: 10, right: 14, top: 4),
            _baseUnitQtty(widget.unit),
          ],
        ).paddingTop(4).expand(),
      ],
    );
  }

  Row _productWithoutInfoPrice() {
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
        Text(
          capitalizeText(widget.unit!.name),
          style: normalTextStyle(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ).expand(),
        _baseUnitPrice(widget.unit!),
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
            color: greyMediumLight,
          ),
          child: _productPriceTotal(),
        ).paddingOnly(right: 10).expand(),
      ],
    );
  }

  Widget _productPrefs() {
    if (widget.prefsSelection.isNotEmpty) {
      try {
        //   List<Widget> wChildren = [];
        //   for (var prefCat in widget.prefsSelection!.keys) {
        //     wChildren.add(Text(
        //       prefCat + ': ',
        //       style: smallTextStyle2(context, fontWeightDelta: 2),
        //     ));
        //     for (var pref in widget.prefsSelection![prefCat] ?? []) {
        //       wChildren.add(Text(
        //         pref != widget.prefsSelection![prefCat]?.last
        //             ? (pref + ', ')
        //             : pref,
        //         style: smallTextStyle2(context),
        //       ));
        //     }
        //   }
        return Text(
          widget.prefsSelection,
          style: smallTextStyle2(context),
        );
      } catch (e) {
        printConsole(e);
        return Container();
      }
    } else {
      return Container();
    }
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
    return descText(
      capitalizeText(product?.name ?? ''),
      context,
      maxLines: 2,
      fontSizeFactor: 0.88,
      fweigth: 2,
    );
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
      height: 38,
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
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 14.0, // Ajusta este número a tu gusto
              fontWeight:
                  FontWeight.bold, // Opcional, por si quieres que sea negrita
            ),
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
                  } // Solo mostrar el diálogo si el valor no es exactamente "0"
                  else if (value != '0') {
                    confirmDialog(
                      context,
                      'Cantidad de producto no valida',
                      'assets/images/alert.png',
                    );
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
            'assets/images/out-of-stock.png',
          );
        }
      },
      child: const Icon(
        Icons.add,
        color: Colors.green,
      ),
    );
  }

  // Widget _delete() {
  //   // Delete a product from sales's cart (bloc_sale)
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
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<UnitsModel?> snapshot,
                    ) {
                      return Text(
                        capitalizeText(snapshot.data?.code ?? ''),
                        style: normalTextStyle(context, fontWeightDelta: 2),
                      );
                    },
                  ))
            .paddingRight(4),
        _productPrice(),
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
      'El producto ${product?.name} no tiene suficiente stock. Stock actual ${getRoundedQtty(product?.inventory ?? 0)}',
      'assets/images/out-of-stock.png',
    );
  }

  // Widget _productPriceTotal() {
  //   return Text(
  //     (getFormatedCurrency(
  //       (product?.getPriceWithIVA() ?? 1) * (product?.quantity ?? 1),
  //     )).toString(),
  //     style:
  //         numbersTextStyle(fontWeight: FontWeight.bold, color: greyDarkerColor),
  //     overflow: TextOverflow.ellipsis,
  //   );
  // }

  Widget _productPriceTotal() {
    final bool canEditPrice =
        dataBloc.userDataMap['edit_right'].toString() == '1';

    if (!canEditPrice) {
      return Text(
        (getFormatedCurrency(
          (product?.getPriceWithIVA() ?? 1) * (product?.quantity ?? 1),
        )).toString(),
        style: numbersTextStyle(
            fontWeight: FontWeight.bold, color: greyDarkerColor),
        overflow: TextOverflow.ellipsis,
      );
    }

    return SizedBox(
      width: 90,
      height: 32,
      child: TextFormField(
        controller: _priceController,
        focusNode: _priceFocusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.right,
        style: numbersTextStyle(
          fontWeight: FontWeight.bold,
          color: greyDarkerColor,
        ),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          border: InputBorder.none,
          isDense: true,
        ),
        onChanged: (value) {
          final newPrice = double.tryParse(value);
          if (newPrice != null && newPrice > 0) {
            setState(() {
              product?.price = newPrice; // ajusta según tu modelo
            });
          }
        },
        onEditingComplete: () async {
          FocusScope.of(context).unfocus();
          // Recalcular y formatear al terminar de editar
          if (product?.price != null) {
            final res = await widget.editPrice(product!.price);
            if (res) {
              setState(() {
                _priceController.text = getFormatedCurrency(
                  (product?.getPriceWithIVA() ?? 1) * (product?.quantity ?? 1),
                ).toString();
              });
            }
          }
        },
      ),
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

    if (value == 1.0) {
      _quantityController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _quantityController.text.length,
      );
    } else {
      _quantityController.selection = TextSelection.fromPosition(
        TextPosition(offset: _quantityController.text.length),
      );
    }
    _priceController.text = getFormatedCurrency(
      (product?.getPriceWithIVA() ?? 1) * (product?.quantity ?? 1),
    ).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: GestureDetector(
        onTap: () async {
          widget.quantityFocusNode.unfocus();

          final localSettings = await LocalSettingsProvider.getPriceSettings();

          if (localSettings.politica == PoliticaPrecios.app) {
            // política definida en local app -> mostrar modal de selección de precio
            await _showPriceSelectorModal(context);
          } else {
            // comportamiento normal
            ProductDetails(
              product: product!,
            ).launch(context);
          }
        },
        child: _productTile(),
      ),
    );
  }

  Future<void> _showPriceSelectorModal(BuildContext context) async {
    // Listas de precio permitidas para el usuario actual
    List<String> allowedIds = [];
    if (dataBloc.userData?.priceGroups != null) {
      final String raw = dataBloc.userData!.priceGroups!;
      if (raw.isNotEmpty) {
        allowedIds = List<String>.from(json.decode(raw));
      }
    }
    final Set<int> allowedIdsInt = allowedIds.map(int.parse).toSet();

    if (allowedIdsInt.isEmpty) {
      // usuario sin listas de precio asignadas -> fallback
      ProductDetails(product: product!).launch(context);
      return;
    }

    final settings = await LocalSettingsProvider.getPriceSettings();
    final priceGroups =
        await LocalSettingsProvider.loadAllPriceGroupsForDropdown();
    final groups = priceGroups.map((e) => PriceGroupOption.fromMap(e)).toList();

    // Solo las listas que además están permitidas para el usuario
    final allowedGroups =
        groups.where((g) => allowedIdsInt.contains(g.id)).toList();

    if (allowedGroups.isEmpty) {
      ProductDetails(product: product!).launch(context);
      return;
    }

    final savedId = settings.defaultPriceList.toInt();
    final validId = allowedGroups.any((g) => g.id == savedId) ? savedId : null;

    // Trae el precio del producto para cada lista permitida
    final List<Map<String, dynamic>> prices = [];
    for (final group in allowedGroups) {
      final productPrice = await ProductsProvider.findProductPrice(
        product!.idCloud.toString(),
        group.id.toString(),
      );
      if (productPrice != null) {
        prices.add({
          'group_id': group.id,
          'price_list_name': group.name,
          'price': productPrice['price'],
        });
      }
    }
    if (prices == null || prices.isEmpty) {
      // fallback si no hay precios configurados en ninguna lista
      ProductDetails(product: product!).launch(context);
      return;
    }

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Seleccionar precio',
                  style: buttonsSmallTextStyle(context),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: prices.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = prices[index];
                    final priceValue =
                        double.tryParse(item['price'].toString()) ?? 0.0;
                    final listName = item['price_list_name']?.toString() ??
                        item['name']?.toString() ??
                        'Lista ${index + 1}';

                    return ListTile(
                      title: Text(listName),
                      trailing: Text(
                        getFormatedCurrency(priceValue),
                        style: normalTextStyle(context),
                      ),
                      onTap: () {
                        setState(() {
                          product!.price = priceValue;
                          product!.priceWithoutDiscount = priceValue;
                          product!.pricePolicyPrices = priceValue;
                          product!.discount = 0;
                          product!.priceGroupId = item['group_id'];
                          _priceController.text = getFormatedCurrency(
                            (product?.getPriceWithIVA() ?? 1) *
                                (product?.quantity ?? 1),
                          ).toString();
                          final subtotal = posBloc.getSubTotal();
                          posBloc.setVerifyPrices(0);
                          posBloc.setSubTotal(subtotal);
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
