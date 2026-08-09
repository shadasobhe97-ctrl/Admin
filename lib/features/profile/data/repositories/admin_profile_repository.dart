import '../datasources/admin_profile_remote_data_source.dart';
import '../models/admin_profile_model.dart';

class AdminProfileRepository {
  final AdminProfileRemoteDataSource _remoteDataSource;

  AdminProfileRepository(this._remoteDataSource);

  Future<AdminProfileModel> getProfile() async {
    return await _remoteDataSource.getProfile();
  }

  Future<Map<String, dynamic>> updateProfile(dynamic adminId, Map<String, dynamic> data) async {
    return await _remoteDataSource.updateProfile(adminId, data);
  }
}
