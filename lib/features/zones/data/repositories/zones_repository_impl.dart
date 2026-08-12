import '../datasources/zones_remote_datasource.dart';
import '../models/geo_action_result.dart';
import '../models/municipality_model.dart';
import '../models/sub_municipality_model.dart';
import '../models/zone_model.dart';

/// عقد طبقة البيانات الجغرافية بمستوياتها الثلاثة.
abstract class ZonesRepository {
  Future<List<MunicipalityModel>> getMunicipalities();
  Future<GeoActionResult> addMunicipality({required String name});
  Future<GeoActionResult> updateMunicipality(int id, {required String name});
  Future<GeoActionResult> deleteMunicipality(int id);

  Future<List<SubMunicipalityModel>> getSubMunicipalities();
  Future<GeoActionResult> addSubMunicipality({
    required String name,
    required int municipalityId,
  });
  Future<GeoActionResult> updateSubMunicipality(
    int id, {
    required String name,
    required int municipalityId,
  });
  Future<GeoActionResult> deleteSubMunicipality(int id);

  Future<List<ZoneModel>> getZones();
  Future<List<MunicipalityModel>> getZonesTree();
  Future<ZoneModel> getZoneDetails(int id);
  Future<GeoActionResult> addZone({
    required String name,
    int? subMunicipalityId,
  });
  Future<GeoActionResult> updateZone(
    int id, {
    required String name,
    int? subMunicipalityId,
  });
  Future<GeoActionResult> deleteZone(int id);
}

class ZonesRepositoryImpl implements ZonesRepository {
  final ZonesRemoteDataSource _remoteDataSource;

  ZonesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<MunicipalityModel>> getMunicipalities() =>
      _remoteDataSource.getMunicipalities();

  @override
  Future<GeoActionResult> addMunicipality({required String name}) =>
      _remoteDataSource.addMunicipality(name: name);

  @override
  Future<GeoActionResult> updateMunicipality(int id, {required String name}) =>
      _remoteDataSource.updateMunicipality(id, name: name);

  @override
  Future<GeoActionResult> deleteMunicipality(int id) =>
      _remoteDataSource.deleteMunicipality(id);

  @override
  Future<List<SubMunicipalityModel>> getSubMunicipalities() =>
      _remoteDataSource.getSubMunicipalities();

  @override
  Future<GeoActionResult> addSubMunicipality({
    required String name,
    required int municipalityId,
  }) =>
      _remoteDataSource.addSubMunicipality(
        name: name,
        municipalityId: municipalityId,
      );

  @override
  Future<GeoActionResult> updateSubMunicipality(
    int id, {
    required String name,
    required int municipalityId,
  }) =>
      _remoteDataSource.updateSubMunicipality(
        id,
        name: name,
        municipalityId: municipalityId,
      );

  @override
  Future<GeoActionResult> deleteSubMunicipality(int id) =>
      _remoteDataSource.deleteSubMunicipality(id);

  @override
  Future<List<ZoneModel>> getZones() => _remoteDataSource.getZones();

  @override
  Future<List<MunicipalityModel>> getZonesTree() =>
      _remoteDataSource.getZonesTree();

  @override
  Future<ZoneModel> getZoneDetails(int id) =>
      _remoteDataSource.getZoneDetails(id);

  @override
  Future<GeoActionResult> addZone({
    required String name,
    int? subMunicipalityId,
  }) =>
      _remoteDataSource.addZone(
        name: name,
        subMunicipalityId: subMunicipalityId,
      );

  @override
  Future<GeoActionResult> updateZone(
    int id, {
    required String name,
    int? subMunicipalityId,
  }) =>
      _remoteDataSource.updateZone(
        id,
        name: name,
        subMunicipalityId: subMunicipalityId,
      );

  @override
  Future<GeoActionResult> deleteZone(int id) =>
      _remoteDataSource.deleteZone(id);
}
