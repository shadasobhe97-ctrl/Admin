import '../../../zones/data/models/zone_model.dart';
import '../datasources/schools_remote_datasource.dart';
import '../models/school_model.dart';
import '../models/school_payload.dart';

/// عقد طبقة البيانات كما تراه طبقة المنطق.
/// الشاشات والـ Cubit لا تعرف شيئاً عن Dio أو مسارات الـ API.
abstract class SchoolsRepository {
  Future<List<SchoolModel>> getSchools();
  Future<SchoolModel> getSchoolDetails(int id);
  Future<SchoolActionResult> addSchool(CreateSchoolPayload payload);
  Future<SchoolActionResult> updateSchool(int id, UpdateSchoolPayload payload);
  Future<SchoolActionResult> deleteSchool(int id);
  Future<List<ZoneModel>> getZones();
}

class SchoolsRepositoryImpl implements SchoolsRepository {
  final SchoolsRemoteDataSource _remoteDataSource;

  SchoolsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<SchoolModel>> getSchools() => _remoteDataSource.getSchools();

  @override
  Future<SchoolModel> getSchoolDetails(int id) =>
      _remoteDataSource.getSchoolDetails(id);

  @override
  Future<SchoolActionResult> addSchool(CreateSchoolPayload payload) =>
      _remoteDataSource.addSchool(payload);

  @override
  Future<SchoolActionResult> updateSchool(
    int id,
    UpdateSchoolPayload payload,
  ) =>
      _remoteDataSource.updateSchool(id, payload);

  @override
  Future<SchoolActionResult> deleteSchool(int id) =>
      _remoteDataSource.deleteSchool(id);

  @override
  Future<List<ZoneModel>> getZones() => _remoteDataSource.getZones();
}
