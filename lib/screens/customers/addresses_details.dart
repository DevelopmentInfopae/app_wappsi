// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:pos_wappsi/components/back_app_bar.dart';
import 'package:pos_wappsi/components/widgets.dart';
import 'package:pos_wappsi/constant.dart';

import 'package:pos_wappsi/models/companies_model.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';

import 'package:pos_wappsi/screens/customers/components/widgets.dart';
import 'package:pos_wappsi/utils/print_errors.dart';

import '../../utils/location/custom_controller.dart';

class AddressDetails extends StatefulWidget {
  const AddressDetails(
      {required this.customer, required this.address, Key? key})
      : super(key: key);

  final CompanyModel customer;
  final CustomerAddressesModel address;

  @override
  State<AddressDetails> createState() => _AddressDetailsState();
}

class _AddressDetailsState extends State<AddressDetails> {
  // late Size _size = MediaQuery.of(context).size;
  // late Color _pc;
  late CustomController? controller;
  late GeoPoint? gLoc;
  late GlobalKey<ScaffoldState> scaffoldKey;
  bool markerDrawed = false;
  Key mapGlobalkey = UniqueKey();
  @override
  void initState() {
    super.initState();
    if (widget.address.geoLocation != null &&
        widget.address.geoLocation != {}) {
      gLoc = GeoPoint.fromMap(
        widget.address.geoLocation!,
      );
      controller = CustomController(
        initMapWithUserPosition: false,
        initPosition: gLoc,

        // areaLimit: BoundingBox(
        //   east: 10.4922941,
        //   north: 47.8084648,
        //   south: 45.817995,
        //   west: 5.9559113,
        // ),
      );

      // controller!.;
      // controller!.changeLocation(gLoc!);
      // controller!.setMarkerIcon(
      //     gLoc!, const MarkerIcon(icon: Icon(Icons.location_on_outlined)));

    } else {
      controller = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // _pc = pColor;

    return Scaffold(
      appBar: appBar(context, 'Detalle de sucursal',
          image: 'assets/images/enterprise.png'),
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
        // bottom(
        //     Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //       children: [
        //         const GoBackBottom(),
        //         // _addresses(context),
        //         // _favorites(context),
        //       ],
        //     ),
        //     pColor,
        //     size)
      ],
    );
  }

  Card _addressHead(BuildContext context) {
    return Card(
      child: Row(
        children: [
          addressPhoto(widget.customer.customerProfilePhoto ?? '',
                  fit: BoxFit.cover)
              .withSize(width: 100, height: 100),
          addressDesc(context, widget.customer, widget.address)
              .paddingSymmetric(vertical: 4)
              .expand()
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
                labelContent('Ubicación ', stateCity),
                hDivider(),
                labelContent('Dirección ', widget.address.direccion ?? ''),
                hDivider(),
                labelContent('Telefono ', widget.address.phone ?? ''),
                // hDivider(),
                // futureLabelContent(DBProvider.db.findCustomerDiscount(customer.customerGroupId??1), 'name', 'Marca')
              ],
            )),
        Card(
                elevation: 5,
                child: controller != null
                    ? _map()
                        .paddingSymmetric(horizontal: 4, vertical: 4)
                        .withHeight(300)
                    : Container())
            .expand(),
      ],
    );
  }

  Widget _map() {
    // to make this shit draw position marker
    if (!markerDrawed) {
      Timer(const Duration(seconds: 2), () {
        try {
          controller!.addMarker(gLoc!,
              markerIcon: const MarkerIcon(
                  icon: Icon(
                Icons.location_on,
                color: Colors.red,
                size: kIconSize + 50,
              )));
          controller!.osmBaseController;
          setState(() {
            markerDrawed = true;
          });
        } catch (e) {
          printConsole(e);
        }
      });
    }
    return OSMFlutter(
      // androidHotReloadSupport: true,
      // showDefaultInfoWindow: true,
      showZoomController: true,
      mapIsLoading: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Loader(),
            const Text("Cargando mapa.."),
          ],
        ),
      ),
      // showZoomController: true,
      controller: controller!,
      initZoom: 16,
    );
  }
}
