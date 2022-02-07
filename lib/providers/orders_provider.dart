import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/orders_bloc.dart';

import 'package:pos_wappsi/config/endpoints.dart';

import 'package:pos_wappsi/models/sale_model.dart';
import 'package:pos_wappsi/providers/api_provider.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';

import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

class OrdersProvider {
  /// Send current pos data to server, if there is any changes between local db and server,
  /// server response will contain those changes and they'll be writen into local db, then
  /// reload POS data
  ///
  static Future<bool> sendOrderData(BuildContext context) async {
    bool result = false;
    final productsDetails = orderBloc.getProductDetailMapLists();
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
        if (res['error'] ?? true) {
          if (res['body']['data'] != [] &&
              res['body']['data'] != null &&
              res['body']['sync']) {
            hideCurrentScaffoldAlert(context);
            scaffoldAlert(
                context,
                res['body']['error_message'] ?? res['body']['message'],
                const Duration(seconds: 2));
            final Map<String, dynamic> changes = res['body']['data'];
            // to show changes in costumer or products
            // String chText = _getChangesString(changes);
            await Future.forEach(changes.keys.toList(), (String key) async {
              // ignore: unnecessary_null_comparison
              if (key != null) {
                await DBProvider.db
                    .insertOrUpdateQuerys(key.toString(), changes[key] ?? []);
              }
            });
            final reload = await orderBloc.reloadPOSData();

            if (!reload) {
              confirmDialog(context, 'Error al recargar datos de venta POS',
                  'assets/images/browser.png');
            } else {
              hideCurrentScaffoldAlert(context);

              Navigator.pop(context);
              confirmDialog(context, 'Datos de venta POS recargados',
                  'assets/images/success.png');
            }
          } else {
            confirmDialog(context, res['body']['message'] ?? res['message'],
                'assets/images/browser.png');
          }
        } else {
          try {
            //Load data into SalesModel instance to work with it
            // final printData = await _buildPrintDataMap(res['body']);
            // final salesModel = SalesModel.fromorderBloc(
            //   productsDetails,
            //   salePrintData: res['body'],
            // );
            // Save sale data into local DB
            // final saleId = await salesModel.saveSaleData();

            // // Verify if sale was saved successfully
            // if (saleId != null) {
            // Save sale items into dbUpdated
            // final saleItemsStatus = await SaleItemsProvider.saveAllIntoDB(
            //     productsDetails['product_detail_list'], saleId);

            // final paymentsStatus =
            //     await PaymentProvider.saveAllIntoDB(saleId);
            // // Verify if sale items were saved successfully
            // if (saleItemsStatus && paymentsStatus) {
            //   orderBloc.setPrintData(printData);
            scaffoldAlert(context, 'Venta creada', const Duration(seconds: 1));
            result = true;
            // }
            // }
          } catch (e) {
            hideCurrentScaffoldAlert(context);
            confirmDialog(context, e.toString(), 'assets/images/browser.png');
          }
          hideCurrentScaffoldAlert(context);
        }
      }
    } catch (e) {
      printConsole(e);
      hideCurrentScaffoldAlert(context);
      confirmDialog(context, e.toString(), 'assets/images/browser.png');
    }
    return result;
  }

  // static Future<Map> _buildPrintDataMap(Map saleData) async {
  //   final settings = (await DBProvider.db.getSettings())!;
  //   final docDetails = await DBProvider.db
  //       .getDocumentDetails(dataBloc.userData!.documentTypeId.toString());
  //   final temp = removeRareSpaceChr(docDetails?['invoice_footer'] ?? '');
  //   return {
  //     "products": orderBloc.getProductsListMap(),
  //     "customer": orderBloc.getCustomer!.toJson(),
  //     "customer_address": orderBloc.getCustomerAddresses!.toJson(),
  //     "payment_method": orderBloc.getPaymentMethod!.toJson(),
  //     "sale_data": saleData,
  //     "pos_note": orderBloc.getOrderNote ?? '',
  //     "total": orderBloc.getSubTotal(),
  //     "iva": orderBloc.getIVAs(),
  //     "company_data": dataBloc.getBillerCompany,
  //     "biller_data": dataBloc.getBIllerData,
  //     "settings": settings,
  //     "footer": temp
  //   };
  // }
}
