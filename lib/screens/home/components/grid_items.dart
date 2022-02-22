class GridItems {
  final String title, icon, route;

  GridItems({required this.title, required this.icon, required this.route});
}

List<GridItems> freeIcons = [
  // GridItems(
  //   title: 'Agregar venta',
  //   route: "sales",
  //   icon: 'assets/images/add-to-cart.png',
  // ),
  GridItems(
    title: 'Agregar pedido',
    route: "orders",
    icon: 'assets/images/cargo.png',
  ),
  // GridItems(
  //   title: 'Listado de ventas',
  //   route: "list_sales",
  //   icon: 'assets/images/shopping-list.png',
  // ),
  GridItems(
    title: 'Listado de pedidos',
    route: "list_orders",
    icon: 'assets/images/order-list.png',
  ),
  GridItems(
    title: 'Agregar cliente',
    route: "addCustomer",
    icon: 'assets/images/add-user.png',
  ),
  GridItems(
    title: 'Lista de clientes',
    route: "customers",
    icon: 'assets/images/enterprise.png',
  ),
  GridItems(
    title: 'Lista de productos',
    route: "products",
    icon: 'assets/images/box.png',
  ),
  GridItems(
    title: 'Verificador de precios',
    route: "priceVerifier",
    icon: 'assets/images/give-money.png',
  ),
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