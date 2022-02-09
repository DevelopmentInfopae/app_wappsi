import 'package:pos_wappsi/bloc/data_bloc.dart';

import 'package:pos_wappsi/models/order_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

class LocalOrdersProvider {
  static Future<List<OrderModel>?> listLocalOrders(
      {String search = '',
      int? limit,
      String orderBy = 'name',
      bool offset = false,
      int offsetValue = 1}) async {
    final pagination = offset ? " LIMIT 30 OFFSET $offsetValue" : "";
    final currentBiller = dataBloc.userData!.billerId;
    final sql = '''select * from sma_order_sales os 
        WHERE (os.customer LIKE "%$search%" OR os.note LIKE "%$search%" OR os.staff_note LIKE "%$search%" 
        OR os.reference_no LIKE "%$search%") 
        AND os.biller_id=$currentBiller$pagination ORDER BY registration_date DESC;
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
}
