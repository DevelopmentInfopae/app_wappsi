import 'base_config_class.dart';

class ProdConfig implements BaseConfig {
  @override
  // String get apiHost => 'http://lapappaya.com';
  String get apiHost => 'http://wposmovil.com';
  // String get apiHost => 'http://wappsi281.com';

  @override
  // String get cFolder => '/erp/';
  // String get cFolder => '/dulcelandia_pruebas/';
  String get cFolder => '/dulcelandia/';

  @override
  // String get hostFolder => '/wappsi_apis_dev/';
  String get hostFolder => '/git_repos/WappsiAPI7.2/public/';

  @override
  bool get printErrors => false;

  @override
  bool get trackEvents => false;

  @override
  bool get useHttps => false;
}
