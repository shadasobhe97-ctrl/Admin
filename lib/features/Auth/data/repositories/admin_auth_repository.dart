import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/login_request_model.dart';
import '../models/admin_user_model.dart';

class AdminAuthRepository {
  final ApiClient _apiClient;

  AdminAuthRepository(this._apiClient);

  Future<AdminUserModel> login(LoginRequestModel request) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );

    if (response.data['status'] == true) {
      return AdminUserModel.fromJson(response.data);
    } else {
      throw Exception(response.data['message'] ?? 'فشل تسجيل الدخول');
    }
  }

  Future<bool> logout() async {
    try {
      final response = await _apiClient.post(ApiEndpoints.logout);
      return response.data['status'] == true;
    } catch (_) {
      return false;
    }
  }
}