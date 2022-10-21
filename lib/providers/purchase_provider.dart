import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/purchases_bloc.dart';

import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/models/purchase_items_model.dart';
import 'package:pos_wappsi/models/purchase_model.dart';

// import 'package:pos_wappsi/models/sale_model.dart';
import 'package:pos_wappsi/providers/api_provider.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';
import 'package:pos_wappsi/utils/local_storage/local_db.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

import 'local_db_provider.dart';

class PurchaseProvider {
  /// Send current pos data to server, if there is any changes between local db and server,
  /// server response will contain those changes and they'll be written into local db, then
  /// reload POS data
  ///
  static Future<bool> sendPurchaseData(BuildContext context) async {
    bool result = false;
    final productsDetails = purchaseBloc.getProductDetailMapLists();
    Map<String, dynamic> purchase = purchaseBloc.getPurchase!
        .buildPurchase(dataBloc.userData!, productsDetails);

    List<Map<String, dynamic>> purchaseItems =
        PurchaseItemsModel.buildPurchaseSaleItems(
      purchaseBloc.getProducts!.keys.toList(),
      dataBloc.userData!,
      purchaseBloc.getPurchase!.date!,
    );
    // final debug = sale.toString();

    final data = {'purchase': purchase, 'purchase_items': purchaseItems};
    final api = DataProvider();

    try {
      scaffoldAlert(
        context,
        'Registrando compra...',
        const Duration(seconds: 5),
      );
      final res =
          await api.postPetition(addPurchaseEndP, data, dataBloc.getHeaders());
      hideCurrentScaffoldAlert(context);
      if (res['status'] == -1) {
        reloadDialog(
          context,
          (res['body']['error_message'] ?? res['body']['message'] ?? ''),
          'assets/images/dizzy-robot.png',
        );
      } else {
        if (res['error'] ?? true) {
          // sometimes trying to hide an un-existing scaffoldAlert
          try {
            hideCurrentScaffoldAlert(context);
          } catch (e) {
            printConsole(e);
          }

          confirmDialog(
            context,
            res['body']['message'] ?? res['message'],
            'assets/images/browser.png',
          );
        } else {
          scaffoldAlert(
            context,
            'Compra registrada',
            const Duration(seconds: 1),
          );
          // final purchaseId = res['body']['data']['purchase_sale_id'];
          // purchase['reference_no'] = res['body']['data']['reference_no'];
          // purchase['registration_date'] = res['body']['data']['server_date'];
          // purchase['id_cloud'] = purchaseId;
          // // purchaseItems['registration_date'] = res['body']['data']['server_date'];
          // final purchaseSaveR =
          //     await DBProvider.db.insertQuery('sma_purchases', purchase);
          // final purchaseItemsSaveR = await PurchaseItemsProvider.saveAllIntoDB(
          //     purchaseItems, purchaseId);

          // if (purchaseSaveR && purchaseItemsSaveR) {
          // }
          await dataBloc.syncElements(['Compras'], context);
          scaffoldAlert(
            context,
            'Compra registrada exitosamente',
            const Duration(seconds: 2),
          );
          // get purchase print data

          result = true;

          // hideCurrentScaffoldAlert(context);
        }
      }
    } catch (e) {
      // printConsole(e);
      await logError(e, from: 'Send purchase Data');
      hideCurrentScaffoldAlert(context);
      confirmDialog(context, e.toString(), 'assets/images/browser.png');
    }
    return result;
  }

  static Future<bool> validateReference(
    String reference,
    int supplierId,
  ) async {
    final dProv = DataProvider();
    final res = await dProv.postPetition(
      checkPuRefEndP,
      {'reference_no': reference, 'supplier_id': supplierId},
      dataBloc.getHeaders(),
    );
    if (res['error'] ?? true) {
      return false;
    } else {
      return res['body']?['data']?['valid_ref'] ?? false;
    }
  }

  static Future<bool> validateConsecutive(
    String consecutiveSup,
    int supplierId,
  ) async {
    final dProv = DataProvider();
    final res = await dProv.postPetition(
      checkPuSupConsEndP,
      {'consecutive_supplier': consecutiveSup, 'supplier_id': supplierId},
      dataBloc.getHeaders(),
    );
    if (res['error'] ?? true) {
      return false;
    } else {
      return res['body']?['data']?['valid_consecutive'] ?? false;
    }
  }

  static Future<List<PurchaseModel>?> listLocalPurchases({
    String search = '',
    int? limit,
    String orderBy = 'name',
    List<String>? filters,
    bool offset = false,
    int offsetValue = 1,
  }) async {
    String? filter;
    if (filters != null) {
      if (filters.isNotEmpty) {
        filter = "AND p.status IN ('" + filters.join("','") + "') ";
      }
    }
    final onlyCreatedByUser = dataBloc.userData?.viewRight == 0
        ? 'AND p.created_by=${dataBloc.userData!.id}'
        : '';

    final pagination = offset ? ' LIMIT 30 OFFSET $offsetValue' : '';
    final currentBiller = dataBloc.userData!.billerId;
    final sql = '''select * from sma_purchases p 
        WHERE (p.supplier LIKE "%$search%" OR p.note LIKE "%$search%"
        OR p.reference_no LIKE "%$search%") ${filter ?? ""}AND p.biller_id=$currentBiller $onlyCreatedByUser$pagination ORDER BY registration_date DESC;
    ''';
    final res = await DBProvider.db.sqlRawQuery(sql);
    if (res != null) {
      List<PurchaseModel> purchases = [];
      try {
        purchases = PurchaseModel.fromJsonList(res);
      } catch (e) {
        // printConsole(e);
        await logError(e, from: 'Loading purchases list');
      }
      return purchases;
    } else {
      return [];
    }
  }

  static Future<List<String>> status() async {
    const sql = '''SELECT DISTINCT status FROM sma_purchases''';
    final res = await DBProvider.db.sqlRawQuery(sql);
    List<String> status = [];
    if (res != null) {
      final temp = queryResultToMapList(res);
      try {
        for (Map element in temp) {
          status.add(element['status']);
        }
      } catch (e) {
        printConsole(e);
      }
    }
    return status;
  }
}
