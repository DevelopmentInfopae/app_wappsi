import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/pos_bloc.dart';
import 'package:pos_wappsi/config/bd_sync.dart';
import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/models/local_sales_model.dart';
import 'package:pos_wappsi/models/sale_model.dart';
import 'package:pos_wappsi/providers/api_provider.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/local_sale_items_provider.dart';
import 'package:pos_wappsi/providers/payment_provider.dart';
import 'package:pos_wappsi/providers/sync_db_provider.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

class SalesProvider {
  /// Send current pos data to server, if there is any changes between local db and server,
  /// server response will contain those changes and they'll be writen into local db, then
  /// reload POS data
  ///
  static Future<bool> sendPosData(BuildContext context) async {
    bool result = false;
    final productsDetails = posBloc.getProductDetailMapLists();
    final sale =
        SaleModel.buildSale(dataBloc.userData!, productsDetails).toJson();
    // final debug = sale.toString();
    final api = DataProvider();

    try {
      final res =
          await api.postPetition(newSaleEndP, sale, dataBloc.getHeaders());
      if (res['status'] == -1) {
        reloadDialog(
            context,
            res['body']['error_message'] ?? res['body']['message'],
            'assets/images/dizzy-robot.png');
      } else {
        hideCurrentScaffoldAlert(context);
        // try {
        // scaffoldAlert(
        //     context,
        //     res['body']['message'] ??
        //         res['message'] ??
        //         'Error al registrar la venta',
        //     const Duration(seconds: 2),
        //     backGroundColor: Colors.red);
        // } catch (e) {
        //   confirmDialog(context, res['body']['message'] ?? res['message'],
        //       'assets/images/browser.png');
        // }
        if (res['error'] ?? true) {
          if (res['body']['data'] != [] &&
              res['body']['data'] != null &&
              res['body']['sync']) {
            scaffoldAlert(context, 'Recargando datos de venta POS',
                const Duration(seconds: 2),
                backGroundColor: Colors.red);

            final Map<String, dynamic> changes = res['body']['data'];
            // to show changes in costumer or products
            // String chText = _getChangesString(changes);
            await Future.forEach(changes.keys.toList(), (String key) async {
              // here update tables who are suposed to be not updated
              if (changes[key]) {
                final syncDB = SyncDBProvider();
                await syncDB.syncOption(context, tableNamesToSyncOpt[key]!);
              }
            });
            final reload = await posBloc.reloadPOSData();

            if (!reload) {
              hideCurrentScaffoldAlert(context);
              scaffoldAlert(context, 'Error al recargar datos de venta POS',
                  const Duration(seconds: 2),
                  backGroundColor: Colors.red);
            } else {
              hideCurrentScaffoldAlert(context);

              Navigator.pop(context);

              scaffoldAlert(context, 'Datos de venta POS recargados',
                  const Duration(seconds: 2));
            }
          } else {
            scaffoldAlert(
                context,
                res['body']['message'] ??
                    res['message'] ??
                    'Error al registrar la venta',
                const Duration(seconds: 2),
                backGroundColor: Colors.red);
          }
        } else {
          try {
            //Load data into SalesModel instance to work with it
            final printData = await _buildPrintDataMap(res['body']);
            final salesModel = SalesModel.fromPosBloc(
              productsDetails,
              salePrintData: res['body'],
            );
            // Save sale data into local DB
            final saleId = await salesModel.saveSaleData();

            // Verify if sale was saved successfully
            if (saleId != null) {
              // Save sale items into dbUpdated
              final saleItemsStatus = await SaleItemsProvider.saveAllIntoDB(
                  productsDetails['product_detail_list'], saleId);

              final paymentsStatus =
                  await PaymentProvider.saveAllIntoDB(saleId);
              // Verify if sale items were saved successfully
              if (saleItemsStatus && paymentsStatus) {
                posBloc.setPrintData(printData);
                scaffoldAlert(
                    context, 'Venta creada', const Duration(seconds: 1));
                result = true;
              }
            }
          } catch (e) {
            await logError(e, from: 'Writing sale data from local info');

            hideCurrentScaffoldAlert(context);
            confirmDialog(context, e.toString(), 'assets/images/browser.png');
          }
          hideCurrentScaffoldAlert(context);
        }
      }
    } catch (e) {
      // printConsole(e);
      await logError(e, from: 'Sending sale data');

      hideCurrentScaffoldAlert(context);
      confirmDialog(context, e.toString(), 'assets/images/browser.png');
    }
    return result;
  }

  static Future<Map> _buildPrintDataMap(Map saleData) async {
    final settings = (await DBProvider.db.getSettings())!;
    final docDetails = await DBProvider.db
        .getDocumentDetails(dataBloc.userData!.documentTypeId.toString());
    final temp = removeRareSpaceChr(docDetails?['invoice_footer'] ?? '');
    return {
      "products": await posBloc.getProductsListMap(),
      "customer": posBloc.getCustomer!.toJson(),
      "customer_address": posBloc.getCustomerAddresses!.toJson(),
      "payment_method": posBloc.getPaymentMethod!.toJson(),
      "sale_data": saleData,
      "pos_note": posBloc.getInvoiceNote ?? '',
      "payment": posBloc.getPaymentValue!.toDouble(),
      "total": posBloc.getSubTotal(),
      "iva": posBloc.getIVAs(),
      "company_data": dataBloc.getBillerCompany,
      "biller_data": dataBloc.getBIllerData,
      "settings": settings,
      "footer": temp
    };
  }
}
