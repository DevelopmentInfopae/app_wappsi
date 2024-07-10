import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:pos_wappsi/utils/utils.dart';

/// App global Lazy singletons locator
class GlobalLocator {
  /// Responsive design class with useful methods to perform
  /// responsive design
  static ResponsiveDesign get responsiveDesign =>
      ResponsiveDesign(appNavigator.currentState!.context);

  /// Global app logger instance
  static Logger get appLogger => GetIt.instance.get<Logger>();

  /// App NavigatorState key
  static GlobalKey<NavigatorState> get appNavigator =>
      GetIt.instance.get<GlobalKey<NavigatorState>>();

  /// App context
  static BuildContext? get context => appNavigator.currentContext;
}
