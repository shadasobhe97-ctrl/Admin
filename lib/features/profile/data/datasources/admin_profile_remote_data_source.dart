import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/admin_profile_model.dart';

abstract class AdminProfileRemoteDataSource {
  Future<AdminProfileModel> getProfile();
  Future<Map<String, dynamic>> updateProfile(dynamic adminId, Map<String, dynamic> data);
}

class AdminProfileRemoteDataSourceImpl implements AdminProfileRemoteDataSource {
  final ApiClient _apiClient;

  AdminProfileRemoteDataSourceImpl(this._apiClient);

  void _logError(String tag, String method, String endpoint, dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode ?? 'No Status';
      dynamic responseData = error.response?.data;

      // Sanitize sensitive fields before logging
      if (responseData is Map<String, dynamic>) {
        final sanitized = Map<String, dynamic>.from(responseData);
        sanitized.remove('password');
        sanitized.remove('password_confirmation');
        sanitized.remove('token');
        sanitized.remove('access_token');
        responseData = sanitized;
      }

      debugPrint('[$tag]');
      debugPrint('Method: $method');
      debugPrint('Endpoint: $endpoint');
      debugPrint('Status Code: $statusCode');
      debugPrint('Message: $responseData');
    } else {
      debugPrint('[$tag] Method: $method | Endpoint: $endpoint | Error: $error');
    }
  }

  String _extractErrorMessage(dynamic error, String defaultMsg) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        if (data['errors'] is Map && (data['errors'] as Map).isNotEmpty) {
          final errorsMap = data['errors'] as Map;
          final List<String> messages = [];
          for (var entry in errorsMap.entries) {
            if (entry.value is List && (entry.value as List).isNotEmpty) {
              messages.add((entry.value as List).first.toString());
            } else if (entry.value != null) {
              messages.add(entry.value.toString());
            }
          }
          if (messages.isNotEmpty) {
            return messages.join('\n');
          }
        }
        if (data['message'] != null && data['message'].toString().isNotEmpty) {
          return data['message'].toString();
        }
      }
      final statusCode = error.response?.statusCode;
      if (statusCode == 401) {
        return 'انتهت الجلسة (401 Unauthorized)، يرجى إعادة تسجيل الدخول.';
      }
      if (statusCode == 403) {
        return 'غير مصرح لك باستعرض أو تعديل البروفايل (403 Forbidden).';
      }
      if (statusCode == 422) {
        return 'البيانات المدخلة غير صالحة (422 Unprocessable Entity).';
      }
      if (statusCode == 500) {
        return 'حدث خطأ في الخادم (500 Internal Server Error).';
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'انتهت مهلة الاتصال بالخادم، يرجى التأكد من الاتصال بالإنترنت.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'تعذر الاتصال بالخادم، يرجى التحقق من الشبكة.';
      }
    }
    return error.toString().replaceAll('Exception: ', '');
  }

  @override
  Future<AdminProfileModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final isSuccess = data['status'] == true || data['success'] == true || data['data'] != null;
        if (isSuccess && data['data'] is Map<String, dynamic>) {
          return AdminProfileModel.fromJson(data['data'] as Map<String, dynamic>);
        } else if (data['id'] != null || data['full_name'] != null) {
          return AdminProfileModel.fromJson(data);
        }
        throw Exception(data['message'] ?? 'فشل جلب بيانات البروفايل من الخادم');
      }
      throw Exception('استجابة غير متوافقة من الخادم عند جلب البروفايل');
    } catch (e) {
      _logError('PROFILE API ERROR', 'GET', ApiEndpoints.profile, e);
      throw Exception(_extractErrorMessage(e, 'فشل جلب بيانات البروفايل'));
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfile(dynamic adminId, Map<String, dynamic> updateData) async {
    final endpoint = ApiEndpoints.adminDetails(adminId);
    try {
      final response = await _apiClient.post(endpoint, data: updateData);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final isSuccess = data['status'] == true || data['success'] == true;
        if (isSuccess) {
          AdminProfileModel? updatedModel;
          if (data['data'] is Map<String, dynamic>) {
            updatedModel = AdminProfileModel.fromJson(data['data'] as Map<String, dynamic>);
          }
          return {
            'status': true,
            'message': data['message']?.toString() ?? 'تم تحديث بيانات البروفايل بنجاح.',
            'profile': updatedModel,
          };
        }
        throw Exception(data['message'] ?? 'تعذر تحديث البروفايل');
      }
      throw Exception('استجابة غير متوقعة من الخادم عند التحديث');
    } catch (e) {
      _logError('UPDATE PROFILE API ERROR', 'POST', endpoint, e);
      throw Exception(_extractErrorMessage(e, 'تعذر تحديث البروفايل'));
    }
  }
}
