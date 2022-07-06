import 'package:pos_wappsi/bloc/data_bloc.dart';

import 'package:pos_wappsi/models/order_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';
import 'package:pos_wappsi/utils/local_storage/local_db.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

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
      searchSql = '''(customer LIKE "%$search%" OR note LIKE "%$search%" OR staff_note LIKE "%$search%" OR reference_no LIKE "%$search%") ''';
      if(filters?.isEmpty??true){
        searchSql+=" AND";
      }
    }

    if (filters != null) {
      if (filters.isNotEmpty) {
        if(searchSql.isNotEmpty){
          filter = "AND sale_status IN ('" + filters.join("','") + "') AND";
        }else{
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
      searchSql = '''(customer LIKE "%$search%" OR note LIKE "%$search%" OR staff_note LIKE "%$search%" OR reference_no LIKE "%$search%") ''';
      if(filters?.isEmpty??true){
        searchSql+=" AND";
      }
    }
    if (filters != null) {
      if (filters.isNotEmpty) {
        if(searchSql.isNotEmpty){
          filter = "AND sale_status IN ('" + filters.join("','") + "') AND";
        }else{
          filter = "sale_status IN ('" + filters.join("','") + "') AND";
        }
      }
    }
    final currentBiller = dataBloc.userData!.billerId;
    final sql = "select id_cloud from sma_order_sales WHERE $searchSql$filter biller_id=$currentBiller AND sale_status!='cancelled' $onlyCreatedByUser;";
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
}
