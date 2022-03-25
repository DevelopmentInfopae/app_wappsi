
import 'package:pos_wappsi/models/purchase_items_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';

class PurchaseItemsProvider {
  static Future<List<PurchaseItemsModel>> loadFromDB(int purchaseId) async {
    final res = await DBProvider.db
        .sqlQuery('sma_purchase_items', where: 'purchase_id=$purchaseId');
    if (res != null) {
      return PurchaseItemsModel.fromJsonList(res);
    } else {
      return [];
    }
  }

  static Future<bool> saveAllIntoDB(
      List<Map<String, dynamic>> purchaseItems, int purchaseId) async {
    for (int i = 0; i < purchaseItems.length; i++) {
      purchaseItems[i]['purchase_id'] = purchaseId;
      // purchaseItems[i]['registration_date'] = registrationData;
    }
    return await DBProvider.db
        .insertOrUpdateQuerys('sma_purchase_items', purchaseItems);
  }
}