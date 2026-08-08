import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/login_request_model.dart';
import '../models/admin_user_model.dart';

class AdminAuthRepository {
  final ApiClient _apiClient;

  AdminAuthRepository(this._apiClient);

  Exception _handleDioError(DioException e, String method, String endpoint) {
    final status = e.response?.statusCode ?? 0;
    String message = 'حدث خطأ في الاتصال بالخادم ($status)';

    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['errors'] is Map && (data['errors'] as Map).isNotEmpty) {
        final firstVal = (data['errors'] as Map).values.first;
        if (firstVal is List && firstVal.isNotEmpty) {
          message = firstVal.first.toString();
        } else {
          message = firstVal.toString();
        }
      } else if (data['message'] != null && data['message'].toString().isNotEmpty) {
        message = data['message'].toString();
      }
    } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      message = 'انتهت مهلة الاتصال بالخادم، يرجى التحقق من الشبكة.';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'تعذر الاتصال بالخادم، يرجى التأكد من تشغيل الخادم والاتصال بالإنترنت.';
    }

    debugPrint('[AUTH API ERROR] $method $endpoint | Status: $status | Message: $message');
    return Exception(message);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Login: POST /api/auth/login
  // ────────────────────────────────────────────────────────────────────────────
  Future<AdminUserModel> login(LoginRequestModel request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == true || data['access_token'] != null || data['token'] != null) {
          return AdminUserModel.fromJson(data);
        } else {
          final msg = data['message']?.toString() ?? 'فشل عملية تسجيل الدخول';
          debugPrint('[AUTH API ERROR] POST ${ApiEndpoints.login} | Status: 200 | Message: $msg');
          throw Exception(msg);
        }
      } else {
        throw Exception('استجابة الخادم غير متوافقة');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'POST', ApiEndpoints.login);
    } catch (e) {
      rethrow;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Logout: POST /api/auth/logout
  // ────────────────────────────────────────────────────────────────────────────
  Future<bool> logout() async {
    try {
      final response = await _apiClient.post(ApiEndpoints.logout);
      if (response.data is Map<String, dynamic>) {
        return response.data['status'] == true;
      }
      return true;
    } on DioException catch (e) {
      _handleDioError(e, 'POST', ApiEndpoints.logout);
      return false;
    } catch (_) {
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Password Reset – Step 1: Send OTP
  // POST /api/admin/auth/password/send-otp
  // ────────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.adminSendOtp,
        data: {'email': email},
      );
      if (response.data is Map<String, dynamic>) return response.data;
      throw Exception('استجابة غير متوقعة من الخادم');
    } on DioException catch (e) {
      throw _handleDioError(e, 'POST', ApiEndpoints.adminSendOtp);
    } catch (e) {
      rethrow;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Password Reset – Step 2: Verify OTP
  // POST /api/admin/auth/password/verify-otp
  // ────────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.adminVerifyOtp,
        data: {'email': email, 'otp': otp},
      );
      if (response.data is Map<String, dynamic>) return response.data;
      throw Exception('استجابة غير متوقعة من الخادم');
    } on DioException catch (e) {
      throw _handleDioError(e, 'POST', ApiEndpoints.adminVerifyOtp);
    } catch (e) {
      rethrow;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Password Reset – Step 3: Reset Password
  // POST /api/admin/auth/password/reset
  // ────────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.adminResetPassword,
        data: {
          'email': email,
          'otp': otp,
          'password': newPassword,
          'password_confirmation': newPassword,
        },
      );
      if (response.data is Map<String, dynamic>) return response.data;
      throw Exception('استجابة غير متوقعة من الخادم');
    } on DioException catch (e) {
      throw _handleDioError(e, 'POST', ApiEndpoints.adminResetPassword);
    } catch (e) {
      rethrow;
    }
  }
}
