import 'package:flutter/widgets.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/models/delivery_time_model.dart';
import 'package:pos_wappsi/providers/api_provider.dart';
import 'package:pos_wappsi/utils/alerts.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';

class DeliveryTimeProvider {
  static Future<List<DeliveryTime>> getAvailableDeliveryTimes(
    BuildContext context,
    String date,
    int? addressLocation,
  ) async {
    List<DeliveryTime> deliveryTimes = [];

    // instance of api provider
    final apiProvider = DataProvider();

    final res = await apiProvider.postPetition(
      availableDelTimeEndP,
      {'date': date, 'location': addressLocation},
      dataBloc.getHeaders(),
    );
    if (res['status'] == -1) {
      reloadDialog(
        context,
        res['body']['error_message'] ?? res['body']['message'],
        'assets/images/dizzy-robot.png',
      );
    } else {
      if (res['error'] ?? true) {
        confirmDialog(
          context,
          res['body']['message'] ?? res['message'],
          'assets/images/browser.png',
        );
        await logError(res);
      } else {
        deliveryTimes = DeliveryTime.fromJsonList(
          res['body']?['data']?['avaiable_delivery_times'] ?? [{}],
        );
      }
    }

    return deliveryTimes;
  }
}
