import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/orders_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/bloc/quotes_bloc.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/providers/companies_provider.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';

class PricePoliciesProvider {
  /// Checks what else is required to add product price correctly
  static Map checkProductSelectionRequirements() {
    final Map requirements = {
      'product_unit': false,
    };
    final pricePolicy = dataBloc.settings!['prioridad_precios_producto'];
    if (pricePolicy == 10) {
      requirements['product_unit'] = true;
    }
    return requirements;
  }

  /// Return ProductModel object with prices calculated by price_policy
  static Future<ProductModel> policyCases(
    ProductModel product,
    int? policy,
    CompanyModel? customer, {
    bool defaultPrice = false,
    String? productKey,
    UnitsModel? unit,
  }) async {
    //tax rate for IVA

    double price = product.getPriceWithoutIVA();

    /// For price_policy with id 6
    if (policy == 6) {
      if (customer != null) {
        if (product.promoPrice != null) {
          product.price = product.promoPrice!;
          product.discount = 0;
          product.priceWithoutDiscount = product.promoPrice!;
          return product;
        } else {
          if (customer.priceGroupId != null) {
            price = await product.customerPrice(
              customer,
              product.billerPrice(product.getPrice()),
            );
          } else {
            price = await product.billerPrice(product.getPrice());
          }
          // printConsole(price);
          final values = await priceWDiscount(price, customer);
          product.price = values[0];
          product.priceWithoutDiscount = price;
          product.discount = values[1];
          product.pricePolicyPrices = price;

          return product;
        }
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
      if (unit != null) {
        product.price = unit.unitValue / (unit.operationValue);
        product.pricePolicyPrices = unit.unitValue / (unit.operationValue);
      }
      return product;
    } else {
      product.priceWithoutDiscount = price;
      product.price = price;
      product.discount = 0;

      return product;
    }
  }

  /// Return ProductModel object with prices calculated by price_policy
  static Future<bool> policyCasesPrice(
    String? productKey,
    int? policy,
    CompanyModel? customer, {
    bool defaultPrice = false,
    bool toOrder = false,
    bool toQuote = false,
  }) async {
    //tax rate for IVA

    double price = 0.0;

    bool result = false;

    ProductModel product;

    if (toOrder) {
      product = orderBloc.getProducts![productKey]!;
    } else if (toQuote) {
      product = quoteBloc.getProducts![productKey]!;
    } else {
      product = posBloc.getProducts![productKey]!;
    }

    try {
      /// For price_policy with id 6
      if (policy == 6) {
        ProductModel? t;
        if (toOrder) {
          t = orderBloc.getProducts?[productKey];
        } else if (toQuote) {
          t = quoteBloc.getProducts?[productKey];
        } else {
          t = posBloc.getProducts?[productKey];
        }
        if (t?.promoPrice != null) {
          product.price = product.promoPrice!;
          product.discount = 0;
          product.priceWithoutDiscount = product.promoPrice!;
        } else {
          if (customer != null) {
            if (customer.priceGroupId != null) {
              price = await product.customerPrice(
                customer,
                product.billerPrice(product.getPrice()),
              );
            } else {
              price = await product.billerPrice(product.getPrice());
            }
            // printConsole(price);
            final values = await priceWDiscount(price, customer);
            product.price = values[0];
            product.priceWithoutDiscount = price;
            product.discount = values[1];
            product.pricePolicyPrices = price;
          } else {
            //if customer not selected
            final values = await priceWDiscount(price, customer);
            product.price = values[0];
            product.priceWithoutDiscount = price;
            product.discount = values[1];
          }
        }
        result = true;
      } else if (policy == 10) {
        // posBloc.getProducts![productKey]!.price= posBloc.getProductUnits[]
        UnitsModel unit;

        if (toOrder) {
          unit = orderBloc.getProductUnits![productKey]!;
        } else if (toQuote) {
          unit = quoteBloc.getProductUnits![productKey]!;
        } else {
          unit = posBloc.getProductUnits![productKey]!;
        }
        product.pricePolicyPrices = unit.unitValue / (unit.operationValue);
        product.price = unit.unitValue / (unit.operationValue);
      } else {
        product.priceWithoutDiscount = price;
        product.price = price;
        product.discount = 0;
      }
      if (toOrder) {
        orderBloc.getProducts![productKey!] = product;
      } else if (toQuote) {
        quoteBloc.getProducts![productKey!] = product;
      } else {
        posBloc.getProducts![productKey!] = product;
      }
      result = true;
    } catch (e) {
      await logError(e, from: 'policyCasesPrice');
      // printConsole(e);
      result = false;
    }
    return result;
  }

  /// Return ProductModel object with prices calculated by price_policy
  static Future<bool> policyCasesPriceOrder(
    String? productKey,
    int? policy,
    CompanyModel? customer, {
    bool defaultPrice = false,
  }) async {
    //tax rate for IVA

    double price = 0.0;

    try {
      /// For price_policy with id 6
      if (policy == 6) {
        if (orderBloc.getProducts![productKey]!.promoPrice != null) {
          orderBloc.getProducts![productKey]!.price =
              orderBloc.getProducts![productKey]!.promoPrice!;
          orderBloc.getProducts![productKey]!.discount = 0;
          orderBloc.getProducts![productKey]!.priceWithoutDiscount =
              orderBloc.getProducts![productKey]!.promoPrice!;
        } else {
          if (customer != null) {
            if (customer.priceGroupId != null) {
              price = await orderBloc.getProducts![productKey]!.customerPrice(
                customer,
                orderBloc.getProducts![productKey]!.billerPrice(
                  orderBloc.getProducts![productKey]!.getPrice(),
                ),
              );
            } else {
              price = await orderBloc.getProducts![productKey]!
                  .billerPrice(orderBloc.getProducts![productKey]!.getPrice());
            }
            // printConsole(price);
            final values = await priceWDiscount(price, customer);
            orderBloc.getProducts![productKey]!.price = values[0];
            orderBloc.getProducts![productKey]!.priceWithoutDiscount = price;
            orderBloc.getProducts![productKey]!.discount = values[1];
            orderBloc.getProducts![productKey]!.pricePolicyPrices = price;
          } else {
            //if customer not selected
            final values = await priceWDiscount(price, customer);
            orderBloc.getProducts![productKey]!.price = values[0];
            orderBloc.getProducts![productKey]!.priceWithoutDiscount = price;
            orderBloc.getProducts![productKey]!.discount = values[1];
          }
        }
      } else if (policy == 10) {
        // orderBloc.getProducts![productKey]!.price= orderBloc.getProductUnits[]

        orderBloc.getProducts![productKey]!.pricePolicyPrices =
            orderBloc.getProductUnits![productKey]!.unitValue /
                (orderBloc.getProductUnits![productKey]!.operationValue);
        orderBloc.getProducts![productKey]!.price =
            orderBloc.getProductUnits![productKey]!.unitValue /
                orderBloc.getProducts![productKey]!.quantity;
      } else {
        orderBloc.getProducts![productKey]!.priceWithoutDiscount = price;
        orderBloc.getProducts![productKey]!.price = price;
        orderBloc.getProducts![productKey]!.discount = 0;
      }
      return true;
    } catch (e) {
      // printConsole(e);
      await logError(e, from: 'Price policy fromPosOrder');
      return false;
    }
  }

  static Future<List<double>> priceWDiscount(
    double price,
    CompanyModel? customer,
  ) async {
    int? discount = 0;
    double discountVal = 0.0;
    double priceD = price;

    if (customer != null) {
      final discountData = await CompaniesProvider.findCustomerDiscount(
        customer.customerGroupId!,
      );

      // ignore: unnecessary_null_comparison
      discount = discountData!['percent'];
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
