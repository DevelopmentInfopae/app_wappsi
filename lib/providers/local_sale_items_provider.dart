import 'package:pos_wappsi/models/local_sale_items_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';

class SaleItemsProvider {
  static Future<List<LocalSaleItems>> loadFromDB(int saleId) async {
    final res = await DBProvider.db
        .sqlQuery('sma_sale_items', where: 'sale_id=$saleId');
    if (res != null) {
      return LocalSaleItems.fromJsonList(res);
    } else {
      return [];
    }
  }

  static Future<bool> saveAllIntoDB(
      List<Map<String, dynamic>> productsDetails, int saleId) async {
    List<Map<String, dynamic>> productsD = [];
    for (var pD in productsDetails) {
      productsD.add(LocalSaleItems.fromJson(pD, saleId: saleId).toJson());
    }
    return await DBProvider.db.insertQuerys('sma_sale_items', productsD);
  }
}
