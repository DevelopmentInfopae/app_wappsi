import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/components/image_file.dart';
import 'package:pos_wappsi/config/host_params.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/utils/local_storage/local_files.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

Widget labelContent(String label, String content,
    {bool padding = true, EdgeInsetsGeometry paddingValue = EdgeInsets.zero}) {
  return Padding(
    padding: padding
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
        : paddingValue,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            // fontSize: 13
          ),
        ),
        Text(
          capitalizeText(content),
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 17),
        )
      ],
    ),
  );
}

class DecoratedLabeledContent extends StatelessWidget {
  const DecoratedLabeledContent(
      {Key? key,
      required this.label,
      required this.content,
      this.backgroundColor,
      this.paddingValue = EdgeInsets.zero,
      this.withPadding = true})
      : super(key: key);
  final String label;
  final Color? backgroundColor;
  final String content;
  final EdgeInsetsGeometry paddingValue;
  final bool withPadding;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey[300]!,
          borderRadius: BorderRadius.circular(15)),
      child: labelContent(label, content,
          padding: true, paddingValue: paddingValue),
    );
  }
}

class FutureDecoratedLabeledContent extends StatelessWidget {
  const FutureDecoratedLabeledContent(
      {Key? key,
      required this.label,
      required this.mapKey,
      required this.function,
      this.backgroundColor})
      : super(key: key);
  final Future<Map<dynamic, dynamic>?> function;
  final String label;
  final Color? backgroundColor;
  final String mapKey;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey[300]!,
          borderRadius: BorderRadius.circular(15)),
      child: futureLabelContent(function, mapKey, label),
    );
  }
}

Widget labelContentH(String label, String content, BuildContext context,
    {withInnerPading = true,
    EdgeInsetsGeometry? padding,
    int flexCol1 = 1,
    int flexCol2 = 2}) {
  return Padding(
    padding: withInnerPading
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
        : padding!,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          textAlign: TextAlign.start,
          maxLines: flexCol1,
          overflow: TextOverflow.ellipsis,
          style: normalTextStyle(context, fontWeightDelta: 2),
        ).flexible(flex: 2),
        Text(
          content,
          textAlign: TextAlign.end,
          style: normalTextStyle(context),
        ).flexible(flex: flexCol2)
      ],
    ),
  );
}

Widget futureLabelContent(Future<Map?> function, String key, String label) {
  return FutureBuilder<Map?>(
      future: function,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return labelContent('$label ', snapshot.data![key]);
        } else {
          return labelContent('$label ', '');
        }
      });
}

Widget hDivider(
    {EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 20),
    double height = 0.5}) {
  return Padding(
    padding: padding,
    child: Container(
      width: double.infinity,
      color: Colors.black,
      height: height,
    ),
  );
}

Widget vDivider(
    {double heigh = 40,
    double width = 2,
    double pleft = 0.0,
    double prigth = 0.0,
    double ptop = 0.0,
    double pbottom = 0.0}) {
  return Container(
    padding:
        EdgeInsets.only(left: pleft, right: prigth, top: ptop, bottom: pbottom),
    height: heigh,
    width: width,
    color: Colors.black,
  );
}

Widget bottom(Widget child, Color _pc, Size _size,
    {Alignment? alignment, bool elevation = true}) {
  return Container(
      height: 64,
      width: _size.width,
      alignment: alignment,
      decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(10),
          color: _pc,
          boxShadow: elevation
              ? [
                  const BoxShadow(
                    color: Colors.grey,
                    offset: Offset(1.0, 0.0), //(x,y)
                    blurRadius: 5.0,
                  )
                ]
              : null),
      // padding: EdgeInsets.symmetric(vertical: ),

      child: child);
}

Positioned loadingIndicator(double width) {
  return Positioned(
      left: 0,
      bottom: 0,
      child: SizedBox(
        width: width,
        child: Loader(),
      ));
}

Widget customerPhoto(String img, {fit = BoxFit.contain}) {
  String url;
  if (img == '') {
    img = defaultCustomersImage;
    url = dataBloc.userData!.hostUrl +
        dataBloc.userData!.companyFolder +
        defaultImgDir +
        defaultCustomersImage;
  } else {
    url = dataBloc.userData!.hostUrl +
        dataBloc.userData!.companyFolder +
        avatarsImgDir +
        img;
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    child: FutureBuilder(
      future: initSavetoPath(img, 'images/customers', url),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return imageFile(snapshot.data, fit: fit);
        } else {
          return Image.asset(
            'assets/images/no_image.png',
            fit: fit,
          );
        }
      },
    ),
  );
}

Widget productPhoto(String img) {
  final url = dataBloc.userData!.hostUrl +
      dataBloc.userData!.companyFolder +
      imgDir +
      img;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    child: FutureBuilder(
      future: initSavetoPath(img, 'images/products', url),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return imageFile(snapshot.data);
        } else {
          return Image.asset('assets/images/no_image.png');
        }
      },
    ),
  );
}

Widget billerThumbNail(String img) {
  final url = dataBloc.userData!.hostUrl +
      dataBloc.userData!.companyFolder +
      logosImgDir +
      img;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    child: FutureBuilder(
      future: initSavetoPath(img, 'images/biller', url),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return imageFile(snapshot.data);
        } else {
          return Image.asset('assets/images/no_image.png');
        }
      },
    ),
  );
}

Widget billerImage(String image) {
  String imgURL = dataBloc.userData!.hostUrl +
      dataBloc.userData!.companyFolder +
      'assets/uploads/logos/' +
      image;

  String img = image;
  // if img is png convert to png
  if (img.substring(img.length - 4) == '.png') {
    imgURL = dataBloc.userData!.hostUrl +
        "/wappsi_apis/utils/pngToJpg?img=" +
        imgURL;
    img = img.substring(0, img.length - 4) + '.jpg';
  }
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    child: FutureBuilder(
      future: initSavetoPath(img, 'images/biller/', imgURL),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return imageFile(snapshot.data, fit: BoxFit.fitHeight);
        } else {
          return Image.asset('assets/images/wappsi.png');
        }
      },
    ),
  );
}
