enum PoliticaPrecios { erp, app }

enum TipoLista { porProducto }

class PriceSettings {
  final PoliticaPrecios politica;
  final TipoLista? tipoLista;
  final String? defaultPriceList;
  PriceSettings(this.politica, this.tipoLista, this.defaultPriceList);
}
