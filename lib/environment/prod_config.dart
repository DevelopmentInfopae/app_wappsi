

import 'base_config_class.dart';

class ProdConfig implements BaseConfig {
  @override
  String get apiHost => 'http://lapappaya.com';

  @override
  String get cFolder => '/erp/';

  @override
  String get hostFolder => '/wappsi_apis/';

  @override
  bool get printErrors => false;

  @override
  bool get trackEvents => false;

  @override
  bool get useHttps => false;
}