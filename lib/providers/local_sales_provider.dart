import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/models/local_sales_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

class LocalSalesProvider {
  static Future<List<SalesModel>?> listLocalSales(
      {String search = '',
      int? limit,
      String orderBy = 'name',
      bool offset = false,
      int offsetValue = 1}) async {
    final pagination = offset ? " LIMIT 30 OFFSET $offsetValue" : "";
    final currentBiller = dataBloc.userData!.billerId;
    final sql = '''select * from sma_sales s 
        WHERE (s.customer LIKE "%$search%" OR s.note LIKE "%$search%" OR s.staff_note LIKE "%$search%" 
        OR s.reference_no LIKE "%$search%") 
        AND s.biller_id=$currentBiller$pagination ORDER BY registration_date DESC;
    ''';
    final res = await DBProvider.db.sqlRawQuery(sql);
    if (res != null) {
      List<SalesModel> sales = [];
      try {
        sales = SalesModel.fromJsonList(res);
      } catch (e) {
        printConsole(e);
      }
      return sales;
    } else {
      return [];
    }
  }
}
