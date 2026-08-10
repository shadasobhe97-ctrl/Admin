import '../../../schools/data/models/zone_model.dart';
import '../datasources/zones_remote_datasource.dart';

abstract class ZonesRepository {
  Future<List<ZoneModel>> getZones();
  Future<List<ZoneModel>> getZonesTree();
  Future<Map<String, dynamic>> addZone(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateZone(int id, Map<String, dynamic> data);
  Future<Map<String, dynamic>> deleteZone(int id);
}

class ZonesRepositoryImpl implements ZonesRepository {
  final ZonesRemoteDataSource _remoteDataSource;

  ZonesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ZoneModel>> getZones() async {
    return await _remoteDataSource.getZones();
  }

  @override
  Future<List<ZoneModel>> getZonesTree() async {
    return await _remoteDataSource.getZonesTree();
  }

  @override
  Future<Map<String, dynamic>> addZone(Map<String, dynamic> data) async {
    return await _remoteDataSource.addZone(data);
  }

  @override
  Future<Map<String, dynamic>> updateZone(int id, Map<String, dynamic> data) async {
    return await _remoteDataSource.updateZone(id, data);
  }

  @override
  Future<Map<String, dynamic>> deleteZone(int id) async {
    return await _remoteDataSource.deleteZone(id);
  }
}
