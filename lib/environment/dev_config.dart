import 'base_config_class.dart';

class DevConfig implements BaseConfig {
  @override
  // String get apiHost => 'http://wappsi281.com';
String get apiHost => 'http://lapappaya.com';

  @override
  String get hostFolder => '/wappsi_apis/';
  @override
  // String get cFolder => '/dulcelandia/';
  String get cFolder => '/erp/';

  @override
  bool get printErrors => true;

  @override
  bool get trackEvents => true;

  @override
  bool get useHttps => false;
}
