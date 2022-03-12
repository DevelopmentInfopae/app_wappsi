import 'package:pos_wappsi/bloc/data_bloc.dart';

class GridItems {
  final String title, icon, route;

  GridItems({required this.title, required this.icon, required this.route});
}

List<GridItems> basePermissions = [
  // // GridItems(
  // //   title: 'Agregar venta',
  // //   route: "sales",
  // //   icon: 'assets/images/add-to-cart.png',
  // // ),
  // GridItems(
  //   title: 'Agregar pedido',
  //   route: "orders",
  //   icon: 'assets/images/cargo.png',
  // ),
  // // GridItems(
  // //   title: 'Listado de ventas',
  // //   route: "list_sales",
  // //   icon: 'assets/images/shopping-list.png',
  // // ),
  // GridItems(
  //   title: 'Listado de pedidos',
  //   route: "list_orders",
  //   icon: 'assets/images/order-list.png',
  // ),
  // GridItems(
  //   title: 'Agregar cliente',
  //   route: "addCustomer",
  //   icon: 'assets/images/add-user.png',
  // ),
  // GridItems(
  //   title: 'Lista de clientes',
  //   route: "customers",
  //   icon: 'assets/images/enterprise.png',
  // ),
  // GridItems(
  //   title: 'Lista de productos',
  //   route: "products",
  //   icon: 'assets/images/box.png',
  // ),
  // GridItems(
  //   title: 'Verificador de precios',
  //   route: "priceVerifier",
  //   icon: 'assets/images/give-money.png',
  // ),
  // GridItems(
  //   title: 'Control de caja',
  //   route: "register",
  //   icon: 'assets/images/cash-register.png',
  // ),
  
  GridItems(
    title: 'Sincronizar datos',
    route: "syncElements",
    icon: 'assets/images/synchronization.png',
  ),
  GridItems(
    title: 'Cuenta de usuario',
    route: "profile",
    icon: 'assets/images/user.png',
  ),
  GridItems(
    title: 'Ajustes',
    route: "settings",
    icon: 'assets/images/settings.png',
  ),
  GridItems(
    title: 'Cerrar sesión',
    route: "logout",
    icon: 'assets/images/logout.png',
  ),
];


Map<String, GridItems> gridItemsMap = {


  'pos-index': GridItems(
    title: 'Agregar venta',
    route: "sales",
    icon: 'assets/images/add-to-cart.png',
  ),
  'sales-add_order':GridItems(
    title: 'Agregar pedido',
    route: "orders",
    icon: 'assets/images/cargo.png',
  ),
  'pos-sales':GridItems(
    title: 'Listado de ventas',
    route: "list_sales",
    icon: 'assets/images/shopping-list.png',
  ),
  'sales-orders':GridItems(
    title: 'Listado de pedidos',
    route: "list_orders",
    icon: 'assets/images/order-list.png',
  ),
  'customers-add':GridItems(
    title: 'Agregar cliente',
    route: "addCustomer",
    icon: 'assets/images/add-user.png',
  ),
  'customers-index':GridItems(
    title: 'Lista de clientes',
    route: "customers",
    icon: 'assets/images/enterprise.png',
  ),
  'products-index':GridItems(
    title: 'Lista de productos',
    route: "products",
    icon: 'assets/images/box.png',
  ),
  'products-price':GridItems(
    title: 'Verificador de precios',
    route: "priceVerifier",
    icon: 'assets/images/give-money.png',
  ),
  'pos-pos_register_add_movement':GridItems(
    title: 'Control de caja',
    route: "register",
    icon: 'assets/images/cash-register.png',
  ),

};

List<GridItems> gridItemsForPermissions(){
  List<GridItems> gridItems = [];

  if(dataBloc.permissions?.posIndex==1){
    gridItems.add(gridItemsMap['pos-index']!);
  }
  if(dataBloc.permissions?.salesAddOrder==1){
    gridItems.add(gridItemsMap['sales-add_order']!);
  }
  if(dataBloc.permissions?.salesOrders==1){
    gridItems.add(gridItemsMap['sales-orders']!);
  }
  if(dataBloc.permissions?.posSales==1){
    gridItems.add(gridItemsMap['pos-sales']!);
  }
  if(dataBloc.permissions?.customersAdd==1){
    gridItems.add(gridItemsMap['customers-add']!);
  }
  if(dataBloc.permissions?.customersIndex==1){
    gridItems.add(gridItemsMap['customers-index']!);
  }
  if(dataBloc.permissions?.productsPrice==1){
    gridItems.add(gridItemsMap['products-price']!);
  }
  if(dataBloc.permissions?.posPosRegisterAddMovement==1){
    gridItems.add(gridItemsMap['pos-pos_register_add_movement']!);
  }

  gridItems.addAll(basePermissions);

  return gridItems;
}

// List<GridItems> businessIcons = [
  

  

//   GridItems(
//     title: 'Dashboard',
//     icon: 'assets/images/dashboard.png',

//   ),
// ];

// List<GridItems> enterpriseIcons = [
//   // GridItems(
//   //   title: 'Branch',
//   //   icon: 'assets/images/branch.png',

//   // ),
//   // GridItems(
//   //   title: 'Damage',
//   //   icon: 'assets/images/damage.png',

//   // ),
//   // GridItems(
//   //   title: 'Adjustment',
//   //   icon: 'assets/images/adjustment.png',

//   // ),
//   GridItems(
//     title: 'Transaction',
//     icon: 'assets/images/transaction.png',

//   ),
 
//   GridItems(
//     title: 'Loss&Profit',
//     icon: 'assets/images/lossProfit.png',
//   ),
//   GridItems(
//     title: 'Backup',
//     icon: 'assets/images/backup.png',
//   ),
// ];