import '../datasources/admin_profile_remote_data_source.dart';
import '../models/admin_profile_model.dart';
import '../models/email_change_status_model.dart';
import '../models/profile_update_request.dart';

class AdminProfileRepository {
  final AdminProfileRemoteDataSource _remoteDataSource;

  AdminProfileRepository(this._remoteDataSource);

  Future<AdminProfileModel> getProfile() async {
    return await _remoteDataSource.getProfile();
  }

  Future<Map<String, dynamic>> updateProfile(ProfileUpdateRequest request) async {
    return await _remoteDataSource.updateProfile(request);
  }

  Future<EmailChangeStatusModel> getEmailChangeStatus() async {
    return await _remoteDataSource.getEmailChangeStatus();
  }

  Future<String> cancelEmailChange() async {
    return await _remoteDataSource.cancelEmailChange();
  }

  Future<String> resendEmailVerification() async {
    return await _remoteDataSource.resendEmailVerification();
  }
}
