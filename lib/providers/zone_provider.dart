import 'package:nb_utils/nb_utils.dart';
import 'package:pos_wappsi/bloc/data_bloc.dart';
import 'package:pos_wappsi/config/endpoints.dart';
import 'package:pos_wappsi/models/subzone_model.dart';
import 'package:pos_wappsi/models/zone_model.dart';
import 'package:pos_wappsi/providers/api_provider.dart';

class ZonesProvider {
  static Future<List<ZoneModel>> loadCityZones(String cityCode) async {
    final data = await DataProvider().postPetition(
        cityZonesEndP, {"city_code": cityCode}, dataBloc.getHeaders());
    List<ZoneModel> list = [];
    if (!(data['error'] ?? true)) {
      if (data["body"]['data'] is List) {
        try {
          for (Map element in data["body"]['data']) {
            final zone = ZoneModel.fromJson(element);
            list.add(
              zone,
            );
          }
        } catch (e) {
          log(e);
        }
      }
    }
    return list;
  }

  static Future<List<SubzoneModel>> loadSubZones(int? idZone) async {
    final data = await DataProvider().postPetition(
        subZonesEndP, {"zone_id": idZone}, dataBloc.getHeaders());
    List<SubzoneModel> list = [];
    if (!(data['error'] ?? true)) {
      if (data["body"]['data'] is List) {
        try {
          for (Map element in data["body"]['data']) {
            final subzone = SubzoneModel.fromJson(element);
            list.add(
              subzone,
            );
          }
        } catch (e) {
          log(e);
        }
      }
    }
    return list;
  }
}
