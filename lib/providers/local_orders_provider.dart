import 'package:pos_wappsi/bloc/data_bloc.dart';

import 'package:pos_wappsi/models/order_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/units_provider.dart';
import 'package:pos_wappsi/providers/zone_provider.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';
import 'package:pos_wappsi/utils/local_storage/local_db.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

import '../utils/text_formating/functions.dart';
import 'biller_data_provider.dart';
import 'companies_provider.dart';
import 'customer_addresses_provider.dart';
import 'order_sale_items_provider.dart';

class LocalOrdersProvider {
  static Future<List<OrderModel>> listLocalOrders(
      {String search = '',
      int? limit,
      String orderBy = 'name',
      List<String>? filters,
      bool offset = false,
      int offsetValue = 1}) async {
    String? filter;
    String searchSql = "";

    final onlyCreatedByUser = dataBloc.userData?.viewRight == 0
        ? 'AND created_by=${dataBloc.userData!.id}'
        : '';

    final pagination = offset ? " LIMIT 30 OFFSET $offsetValue" : "";
    final currentBiller = dataBloc.userData!.billerId;

    if (search.isNotEmpty) {
      searchSql =
          '''(customer LIKE "%$search%" OR note LIKE "%$search%" OR staff_note LIKE "%$search%" OR reference_no LIKE "%$search%") ''';
      if (filters?.isEmpty ?? true) {
        searchSql += " AND";
      }
    }

    if (filters != null) {
      if (filters.isNotEmpty) {
        if (searchSql.isNotEmpty) {
          filter = "AND sale_status IN ('" + filters.join("','") + "') AND";
        } else {
          filter = "sale_status IN ('" + filters.join("','") + "') AND";
        }
      }
    }
    final sql = '''select * from sma_order_sales 
        WHERE $searchSql${filter ?? ""} biller_id=$currentBiller AND sale_status!='cancelled' $onlyCreatedByUser ORDER BY registration_date DESC$pagination;
    ''';
    final res = await DBProvider.db.sqlRawQuery(sql);
    if (res != null) {
      List<OrderModel> orders = [];
      try {
        orders = OrderModel.fromJsonList(res);
      } catch (e) {
        // printConsole(e);
        await logError(e, from: 'Loading orders list');
      }
      return orders;
    } else {
      return [];
    }
  }

  static Future<List<String>> orderStatus() async {
    const sql =
        '''SELECT DISTINCT sale_status FROM sma_order_sales WHERE sale_status!="cancelled"''';
    final res = await DBProvider.db.sqlRawQuery(sql);
    List<String> status = [];
    if (res != null) {
      final temp = queryResultToMapList(res);
      try {
        for (Map element in temp) {
          status.add(element['sale_status']);
        }
      } catch (e) {
        printConsole(e);
      }
    }
    return status;
  }

  static Future<List<int>> ordersIds(
      {String search = '', List<String>? filters}) async {
    // const sql =
    // '''SELECT id_cloud FROM sma_order_sales''';
    // final res = await DBProvider.db.sqlRawQuery(sql);
    String filter = "";
    String searchSql = "";
    if (filters != null) {
      if (filters.isNotEmpty) {
        filter = "AND sale_status IN ('" + filters.join("','") + "') ";
      }
    }
    final onlyCreatedByUser = dataBloc.userData?.viewRight == 0
        ? 'AND created_by=${dataBloc.userData!.id}'
        : '';
    if (search.isNotEmpty) {
      searchSql =
          '''(customer LIKE "%$search%" OR note LIKE "%$search%" OR staff_note LIKE "%$search%" OR reference_no LIKE "%$search%") ''';
      if (filters?.isEmpty ?? true) {
        searchSql += " AND";
      }
    }
    if (filters != null) {
      if (filters.isNotEmpty) {
        if (searchSql.isNotEmpty) {
          filter = "AND sale_status IN ('" + filters.join("','") + "') AND";
        } else {
          filter = "sale_status IN ('" + filters.join("','") + "') AND";
        }
      }
    }
    final currentBiller = dataBloc.userData!.billerId;
    final sql =
        "select id_cloud from sma_order_sales WHERE $searchSql$filter biller_id=$currentBiller AND sale_status!='cancelled' $onlyCreatedByUser;";
    final res = await DBProvider.db.sqlRawQuery(sql);

    List<int> ids = [];
    if (res != null) {
      final temp = queryResultToMapList(res);
      try {
        for (Map element in temp) {
          ids.add(element['id_cloud']);
        }
      } catch (e) {
        printConsole(e);
      }
    }
    return ids;
  }

  static Future<Map> buildPrintDataMap(OrderModel order) async {
    final customer =
        await CompaniesProvider.getCompanyById(order.customerId.toString());
    final biller =
        await CompaniesProvider.getCompanyById(order.billerId.toString());
    final billerData =
        await BillerDataProvider.loadBillerDataId(order.billerId.toString());
    final customerAddress = await CustomerAddressesProvider.loadCustomerAddress(
        order.addressId.toString());
    // Load only first sale payment

    final settings = dataBloc.settings;
    final docDetails =
        await DBProvider.db.getDocumentDetails(order.documentTypeId.toString());
    final temp = removeRareSpaceChr(docDetails?['invoice_footer'] ?? '');

    final productsInfo = await _productsMap(order.idCloud!);

    return {
      "products": productsInfo['products'],
      "customer": customer?.toJson() ?? {},
      "customer_address": customerAddress?.toJson() ?? {},
      "order_data": {
        'reference_no': order.referenceNo,
        'resolucion': order.resolucion,
        'date': order.registrationDate
      },
      "zone_szone_data": await ZonesProvider.getZoneSzoneDataJson(
          zoneId: customerAddress?.location,
          subzoneId: customerAddress?.subzone
      ),
      "pos_note": order.note ?? '',
      "total": order.total,
      "grand_total": order.grandTotal,
      "products_discount": order.productDiscount,
      "order_discount": order.orderDiscount,
      "total_discount": order.totalDiscount,
      "iva": productsInfo['iva'],
      "company_data": biller,
      "biller_data": billerData,
      "settings": settings,
      "footer": temp
    };
  }

  static Future<Map<String, dynamic>> _productsMap(int saleId) async {
    final saleItems = await OrderSaleItemsProvider.loadFromDB(saleId);

    List<Map<String, dynamic>> productsMap = [];
    Map<double, dynamic> ivasMap = {};
    try {
      for (var item in saleItems) {
        final unit = await UnitsProvider.getUnitInfo(item.productUnitId);
        final bUnit = await UnitsProvider.getUnitInfo(unit?.baseUnit);
        final tItempMap = {
          'quantity': item.quantity,
          'price': item.unitPrice,
          'name': item.productName,
          'unit': unit?.toJson(),
          'preferences': item.preferences,
          'base_unit': bUnit?.toJson()
        };
        productsMap.add(tItempMap);
        final taxRate =
            roundDouble((item.unitPrice / item.netUnitPrice) - 1, 2);
        if (ivasMap.containsKey(taxRate)) {
          ivasMap[taxRate]['value'] =
              ivasMap[taxRate]['value'] + (item.priceBeforeTax * item.quantity);
        } else {
          ivasMap[taxRate] = {
            'value': (item.priceBeforeTax * item.quantity),
            'name': item.tax
          };
        }
      }
    } catch (e) {
      await logError(e, from: 'OrderModel, _productsMap');
      // printConsole(e);
      return {};
    }

    return {
      'iva': ivasMap,
      'products': productsMap,
    };
  }
}
