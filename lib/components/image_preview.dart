import 'dart:io';

import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/constant.dart';
// import 'package:pos_wappsi/components/image_file.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview(
      {Key? key,
      required this.imagePath,
      this.isAssetImage = false,
      this.isFileImage = true,
      this.isNetworkImage = false})
      : super(key: key);
  final String imagePath;
  final bool isAssetImage;
  final bool isFileImage;
  final bool isNetworkImage;
  @override
  Widget build(BuildContext context) {
    dynamic imgProvider;
    if (isFileImage) {
      imgProvider = FileImage(File(imagePath));
    } else if (isAssetImage) {
      imgProvider = AssetImage(imagePath);
    } else if (isNetworkImage) {
      imgProvider = NetworkImage(imagePath);
    }
    return Scaffold(
      appBar: appBar(context, 'Ver Imagen', image: 'assets/images/gallery.png'),
      body: PhotoView(
        backgroundDecoration: BoxDecoration(color: greyLight),
        imageProvider: imgProvider,
      ).paddingAll(16),
    );
  }
}
