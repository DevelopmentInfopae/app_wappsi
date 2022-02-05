

import 'base_config_class.dart';

class DevConfig implements BaseConfig {
  @override
  String get apiHost => 'http://localhost';

  @override
  String get hostFolder => '/wappsi_apis/';
  @override
  String get cFolder => '/erp/';

  @override
  bool get printErrors => true;

  @override
  bool get trackEvents => true;

  @override
  bool get useHttps => false;
}