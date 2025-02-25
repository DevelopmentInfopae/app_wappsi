//______________________________________________________________________________________________________________
//
//                                     Método de pago y tipo - Proveedores
//_______________________________________________________________________________________________________________

import 'package:pos_wappsi/screens/customers/components/drop_down_s_item.dart';

final supplierPayM = {
  '0': DropdDownSItem(name: 'Crédito', value: '0'),
  '1': DropdDownSItem(name: 'Contado', value: '1'),
};
final supplierType = {
  '1': DropdDownSItem(name: 'Productos y Gastos', value: '1'),
  '2': DropdDownSItem(name: 'Productos', value: '2'),
  '3': DropdDownSItem(name: 'Gastos', value: '3'),
  '4': DropdDownSItem(name: 'Acreedores', value: '4'),
  '5': DropdDownSItem(name: 'Entidad Financiera', value: '5'),
  '6': DropdDownSItem(name: 'Entidad Promotora de Salud (EPS)', value: '6'),
  '7': DropdDownSItem(name: 'Fondo de Pensiones y Cesantías', value: '7'),
  '8': DropdDownSItem(
    name: 'Administradora de Riesgos Laborales (ARL)',
    value: '8',
  ),
  '9': DropdDownSItem(name: 'Caja de compensación', value: '9'),
  '10': DropdDownSItem(
    name: 'Servicio Nacional de Aprendizaje (SENA)',
    value: '10',
  ),
};
