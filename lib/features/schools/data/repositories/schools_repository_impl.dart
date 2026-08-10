import '../datasources/schools_remote_datasource.dart';
import '../models/school_model.dart';
import '../models/zone_model.dart';

abstract class SchoolsRepository {
  Future<List<SchoolModel>> getSchools({String? search});
  Future<SchoolModel> getSchoolDetails(int id);
  Future<Map<String, dynamic>> addSchool(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateSchool(int id, Map<String, dynamic> data);
  Future<Map<String, dynamic>> deleteSchool(int id);
  Future<List<ZoneModel>> getZones();
}

class SchoolsRepositoryImpl implements SchoolsRepository {
  final SchoolsRemoteDataSource _remoteDataSource;

  SchoolsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<SchoolModel>> getSchools({String? search}) async {
    return await _remoteDataSource.getSchools(search: search);
  }

  @override
  Future<SchoolModel> getSchoolDetails(int id) async {
    return await _remoteDataSource.getSchoolDetails(id);
  }

  @override
  Future<Map<String, dynamic>> addSchool(Map<String, dynamic> data) async {
    return await _remoteDataSource.addSchool(data);
  }

  @override
  Future<Map<String, dynamic>> updateSchool(int id, Map<String, dynamic> data) async {
    return await _remoteDataSource.updateSchool(id, data);
  }

  @override
  Future<Map<String, dynamic>> deleteSchool(int id) async {
    return await _remoteDataSource.deleteSchool(id);
  }

  @override
  Future<List<ZoneModel>> getZones() async {
    return await _remoteDataSource.getZones();
  }
}
