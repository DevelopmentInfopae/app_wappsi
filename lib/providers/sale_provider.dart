import 'dart:convert';

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
import 'package:pos_wappsi/utils/conection/connectivity_functions.dart';
import '../utils/sale_functions/sale_local_format.dart';

class SalesProvider {
  /// Send current pos data to server, if there is any changes between local db and server,
  /// server response will contain those changes and they'll be written into local db, then
  /// reload POS data
  ///
  static Future<bool> sendPosData(BuildContext context) async {
    bool result = false;
    final productsDetails = posBloc.getProductDetailMapLists();
    final documentTypeId = posBloc.getDocumentTypeId(dataBloc.userData!);
    final docDetails =
        await DBProvider.db.getDocumentDetails(documentTypeId.toString());

    // Now, buildSale includes mobile_reference_no because it must be sent to the server when working offline.
    final sale =
        SaleModel.buildSale(dataBloc.userData!, productsDetails, docDetails!)
            .toJson();

    // debugPrint(const JsonEncoder.withIndent('  ').convert(sale),
    //     wrapWidth: 1024);
    // return false;

    final api = DataProvider();
    final bool hasInternet = await ConnectionHelper.hasInternetConnection();
    if (!hasInternet) {
      // <- No tiene internet
      try {
        final res = await formatedSale(
          sale,
        ); // <- Retorna el mismo formato que retorna el api
        // debugPrint(const JsonEncoder.withIndent('  ').convert(res),
        //     wrapWidth: 1024);
        // return false;
        final printData = await _buildPrintDataMap(res['body']);
        final salesModel = SalesModel.fromPosBloc(
          productsDetails,
          salePrintData: res['body'],
        );

        final saleId = await salesModel.saveSaleData(); // <- Guarda localmente

        if (saleId != null) {
          // Verify if sale was saved successfully
          final saleItemsStatus = await SaleItemsProvider.saveAllIntoDB(
            // Save sale items into dbUpdated
            productsDetails['product_detail_list'],
            saleId,
          );

          final paymentsStatus = await PaymentProvider.saveAllIntoDB(saleId);
          if (saleItemsStatus && paymentsStatus) {
            // Verify if sale items were saved successfully
            await dataBloc
                .incrementSalesConsecutive(sale['document_type_id'].toString());
            posBloc.setPrintData(printData);
            posBloc.setDocumentType(true);
            scaffoldAlert(
              context,
              'Venta creada',
              const Duration(seconds: 1),
            );
            result = true;
          }
        }
      } catch (e) {
        await logError(e, from: 'Writing sale data from local info');
        hideCurrentScaffoldAlert(context);
        confirmDialog(context, e.toString(), 'assets/images/browser.png');
      }
      hideCurrentScaffoldAlert(context);
      return result;
    }

    try {
      final res =
          await api.postPetition(newSaleEndP, sale, dataBloc.getHeaders());
      if (res['status'] == -1) {
        reloadDialog(
          context,
          res['body']['error_message'] ?? res['body']['message'],
          'assets/images/dizzy-robot.png',
        );
      } else {
        hideCurrentScaffoldAlert(context);

        if (res['error'] ?? true) {
          if (res['body']['data'] != [] &&
              res['body']['data'] != null &&
              res['body']['sync'] != null) {
            scaffoldAlert(
              context,
              'Se encontraron cambios en los detalles de la venta.',
              const Duration(seconds: 2),
              backGroundColor: Colors.red,
            );

            await logError(res, from: 'Sale creation');
            final Map<String, dynamic> changes = res['body']['data'];
            // to show changes in costumer or products
            // String chText = _getChangesString(changes);
            await Future.forEach(changes.keys.toList(), (String key) async {
              // here update tables who are supposed to be not updated
              if (changes[key]) {
                await SyncDBProvider.syncOption(tableNamesToSyncOpt[key]!);
              }
            });
            final reload = await posBloc.reloadPOSData(context);
            await Future.delayed(const Duration(seconds: 1));
            if (!reload) {
              hideCurrentScaffoldAlert(context);
              scaffoldAlert(
                context,
                'Error al recargar datos de venta POS',
                const Duration(seconds: 2),
                backGroundColor: Colors.red,
              );
              await Future.delayed(const Duration(seconds: 1));
            } else {
              hideCurrentScaffoldAlert(context);

              Navigator.pop(context);

              scaffoldAlert(
                context,
                'Datos de venta POS recargados',
                const Duration(seconds: 2),
              );
            }
          } else {
            scaffoldAlert(
              context,
              res['body']['message'] ??
                  res['message'] ??
                  'Error al registrar la venta',
              const Duration(seconds: 2),
              backGroundColor: Colors.red,
            );
          }
        } else {
          try {
            //Load data into SalesModel instance to work with it
            // res['body']['date'] = res['current_server_date'];
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
                productsDetails['product_detail_list'],
                saleId,
              );

              final paymentsStatus =
                  await PaymentProvider.saveAllIntoDB(saleId);
              // Verify if sale items were saved successfully
              if (saleItemsStatus && paymentsStatus) {
                await dataBloc.incrementSalesConsecutive(
                    sale['document_type_id'].toString());
                posBloc.setPrintData(printData);
                posBloc.setDocumentType(true);
                scaffoldAlert(
                  context,
                  'Venta creada',
                  const Duration(seconds: 1),
                );
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
      'products': await posBloc.getProductsListMap(),
      'customer': posBloc.getCustomer!.toJson(),
      'customer_address': posBloc.getCustomerAddresses!.toJson(),
      'payment_method': posBloc.getPaymentMethod!.toJson(),
      'sale_data': saleData,
      'pos_note': posBloc.getInvoiceNote ?? '',
      'payment': posBloc.getPaymentValue!.toDouble(),
      'total': posBloc.getSubTotal(),
      'iva': posBloc.getIVAs(),
      'company_data': dataBloc.getBillerCompany,
      'biller_data': dataBloc.getBIllerData,
      'settings': settings,
      'footer': temp,
    };
  }
}
