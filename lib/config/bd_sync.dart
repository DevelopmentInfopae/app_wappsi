import 'package:pos_wappsi/bloc/data_bloc.dart';

/// To get sync option name with the table_name
Map<String, String> tableNamesToSyncOpt = {
  'sma_products': 'Productos',
  'sma_addresses': 'Sucursales',
  'sma_companies': 'Terceros',
  'sma_product_photos': 'Fotos de Productos',
  'sma_product_variants': 'Variantes de Productos',
  'sma_product_prices': 'Precios de Productos',
  'sma_biller_data': 'Datos de Facturación',
  'sma_customer_groups': 'Grupos de Clientes',
  'sma_warehouses_products': 'Productos de Sucursales',
  'sma_brands': 'Marcas',
  'sma_payment_methods': 'Métodos de Pago',
  'sma_settings': 'Parámetros Generales',
  'sma_groups': 'Grupos',
  'sma_tax_rates': 'Tasas de Impuesto',
  'sma_pos_settings': 'Ajustes POS',
  'sma_documentypes': 'Tipos de documento',
  'sma_documents_types': 'Documentos para operaciones',
  'sma_categories': 'Categorías productos',
  'sma_units': 'Unidades',
  'sma_warehouses': 'Bodegas',
  'sma_unit_prices': 'sma_unit_prices',
  'sma_order_sales': 'Ordenes de pedido',
  'sma_quotes': 'Cotizaciones',
  'sma_purchases': 'Compras',
  'sma_countries' : 'Countries',
};

List<String> specialSync = [
  'Ordenes de pedido',
  'Productos',
  'Cotizaciones',
  'Compras',
  'Ventas',
  'Preferencias de productos',
];

Map<String, Map<String, dynamic>> _options = {

  'Parámetros Generales': {
    'path': 'sync/settings',
    'table': 'sma_settings',
    'sync_id': 1,
    'image': 'settings.png',
  },

  'Productos': {
    'path': 'sync/products',
    'table': 'sma_products',
    'sync_id': 2,
    'image': 'box.png',
    'independent_table': 'sma_products',
    'dependent_table': 'sma_unit_prices',
    'delete_before': true,
    'id_key': 'id_cloud',
    'column_name': 'id_product',
  },
  'Preferencias de productos': {
    'path': 'sync/productPreferences',
    'table': 'sma_product_preferences',
    'sync_id': 27,
    'image': 'box.png',
    'independent_table': 'sma_product_preferences',
    'dependent_table': 'sma_preferences',
    'dependent_table_2': 'sma_preferences_categories',
    'delete_before': true,
    'id_key': 'preference_id',
    'id_key_2': 'preference_category_id',
    'column_name': 'id',
    'column_name_2': 'id',
  },
  'Sucursales': {
    'path': 'sync/addresses',
    'table': 'sma_addresses',
    'sync_id': 3,
    'image': 'locations.png',
  },
  'Terceros': {
    'path': 'sync/companies',
    'table': 'sma_companies',
    'sync_id': 4,
    'image': 'people.png',
  },

  // 'Favoritos': {
  //   'path': 'sync/wishlist',
  //   'table': 'sma_wishlist',
  //   'sync_id': 3,
  //   'image': 'favorite.png'
  // },
  'Fotos de Productos': {
    'path': 'sync/productPhotos',
    'table': 'sma_product_photos',
    'sync_id': 5,
    'image': 'photos.png',
  },
  'Variantes de Productos': {
    'path': 'sync/productVariants',
    'table': 'sma_product_variants',
    'sync_id': 6,
    'image': 'product-range.png',
  },
  'Precios de Productos': {
    'path': 'sync/productPrices',
    'table': 'sma_product_prices',
    'sync_id': 7,
    'image': 'price-tag.png',
  },
  'Datos de Facturación': {
    'path_data': 'sync/billerData',
    'path_documents_data': 'sync/billerDocumentsTypes',
    'table_data': 'sma_biller_data',
    'table_documents_data': 'sma_biller_documents_types',
    'sync_id': 8,
    'image': 'report.png',
  },
  'Grupos de Clientes': {
    'path': 'sync/customerGroups',
    'table': 'sma_customer_groups',
    'sync_id': 9,
    'image': 'meeting.png',
  },
  'Grupos de Precios': {
    'path': 'sync/priceGroups',
    'table': 'sma_price_groups',
    'sync_id': 10,
    'image': 'prices.png',
  },
  'Productos de Sucursales': {
    'path': 'sync/warehousesProducts',
    'table': 'sma_warehouses_products',
    'sync_id': 11,
    'image': 'inventory.png',
  },
  'Marcas': {
    'path': 'sync/brands',
    'table': 'sma_brands',
    'sync_id': 12,
    'image': 'brand.png',
  },
  'Métodos de Pago': {
    'path': 'sync/paymentMethods',
    'table': 'sma_payment_methods',
    'sync_id': 13,
    'image': 'wallet.png',
  },
  'Grupos': {
    'path': 'sync/companyGroups',
    'table': 'sma_groups',
    'sync_id': 13,
    'image': 'group.png',
  },
  'Tasas de Impuesto': {
    'path': 'sync/taxRates',
    'table': 'sma_tax_rates',
    'sync_id': 14,
    'image': 'rates.png',
  },
  'Ajustes POS': {
    'path': 'sync/posSettings',
    'table': 'sma_pos_settings',
    'sync_id': 15,
    'image': 'settings.png',
  },
  'Tipos de documento': {
    'path': 'sync/documentypes',
    'table': 'sma_documentypes',
    'sync_id': 16,
    'image': 'document.png',
  },
  'Documentos para operaciones': {
    'path': 'sync/documentsTypes',
    'table': 'sma_documents_types',
    'sync_id': 17,
    'image': 'document.png',
  },
  'Categorías productos': {
    'path': 'sync/productCategories',
    'table': 'sma_categories',
    'sync_id': 18,
    'image': 'categories.png',
  },
  'Unidades': {
    'path': 'sync/units',
    'table': 'sma_units',
    'sync_id': 19,
    'image': 'packages.png',
  },
  'Bodegas': {
    'path': 'sync/warehouses',
    'table': 'sma_warehouses',
    'sync_id': 20,
    'image': 'packages.png',
  },
  // 'Precios de unidades': {
  //   'path': 'sync/unitPrices',
  //   'table': 'sma_unit_prices',
  //   'sync_id': 21,
  //   'image': 'packages.png'
  // },
  'Ordenes de pedido': {
    'path': 'sync/orders',
    'table': 'sma_order_sales',
    'sync_id': 22,
    'image': 'order-list.png',
    'independent_table': 'sma_order_sales',
    'dependent_table': 'sma_order_sale_items',
    'delete_before': true,
    'id_key': 'id_cloud',
    'column_name': 'sale_id',
  },
  'Compras': {
    'path': 'sync/purchases',
    'table': 'sma_purchases',
    'sync_id': 25,
    'image': 'order-list.png',
    'independent_table': 'sma_purchases',
    'dependent_table': 'sma_purchase_items',
    'delete_before': true,
    'id_key': 'id_cloud',
    'column_name': 'purchase_id',
  },
  'Ventas': {
    'path': 'sync/sales',
    'table': 'sma_sales',
    'sync_id': 26,
    'image': 'shopping-list.png',
    'independent_table': 'sma_sales',
    'dependent_table': 'sma_sale_items',
    'dependent_table_2': 'sma_payments',
    'delete_before': true,
    'id_key': 'id_cloud',
    'column_name': 'sale_id',
  },
  'Cotizaciones': {
    'path': 'sync/quotes',
    'table': 'sma_quotes',
    'sync_id': 23,
    'image': 'quotation.png',
    'independent_table': 'sma_quotes',
    'dependent_table': 'sma_quote_items',
    'delete_before': true,
    'id_key': 'id_cloud',
    'column_name': 'quote_id',
  },
  'Proveedores': {
    'path': 'sync/suppliers',
    'table': 'sma_companies',
    'sync_id': 24,
    'image': 'enterprise.png',
  },
  'Paises': {
    'path': 'sync/countries',
    'table': 'sma_countries',
    'sync_id': 29,
    'image': 'location.png',
  },
  'Departamentos': {
    'path': 'sync/states',
    'table': 'sma_states',
    'sync_id': 30,
    'image': 'location.png',
  },
  'Ciudades': {
    'path': 'sync/cities',
    'table': 'sma_cities',
    'sync_id': 31,
    'image': 'location.png',
  },
};

Map<String, Map<String, dynamic>> get enabledOptions {
  if (dataBloc.permissions?.salesOrders == 0) {
    _options.remove('Ordenes de pedido');
  }
  if (dataBloc.permissions?.posSales == 0) {
    _options.remove('Ventas');
  }
  if (dataBloc.permissions?.quotesIndex == 0) {
    _options.remove('Cotizaciones');
  }
  if (dataBloc.permissions?.purchasesIndex == 0) {
    _options.remove('Compras');
  }

  // if (dataBloc.permissions?.customersIndex == 0) {
  // }
  if (dataBloc.permissions?.suppliersIndex == 0) {
    _options.remove('Proveedores');
  }
  // if (dataBloc.permissions?.productsIndex == 0) {}
  // if (dataBloc.permissions?.productsPrice == 0) {}

  return _options;
}
