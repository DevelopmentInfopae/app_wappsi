import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/components/location/subzone_dropdown.dart';
import 'package:pos_wappsi/components/location/zone_future_dropdown.dart';
import 'package:pos_wappsi/constant.dart';
import 'package:pos_wappsi/models/customer_addresses_model.dart';
import 'package:pos_wappsi/providers/customer_addresses_provider.dart';
import 'package:pos_wappsi/providers/sync_db_provider.dart';
import 'package:pos_wappsi/utils/alerts.dart';

import '../../../models/subzone_model.dart';
import '../../../models/zone_model.dart';
import '../../../providers/zone_provider.dart';

class ZoneSZoneSelection extends StatefulWidget {
  const ZoneSZoneSelection({Key? key, required this.address}) : super(key: key);
  final CustomerAddressesModel address;
  @override
  State<ZoneSZoneSelection> createState() => _ZoneSZoneSelectionState();
}

class _ZoneSZoneSelectionState extends State<ZoneSZoneSelection> {
  final StreamController<List<SubzoneModel>> _subzonesController =
      StreamController<List<SubzoneModel>>.broadcast();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _subzoneController = TextEditingController();

  final _subZoneDropDownKey = GlobalKey<DropdownSearchState<SubzoneModel?>>();

  ZoneModel? _selectedZone;

  SubzoneModel? _selectedSZone;

  bool loading = false;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _zoneController.dispose();
    _subzoneController.dispose();
    _subzonesController.close();
    super.dispose();
  }

  Future<void> _loadSubzones() async {
    final szones = await ZonesProvider.loadSubZones(_selectedZone?.id);
    _subzonesController.sink.add(szones);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(alertBorderRadius)),
      actionsPadding: EdgeInsets.zero,
      // insetPadding: EdgeInsets.zero,
      buttonPadding: EdgeInsets.zero,
      backgroundColor: alertBackground,
      actions: [
        GestureDetector(
          child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(alertBorderRadius),
                    bottomRight: Radius.circular(alertBorderRadius)),
                color: loading ? greyColor : pColor.withOpacity(0.7),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Aceptar',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              )),
          // enabled: !loading,
          onTap: () async {
            if (!loading) {
              setState(() {
                loading = true;
              });
              if (formKey.currentState?.validate() ?? false) {
                final result =
                    await CustomerAddressesProvider.addZoneSZoneToAddress(
                        context,
                        addressId: widget.address.idCloud.toString(),
                        zoneId: _selectedZone?.id,
                        subzoneId: _selectedSZone?.id);
                if (result) {
                  await confirmDialog(
                      context,
                      "Zona y subzona asignadas con exito.",
                      'assets/images/success.png');
                  await SyncDBProvider().syncOption(context, "Sucursales");
                } else {
                  await confirmDialog(
                      context,
                      "Ha ocurrido un error al asignar zona y subzona a la sucursal.",
                      'assets/images/dizzy-robot.png');
                }
                finish(context, {"reload_address": true});
              }
            }
            // setState(() {
            //   loading = false;
            // });
          },
        ),
      ],
      title: Text(
        "Seleccione zona y barrio para la sucursal de cliente seleccionada",
        style: normalTextStyle(context),
      ),
      content: Material(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _zones().paddingOnly(top: 8, bottom: 2),
              _subZones().paddingSymmetric(vertical: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _zones() {
    return ZoneFutureDropDown(
        selectedCityCode: widget.address.cityCode,
        required: false,
        onChange: (data) async {
          if (_selectedZone?.zoneCode != data?.zoneCode) {
            _selectedZone = data;
            _subZoneDropDownKey.currentState?.changeSelectedItem(null);
            await _loadSubzones();
            // _subZoneDropDownKey.currentState?.openDropDownSearch();
          }
        },
        selectedZone: _selectedZone?.id);
  }

  Widget _subZones() {
    return SubZoneDropDown(
        stream: _subzonesController.stream,
        dropDownKey: _subZoneDropDownKey,
        required: false,
        onChange: (data) async {
          _selectedSZone = data;
        },
        selectedSZoneCode: _selectedSZone?.id);
  }
}
