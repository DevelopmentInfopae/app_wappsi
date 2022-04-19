import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/quotes_bloc.dart';

import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/models/quote_items_model.dart';

import 'package:pos_wappsi/models/quotes_model.dart';

// import 'package:pos_wappsi/models/sale_model.dart';
import 'package:pos_wappsi/providers/api_provider.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/quote_items_provider.dart';

import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';
import 'package:pos_wappsi/utils/print_errors.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

class QuotesProvider {
  /// Send current pos data to server, if there is any changes between local db and server,
  /// server response will contain those changes and they'll be writen into local db, then
  /// reload POS data
  ///
  static Future<bool> sendQuoteData(BuildContext context) async {
    bool result = false;
    final productsDetails = quoteBloc.getProductDetailMapLists();
    Map<String, dynamic> quote =
        QuoteModel.buildQuote(dataBloc.userData!, productsDetails)
            .toJson(toCreateQuote: true);

    List<Map<String, dynamic>> quoteItems =
        QuoteItemsModel.buildQuoteItems(quoteBloc.getProducts!.keys.toList());
    // final debug = sale.toString();

    final data = {'quote': quote, 'quote_items': quoteItems};
    final api = DataProvider();

    try {
      scaffoldAlert(
          context, 'Registrando cotización', const Duration(seconds: 5));
      final res =
          await api.postPetition(newQuoteEndP, data, dataBloc.getHeaders());
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
              context, 'Cotización creada', const Duration(seconds: 1));
          final quoteId = res['body']['data']['quote_id'];
          quote['reference_no'] = res['body']['data']['reference_no'];
          quote['date'] = res['body']['data']['server_date'];
          quote['id_cloud'] = quoteId;
          // quoteItems['date'] = res['body']['data']['server_date'];
          final quoteSaveR =
              await DBProvider.db.insertQuery('sma_quotes', quote);
          final quoteItemsSaveR =
              await QuoteItemsProvider.saveAllIntoDB(quoteItems, quoteId);

          if (quoteSaveR && quoteItemsSaveR) {
            scaffoldAlert(context, 'Cotización creada exitosamente',
                const Duration(seconds: 2));
          }
          // get quote print data
          final printData = await _buildPrintDataMap(quote);

          quoteBloc.setPrintData(printData);

          result = true;

          // hideCurrentScaffoldAlert(context);
        }
      }
    } catch (e) {
      // printConsole(e);
      await logError(e, from: 'Send quote data');
      hideCurrentScaffoldAlert(context);
      confirmDialog(context, e.toString(), 'assets/images/browser.png');
    }
    return result;
  }

  static Future<Map> _buildPrintDataMap(Map quote) async {
    final settings = (await DBProvider.db.getSettings())!;
    final docDetails = await DBProvider.db
        .getDocumentDetails(quote['document_type_id'].toString());
    final temp = removeRareSpaceChr(docDetails?['invoice_footer'] ?? '');
    return {
      "products": await quoteBloc.getProductsListMap(),
      "customer": quoteBloc.getCustomer!.toJson(),
      "customer_address": quoteBloc.getCustomerAddresses!.toJson(),
      "quote_data": quote,
      "pos_note": quoteBloc.getNote ?? '',
      "total": quote['total'],
      "total_discount": quote['total_discount'],
      "grand_total": quote['grand_total'],
      "iva": quoteBloc.getIVAs(),
      "company_data": dataBloc.getBillerCompany,
      "biller_data": dataBloc.getBIllerData,
      "settings": settings,
      "footer": temp
    };
  }

  static Future<List<QuoteModel>?> listLocalQuotes(
      {String search = '',
      int? limit,
      String orderBy = 'name',
      List<String>? filters,
      bool offset = false,
      int offsetValue = 1}) async {
    final onlyCreatedByUser = dataBloc.userData?.viewRight == 0
        ? 'AND q.created_by=${dataBloc.userData!.id}'
        : '';
    // final onlyCreatedByUser = '';

    final pagination = offset ? " LIMIT 30 OFFSET $offsetValue" : "";
    final currentBiller = dataBloc.userData!.billerId;
    final sql = '''select * from sma_quotes q 
        WHERE (q.customer LIKE "%$search%" OR q.note LIKE "%$search%" OR q.note LIKE "%$search%" 
        OR q.reference_no LIKE "%$search%") AND q.biller_id=$currentBiller $onlyCreatedByUser$pagination ORDER BY date DESC;
    ''';
    final res = await DBProvider.db.sqlRawQuery(sql);
    if (res != null) {
      List<QuoteModel> orders = [];
      try {
        orders = QuoteModel.fromJsonList(res);
      } catch (e) {
        await logError(e, from: 'Listing quotes');
        printConsole(e);
      }
      return orders;
    } else {
      return [];
    }
  }

  // static Future<List<String>> orderStatus() async {
  //   const sql = '''SELECT DISTINCT sale_status FROM sma_order_sales WHERE sale_status!="cancelled"''';
  //   final res = await DBProvider.db.sqlRawQuery(sql);
  //   List<String> status = [];
  //   if (res != null) {
  //     final temp = queryResultToMapList(res);
  //     try {
  //       for (Map element in temp) {
  //         status.add(element['sale_status']);
  //       }
  //     } catch (e) {
  //       printConsole(e);
  //     }
  //   }
  //   return status;
  // }
}
