// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

// import 'package:intl/intl.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';

import 'package:pos_wappsi/models/biller_data_model.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/units_model.dart';

import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/products_provider.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

ProductModel productModelFromJson(Map<String, dynamic> str) =>
    ProductModel.fromJson(str);

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
  ProductModel({
    required this.name,
    required this.id,
    required this.idCloud,
    required this.slug,
    required this.code,
    required this.image,
    required this.price,
    required this.cost,
    this.priceWithoutDiscount,
    this.pricePolicyPrices,
    required this.promoStart,
    required this.promoEnd,
    this.promoPrice = 0.0,
    this.quantity = 1,
    required this.inventory,
    required this.taxMethod,
    required this.brand,
    required this.taxRateId,
    required this.taxRate,
    required this.categoryId,
    required this.subCategoryId,
    required this.unit,
    required this.type,
    required this.taxRateName,
    this.discount = 0.0,
  });
  String type;
  String slug;
  int id;
  int idCloud;
  String image;
  double price;
  double? pricePolicyPrices;
  double? priceWithoutDiscount;
  String name;
  String categoryId;
  String subCategoryId;
  dynamic code;
  String promoStart;
  String promoEnd;
  int taxMethod;
  double? promoPrice;
  double quantity;
  double cost;
  int brand;
  int taxRateId;
  String taxRateName;
  int unit;
  double discount;
  double inventory;

  // other data
  // ignore: avoid_init_to_null
  double? taxRate;

  // ignore: unused_element
  static List get _productColumns => [
        'name',
        'slug',
        'id',
        'id_cloud',
        'image',
        'price',
        'code',
        'start_date',
        'type',
        'end_date',
        'tax_method',
        'promo_price',
        'brand',
        'tax_rate',
        'tax_method',
        'product_details',
        'unit',
        'category_id',
        'subcategory_id',
      ];

  factory ProductModel.fromJson(
    Map<dynamic, dynamic> json, {
    bool loadInitialQtty = false,
    String? qtyKey,
  }) =>
      ProductModel(
        idCloud: int.parse(json['id_cloud'].toString()),
        id: int.parse(json['id'].toString()),
        slug: json['slug'] ?? json['name'],
        image: json['image'] ?? '',
        name: (json['name'] ?? json['slug'] ?? '').toString(),
        code: json['code'],
        price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
        pricePolicyPrices:
            double.tryParse(json['price_policy']?.toString() ?? '0.0') ?? 0.0,
        priceWithoutDiscount: double.tryParse(
              json['price_without_discount']?.toString() ?? '0',
            ) ??
            0.0,
        discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
        cost: double.tryParse(json['cost']?.toString() ?? '0') ?? 0.0,
        promoStart: json['start_date'] ?? '',
        promoEnd: json['end_date'] ?? '',
        taxMethod: int.tryParse(json['tax_method']?.toString() ?? '0') ?? 0,
        promoPrice: _promoPrice(json),
        inventory: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
        brand: json['brand'],
        unit: int.tryParse(json['unit']?.toString() ?? '0') ?? 0,
        taxRateId: json['tax_rate'],
        taxRate: double.tryParse(json['rate']?.toString() ?? '0') ?? 0.0,
        type: json['type'] ?? '',
        categoryId: (json['category_id'] ?? 0).toString(),
        subCategoryId: (json['subcategory_id'] ?? 0).toString(),
        taxRateName: json['tax_rate_name'],
        quantity: loadInitialQtty ? (json[qtyKey]) + 0.0 : 1.0,
      );

  /// Load ProductModel instances of a given list of product data
  static List<ProductModel> fromJsonList(
    List<Map> list, {
    bool loadInitialQtty = false,
    String qttyKey = 'initial_qtty',
    bool initialPrice = false,
    String initialPriceKey = '',
  }) {
    List<ProductModel> products = [];
    // to check product promo

    Map temp = {};

    for (var item in list) {
      for (var i = 0; i < item.keys.length; i++) {
        // printConsole(item.values.toList()[i]);
        // printConsole(item.keys.toList()[i]);
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      try {
        temp['promo_price'] = _promoPrice(temp);
      } catch (e) {
        printConsole(e);

        temp['promo_price'] = null;
      }
      if (initialPrice) {
        try {
          temp['price'] = temp[initialPriceKey];
        } catch (e) {
          printConsole(e);
        }
      }

      products.add(
        ProductModel.fromJson(
          temp,
          loadInitialQtty: loadInitialQtty,
          qtyKey: qttyKey,
        ),
      );
    }

    return products;

    // printConsole(temp);
  }

  static double? _promoPrice(Map<dynamic, dynamic> temp) {
    if (temp['start_date'] == '' || temp['end_date'] == '') {
      return null;
    } else {
      final start = DateTime.tryParse(temp['start_date'] ?? '');
      final end = DateTime.tryParse(temp['end_date'] ?? '');
      double? promoPrice;
      var now = DateTime.now();
      // printConsole(temp['name'] + start.toString() +end.toString());
      if (start != null && end != null) {
        if (!(now.isAfter(start) && now.isBefore(end)) ||
            !(start.difference(now).inDays <= 0 ||
                end.difference(now).inDays >= 0)) {
          promoPrice = null;
        } else {
          try {
            promoPrice = double.parse(temp['promo_price'].toString());
          } catch (e) {
            printConsole(e);
            // await logError(e, from: 'ProductModel,_promoPrice');

            promoPrice = null;
          }
        }
      }
      return promoPrice;
    }
  }

  double getPriceWithoutIVA() {
    double pwoutIVA = price;

    if (taxMethod == 0) {
      pwoutIVA = price / ((100 + taxRate!) / 100);
    } else {
      pwoutIVA = price;
    }

    return pwoutIVA;
  }

  double getCOstWithoutIVA() {
    double pwoutIVA = cost;

    if (taxMethod == 0) {
      pwoutIVA = cost / ((100 + taxRate!) / 100);
    } else {
      pwoutIVA = cost;
    }

    return pwoutIVA;
  }

  String getFormatedPriceIVA({int? decimals}) {
    return getFormatedCurrency(getPriceWithIVA(), decimals: decimals);
  }

  String getFormatedCost({int? decimals}) {
    return getFormatedCurrency(cost, decimals: decimals);
  }

  String getFormatedPriceNoIva() {
    return getFormatedCurrency(getPriceWithoutIVA());
  }

  double getPriceWithIVA() {
    double pWithIVA = price;

    if (taxMethod == 0) {
      pWithIVA = price;
    } else {
      pWithIVA = price * (100 + taxRate!) / 100;
    }

    return pWithIVA;
  }

  double getCostWithIVA() {
    double pWithIVA = price;

    if (taxMethod == 0) {
      pWithIVA = cost;
    } else {
      pWithIVA = cost * (100 + taxRate!) / 100;
    }

    return pWithIVA;
  }

  double getIVA() {
    return getPriceWithIVA() - getPriceWithoutIVA();
  }

  Map<String, dynamic> toJson() => {
        'slug': slug,
        'id': id,
        'id_cloud': idCloud,
        'image': image,
        'price': getPriceWithIVA(),
        'name': name,
        'code': code,
        'start_date': promoStart,
        'end_date': promoEnd,
        'price_without_discount': priceWithoutDiscount,
        'tax_method': taxMethod,
        'promo_price': promoPrice,
        'quantity': quantity,
        'brand': brand,
        'inventory': inventory,
        'tax_rate': taxRateId,
        'rate': taxRate,
        'tax_rate_name': taxRateName
      };

  /// Customer's price for a product
  Future<double> customerPrice(
    CompanyModel customer,
    Future<double> function,
  ) async {
    final productPrice = await ProductsProvider.findProductPrice(
      idCloud.toString(),
      customer.priceGroupId!,
    );
    return double.tryParse(productPrice!['price'].toString()) ?? await function;
  }

  @override
  String toString() => name;

  Future<double> billerPrice(Future<double> functionAfter) async {
    if (dataBloc.getBIllerData == null) {
      final billerData = await DBProvider.db.getBillerData();
      if (billerData == null) {
        return await functionAfter;
      } else {
        dataBloc.setBillerData(BillerDataModel.fromJson(billerData));
        return await billerPrice(getPrice());
      }
    } else {
      if (dataBloc.getBIllerData!.defaultPriceGroup != null) {
        final productPrice = await ProductsProvider.findProductPrice(
          idCloud.toString(),
          dataBloc.getBIllerData!.defaultPriceGroup!,
        );
        if (productPrice != null) {
          return double.tryParse(productPrice['price'].toString()) ??
              priceWithoutDiscount!;
        } else {
          return priceWithoutDiscount!;
        }
      } else {
        return priceWithoutDiscount!;
      }
    }
  }

  ///Returns a Map<String,dynamic>, where the keys are the same of
  ///SaleModel.fromJson(), it could be useful to build an instance of
  ///SaleModel to send to an endpoint of API's service. It also returns
  ///key product_detail_list which contains a list of product details
  static Map<String, dynamic> getProductDetailMapLists(
    Map<String, ProductModel>? products,
    int warehouseId,
    Map<String, UnitsModel>? units,
    Function(String) getProdPrefText,
  ) {
    List<double> _quantities = [];
    List<int> _units = [];
    List<int?> _unitsSelected = [];
    List<int> _ids = [];
    List<String> _types = [];
    List<String> _codes = [];
    List<String> _names = [];
    List<int> _discounts = [];
    List<double> _discountValues = [];
    List<int> _taxRates = [];
    List<double> _taxValues = [];
    List<double> _prices = [];
    List<double?> _pricePPolicy = [];
    List<double> _pricesIVA = [];
    List<double> _realPrices = [];
    List<int> _taxRateIds = [];
    List<String> _productPrefsText = [];

    // to order

    double totalDiscount = 0.0;
    double totalTax = 0.0;

    /// To save product details to save into local db
    List<Map<String, dynamic>> productsDetails = [];

    if (products != null && products != {}) {
      for (var key in products.keys) {
        final pIVA = products[key]!.getPriceWithIVA();
        final pNoIVA = products[key]!.getPriceWithoutIVA();
        final taxValue = pIVA - pNoIVA;
        final discountVal =
            (products[key]!.priceWithoutDiscount! - products[key]!.price);
        _ids.add(products[key]!.idCloud);
        _codes.add(products[key]!.code);
        _quantities.add(products[key]!.quantity);
        _units.add(products[key]!.unit);
        _unitsSelected.add(units?[key]?.idCloud);
        _types.add(products[key]!.type);
        _names.add(products[key]!.name);
        totalDiscount += products[key]!.discount;
        _discounts.add(products[key]!.discount.toInt());
        _discountValues.add(discountVal < 0 ? 0 : discountVal);
        totalTax += products[key]!.taxRate ?? 0;
        _taxRates.add(products[key]!.taxRate!.toInt());
        _taxValues.add(taxValue);
        _prices.add(pNoIVA);
        _pricePPolicy.add(products[key]!.pricePolicyPrices);
        _pricesIVA.add(pIVA);
        _realPrices.add(products[key]!.priceWithoutDiscount!);
        _taxRateIds.add(products[key]!.taxRateId);
        _productPrefsText.add(getProdPrefText(key) ?? '');

        double discountPercent = 1 -
            (products[key]!.price /
                (products[key]!.priceWithoutDiscount ?? products[key]!.price));
        discountPercent = discountPercent * 100;

        productsDetails.add({
          'product_id': products[key]!.idCloud,
          'product_type': products[key]!.type,
          'product_code': products[key]!.code,
          'product_name': products[key]!.name,
          'quantity': products[key]!.quantity,
          'warehouse_id': warehouseId,
          'tax_rate_id': products[key]!.taxRateId,
          'unit_': products[key]!.taxRateId,
          'product_unit_id': products[key]!.unit,
          'product_unit_id_selected': units?[key]?.idCloud,
          'tax': products[key]!.taxRateName,
          'unit_price': pIVA,
          'net_unit_price': pNoIVA,
          'discount': discountPercent.toString() + '%',
          'item_tax': taxValue,
          'subtotal':
              products[key]!.getPriceWithIVA() * products[key]!.quantity,
          'price_before_tax': products[key]!.getPriceWithoutIVA(),
          'unit_quantity': products[key]!.quantity,
          'product_preferences_text': getProdPrefText(key)
        });
      }
    }
    return {
      'product_id': _ids,
      'product_total_discount': totalDiscount,
      'product_total_tax': totalTax,
      'product_type': _types,
      'product_code': _codes,
      'product_name': _names,
      'product_discount': _discounts,
      'product_discount_val': _discountValues,
      'product_tax': _taxRateIds,
      'product_tax_rate': _taxRates,
      'unit_product_tax': _taxValues,
      'product_tax_val': _taxValues,
      'net_price': _prices,
      'unit_price': _pricesIVA,
      'real_unit_price': _pricePPolicy,
      'quantity': _quantities,
      'product_unit': _units,
      'product_unit_id_selected': _unitsSelected,
      'product_base_quantity': _quantities,
      'product_detail_list': productsDetails,
      'product_preferences_text': _productPrefsText
    };
  }

  ///Returns a Map<String,dynamic>, where the keys are the same of
  ///SaleModel.fromJson(), it could be usefull to build an instance of
  ///SaleModel to send to an endpoint of API's service. It also returns
  ///key product_detail_list wich contains a list of product details
  static Map<String, dynamic> getProductDetailsWithCost(
    Map<String, ProductModel>? products,
    int warehouseId,
    Map<String, UnitsModel>? units,
  ) {
    List<double> _quantitys = [];
    List<int> _units = [];
    List<int?> _unitsSelected = [];
    List<int> _ids = [];
    List<String> _types = [];
    List<String> _codes = [];
    List<String> _names = [];
    List<int> _discounts = [];
    List<double> _discountValues = [];
    List<int> _taxRates = [];
    List<double> _taxValues = [];
    List<double> _prices = [];
    List<double?> _pricePPolicy = [];
    List<double> _pricesIVA = [];
    List<double> _realPrices = [];
    List<int> _taxRateIds = [];

    // to order

    double totalDiscount = 0.0;
    double totalTax = 0.0;

    /// To save product details to save into local db
    List<Map<String, dynamic>> productsDetails = [];

    if (products != null && products != {}) {
      for (var key in products.keys) {
        final pIVA = products[key]!.getCostWithIVA();
        final pNoIVA = products[key]!.getCOstWithoutIVA();
        final taxValue = pIVA - pNoIVA;
        final discountVal =
            (products[key]!.priceWithoutDiscount! - products[key]!.price);
        _ids.add(products[key]!.idCloud);
        _codes.add(products[key]!.code);
        _quantitys.add(products[key]!.quantity);
        _units.add(products[key]!.unit);
        _unitsSelected.add(units?[key]?.idCloud);
        _types.add(products[key]!.type);
        _names.add(products[key]!.name);
        totalDiscount += products[key]!.discount;
        _discounts.add(products[key]!.discount.toInt());
        _discountValues.add(discountVal < 0 ? 0 : discountVal);
        totalTax += products[key]!.taxRate ?? 0;
        _taxRates.add(products[key]!.taxRate!.toInt());
        _taxValues.add(taxValue);
        _prices.add(pNoIVA);
        _pricePPolicy.add(products[key]!.pricePolicyPrices);
        _pricesIVA.add(pIVA);
        _realPrices.add(products[key]!.priceWithoutDiscount!);
        _taxRateIds.add(products[key]!.taxRateId);

        double discountPercent = 1 -
            (products[key]!.price /
                (products[key]!.priceWithoutDiscount ?? products[key]!.price));
        discountPercent = discountPercent * 100;

        productsDetails.add({
          'product_id': products[key]!.idCloud,
          'product_type': products[key]!.type,
          'product_code': products[key]!.code,
          'product_name': products[key]!.name,
          'quantity': products[key]!.quantity,
          'warehouse_id': warehouseId,
          'tax_rate_id': products[key]!.taxRateId,
          'unit_': products[key]!.taxRateId,
          'product_unit_id': products[key]!.unit,
          'product_unit_id_selected': units?[key]?.idCloud,
          'tax': products[key]!.taxRateName,
          'unit_price': pIVA,
          'net_unit_price': pNoIVA,
          'discount': discountPercent.toString() + '%',
          'item_tax': taxValue,
          'subtotal':
              products[key]!.getPriceWithIVA() * products[key]!.quantity,
          'price_before_tax': products[key]!.getCOstWithoutIVA(),
          'unit_quantity': products[key]!.quantity
        });
      }
    }
    return {
      'product_id': _ids,
      'product_total_discount': totalDiscount,
      'product_total_tax': totalTax,
      'product_type': _types,
      'product_code': _codes,
      'product_name': _names,
      'product_discount': _discounts,
      'product_discount_val': _discountValues,
      'product_tax': _taxRateIds,
      'product_tax_rate': _taxRates,
      'unit_product_tax': _taxValues,
      'product_tax_val': _taxValues,
      'net_price': _prices,
      'unit_price': _pricesIVA,
      'real_unit_price': _pricePPolicy,
      'quantity': _quantitys,
      'product_unit': _units,
      'product_unit_id_selected': _unitsSelected,
      'product_base_quantity': _quantitys,
      'product_detail_list': productsDetails
    };
  }

  Future<double> getPrice() async {
    return priceWithoutDiscount!;
  }
}
