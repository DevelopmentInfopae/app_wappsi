// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/screens/components/back_app_bar.dart';
import 'package:pos_wappsi/screens/components/widgets.dart';
import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/utils/local_storage/error_log.dart';

// import '../../utils/location/custom_controller.dart';
import '../components/location/zone_szone_data.dart';

class AddressDetails extends StatefulWidget {
  const AddressDetails({
    required this.customer,
    required this.address,
    Key? key,
  }) : super(key: key);

  final CompanyModel customer;
  final CustomerAddressesModel address;

  @override
  State<AddressDetails> createState() => _AddressDetailsState();
}

class _AddressDetailsState extends State<AddressDetails> {
  // late Size _size = MediaQuery.of(context).size;
  // late Color _pc;
  // late CustomController? controller;
  // late GeoPoint? gLoc;
  late GlobalKey<ScaffoldState> scaffoldKey;
  bool markerDraw = false;
  Key mapGlobalKey = UniqueKey();
  @override
  void initState() {
    super.initState();
    if (widget.address.latitude != null && widget.address.longitude != null) {
      try {
        // gLoc = GeoPoint(
        //   latitude: widget.address.latitude!,
        //   longitude: widget.address.longitude!,
        // );
        // controller = CustomController(
        //   initMapWithUserPosition: UserTrackingOption(enableTracking: true),
        //   initPosition: gLoc,

        //   // areaLimit: BoundingBox(
        //   //   east: 10.4922941,
        //   //   north: 47.8084648,
        //   //   south: 45.817995,
        //   //   west: 5.9559113,
        //   // ),
        // );
      } catch (e) {
        logError(e);
      }

      // controller!.;
      // controller!.changeLocation(gLoc!);
      // controller!.setMarkerIcon(
      //     gLoc!, const MarkerIcon(icon: Icon(Icons.location_on_outlined)));
    } else {
      // controller = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // _pc = pColor;

    return Scaffold(
      appBar: appBar(
        context,
        'Detalle de sucursal',
        image: 'assets/images/locations.png',
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _addressHead(context).paddingOnly(left: 10, right: 10, bottom: 5),
        _addressDetails().paddingOnly(left: 10, right: 10, bottom: 5).expand(),
      ],
    );
  }

  Card _addressHead(BuildContext context) {
    return Card(
      child: Row(
        children: [
          addressPhoto(
            widget.customer.customerProfilePhoto ?? '',
            fit: BoxFit.cover,
          ).withSize(width: 100, height: 100),
          addressDesc(context, widget.customer, widget.address)
              .paddingSymmetric(vertical: 4)
              .expand(),
        ],
      ),
    );
  }

  Widget _addressDetails() {
    String stateCity = '';
    if (widget.address.state != null) {
      stateCity = widget.address.state! + ' - ';
    }
    if (widget.address.city != null) {
      stateCity =
          (widget.address.state ?? '') + '-' + (widget.address.city ?? '');
    }
    return Column(
      children: [
        Card(
          elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // padding: const EdgeInsets.all(5),
            children: [
              labelContent('Teléfono ', widget.address.phone ?? ''),
              hDivider(),
              labelContent('Ubicación ', stateCity),
              hDivider(),
              labelContent('Dirección ', widget.address.direccion ?? ''),
              hDivider(),
              _zoneSzoneInfo(),
            ],
          ),
        ),
        // Card(
        //   elevation: 5,
        //   child: controller != null
        //       ? _map()
        //           .paddingSymmetric(horizontal: 4, vertical: 4)
        //           .withHeight(300)
        //       : Container(),
        // ).expand(),
      ],
    );
  }

  Widget _zoneSzoneInfo() {
    int? zoneId = widget.address.location;
    int? subzoneId = widget.address.subzone;
    return ZoneSZoneData(
      zoneId: zoneId,
      subzoneId: subzoneId,
    );
  }

  Widget _map() {
    // to make this shit draw position marker
    if (!markerDraw) {
      // Timer(const Duration(seconds: 2), () {
      //   try {
      //     controller!.addMarker(
      //       gLoc!,
      //       markerIcon: const MarkerIcon(
      //         icon: Icon(
      //           Icons.location_on,
      //           color: Colors.red,
      //           size: kIconSize + 50,
      //         ),
      //       ),
      //     );
      //     controller!.osmBaseController;
      //     setState(() {
      //       markerDraw = true;
      //     });
      //   } catch (e) {
      //     printConsole(e);
      //   }
      // });
    }
    return Container();
    // return OSMFlutter(
    //   // androidHotReloadSupport: true,
    //   // showDefaultInfoWindow: true,
    //   osmOption: OSMOption(
    //     showZoomController: true,
    //     zoomOption: ZoomOption(
    //       initZoom: 16,
    //     ),
    //   ),
    //   mapIsLoading: Center(
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         Loader(),
    //         const Text('Cargando mapa..'),
    //       ],
    //     ),
    //   ),
    //   // showZoomController: true,
    //   controller: controller!,
    // );
  }
}
