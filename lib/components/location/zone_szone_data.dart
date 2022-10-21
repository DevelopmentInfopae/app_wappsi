import 'package:flutter/material.dart';

import '../../models/subzone_model.dart';
import '../../models/zone_model.dart';
import '../../providers/zone_provider.dart';
import '../widgets.dart';

class ZoneSZoneData extends StatelessWidget {
  const ZoneSZoneData({
    Key? key,
    required this.zoneId,
    required this.subzoneId,
    // required this.withDivider
  }) : super(key: key);

  final int? zoneId;
  final int? subzoneId;
  // final bool withDivider;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          ZonesProvider.getLocationData(zoneId: zoneId, subzoneId: subzoneId),
      // initialData: InitialData,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          ZoneModel? zone;
          SubzoneModel? subzone;
          zone = snapshot.data['zone_data'];
          subzone = snapshot.data['subzone_data'];

          return labelContent(
            'Zona / Barrio',
            (zone?.capitalizeZoneName() ?? '--') +
                ' / ' +
                (subzone?.capitalizeSubzoneName() ?? '--'),
          );
        }
        return Container();
      },
    );
  }
}
