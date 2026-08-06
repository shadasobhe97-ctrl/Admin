import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/password_reset_response_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/send_otp_request_model.dart';
import '../models/verify_otp_request_model.dart';

class PasswordResetRemoteDataSource {
  final ApiClient _apiClient;

  PasswordResetRemoteDataSource(this._apiClient);

  Future<PasswordResetResponseModel> sendOtp(SendOtpRequestModel request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.adminSendOtp,
        data: request.toJson(),
      );
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<PasswordResetResponseModel> verifyOtp(VerifyOtpRequestModel request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.adminVerifyOtp,
        data: request.toJson(),
      );
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<PasswordResetResponseModel> resetPassword(ResetPasswordRequestModel request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.adminResetPassword,
        data: request.toJson(),
      );
      return _handleResponse(response.data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  PasswordResetResponseModel _handleResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      final response = PasswordResetResponseModel.fromJson(data);
      if (response.status) {
        return response;
      }
      throw Exception(response.message.isNotEmpty ? response.message : 'حدث خطأ غير متوقع، الرجاء المحاولة مرة أخرى.');
    }
    throw Exception('استجابة الخادم غير متوافقة');
  }

  Exception _mapDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return Exception(firstError.first.toString());
        }
        return Exception(firstError.toString());
      }
      final message = data['message'];
      if (message != null && message.toString().isNotEmpty) {
        return Exception(message.toString());
      }
      return Exception('حدث خطأ في الاتصال بالخادم، الرجاء المحاولة مرة أخرى.');
    }
    return Exception('تعذر الاتصال بالخادم، الرجاء التحقق من الاتصال والمحاولة مرة أخرى.');
  }
}
