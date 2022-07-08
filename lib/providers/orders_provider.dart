import 'package:flutter/material.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/bloc/orders_bloc.dart';

import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/models/order_model.dart';
import 'package:pos_wappsi/models/order_sale_items.dart';

// import 'package:pos_wappsi/models/sale_model.dart';
import 'package:pos_wappsi/providers/api_provider.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';
import 'package:pos_wappsi/providers/local_orders_provider.dart';
import 'package:pos_wappsi/providers/order_sale_items_provider.dart';
import 'package:pos_wappsi/providers/sync_db_provider.dart';
import 'package:pos_wappsi/providers/zone_provider.dart';

import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

import '../config/bd_sync.dart';

class OrdersProvider {
  /// Send current pos data to server, if there is any changes between local db and server,
  /// server response will contain those changes and they'll be writen into local db, then
  /// reload POS data
  ///
  static Future<bool> sendOrderData(BuildContext context) async {
    bool result = false;
    final productsDetails = orderBloc.getProductDetailMapLists();
    Map<String, dynamic> order =
        OrderModel.buildOrder(dataBloc.userData!, productsDetails)
            .toJson(toCreateOrder: true);

    List<Map<String, dynamic>> orderItems =
        OrderSaleItemsModel.buildOderSaleItems(
            orderBloc.getProducts!.keys.toList());
    // final debug = sale.toString();

    final data = {'order_sales': order, 'order_sale_items': orderItems};
    final api = DataProvider();

    try {
      scaffoldAlert(context, 'Registrando pedido', const Duration(seconds: 5));
      final res =
          await api.postPetition(newOrderEndP, data, dataBloc.getHeaders());
      hideCurrentScaffoldAlert(context);
      if (res['status'] == -1) {
        reloadDialog(
            context,
            res['body']['error_message'] ?? res['body']['message'],
            'assets/images/dizzy-robot.png');
      } else {
        if (res['error'] ?? true) {
          if (res['body']?['data'] != [] &&
              res['body']?['data'] != null &&
              (res['body']?['sync']??false)) {
            hideCurrentScaffoldAlert(context);
            scaffoldAlert(
                context,
                res['body']['error_message'] ?? res['body']['message'],
                const Duration(seconds: 2));
          } else {
            confirmDialog(context, res['body']['message'] ?? res['message'],
                'assets/images/warning.png');
          }
        } else {
          scaffoldAlert(context, 'Pedido creado', const Duration(seconds: 1));
          final orderId = res['body']['data']['order_sale_id'];
          order['reference_no'] = res['body']['data']['reference_no'];
          order['registration_date'] = res['body']['data']['server_date'];
          order['id_cloud'] = orderId;
          order['delivery_text'] =
              orderBloc.getDeliveryTime?.getDelvTimeText(context);
          // orderItems['registration_date'] = res['body']['data']['server_date'];
          final orderSaveR =
              await DBProvider.db.insertQuery('sma_order_sales', order);
          final orderItemsSaveR = await OrderSaleItemsProvider.saveAllIntoDB(
            orderItems,
            orderId,
            res['body']['data']['server_date'] ?? '',
          );

          if (orderSaveR && orderItemsSaveR) {
            scaffoldAlert(context, 'Pedido creado exitosamente',
                const Duration(seconds: 2));
          }
          // get Order print data
          final printData = await _buildPrintDataMap(order);

          orderBloc.setPrintData(printData);

          result = true;

          // hideCurrentScaffoldAlert(context);
        }
      }
    } catch (e) {
      // printConsole(e);
      await logError(e, from: 'Send Order Data');
      hideCurrentScaffoldAlert(context);
      confirmDialog(context, e.toString(), 'assets/images/browser.png');
    }
    return result;
  }

  static Future<Map> _buildPrintDataMap(Map order) async {
    final settings = (await DBProvider.db.getSettings())!;
    final docDetails = await DBProvider.db
        .getDocumentDetails(order['document_type_id'].toString());
    final temp = removeRareSpaceChr(docDetails?['invoice_footer'] ?? '');
    return {
      "products": await orderBloc.getProductsListMap(),
      "customer": orderBloc.getCustomer!.toJson(),
      "customer_address": orderBloc.getCustomerAddresses!.toJson(),
      "zone_szone_data": await ZonesProvider.getZoneSzoneDataJson(
          zoneId: orderBloc.getCustomerAddresses?.location,
          subzoneId: orderBloc.getCustomerAddresses?.subzone
      ),
      "order_data": order,
      "pos_note": orderBloc.getOrderNote ?? '',
      "total": order['total'],
      "total_discount": order['total_discount'],
      "grand_total": order['grand_total'],
      "iva": orderBloc.getIVAs(),
      "company_data": dataBloc.getBillerCompany,
      "biller_data": dataBloc.getBIllerData,
      "settings": settings,
      "footer": temp
    };
  }

  /// get new orders from server
  static Future<bool> getOrdersFromServer(BuildContext context,
      {String search = "", List<String>? filters, int limit = 30}) async {
    try {
      final localIds =
          await LocalOrdersProvider.ordersIds(search: search, filters: filters);
      // final currentBiller = dataBloc.userData!.billerId;

      final res = await DataProvider().postPetition(
          searchOrdersEndP,
          {
            "query": search,
            "status_filter": filters,
            "limit": limit,
            "local_orders": localIds,
            "biller_id": dataBloc.userData?.billerId
          },
          dataBloc.getHeaders());
      if (res['status'] == -1) {
        reloadDialog(
            context,
            res['body']['error_message'] ?? res['body']['message'],
            'assets/images/dizzy-robot.png');
      } else if (!(res['error'] ?? true)) {
        final syncOptionName = tableNamesToSyncOpt['sma_order_sales']!;
        // here this if condition is innesesary 'cause order_sales are specialSync
        // if (specialSync.contains("Ordenes de pedido")) {
        // final Map data = res['body']?['data']??{};
        if (res['body']?['data'].isNotEmpty ?? false) {
          return await SyncDBProvider.addNewDataOnSpecialOption(
              syncOptionName, res);
        }
        //  }
      }
    } catch (e) {
      logError(e, from: "Finding orders froms server");
    }

    return false;
  }
}
