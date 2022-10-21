import 'package:pos_wappsi/models/quote_items_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';

class QuoteItemsProvider {
  static Future<List<QuoteItemsModel>> loadFromDB(int quoteId) async {
    final res = await DBProvider.db
        .sqlQuery('sma_quote_items', where: 'quote_id=$quoteId');
    if (res != null) {
      return QuoteItemsModel.fromJsonList(res);
    } else {
      return [];
    }
  }

  static Future<bool> saveAllIntoDB(
    List<Map<String, dynamic>> quoteItems,
    int quoteId,
  ) async {
    for (int i = 0; i < quoteItems.length; i++) {
      quoteItems[i]['quote_id'] = quoteId;
      // quoteItems[i]['registration_date'] = registrationData;
    }
    return await DBProvider.db
        .insertOrUpdateQuery('sma_quote_items', quoteItems);
  }
}
