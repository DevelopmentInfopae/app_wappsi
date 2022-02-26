import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

Widget imageFile(String? pathImage, {BoxFit? fit}) {
  // final imgURL = dataBloc.userData!.hostUrl +
  //     dataBloc.userData!.companyFolder +
  //     '/assets/uploads/logos/' +
  //     posPrintData['company_data'].logo;

  try {
    return pathImage != null
        ? Image.file(
            File(pathImage),
            fit: fit,
          )
        : Image.asset(
            'assets/images/no_image.png',
            fit: fit,
          );
  } catch (e) {
    printConsole(e);
    return Image.asset(
      'assets/images/no_image.png',
      fit: fit,
    );
  }
  // return Image.file(File(pathImage));
}
