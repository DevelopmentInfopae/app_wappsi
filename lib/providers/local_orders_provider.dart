import 'package:pos_wappsi/bloc/data_bloc.dart';

import 'package:pos_wappsi/models/order_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/utils/local_storage/local_db.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

class LocalOrdersProvider {
  static Future<List<OrderModel>?> listLocalOrders(
      {String search = '',
      int? limit,
      String orderBy = 'name',
      List<String>? filters,
      bool offset = false,
      int offsetValue = 1}) async {
    String? filter;
    if (filters != null) {
      if (filters.isNotEmpty) {
        filter = "AND os.sale_status IN ('" + filters.join("','") + "') ";
      }
    }
    final pagination = offset ? " LIMIT 30 OFFSET $offsetValue" : "";
    final currentBiller = dataBloc.userData!.billerId;
    final sql = '''select * from sma_order_sales os 
        WHERE (os.customer LIKE "%$search%" OR os.note LIKE "%$search%" OR os.staff_note LIKE "%$search%" 
        OR os.reference_no LIKE "%$search%") ${filter ?? ""}AND os.biller_id=$currentBiller AND os.created_by=${dataBloc.userData!.id}$pagination ORDER BY registration_date DESC;
    ''';
    final res = await DBProvider.db.sqlRawQuery(sql);
    if (res != null) {
      List<OrderModel> orders = [];
      try {
        orders = OrderModel.fromJsonList(res);
      } catch (e) {
        printConsole(e);
      }
      return orders;
    } else {
      return [];
    }
  }

  static Future<List<String>> orderStatus() async {
    const sql = '''SELECT DISTINCT sale_status FROM sma_order_sales''';
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
}
