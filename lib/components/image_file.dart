import 'dart:io';

import 'package:flutter/material.dart';

Widget imageFile(String pathImage, {BoxFit? fit}) {
  // final imgURL = dataBloc.userData!.hostUrl +
  //     dataBloc.userData!.companyFolder +
  //     '/assets/uploads/logos/' +
  //     posPrintData['company_data'].logo;
  return FadeInImage(
      placeholder: const AssetImage('assets/images/no_image.png'),
      fit: fit,
      image: FileImage(File(pathImage)));
  // return Image.file(File(pathImage));
}
