import 'package:pos_wappsi/models/biller_data_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';

class BillerDataProvider {
  static Future<BillerDataModel?> loadBillerData() async {
    final billerData = await DBProvider.db.getBillerData();
    if (billerData != null) {
      return BillerDataModel.fromJson(billerData);
    } else {
      return null;
    }
  }

  static Future<BillerDataModel?> loadBillerDataId(String id) async {
    final billerData = await DBProvider.db
        .sqlFirstQuery('sma_biller_data', where: 'biller_id = $id');
    if (billerData != null) {
      return BillerDataModel.fromJson(billerData);
    } else {
      return null;
    }
  }
}
