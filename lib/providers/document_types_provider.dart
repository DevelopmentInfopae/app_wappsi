import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/config/documents_types.dart';
import 'package:pos_wappsi/models/documents_types_model.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';

class DocumentsTypesProvider {
  static Future<List<DocumentsTypes>> loadFromDB(
      {String? search, String? module}) async {
    List<Map<String, dynamic>>? data = [];
    if (search == null || search == '') {
      data = await allDocumentsTypes(dataBloc.userData!.billerId.toString(),
          module: module ?? posDocModule);
    } else {
      data = await findDocumentsTypes(
          dataBloc.userData!.billerId.toString(), search,
          module: module ?? posDocModule);
    }
    List<DocumentsTypes> list = [];
    if (data != null) {
      Map<String, dynamic> temp = {};
      data.forEach((item) {
        for (var i = 0; i < item.keys.length; i++) {
          temp[item.keys.toList()[i]] = item.values.toList()[i];
        }
        list.add(DocumentsTypes.fromJson(temp));
      });
    }

    return list;
  }

  static Future<DocumentsTypes?> loadPayDoc(String idDoc) async {
    Map<String, dynamic>? data = await findDocumentsTypesById(idDoc);

    if (data != null) {
      return DocumentsTypes.fromJson(data);
    } else {
      return null;
    }
  }

  //____________________________________________________________________________
  //
  //                DOCUMENTS TYPES AND BILLER DOCUMENTS TYPES
  //____________________________________________________________________________

  /// Return all rows in sma_cities
  static Future<List<Map<String, dynamic>>?> allDocumentsTypes(String billerId,
      {String module = '19'}) async {
    return await DBProvider.db.sqlRawQuery(
        '''select * from sma_documents_types dt INNER JOIN sma_biller_documents_types bdt 
    ON dt.id_cloud = bdt.document_type_id AND bdt.biller_id = $billerId WHERE dt.module= $module ''');
  }

  static Future<List<Map<String, dynamic>>?> findDocumentsTypes(
      String billerId, String searchs,
      {String module = '19'}) async {
    return await DBProvider.db.sqlRawQuery(
        '''select * from sma_documents_types dt INNER JOIN sma_biller_documents_types bdt 
    ON dt.id_cloud = bdt.document_type_id AND bdt.biller_id = $billerId WHERE dt.module= '$module' AND dt.nombre LIKE "%$searchs%"''');
  }

  static Future<Map<String, dynamic>?> findDocumentsTypesById(String id) async {
    return await DBProvider.db
        .sqlFirstQuery('sma_documents_types', where: "id_cloud='$id'");
  }
}
