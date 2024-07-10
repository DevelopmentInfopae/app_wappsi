import 'dart:io';
import 'dart:math' as match;

import 'package:flutter/material.dart';
import 'package:pos_wappsi/config/sizes.dart';

const double _kAspectRatio = 0.56222;

/// Class to manage responsive design
class ResponsiveDesign {
  /// Constructor
  ResponsiveDesign(BuildContext context) {
    _context = context;
    _init(context);
  }

  void _init(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var orient = MediaQuery.of(context).orientation;
    var aspectRatio = (MediaQuery.of(context).size.aspectRatio / _kAspectRatio)
        .clamp(0.5, 1.0);
    var padding = MediaQuery.of(context).viewPadding;

    if (orient == Orientation.portrait) {
      _width = size.width;
      _height = size.height;
      _paddingBottom = padding.bottom;
      _paddingTop = padding.top;
    } else {
      _paddingTop = padding.top;
      _width = size.height;
      _height = size.width;
      _paddingBottom = 0;
    }

    _inch = match.sqrt(
      match.pow(_width * aspectRatio, 2) + match.pow(_height * aspectRatio, 2),
    );
  }

  late double _width;
  late double _height;
  late double _inch;
  late double _paddingBottom;
  late double _paddingTop;
  late BuildContext _context;

  final double _screenHeight = 926;
  final double _screenWidth = 428;

  /// width value based on design
  double width(double pixel) {
    double tempPercent = pixel / _screenWidth;
    return _width * tempPercent;
  }

  /// Return screen width value
  double get screenWidth => _width;

  /// Return screen width value
  double get screenHeight => _height;

  /// Generic horizontal padding
  final double _genericHPadding = 54;

  /// Height value based on design
  double height(double pixel) {
    double tempPercent = pixel / _screenHeight;
    return _height * tempPercent;
  }

  /// Height value
  double safeHeight(double pixel) {
    double tempPercent = pixel / _screenHeight;
    final h = ((_height - _paddingTop) * tempPercent);
    return h;
  }

  /// Height value
  double maxHeightValue(double pixel) {
    return safeHeight(pixel) > pixel ? pixel : safeHeight(pixel);
  }

  /// Height value
  double maxWidthValue(double pixel) {
    return width(pixel) > pixel ? pixel : width(pixel);
  }

  ///
  double webMultipleViewMainWidth() {
    return maxWidthValue(500);
  }

  /// Height value
  bool isScreenEnough() {
    _init(_context);
    return _width > 700;
  }

  /// Height value
  double safePaddingTop(double pixel) {
    return maxHeightValue(pixel) + (paddingTop > 0 ? paddingTop - 5 : 0);
  }

  /// Height value
  double safeBottomHeight(double pixel) {
    final h = maxHeightValue(pixel);
    try {
      if (Platform.isIOS) {
        return h + (paddingBottom > 0 ? paddingBottom - 5 : 0);
      }
      return h;
    } catch (e) {
      return h;
    }
  }

  /// Height value
  double buttonsHeight({double height = 60}) {
    return maxHeightValue(height);
  }

  /// Height value
  double get webNabVarWidth => 200;

  /// Horizontal view fraction
  double viewHFractionWPadding(double size) {
    double realWidth = screenWidth - (2 * width(_genericHPadding));
    final h = 1 / (realWidth / maxWidthValue(size));
    return h;
  }

  /// Safe BottomHeight
  double get paddingBottom => _paddingBottom;

  /// Safe padding top
  double get paddingTop => _paddingTop;

  /// TextSize value
  double textMultiplier(double size) {
    double tempPercent = size / 9;
    return inchPercent(tempPercent);
  }

  /// Diagonal
  double inchPercent(double percent) {
    return (_inch * percent) / 100;
  }

  ///
  double space() {
    return width(8.0);
  }

  /// return app commonly horizontal padding
  EdgeInsets get appHorizontalPadding =>
      horizontalPadding(AppSizes.bodyDefaultHPadding);

  /// return app commonly horizontal inner padding
  EdgeInsets get appHInnerPadding =>
      horizontalPadding(AppSizes.bodyDefaultHInnerPadding);

  /// return app commonly padding
  EdgeInsets get appDialogsPadding => EdgeInsets.symmetric(
        horizontal: width(AppSizes.bodyDefaultHPadding),
        vertical: maxHeightValue(AppSizes.bodyDefaultVPadding),
      );

  /// return app horizontal padding
  EdgeInsets horizontalPadding(double padding) => EdgeInsets.symmetric(
        horizontal: width(padding),
      );

  /// return app vertical max padding
  EdgeInsets verticalMaxPadding(double padding) => EdgeInsets.symmetric(
        vertical: maxHeightValue(padding),
      );

  /// return app all max padding
  EdgeInsets allMaxPadding(double padding) => EdgeInsets.all(
        maxHeightValue(padding),
      );
}
