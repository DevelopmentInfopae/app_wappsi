import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/providers/companies_provider.dart';

/// Return ProductModel object with prices calculatd by price_policy
Future<ProductModel> policyCases(ProductModel product, int? policy,
    CompanyModel? customer, {bool defaultPrice=false}) async {
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
    // call an alert dialog to choose product unit
    return product;
  } else {
    product.priceWithoutDiscount = price;
    product.price = price;
    product.discount = 0;

    return product;
  }
}

Future<List<double>> priceWDiscount(
    double price, CompanyModel? customer) async {
  int? discount = 0;
  double discountVal = 0.0;
  double priceD = price;

  if (customer != null) {
    final discountData =
        await CompaniesProvider.findCustomerDiscount(customer.customerGroupId!);

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
