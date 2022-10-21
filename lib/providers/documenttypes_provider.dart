import 'package:pos_wappsi/models/documentypes_model.dart';

import 'local_db_provider.dart';

class DocumentTypesProvider {
  static List<DocumentypeModel> fromJsonList(List<Map> list) {
    List<DocumentypeModel> documentypes = [];
    Map<String, dynamic> temp = {};
    for (var item in list) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      documentypes.add(DocumentypeModel.fromJson(temp));
    }

    return documentypes;

    // prString(temp);
  }

  static Future<DocumentypeModel?> defaultDocument() async {
    final res = await DBProvider.db.defaultDocument();
    return DocumentypeModel.fromJson(res!);
  }

  static Future<DocumentypeModel?> loadDocument(String id) async {
    final res = await DBProvider.db.loadDocument(id);
    return DocumentypeModel.fromJson(res!);
  }

  static Future<List<DocumentypeModel>> loadFromDB({String? search}) async {
    List<Map<String, dynamic>>? data = [];
    if (search == null) {
      data = await DBProvider.db.getAllDocumentypes();
    } else {
      data = await DBProvider.db.findDocument(search);
    }
    List<DocumentypeModel> list = [];
    if (data != null) {
      Map<String, dynamic> temp = {};
      for (var item in data) {
        for (var i = 0; i < item.keys.length; i++) {
          temp[item.keys.toList()[i]] = item.values.toList()[i];
        }
        list.add(DocumentypeModel.fromJson(temp));
      }
    }

    return list;
  }
}
