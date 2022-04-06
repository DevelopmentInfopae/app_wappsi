import 'package:flutter/material.dart';
import 'package:pos_wappsi/constant.dart';

String mapStatusText(String status) {
  String mappedStatus = '';
  //pending = pendiente, partial = parcial, completed = facturado, enlistment = alistamiento, sent = enviado, delivered = entregado
  if (status == 'pending') {
    mappedStatus = 'Pendiente';
  } else if (status == 'received') {
    mappedStatus = 'Recivido';
  } else if (status == 'partial') {
    mappedStatus = 'Parcial';
  } else if (status == 'completed') {
    mappedStatus = 'Facturado';
  } else if (status == 'enlistment') {
    mappedStatus = 'Alistamiento';
  } else if (status == 'sent') {
    mappedStatus = 'Enviado';
  } else if (status == 'delivered') {
    mappedStatus = 'Entregado';
  }
  return mappedStatus;
}

Map<String, Color> mapStatusColor(String status) {
  Map<String, Color> mappedStatusColor = {};
  //pending = pendiente, partial = parcial, completed = facturado, enlistment = alistamiento, sent = enviado, delivered = entregado
  if (status == 'pending') {
    mappedStatusColor = {
      'background': const Color.fromRGBO(248, 171, 91, 1),
      'text': Colors.white
    };
  } else if (status == 'received') {
    mappedStatusColor = {
      'background': const Color.fromRGBO(29, 132, 199, 1),
      'text': Colors.white
    };
  } else if (status == 'partial') {
    mappedStatusColor = {
      'background': const Color.fromRGBO(34, 198, 200, 1),
      'text': Colors.white
    };
  } else if (status == 'completed') {
    mappedStatusColor = {
      'background': const Color.fromRGBO(29, 132, 199, 1),
      'text': Colors.white
    };
  } else if (status == 'enlistment') {
    mappedStatusColor = {
      'background': const Color.fromRGBO(34, 204, 203, 1),
      'text': Colors.white
    };
  } else if (status == 'sent') {
    mappedStatusColor = {
      'background': const Color.fromRGBO(207, 218, 224, 1),
      'text': greyColor
    };
  } else if (status == 'delivered') {
    mappedStatusColor = {
      'background': const Color.fromRGBO(37, 170, 143, 1),
      'text': Colors.white
    };
  }
  return mappedStatusColor;
}
