import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/companies_provider.dart';

class PricePoliciesProvider {
  /// Checks what else is required to add product price correctly
  static Map checkProductSelectionRequirements() {
    final Map requirements = {
      "product_unit": false,
    };
    final pricePolicy = dataBloc.settings!['prioridad_precios_producto'];
    if (pricePolicy == 10) {
      requirements['product_unit'] = true;
    }
    return requirements;
  }

  /// Return ProductModel object with prices calculatd by price_policy
  static Future<ProductModel> policyCases(
      ProductModel product, int? policy, CompanyModel? customer,
      {bool defaultPrice = false, String? productKey}) async {
    //tax rate for IVA

    double price = product.getPriceWithoutIVA();

    /// For price_plicy with id 6
    if (policy == 6) {
      if (customer != null) {
        if (customer.priceGroupId != null) {
          price = await product.customerPrice(
              customer, product.billerPrice(product.getPrice()));
        } else {
          price = await product.billerPrice(product.getPrice());
        }
        // print(price);
        final values = await priceWDiscount(price, customer);
        product.price = values[0];
        product.priceWithoutDiscount = price;
        product.discount = values[1];
        product.pricePolicyPrices = price;

        return product;
      } else {
        //if customer not selected
        final values = await priceWDiscount(price, customer);
        product.price = values[0];
        product.priceWithoutDiscount = price;
        product.discount = values[1];
        return product;
      }
    } else if (policy == 10) {
      // product.price= posBloc.getProductUnits[]
      return product;
    } else {
      product.priceWithoutDiscount = price;
      product.price = price;
      product.discount = 0;

      return product;
    }
  }

  /// Return ProductModel object with prices calculatd by price_policy
  static Future<bool> policyCasesFromPos(
      String? productKey, int? policy, CompanyModel? customer,
      {bool defaultPrice = false}) async {
    //tax rate for IVA

    double price = 0.0;

    try {
      /// For price_plicy with id 6
      if (policy == 6) {
        if (posBloc.getProducts![productKey]!.promoPrice != null) {
          posBloc.getProducts![productKey]!.price =
              posBloc.getProducts![productKey]!.promoPrice!;
          posBloc.getProducts![productKey]!.discount = 0;
          posBloc.getProducts![productKey]!.priceWithoutDiscount =
              posBloc.getProducts![productKey]!.promoPrice!;
        } else {
          if (customer != null) {
            if (customer.priceGroupId != null) {
              price = await posBloc.getProducts![productKey]!.customerPrice(
                  customer,
                  posBloc.getProducts![productKey]!.billerPrice(
                      posBloc.getProducts![productKey]!.getPrice()));
            } else {
              price = await posBloc.getProducts![productKey]!
                  .billerPrice(posBloc.getProducts![productKey]!.getPrice());
            }
            // print(price);
            final values = await priceWDiscount(price, customer);
            posBloc.getProducts![productKey]!.price = values[0];
            posBloc.getProducts![productKey]!.priceWithoutDiscount = price;
            posBloc.getProducts![productKey]!.discount = values[1];
            posBloc.getProducts![productKey]!.pricePolicyPrices = price;
          } else {
            //if customer not selected
            final values = await priceWDiscount(price, customer);
            posBloc.getProducts![productKey]!.price = values[0];
            posBloc.getProducts![productKey]!.priceWithoutDiscount = price;
            posBloc.getProducts![productKey]!.discount = values[1];
          }
        }
      } else if (policy == 10) {
        // posBloc.getProducts![productKey]!.price= posBloc.getProductUnits[]
        posBloc.getProducts![productKey]!.quantity =
            (posBloc.getProductUnits![productKey]!.operationValue ?? 1);
        posBloc.getProducts![productKey]!.pricePolicyPrices =
            posBloc.getProductUnits![productKey]!.unitValue /
                posBloc.getProducts![productKey]!.quantity;
        posBloc.getProducts![productKey]!.price =
            posBloc.getProductUnits![productKey]!.unitValue /
                posBloc.getProducts![productKey]!.quantity;
      } else {
        posBloc.getProducts![productKey]!.priceWithoutDiscount = price;
        posBloc.getProducts![productKey]!.price = price;
        posBloc.getProducts![productKey]!.discount = 0;
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<List<double>> priceWDiscount(
      double price, CompanyModel? customer) async {
    int? discount = 0;
    double discountVal = 0.0;
    double priceD = price;

    if (customer != null) {
      final discountData = await CompaniesProvider.findCustomerDiscount(
          customer.customerGroupId!);

      // ignore: unnecessary_null_comparison
      discount = discountData!['percent'] ?? null;
      if (discount != null) {
        if (discount < 0) {
          discountVal = price * discount / 100;
          priceD = price + discountVal;
        } else {
          discountVal = price * discount / 100;
          priceD = price - discountVal;
        }
      }
    }
    return [priceD, discount!.toDouble(), discountVal];
  }
}
