// // ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors


// import 'package:flutter/material.dart';
// import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:pos_wappsi/bloc/customer_bloc.dart';
// import 'package:pos_wappsi/bloc/data_bloc.dart';
// import 'package:pos_wappsi/components/back_app_bar.dart';
// import 'package:pos_wappsi/constant.dart';
// import 'package:pos_wappsi/utils/location/custom_controller.dart';

// class ViewLocation extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _SearchPageState();
//   final GeoPoint? geoLoc;
//   const ViewLocation({this.geoLoc});
// }

// class _SearchPageState extends State<ViewLocation> {
//   late TextEditingController textEditingController = TextEditingController();
//   late CustomController controller;
//   final FocusNode searchFocus = FocusNode();

//   @override
//   void initState() {
//     searchFocus.addListener(() {
//       if (searchFocus.hasFocus) {
//         dataBloc.homeKey?.currentState
//             ?.changeResizeToAvoidBottomInset(value: false);
//       }
//     });
//     super.initState();
//     controller = CustomController(
//         initMapWithUserPosition: widget.geoLoc == null,
//         initPosition: widget.geoLoc);
//   }

//   @override
//   void dispose() {
//     searchFocus.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return WillPopScope(
//       onWillPop: () async {
//         dataBloc.homeKey?.currentState?.changeResizeToAvoidBottomInset();
//         return true;
//       },
//       child: Scaffold(
//         resizeToAvoidBottomInset: false,
//         appBar: appBar(context, 'Seleccionar localización',
//             elevation: false, image: 'assets/images/checklist.png', onPop: () {
//           dataBloc.homeKey?.currentState?.changeResizeToAvoidBottomInset();
//           Navigator.pop(context);
//         }),
//         body: _locationPicker(context, size),
//       ),
//     );
//   }

//   Widget _locationPicker(BuildContext context, Size size) {
//     return OSMFlutter(
//       controller: controller,
//       initZoom: 17,
//       isPicker: false,
//       mapIsLoading: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Loader(),
//             const Text("Cargando mapa.."),
//           ],
//         ),
//       ),
//       showZoomController: true,
//       trackMyPosition: true,
//     );
//   }

//   Widget _returnCurrentLocation(BuildContext context) {
//     return AppButton(
//       width: 30,
//       // height: 30,
//       padding: kButtonPadding,
//       shapeBorder: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(50),
//           side: BorderSide(color: greyMediumLight)),
//       onTap: () async {
//         GeoPoint p = await controller.selectAdvancedPositionPicker();
//         Navigator.pop(context, p);
//       },
//       child: Icon(
//         Icons.check_rounded,
//         size: kIconSize + 13,
//         color: pColor,
//       ),
//     );
//   }

//   Widget _zoomIn() {
//     return AppButton(
//       width: 30,
//       // height: 30,
//       padding: kButtonPadding,
//       shapeBorder: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(50),
//           side: BorderSide(color: greyMediumLight)),
//       onTap: () async {
//         controller.osmBaseController.zoomIn();
//       },
//       child: Icon(
//         Icons.add,
//         size: kIconSize + 13,
//         color: pColor,
//       ),
//     );
//   }

//   Widget _zoomOut() {
//     return AppButton(
//       width: 30,
//       // height: 30,
//       padding: kButtonPadding,
//       shapeBorder: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(50),
//           side: BorderSide(color: greyMediumLight)),
//       onTap: () async {
//         controller.osmBaseController.zoomOut();
//       },
//       child: Icon(
//         Icons.remove,
//         size: kIconSize + 13,
//         color: pColor,
//       ),
//     );
//   }

//   Widget _goToUserLocation() {
//     return AppButton(
//       width: 30,
//       // height: 30,
//       padding: kButtonPadding,
//       shapeBorder: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(50),
//           side: BorderSide(color: greyMediumLight)),
//       onTap: () async {
//         // await controller. ();

//         if (customerBloc.getLocation != null) {
//           // await controller.osmBaseController.enableTracking();

//           await controller.osmBaseController.currentLocation();
//           await controller.osmBaseController
//               .initMap(initWithUserPosition: true);

//           // await controller.osmBaseController.enableTracking();
//         } else {
//           await controller.osmBaseController.currentLocation();
//           await controller.osmBaseController.enableTracking();

//           // await controller.osmBaseController.enableTracking();
//         }
//         await controller.advancedPositionPicker();
//       },
//       child: Icon(
//         Icons.my_location,
//         size: kIconSize + 13,
//         color: pColor,
//       ),
//     );
//   }
// }
