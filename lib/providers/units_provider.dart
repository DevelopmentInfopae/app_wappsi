import 'package:flutter/cupertino.dart';
import 'package:pos_wappsi/models/product_model.dart';
import 'package:pos_wappsi/models/units_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/screens/sales/components/select_unit_prefs_alert.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

class UnitsProvider {
  static Future<List<UnitsModel>> getProductUnits(
      String productId, String priceGroupId) async {
    final res = await getProductUnitsRaw(productId, priceGroupId);
    List<UnitsModel> units = [];
    if (res != null && res.isNotEmpty) {
      units = UnitsModel.fromJsonList(res);
    }
    return units;
  }

  static Future<List<Map<String, dynamic>>?> getProductUnitsRaw(
      String productId, String priceGroupId) async {
    String sql = '''SELECT u.id as id,u.id_cloud as id_cloud,u.name as name,
    u.code as code ,u.operator as operator,u.base_unit as base_unit,u.operation_value 
    as operation_value,up.valor_unitario as valor_unitario,u.unit_value as unit_value,
    u.last_update as last_update,u.price_group_id as price_group_id FROM sma_unit_prices up INNER JOIN sma_units u ON 
    (u.id_cloud = up.unit_id) WHERE up.id_product = $productId UNION 
    SELECT u2.id as id,u2.id_cloud as id_cloud,u2.name as name,u2.code as code,"" as operator,u2.base_unit as base_unit,
    1 as operation_value,p.price as valor_unitario,p.price as unit_value,u2.last_update as last_update,
    u2.price_group_id as price_group_id FROM sma_products p INNER JOIN sma_units u2 on u2.id_cloud = 
    p.sale_unit WHERE p.id_cloud = $productId ORDER BY valor_unitario ASC''';
    final res = await DBProvider.db.sqlRawQuery(sql);

    return res;
  }

  static Future<UnitsModel?> getUnitInfo(int? unitId) async {
    final res = await DBProvider.db
        .sqlFirstQuery('sma_units', where: "id_cloud=$unitId");
    if (res != null) {
      return UnitsModel.fromJson(res);
    } else {
      return null;
    }
  }

  static Future<UnitsModel?> getPUnitSuspended(
      String productId, String priceGroupId, String unitId) async {
    String sql = '''SELECT u.id as id,u.id_cloud as id_cloud,u.name as name,
    u.code as code ,u.operator as operator,u.base_unit as base_unit,u.operation_value 
    as operation_value,up.valor_unitario as valor_unitario,u.unit_value as unit_value,
    u.last_update as last_update,u.price_group_id as price_group_id FROM sma_unit_prices up INNER JOIN sma_units u ON 
    u.id_cloud = up.unit_id WHERE up.id_product = $productId AND u.id_cloud = $unitId UNION SELECT u2.id as id,u2.id_cloud as id_cloud,u2.name as name,
    u2.code as code,"" as operator,u2.base_unit as base_unit,1 as operation_value,
    p.price as valor_unitario,p.price as unit_value,u2.last_update as last_update,u2.price_group_id as price_group_id 
    FROM sma_products p INNER JOIN sma_units u2 on (u2.id_cloud = p.sale_unit AND u2.id_cloud = $unitId) 
    WHERE p.id_cloud = $productId ORDER BY valor_unitario ASC''';
    final res = await DBProvider.db.sqlFirstRawQuery(sql);
    UnitsModel? unit;
    if (res != null && res.isNotEmpty) {
      unit = UnitsModel.fromJson(res);
    }
    return unit;
  }

  static Future<Map<String, dynamic>?> getProductUnit(
      BuildContext context, ProductModel product, String priceGroupId,
      {bool showAllwaysUnitAlert = false,
      bool showInvInstOfPrice = false}) async {
    final units = await UnitsProvider.getProductUnits(
        product.idCloud.toString(), priceGroupId);
    printConsole(units.first.name);

    if (units.length > 1 || showAllwaysUnitAlert) {
      return await showCupertinoDialog<Map<String, dynamic>?>(
          // to make selection of product unit required
          barrierDismissible: false,
          // useRootNavigator: false,
          context: context,
          builder: (context) {
            return SelectProductUnitDialog(
              product: product,
              units: units,
              showInvInstOfPrice: showInvInstOfPrice,
            );
          });
    } else {
      return {"unit": units.first, "quantity": 1};
    }
  }
}
