import 'package:flutter/cupertino.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/screens/sales/components/select_product_unit_alert.dart';

class UnitsProvider {
  static Future<List<UnitsModel>> getProductUnits(
      String productId, String priceGroupId) async {
    String sql = '''SELECT u.id as id,u.id_cloud as id_cloud,u.name as name,
    u.code as code ,u.operator as operator,u.base_unit as base_unit,u.operation_value 
    as operation_value,up.valor_unitario as valor_unitario,u.unit_value as unit_value,
    u.last_update as last_update FROM sma_unit_prices up INNER JOIN sma_units u ON 
    u.id_cloud = up.unit_id WHERE up.id_product = $productId AND up.price_group_id = 
    $priceGroupId UNION SELECT u2.id as id,u2.id_cloud as id_cloud,u2.name as name,
    u2.code as code,"" as operator,u2.base_unit as base_unit,1 as operation_value,
    p.price as valor_unitario,p.price as unit_value,u2.last_update as last_update FROM
    sma_products p INNER JOIN sma_units u2 on u2.id_cloud = p.sale_unit 
    WHERE p.id_cloud = $productId ORDER BY valor_unitario ASC''';
    final res = await DBProvider.db.sqlRawQuery(sql);
    List<UnitsModel> units = [];
    if (res != null && res.length > 0) {
      units = UnitsModel.fromJsonList(res);
    }
    return units;
  }

  static Future<UnitsModel?> getProductUnit(
      BuildContext context, ProductModel product, String priceGroupId) async {
    final units = await UnitsProvider.getProductUnits(
        product.idCloud.toString(), priceGroupId);
    print(units.first.name);

    if (units.length > 1) {
      return await showCupertinoDialog<UnitsModel>(
          // to make selection of product unit required
          barrierDismissible: false,
          useRootNavigator: false,
          context: context,
          builder: (context) {
            return SelectProductUnitDialog(
              product: product,
              units: units,
            );
          });
    } else {
      return units.first;
    }
  }
}
