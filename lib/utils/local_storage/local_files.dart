import 'dart:io' as io;

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

// function to save files into local storage form a url in a desired folder
initSavetoPath(String file, String folder, String url) async {
  //read and write
  // image max 300px X 300px
  String pathImage = '';
  final filename = file;
  String imgURL = url;
  //if img is png convert to png
  String dir;
  if (dataBloc.dirPath == null) {
    dir = (await getApplicationDocumentsDirectory()).path;
    dataBloc.setDirPath(dir);
  } else {
    dir = dataBloc.dirPath!;
  }

  if (!(await io.File('$dir/$folder').exists())) {
    await io.Directory('$dir/$folder').create(recursive: true);
    // printConsole(directory.path);
  }
  if (!(await io.File('$dir/$folder/$filename').exists())) {
    try {
      var bytes = await NetworkAssetBundle(Uri.parse(imgURL)).load("");
      writeToFile(bytes, '$dir/$folder/$filename');
    } catch (e) {
      printConsole(e);
    }

    pathImage = '$dir/$folder/$filename';
  } else {
    pathImage = '$dir/$folder/$filename';
  }
  return pathImage;
}

Future<void> writeToFile(ByteData data, String path) async{
  final buffer = data.buffer;
  try {
    await io.File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  } catch (e) {
    printConsole(e);
    // return null;
  }
}
