//______________________________________________________________________________________________________________
//
//                                       REGISTER ENDPOINTS
//_______________________________________________________________________________________________________________

/// Endpoint to open register
String regOpenEndP = 'register/open';

/// Endpoint to make movements on a opened register
String regMovEndP = 'register/newMovement';

/// Endpoint to close current register
String regCloseEndP = 'register/close';

//______________________________________________________________________________________________________________
//
//                                       AUTH ENDPOINTS
//_______________________________________________________________________________________________________________

/// EndPoint to login to application
String loginEndP = 'auth/login';

/// Endpoint to logout application
String logoutEndP = 'auth/logout';

/// Endpoint to logout application
String refreshTokenEndP = 'auth/refreshToken';

String verifyUserNameEndP = 'auth/verifyUserName';
String verifyUserExistEndP = 'auth/verifyUserExist';

//______________________________________________________________________________________________________________
//
//                                        SALES ENDPOINTS
//_______________________________________________________________________________________________________________

/// Endpoint to send sale data
String newSaleEndP = 'sales/new';

//______________________________________________________________________________________________________________
//
//                                       COMPANIES ENDPOINTS
//_______________________________________________________________________________________________________________

/// Endpoint to create new company on sma_companies
String addCompanyEndP = 'companies/newCompany2';
String addSupplierEndP = 'companies/newSupplier';

//______________________________________________________________________________________________________________
//
//                                       COMPANIES ENDPOINTS
//_______________________________________________________________________________________________________________

/// Endpoint to create new company on sma_companies
String addAddressEnd = 'addresses/newAddress';
String addAddressZoneSZoneEnd = 'addresses/addAddressZoneSZone';

//______________________________________________________________________________________________________________
//
//                                       Wish List
//_______________________________________________________________________________________________________________

String getCustomerWishListEndP = 'wishlist/companyFavorites';
String getUserWishList = 'wishlist/userFavorites';
String getAllWishListEndP = 'wishlist/all';
String deleteCompanyFavEndP = 'wishlist/deleteCompanyFavorites';
String addCompanyFavEndP = 'wishlist/addCompanyFavorites';

//______________________________________________________________________________________________________________
//
//                                        ORDERS ENDPOINTS
//_______________________________________________________________________________________________________________

/// Endpoint to send sale data
const String newOrderEndP = 'orders/new';
const String cancelPendingOrderEndP = 'orders/cancel';
const String searchOrdersEndP = 'orders/findOrders';

//______________________________________________________________________________________________________________
//
//                                        ERRORS ENDPOINTS
//_______________________________________________________________________________________________________________

/// Endpoint to send sale data
String sendErrorEndP = 'error/reportError';

//______________________________________________________________________________________________________________
//
//                                        QUOTES ENDPOINTS
//_______________________________________________________________________________________________________________

/// Endpoint to send sale data
String newQuoteEndP = 'quotes/new';

//______________________________________________________________________________________________________________
//
//                                        PRUCHASES ENDPOINTS
//_______________________________________________________________________________________________________________

/// Endpoint to send sale data
String addPurchaseEndP = 'purchases/new';
String checkPuRefEndP = 'purchases/checkReferenceNo';
String checkPuSupConsEndP = 'purchases/checkConsecutiveNo';

//______________________________________________________________________________________________________________
//
//                                       DeliveryTimes Endpoint
//_______________________________________________________________________________________________________________

String avaibleDelTimeEndP = 'deliveryTime/getDeliveryTimes';

//______________________________________________________________________________________________________________
//
//                                       Location data
//_______________________________________________________________________________________________________________

const String cityZonesEndP = "/locations/cityZones";

const String subZonesEndP = "/locations/zoneSubzones";

const String locationDataEndP = "locations/locationData";
