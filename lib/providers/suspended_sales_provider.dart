import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/suspended_sale_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/providers/customer_addresses_provider.dart';
import 'package:pos_wappsi/providers/document_types_provider.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/payment_methods_provider.dart';
import 'package:pos_wappsi/providers/products_provider.dart';

class SuspendedSalesProvider {
  /// Load sale into SuspendedSale model given an SuspendedSale id
  static Future<SuspendedSales?> loadFromDB(String id) async {
    // Map<String, dynamic> data = await DBProvider.db.findBrand(0);
    Map<String, dynamic>? data = await DBProvider.db
        .sqlFirstQuery('suspended_sales', where: 'id=$id AND status=1');

    if (data != null) {
      return SuspendedSales.fromJson(data);
    } else {
      return null;
    }
  }

  static Future<List<SuspendedSales>> loadAllSSales() async {
    List<Map<String, dynamic>>? data =
        await DBProvider.db.sqlQuery('suspended_sales', where: 'status=1');

    List<SuspendedSales> list = [];
    if (data != null) {
      Map<String, dynamic> temp = {};
      for (var item in data) {
        for (var i = 0; i < item.keys.length; i++) {
          temp[item.keys.toList()[i]] = item.values.toList()[i];
        }
        list.add(SuspendedSales.fromJson(temp));
      }
    }

    return list;
  }

  //. Given search query return a result
  static Future<List<SuspendedSales>> findSuspSale(String query) async {
    final String where = '''status=1 AND (key_word LIKE "%$query%" 
    OR customer_name LIKE "%$query%" OR seller_name LIKE "%$query%")
    ''';
    List<Map<String, dynamic>>? data =
        await DBProvider.db.sqlQuery('suspended_sales', where: where);

    List<SuspendedSales> list = [];
    if (data != null) {
      Map<String, dynamic> temp = {};
      for (var item in data) {
        for (var i = 0; i < item.keys.length; i++) {
          temp[item.keys.toList()[i]] = item.values.toList()[i];
        }
        list.add(SuspendedSales.fromJson(temp));
      }
    }

    return list;
  }

  /// Save sale basic data into local DB and returns it's id
  static Future<bool> suspendSale({String keyWord = ''}) async {
    bool result = false;
    if (posBloc.getProducts != null &&
        posBloc.getProducts != {} &&
        posBloc.getCustomer != null &&
        posBloc.getCustomerAddresses != null) {
      final saleBasicData = {
        'id_customer': posBloc.getCustomer!.idCloud,
        'key_word': keyWord,
        'id_address': posBloc.getCustomerAddresses!.idCloud,
        'id_pay_document': posBloc.getPaymentDocument?.idCloud ?? '',
        'id_pay_method': posBloc.getPaymentMethod?.idCloud ?? '',
        'pay_value': posBloc.getPaymentValue ?? '',
        'invoice_note': posBloc.getInvoiceNote ?? '',
        'dispatch_note': posBloc.getDispatchNote ?? '',
        'items': posBloc.getItemsCount(),
        'total_value': posBloc.getSubTotal(),
        'seller_name': dataBloc.userData?.sellerName ?? '',
        'customer_name':
            posBloc.getCustomer!.name ?? posBloc.getCustomer!.company,
        'status': 1
      };
      final res = await DBProvider.db
          .insertQuery('suspended_sales', saleBasicData, returnId: true);
      if (res != 0) {
        result = await ProductsProvider.saveProductsSpSale(res ?? 0);
      }
    }

    return result;
  }

  /// Delete suspended sale from DB given a suspended sale id
  static Future<bool> deleteSuspSale(String id) async {
    final res = await DBProvider.db
        .sqlUpdateQuery('suspended_sales', {'status': 0}, 'id=$id');
    return res != null;
  }

  /// Load suspended sale given a suspended sale id. Param getPrices is
  ///used to know if product prices should or not be calculated
  static Future<List<Map<String, dynamic>>> loadSale(String id,
      {bool getPrices = true}) async {
    final suspendedSale = await loadFromDB(id);

    final customer = await CompanyModel.getCompanyDetails(
        suspendedSale!.idCustomer.toString());
    final prodInfo = await ProductsProvider.loadSuspSaleProducts(id, customer!);
    final customerAdd = await CustomerAddressesProvider.loadCustomerAddress(
        suspendedSale.idAddress.toString());

    final payDocument = await DocumentsTypesProvider.loadPayDoc(
        (suspendedSale.idPayDocument ?? '').toString());

    final payMethod = await PaymentMethodsProvider.loadPaymentM(
        (suspendedSale.idPayMethod ?? '').toString());

    posBloc.setPaymentDocument(payDocument);
    posBloc.setPaymentMethod(payMethod);
    posBloc.setCustomer(customer);
    posBloc.setCustomerAddresses(customerAdd);

    final List<ProductModel> products = prodInfo['products'];
    final List<UnitsModel?> units = prodInfo['products_unit'];
    List<Map<String, dynamic>> errors = [];
    await Future.forEach(products, (ProductModel p) async {
      final index = products.indexOf(p);
      // here we send getQttys = false to not get product inital qttys
      bool res = false;
      try {
        res = await posBloc.addProduct({
          'product': p,
          'product_unit': units.isNotEmpty ? units[index] : null
        }, getPrices: getPrices, getQttys: false);
      } catch (e) {
        res = await posBloc
            .addProduct({'product': p}, getPrices: getPrices, getQttys: false);
      }
      if (!res) {
        errors.add(p.toJson());
      }
    });

    return errors;
  }

  static Future<Map<String, dynamic>> suspSaleInfo(
      String id, String keyWord, double totalValue, int items) async {
    final suspendedSale = await loadFromDB(id);

    final customer = await CompanyModel.getCompanyDetails(
        suspendedSale!.idCustomer.toString());
    final products = await ProductsProvider.loadSuspSaleProducts(id, customer!);
    final customerAdd = await CustomerAddressesProvider.loadCustomerAddress(
        suspendedSale.idAddress.toString());

    final payDocument = await DocumentsTypesProvider.loadPayDoc(
        (suspendedSale.idPayDocument ?? '').toString());

    final payMethod = await PaymentMethodsProvider.loadPaymentM(
        (suspendedSale.idPayMethod ?? '').toString());

    return {
      'suspended_sale': suspendedSale.id,
      'products_info': products,
      'customer': customer,
      'pay_document': payDocument,
      'customer_add': customerAdd,
      'pay_method': payMethod,
      'total_value': totalValue,
      'key_word': keyWord,
      'items': items,
    };
  }
}
