import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';

class UnitsProvider {
  static Future<List<UnitsModel>> getProductUnits(String productId) async {
    String sql = '''SELECT u.id,u.id_cloud,u.name,u.code,u.operator,
    u.operation_value,up.valor_unitario,up.id as unit_price_id FROM sma_unit_prices up INNER 
    JOIN sma_units u ON u.id_cloud = up.unit_id WHERE up.id_product = $productId 
    UNION SELECT u2.id,u2.id_cloud,u2.name,u2.code,"" as operator,1 as 
    operation_value,p.price as valor_unitario,0 as unit_price_id FROM
    sma_products p INNER JOIN sma_units u2 on u2.id_cloud = p.sale_unit 
    WHERE p.id_cloud = $productId ORDER BY valor_unitario ASC''';
    final res = await DBProvider.db.sqlRawQuery(sql);
    List<UnitsModel> units = [];
    if (res != null && res.length > 0) {
      units = UnitsModel.fromJsonList(res);
    }
    return units;
  }
}
