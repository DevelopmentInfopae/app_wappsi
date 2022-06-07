// import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:pos_wappsi/bloc/printer_bloc.dart';
import 'package:pos_wappsi/config/bd_creation.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  // ignore: avoid_init_to_null
  static Database? _database = null;

  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database?> get database async {
    // ignore: unnecessary_null_comparison
    _database ??= await initDB();
    return _database;
  }

  //______________________________________________________________________________________________________________
  //
  //                                INIT DB AND CREATE TABLES IF NOT CREATED BEFORE
  //_______________________________________________________________________________________________________________

  Future<Database> initDB() async {
    // Path where DB will be stored
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    final path = join(documentsDirectory.path, 'SmaDB.db');
    // printConsole(path);

    // creation of db
    return await openDatabase(path, version: 9, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      // table creation

      await db.execute(DbProductsSql);
      await db.execute(DbProductsPriceSql);
      await db.execute(DbProductPhotosSql);
      await db.execute(DbProductPreferencesSql);
      await db.execute(DbPreferencesSql);
      await db.execute(DbPreferencesCategoriresSql);
      await db.execute(DbProductVariantsSql);
      await db.execute(DbCompaniesSql);
      await db.execute(DbBillerDataSql);
      await db.execute(DbCustomerGroupsSql);
      await db.execute(DbAddressesSql);
      await db.execute(DbUpdatesSql);
      await db.execute(DbPriceGroupsSql);
      await db.execute(DbSettingsSql);
      await db.execute(WarehouseProductsSql);
      await db.execute(BrandsSql);
      await db.execute(DbTaxRatesSql);
      await db.execute(PaymentMethodsSql);
      await db.execute(DbPosSettingsSql);
      await db.execute(DocumenTypesSql);
      await db.execute(CountriesSql);
      await db.execute(StatesSql);
      await db.execute(CitysSql);
      await db.execute(DocumentTypesSql);
      await db.execute(PCategoriesSql);
      await db.execute(PUnitsSql);
      await db.execute(UnitPricesSql);
      await db.execute(WarehousesSql);
      await db.execute(BillerDocumentTypesSql);
      //favorite products
      await db.execute(FavotitesSql);
      await db.execute(GroupsSql);
      await db.execute(SuspendedSalesSql);
      await db.execute(SuspendedSaleProductsSql);
      // Create tables to save sales locally
      await db.execute(SalesSql);
      await db.execute(SaleItemsSql);
      await db.execute(PaymentSql);

      // orders tables
      await db.execute(OrderSaleItemsSql);
      await db.execute(OrderSalesSql);
      // quotes tables
      await db.execute(PurchasesSql);
      await db.execute(QuotesTableSql);
      await db.execute(QuoteItemsTableSql);
      await db.execute(PurchaseItemsSql);

      ///Errors log
      await db.execute(ErrorsDataSql);

      // index creation
      Batch batch = db.batch();

      for (var element in indexCreation) {
        batch.execute(element);
      }
      try {
        batch.commit();
      } catch (e) {
        printConsole(e);
      }

      // ids sync creation

      batch = db.batch();

      for (var element in syncIds) {
        batch.execute(element);
      }
      try {
        batch.commit();
      } catch (e) {
        printConsole(e);
      }
    });
  }

  ///-----------------------------------------------------------------------------
  ///                                UPDATE QUERYS
  ///              With '' as field separator in query used with json
  ///                        fields in db with "" inside
  ///
  ///-----------------------------------------------------------------------------
  Future<bool> insertOrUpdateQuerys(String table, List query,
      {bool printSql = false}) async {
    final db = await database;
    bool result = true;
    Batch batch = db!.batch();
    for (var element in query) {
      try {
        batch.insert(table, element,
            conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (e) {
        printConsole(e);
        if (element is List) {
          if (element.isNotEmpty) {
            result =
                await insertOrUpdateQuerys(table, element, printSql: false);
          }
          // values = getStringFromValues(element);
        }
      }

      // printConsole(sql);
    }

    try {
      await batch.commit();
      // disable ientity writing
      // await db.execute('SET IDENTITY_INSERT $table ON');
      // debugprintConsole(res.toString());
      return result;
    } catch (e) {
      return await insertOrUpdateQuerys2(table, query);
    }
  }

  ///-----------------------------------------------------------------------------
  ///                                UPDATE QUERYS
  ///              With '' as field separator in query used with json
  ///                        fields in db with "" inside
  ///
  ///-----------------------------------------------------------------------------
  Future<bool> deleteQuerys(String table, String where) async {
    final db = await database;
    bool result = true;

    try {
      await db!.delete(table, where: where);

      // disable ientity writing
      // await db.execute('SET IDENTITY_INSERT $table ON');
      // debugprintConsole(res.toString());
      return result;
    } catch (e) {
      // printConsole(e);
      await printAndSaveError(e);
      return false;
    }
  }

  ///-----------------------------------------------------------------------------
  ///                                UPDATE QUERYS
  ///                    With "" as field separator in query and
  ///               replacing all ' in string to selecte replacment
  ///-----------------------------------------------------------------------------
  Future<bool> insertOrUpdateQuerys2(String table, List query,
      {String replace = '^'}) async {
    final db = await database;
    // final enc = jsonEncode(query);
    // final queryF = jsonDecode(enc.replaceAll("'", replace));
    // Batch batch = db!.batch();
    for (var element in query) {
      try {
        await db!.insert(table, element,
            conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (e) {
        await printAndSaveError(e);

        try {
          String values = getStringFromValues(element.values);
          String sql =
              'INSERT OR REPLACE INTO $table ("${element.keys.join('","')}") VALUES ($values);';
          await db!.rawQuery(sql);
        } catch (e) {
          await printAndSaveError(e);
        }
      }

      // printConsole(sql);
    }

    return true;
  }

  //______________________________________________________________________________________________________________
  //
  //                                       JSON-QUERY INSERT INTO DB
  //_______________________________________________________________________________________________________________

  Future insertQuery(String table, Map<String, dynamic> query,
      {bool returnId = false}) async {
    Database? db = await database;

    try {
      final res = await db!
          .insert(table, query, conflictAlgorithm: ConflictAlgorithm.replace);

      // id of query inserted
      return returnId ? res : true;
    } catch (e) {
      // printConsole(e);
      await printAndSaveError(e);
      return returnId ? 0 : false;
    }
  }

  //______________________________________________________________________________________________________________
  //
  //                                        LIST<JSON> QUERY INSERT

  //_______________________________________________________________________________________________________________

  Future<bool> insertQuerys(String table, List query) async {
    final db = await database;

    // enable identity writing on table
    // await db.execute('SET IDENTITY_INSERT $table ON');

    // to make insert operations in only one petition using a batch
    Batch batch = db!.batch();

    for (var element in query) {
      batch.insert(table, element);
    }
    try {
      await batch.commit();

      return true;
    } catch (e) {
      // printConsole(e);
      await printAndSaveError(e);
      return false;
    }
  }

  //-----------------------------------------------------------------------------
  //                                FIND ALL FIELDS
  //
  //-----------------------------------------------------------------------------

  Future<Map<String, dynamic>?> findTableFieldsById(
      String table, String id) async {
    final db = await database;

    try {
      final res = await db!.query(table, where: 'id_cloud = $id');
      return res.first;
    } catch (e) {
      await printAndSaveError(e);
      return null;
    }
  }

  Future<void> printAndSaveError(Object e,
      {String table = 'errors_log',
      String from = 'local db operations'}) async {
    printConsole(e.toString());
    await insertQuery(table, {'error': e.toString(), 'from': from});
  }

  Future<Map<String, dynamic>?> sqlFirstQuery(String table,
      {String? where, List<String>? columns}) async {
    final db = await database;

    try {
      final res = await db!.query(table, where: where, columns: columns);
      return res.first;
    } catch (e) {
      await printAndSaveError(e);
      return null;
    }
  }

  Future<int?> sqlUpdateQuery(
      String table, Map<String, Object?> values, String where) async {
    final db = await database;

    try {
      final res = await db!.update(table, values, where: where);
      return res;
    } catch (e) {
      await printAndSaveError(e);
      return null;
    }
  }

  /// Execute sql query using query function in a try catch statement
  Future<List<Map<String, dynamic>>?> sqlQuery(String table,
      {String? where,
      int? limit = 50,
      String? orderBy,
      int? offset,
      List<String>? columns}) async {
    final db = await database;

    try {
      final res = await db!.query(table,
          where: where,
          limit: limit,
          orderBy: orderBy,
          offset: offset,
          columns: columns);
      return res;
    } catch (e) {
      await printAndSaveError(e);
      return null;
    }
  }

  /// Execute a given raw query in a try catch
  Future<List<Map<String, dynamic>>?> sqlRawQuery(String sql) async {
    final db = await database;

    try {
      final res = await db!.rawQuery(sql);
      return res;
    } catch (e) {
      // printConsole(e);
      await printAndSaveError(e);

      return null;
    }
  }

  /// Execute a given raw query in a try catch
  Future<bool> sqlDelete(String table, String? where) async {
    final db = await database;

    try {
      await db!.delete(table, where: where);
      return true;
    } catch (e) {
      await printAndSaveError(e);

      return false;
    }
  }

  /// Execute a given raw query in a try catch and return only one first row
  Future<Map<String, dynamic>?> sqlFirstRawQuery(String sql) async {
    final db = await database;

    try {
      final res = await db!.rawQuery(sql);
      return res.first;
    } catch (e) {
      await printAndSaveError(e);

      return null;
    }
  }

  Future<List<Map>?> findTableFieldsByIds(String table, List<int> ids,
      {String column = 'id_cloud'}) async {
    final db = await database;

    try {
      final res =
          await db!.query(table, where: 'id_cloud IN (${ids.join(',')})');

      return res;
    } catch (e) {
      await printAndSaveError(e);

      return null;
    }
  }

  //-----------------------------------------------------------------------------
  //                                SETTINGS
  //
  //-----------------------------------------------------------------------------

  /// Return current settings in sma_settings table.
  Future<Map<String, dynamic>?> getSettings() async {
    return await sqlFirstQuery('sma_settings');
  }

  //-----------------------------------------------------------------------------
  //                                BILLER DATA
  //
  //-----------------------------------------------------------------------------
  /// Return all data from sma_biller_data of a given biller_id
  Future<Map<String, dynamic>?> getBillerData() async {
    return await sqlFirstQuery('sma_biller_data',
        where: 'biller_id = ${dataBloc.userData!.billerId}');
  }

  //-----------------------------------------------------------------------------
  //                                BRANDS
  //
  //-----------------------------------------------------------------------------

  /// Return all data in sma_brands of a given id
  Future<Map?> findBrand(int id) async {
    return await sqlFirstQuery('sma_brands', where: 'id_cloud = $id');
  }

  //______________________________________________________________________________________________________________
  //
  //                                       Documents types
  //_______________________________________________________________________________________________________________

  Future<Map<String, dynamic>?> getDocumentDetails(String id) async {
    return await sqlFirstQuery('sma_documents_types',
        // columns: _customerColumns,
        where: "id_cloud = $id");
  }

  //-----------------------------------------------------------------------------
  //                                DOCUMENTYPES
  //
  //-----------------------------------------------------------------------------

  // Return all rows in sma_documentypes
  Future<List<Map<String, dynamic>>?> getAllDocumentypes() async {
    return await sqlQuery('sma_documentypes', limit: null);
  }

  Future<List<Map<String, dynamic>>?> findDocument(String searchs) async {
    return await sqlQuery('sma_documentypes',
        // columns: _customerColumns,
        where:
            "nombre LIKE '%$searchs%' OR abreviacion LIKE '%$searchs%' OR codigo_doc LIKE '%$searchs%'",
        limit: 20);
  }

  Future<Map<String, dynamic>?> loadDocument(String id) async {
    return await sqlFirstQuery('sma_documentypes',
        // columns: _customerColumns,
        where: "id_cloud=$id");
  }

  Future<Map<String, dynamic>?> defaultDocument() async {
    return await sqlFirstRawQuery('''
        SELECT d.id,d.id_cloud,d.nombre,d.abreviacion,d.codigo_doc FROM sma_documentypes d INNER JOIN sma_settings s
        ON d.codigo_doc = s.tipo_documento
        ''');
  }

  // --------------------------------------------------------------------
  //                   READ AND WRITE LAST_UPDATE DATE
  // --------------------------------------------------------------------

  /// Get last_sync date of a given id
  Future<String?> getUpdateDate(int idSync) async {
    final db = await database;

    try {
      final res =
          await db!.rawQuery("SELECT last_update FROM sync WHERE id='$idSync'");

      return res.first['last_update'].toString();
    } catch (e) {
      printConsole(e);
      return null;
    }
  }

  /// Update last_sync date of a given id with a value
  Future<bool> setUpdateDate(String lastUpdate, int idSync) async {
    final db = await database;

    try {
      await db!
          .update('sync', {'last_update': lastUpdate}, where: 'id = $idSync');
      // printConsole(res);
      return true;
    } catch (e) {
      await printAndSaveError(e);

      return false;
    }

    // id of query inserted
  }
}
