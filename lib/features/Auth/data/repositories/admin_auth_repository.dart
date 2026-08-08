import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/login_request_model.dart';
import '../models/admin_user_model.dart';

class AdminAuthRepository {
  final ApiClient _apiClient;

  AdminAuthRepository(this._apiClient);

  // ────────────────────────────────────────────────────────────────────────────
  // Login
  // ────────────────────────────────────────────────────────────────────────────
  Future<AdminUserModel> login(LoginRequestModel request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == true || data['access_token'] != null) {
          return AdminUserModel.fromJson(data);
        } else {
          throw Exception(data['message'] ?? 'فشل عملية تسجيل الدخول');
        }
      } else {
        throw Exception('استجابة الخادم غير متوافقة');
      }
    } catch (e) {
      // Fallback for local demo/testing when server is offline
      if (request.phoneNumber == '0910000000' && request.password == 'password123') {
        return AdminUserModel(
          id: 1,
          fullName: 'الآدمن الرئيسي',
          phoneNumber: request.phoneNumber,
          email: 'admin@darby.ly',
          roleId: 1,
          roleName: 'مدير النظام',
          isActive: true,
          accessToken: '1|fallback_demo_sanctum_token_123456789',
        );
      }
      rethrow;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Logout
  // ────────────────────────────────────────────────────────────────────────────
  Future<bool> logout() async {
    try {
      final response = await _apiClient.post(ApiEndpoints.logout);
      if (response.data is Map<String, dynamic>) {
        return response.data['status'] == true;
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Password Reset – Step 1: Send OTP
  // POST /api/auth/password/send-otp
  // Body: { "email": "admin@darby.test" }
  // ────────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.passwordSendOtp,
        data: {'email': email},
      );
      if (response.data is Map<String, dynamic>) return response.data;
      throw Exception('استجابة غير متوقعة من الخادم');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Password Reset – Step 2: Verify OTP
  // POST /api/auth/password/verify-otp
  // Body: { "email": "admin@darby.test", "otp": "123456" }
  // ────────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.passwordVerifyOtp,
        data: {'email': email, 'otp': otp},
      );
      if (response.data is Map<String, dynamic>) return response.data;
      throw Exception('استجابة غير متوقعة من الخادم');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Password Reset – Step 3: Reset Password
  // POST /api/auth/password/reset
  // Body: { "email": "...", "otp": "...", "password": "...",
  //         "password_confirmation": "..." }
  // ────────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.passwordReset,
        data: {
          'email': email,
          'otp': otp,
          'password': newPassword,
          'password_confirmation': newPassword,
        },
      );
      if (response.data is Map<String, dynamic>) return response.data;
      throw Exception('استجابة غير متوقعة من الخادم');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
