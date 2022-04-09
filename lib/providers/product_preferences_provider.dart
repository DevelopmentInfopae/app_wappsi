import 'package:pos_wappsi/models/preference_category_model.dart';
import 'package:pos_wappsi/models/preference_model.dart';

import 'local_db_provider.dart';

class ProductPreferencesProvider {
  static Future<Map<PreferenceCategoryModel, List<PreferenceModel>>>
      listProductPreferences(var productId) async {
    Map<PreferenceCategoryModel, List<PreferenceModel>> productPrefs = {};

    final sql =
        '''select * from sma_product_preferences WHERE (product_id = $productId)''';
    final pp = await DBProvider.db.sqlRawQuery(sql);

    final procesedCategories = {};

    if (pp != null) {
      for (var item in pp) {
        final prefId = item['preference_id'];
        final prefCatId = item['preference_category_id'];

        if (procesedCategories.keys.contains(prefCatId)) {
          final catTemp = procesedCategories[prefCatId];

          final sql2 = '''select * from sma_preferences WHERE (id = $prefId)''';
          final t = await DBProvider.db.sqlFirstRawQuery(sql2);
          if (t != null) {
            final pref = PreferenceModel.fromJson(t);
            productPrefs[catTemp]?.add(pref);
          }
        } else {
          final sql2 =
              '''select * from sma_preferences_categories WHERE (id = $prefCatId)''';
          final t = await DBProvider.db.sqlFirstRawQuery(sql2);

          if (t != null) {
            final cat = PreferenceCategoryModel.fromJson(t);
            procesedCategories[prefCatId] = cat;
            final sql3 =
                '''select * from sma_preferences WHERE (id = $prefId)''';
            final t2 = await DBProvider.db.sqlFirstRawQuery(sql3);
            if (t2 != null) {
              final pref = PreferenceModel.fromJson(t2);
              productPrefs[cat] = [pref];
            }
          }
        }
      }
    }

    return productPrefs;
  }
}
