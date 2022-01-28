// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/models/biller_data_model.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/providers/API_provider.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/products_provider.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/local_storage/local_db.dart';
import 'package:pos_wappsi/utils/manage_server_resp.dart';
import 'package:pos_wappsi/utils/sale_functions/product_price_functions.dart';

ProductModel productModelFromJson(Map<String, dynamic> str) =>
    ProductModel.fromJson(str);

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
  final formatCurrency = new NumberFormat.simpleCurrency();
  ProductModel(
      {required this.name,
      required this.id,
      required this.idCloud,
      required this.slug,
      required this.code,
      required this.image,
      required this.price,
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
      this.discount = 0.0});
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
  int brand;
  int taxRateId;
  String taxRateName;
  int unit;
  double discount;
  int inventory;

  // other data
  // ignore: avoid_init_to_null
  double? taxRate;

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

  factory ProductModel.fromJson(Map<dynamic, dynamic> json,
          {bool loadInitialQtty = false, String? qtyKey}) =>
      ProductModel(
          idCloud: json["id_cloud"],
          id: json["id"],
          slug: json["slug"] ?? json["name"],
          image: json["image"] ?? '',
          name: json["name"] ?? json["slug"],
          code: json["code"],
          price: double.tryParse(json["price"].toString()) ?? 0.0,
          pricePolicyPrices:
              double.tryParse(json["price_policy"].toString()) ?? 0.0,
          priceWithoutDiscount:
              double.tryParse(json["price_without_discount"].toString()) ?? 0.0,
          discount: double.tryParse(json["discount"].toString()) ?? 0.0,
          promoStart: json["start_date"] ?? '',
          promoEnd: json["end_date"] ?? '',
          taxMethod: json["tax_method"],
          promoPrice: _promoPrice(json),
          inventory: int.tryParse(json["quantity"].toString()) ?? 0,
          brand: json["brand"],
          unit: int.tryParse(json['unit'].toString()) ?? 0,
          taxRateId: json["tax_rate"],
          taxRate: double.tryParse(json['rate'].toString()) ?? 0.0,
          type: json['type'],
          categoryId: json['category_id'].toString(),
          subCategoryId: json['subcategory_id'].toString(),
          taxRateName: json['tax_rate_name'],
          quantity: loadInitialQtty ? (json[qtyKey]) : 1);

  /// Load ProductModel instances of a given list of product data
  static List<ProductModel> fromJsonList(List<Map> list,
      {bool loadInitialQtty = false,
      String qttyKey = 'initial_qtty',
      bool initalPrice = false,
      String inititalPriceKey = ''}) {
    List<ProductModel> products = [];
    // to check product promo

    Map temp = {};

    list.forEach((item) {
      for (var i = 0; i < item.keys.length; i++) {
        // print(item.values.toList()[i]);
        // print(item.keys.toList()[i]);
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      try {
        temp['promo_price'] = _promoPrice(temp);
      } catch (e) {
        print(e);

        temp['promo_price'] = null;
      }
      if (initalPrice) {
        try {
          temp['price'] = temp[inititalPriceKey];
        } catch (e) {
          print(e);
        }
      }

      products.add(ProductModel.fromJson(temp,
          loadInitialQtty: loadInitialQtty, qtyKey: qttyKey));
    });

    return products;

    // print(temp);
  }

  static double? _promoPrice(Map<dynamic, dynamic> temp) {
    if (temp['start_date'] == '' || temp['end_date'] == '') {
      return null;
    } else {
      final start = DateTime.parse(temp['start_date']);
      final end = DateTime.parse(temp['end_date']);
      double? promoPrice;
      var now = new DateTime.now();
      // print(temp['name'] + start.toString() +end.toString());
      if (!(now.isAfter(start) && now.isBefore(end)) ||
          !(start.difference(now).inDays <= 0 ||
              end.difference(now).inDays >= 0)) {
        promoPrice = null;
      } else {
        try {
          promoPrice = double.parse(temp['promo_price'].toString());
        } catch (e) {
          print(e);
          promoPrice = null;
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

  String getFormatedPriceIVA() {
    return formatCurrency.format(getPriceWithIVA());
  }

  String getFormatedPriceNoIva() {
    return formatCurrency.format(getPriceWithoutIVA());
  }

  double getPriceWithIVA() {
    double pwithIVA = price;

    if (taxMethod == 0) {
      pwithIVA = price;
    } else {
      pwithIVA = price * (100 + taxRate!) / 100;
    }

    return pwithIVA;
  }

  double getIVA() {
    return getPriceWithIVA() - getPriceWithoutIVA();
  }

  Map<String, dynamic> toJson() => {
        "slug": slug,
        "id": id,
        "id_cloud": idCloud,
        "image": image,
        "price": getPriceWithIVA(),
        "name": name,
        "code": code,
        "start_date": promoStart,
        "end_date": promoEnd,
        'price_without_discount': priceWithoutDiscount,
        "tax_method": taxMethod,
        "promo_price": promoPrice,
        "quantity": quantity,
        "brand": brand,
        "inventory": inventory,
        "tax_rate": taxRateId,
        "rate": taxRate,
        "tax_rate_name": taxRateName
      };

  /// Customer's price for a product
  Future<double> customerPrice(
      CompanyModel customer, Future<double> function) async {
    final productPrice = await ProductsProvider.findProductPrice(
        idCloud.toString(), customer.priceGroupId!);
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
            idCloud.toString(), dataBloc.getBIllerData!.defaultPriceGroup!);
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
  ///SaleModel.fromJson(), it could be usefull to build an instance of
  ///SaleModel to send to an endpoint of API's service. It also returns
  ///key product_detail_list wich contains a list of product details
  static Map<String, dynamic> getProductDetailMapLists(
      Map<String, ProductModel>? products, int warehouseId) {
    List<double> _quantitys = [];
    List<int> _units = [];
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

    /// To save product details to save into local db
    List<Map<String, dynamic>> productsDetails = [];

    if (products != null && products != {}) {
      products.values.forEach((value) {
        final pIVA = value.getPriceWithIVA();
        final pNoIVA = value.getPriceWithoutIVA();
        final taxValue = pIVA - pNoIVA;
        _ids.add(value.idCloud);
        _codes.add(value.code);
        _quantitys.add(value.quantity);
        _units.add(value.unit);
        _types.add(value.type);
        _names.add(value.name);
        _discounts.add(value.discount.toInt());
        _discountValues.add(value.priceWithoutDiscount! - value.price);
        _taxRates.add(value.taxRate!.toInt());
        _taxValues.add(taxValue);
        _prices.add(pNoIVA);
        _pricePPolicy.add(value.pricePolicyPrices);
        _pricesIVA.add(pIVA);
        _realPrices.add(value.priceWithoutDiscount!);
        _taxRateIds.add(value.taxRateId);

        double discountPercent =
            1 - (value.price / (value.priceWithoutDiscount ?? value.price));
        discountPercent = discountPercent * 100;

        productsDetails.add({
          "product_id": value.idCloud,
          "product_type": value.type,
          "product_code": value.code,
          "product_name": value.name,
          "quantity": value.quantity,
          "warehouse_id": warehouseId,
          "tax_rate_id": value.taxRateId,
          "tax": value.taxRateName,
          "unit_price": pIVA,
          "net_unit_price": pNoIVA,
          "discount": discountPercent.toString() + '%',
          "item_tax": taxValue,
          "subtotal": value.getPriceWithIVA() * value.quantity,
          "price_before_tax": value.getPriceWithoutIVA(),
          "unit_quantity": value.quantity
        });
      });
    }
    return {
      'product_id': _ids,
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
      'product_unit_id_selected': _units,
      'product_base_quantity': _quantitys,
      "product_detail_list": productsDetails
    };
  }

  Future<double> getPrice() async {
    return priceWithoutDiscount!;
  }
}
