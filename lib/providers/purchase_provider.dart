import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/purchases_bloc.dart';

import 'package:pos_wappsi/config/endpoints.dart';

// import 'package:pos_wappsi/models/sale_model.dart';
import 'package:pos_wappsi/providers/api_provider.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';

class PurchaseProvider {
  /// Send current pos data to server, if there is any changes between local db and server,
  /// server response will contain those changes and they'll be writen into local db, then
  /// reload POS data
  ///
  static Future<bool> sendPurchaseData(BuildContext context) async {
    bool result = false;
    final productsDetails = purchaseBloc.getProductDetailMapLists();
    Map<String, dynamic> purchase = purchaseBloc.getPurchase!
        .buildPurchase(dataBloc.userData!, productsDetails);

    // List<Map<String, dynamic>> purchaseItems =
    //     purchaseSaleItemsModel.buildOderSaleItems(
    //         purchaseBloc.getProducts!.keys.toList());
    // final debug = sale.toString();

    final data = {'purchase_sales': purchase, 'purchase_sale_items': []};
    final api = DataProvider();

    try {
      scaffoldAlert(context, 'Registrando pedido', const Duration(seconds: 5));
      final res =
          await api.postPetition(addPurchaseEndP, data, dataBloc.getHeaders());
      hideCurrentScaffoldAlert(context);
      if (res['status'] == -1) {
        reloadDialog(
            context,
            res['body']['error_message'] ?? res['body']['message'],
            'assets/images/dizzy-robot.png');
      } else {
        if (res['error'] ?? true) {
          if (res['body']['data'] != [] &&
              res['body']['data'] != null &&
              res['body']['sync']) {
            hideCurrentScaffoldAlert(context);
            scaffoldAlert(
                context,
                res['body']['error_message'] ?? res['body']['message'],
                const Duration(seconds: 2));
          } else {
            confirmDialog(context, res['body']['message'] ?? res['message'],
                'assets/images/browser.png');
          }
        } else {
          scaffoldAlert(
              context, 'Compra registrada', const Duration(seconds: 1));
          final purchaseId = res['body']['data']['purchase_sale_id'];
          purchase['reference_no'] = res['body']['data']['reference_no'];
          purchase['registration_date'] = res['body']['data']['server_date'];
          purchase['id_cloud'] = purchaseId;
          // purchaseItems['registration_date'] = res['body']['data']['server_date'];
          // final purchaseSaveR =
          //     await DBProvider.db.insertQuery('sma_purchase_sales', purchase);
          // final purchaseItemsSaveR = await purchaseSaleItemsProvider.saveAllIntoDB(
          //   purchaseItems,
          //   purchaseId,
          //   res['body']['data']['server_date'] ?? '',
          // );

          // if (purchaseSaveR && purchaseItemsSaveR) {
          //   scaffoldAlert(
          //       context,
          //       'Pedido creado exitosamente',
          //       const Duration(seconds: 2));
          // }
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

  static Future<bool> valitateReference(
      String reference, int supplierId) async {
    final dProv = DataProvider();
    final res = await dProv.postPetition(
        checkPuRefEndP,
        {"reference_no": reference, "supplier_id": supplierId},
        dataBloc.getHeaders());
    if (res['error'] ?? true) {
      return false;
    } else {
      return res['data']['valid_ref'];
    }
  }
}
