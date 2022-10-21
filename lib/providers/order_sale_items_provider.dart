import 'package:pos_wappsi/models/order_sale_items.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';

class OrderSaleItemsProvider {
  static Future<List<OrderSaleItemsModel>> loadFromDB(int orderId) async {
    final res = await DBProvider.db
        .sqlQuery('sma_order_sale_items', where: 'sale_id=$orderId');
    if (res != null) {
      return OrderSaleItemsModel.fromJsonList(res);
    } else {
      return [];
    }
  }

  static Future<bool> saveAllIntoDB(
    List<Map<String, dynamic>> orderItems,
    int orderId,
    String registrationData,
  ) async {
    for (int i = 0; i < orderItems.length; i++) {
      orderItems[i]['sale_id'] = orderId;
      orderItems[i]['registration_date'] = registrationData;
    }
    return await DBProvider.db
        .insertOrUpdateQuery('sma_order_sale_items', orderItems);
  }
}
