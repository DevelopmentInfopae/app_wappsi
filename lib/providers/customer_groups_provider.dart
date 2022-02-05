import 'package:pos_wappsi/models/customer_groups_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';

class CustomerGroupsProvider {
  /// Load country given a country id
  static Future<CustomerGroupsModel?> loadCustomerGroup(String id) async {
    final res = await loadCustomerGroupFromDB(id);
    if (res == null) {
      return null;
    } else {
      return CustomerGroupsModel.fromJson(res);
    }
  }

  static Future<List<CustomerGroupsModel>> loadFromDB({String? search}) async {
    List<Map<String, dynamic>>? data = [];
    if (search == null || search == '') {
      data = await allCustomerGroups();
    } else {
      data = await findCustomerGroup(search);
    }
    List<CustomerGroupsModel> list = [];
    if (data != null) {
      Map<String, dynamic> temp = {};
      for (var item in data) {
        for (var i = 0; i < item.keys.length; i++) {
          temp[item.keys.toList()[i]] = item.values.toList()[i];
        }
        list.add(CustomerGroupsModel.fromJson(temp));
      }
    }

    return list;
  }

  /// Return all rows in sma_customer_groups
  static Future<List<Map<String, dynamic>>?> allCustomerGroups() async {
    return await DBProvider.db.sqlQuery('sma_customer_groups');
  }

  /// Return sma_customer_groups row of a given id
  static Future<Map<String, dynamic>?> loadCustomerGroupFromDB(
      String id) async {
    return await DBProvider.db
        .sqlFirstQuery('sma_customer_groups', where: 'id_cloud = $id');
  }

  /// Return a list with customer_groups data wich fields name or percent LIKE
  /// param searchs
  static Future<List<Map<String, dynamic>>?> findCustomerGroup(
      String searchs) async {
    return await DBProvider.db.sqlQuery('sma_customer_groups',
        where: "name LIKE '%$searchs%' OR percent LIKE '%$searchs%'",
        limit: 20);
  }
}
