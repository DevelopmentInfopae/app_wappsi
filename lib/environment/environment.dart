// ignore_for_file: constant_identifier_names


import 'package:pos_wappsi/environment/prod_config.dart';

import 'base_config_class.dart';
import 'dev_config.dart';

class Environment {
  factory Environment() {
    return _singleton;
  }

  Environment._internal();

  static final Environment _singleton = Environment._internal();

  static const String DEV = 'DEV';
  // static const String STAGING = 'STAGING';
  static const String PROD = 'PROD';

  late BaseConfig config;

  late String env;

  initConfig(String environment) {
    config = _getConfig(environment);
    env = environment;
  }


  BaseConfig _getConfig(String environment) {
    switch (environment) {
      case Environment.PROD:
        return ProdConfig();
      default:
        return DevConfig();
    }
  }
}