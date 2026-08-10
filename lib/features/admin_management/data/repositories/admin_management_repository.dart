import '../datasources/admin_management_remote_data_source.dart';
import '../models/admin_details_model.dart';
import '../models/admin_model.dart';
import '../models/create_admin_request_model.dart';
import '../models/update_admin_request_model.dart';

class AdminManagementRepository {
  final AdminManagementRemoteDataSource _remoteDataSource;

  AdminManagementRepository(this._remoteDataSource);

  Future<List<AdminModel>> getAdmins({String? search, int page = 1, int perPage = 10}) async {
    try {
      return await _remoteDataSource.getAdmins(search: search, page: page, perPage: perPage);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<AdminDetailsModel> getAdminDetails(int id) async {
    try {
      return await _remoteDataSource.getAdminDetails(id);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<AdminModel> createAdmin(CreateAdminRequestModel request) async {
    try {
      return await _remoteDataSource.createAdmin(request);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> updateAdmin(int id, UpdateAdminRequestModel request) async {
    try {
      return await _remoteDataSource.updateAdmin(id, request);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<String> deleteAdmin(int id) async {
    try {
      return await _remoteDataSource.deleteAdmin(id);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<String> approveEmailChange(String token) async {
    try {
      return await _remoteDataSource.approveEmailChange(token);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<String> rejectEmailChange(String token) async {
    try {
      return await _remoteDataSource.rejectEmailChange(token);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
