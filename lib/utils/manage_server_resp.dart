import 'package:flutter/material.dart';
import 'package:pos_wappsi/utils/alerts.dart';

manageResponseAlerts(
  Map<String, dynamic> response,
  BuildContext context, {
  bool showErrorDialog = true,
}) {
  if (response['status'] == -1) {
    reloadDialog(
      context,
      response['body']['error_message'] ?? response['body']['message'],
      'assets/images/dizzy-robot.png',
    );
  } else if (showErrorDialog && response['error']) {
    confirmDialog(
      context,
      response['body']['message'] ?? '',
      'assets/images/alert.png',
    );
  }
}
