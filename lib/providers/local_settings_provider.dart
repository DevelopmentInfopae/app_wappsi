import 'package:pos_wappsi/entities/PriceSettings.dart';
import 'package:pos_wappsi/providers/local_db_provider.dart';

class LocalSettingsProvider {
  static const String _table = 'local_settings';
  static const String _kPoliticaPrecios = 'politica_precios';
  static const String _kTipoLista = 'tipo_lista';
  static const String _kDefaultPriceList = 'default_price_list';

// funcion para getter generico
  static Future<String?> _getValor(String clave) async {
    final res = await DBProvider.db.sqlFirstQuery(
      _table,
      where: "clave = '$clave'",
    );
    return res?['valor'] as String?;
  }

// funcion para setter generico
  static Future<void> _setValor(String clave, String valor) async {
    await DBProvider.db.insertQuery(_table, {
      'clave': clave,
      'valor': valor,
    });
  }

  static Future<PoliticaPrecios> getPoliticaPrecios() async {
    final valor = await _getValor(_kPoliticaPrecios);
    return valor == 'APP' ? PoliticaPrecios.app : PoliticaPrecios.erp;
  }

  static Future<void> setPoliticaPrecios(PoliticaPrecios politica) async {
    await _setValor(
      _kPoliticaPrecios,
      politica == PoliticaPrecios.app ? 'APP' : 'ERP',
    );
  }

  // Getter de lista de precio por defecto
  static Future<String?> getdefaultPriceList() async {
    final valor = await _getValor(
        _kDefaultPriceList); // Obtener el valor de la base de datos
    return valor;
  }

  // Setter de lista de precios por defecto
  static Future<void> setDefaultPriceList(String? data) async {
    if (data == null) return;
    await _setValor(_kDefaultPriceList, data);
  }

  static Future<TipoLista?> getTipoLista() async {
    final valor = await _getValor(_kTipoLista);
    return valor == 'PRODUCTO' ? TipoLista.porProducto : null;
  }

  static Future<void> setTipoLista(TipoLista? tipo) async {
    if (tipo == null) return;
    await _setValor(
      _kTipoLista,
      tipo == TipoLista.porProducto ? 'PRODUCTO' : '',
    );
  }

  static Future<PriceSettings> getPriceSettings() async {
    final politica = await getPoliticaPrecios();
    final tipoLista =
        politica == PoliticaPrecios.app ? await getTipoLista() : null;
    final defaultPriceList = await getdefaultPriceList();
    return PriceSettings(politica, tipoLista, defaultPriceList);
  }

  // Getter de price goups
  static Future<List<Map<String, dynamic>>>
      loadAllPriceGroupsForDropdown() async {
    final res = await DBProvider.db.sqlQuery(
      'sma_price_groups',
      columns: ['id', 'name'],
      limit: null, // sin límite, trae todos
      orderBy: 'name ASC',
    );
    return res ?? [];
  }
}
