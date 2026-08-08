import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/admin_details_model.dart';
import '../models/admin_model.dart';
import '../models/create_admin_request_model.dart';
import '../models/update_admin_request_model.dart';

class AdminManagementRemoteDataSource {
  final ApiClient _apiClient;

  AdminManagementRemoteDataSource(this._apiClient);

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

    debugPrint('[ADMIN MANAGEMENT API ERROR]\nMETHOD: $method\nENDPOINT: $endpoint\nSTATUS: $status\nMESSAGE: $message');
    return Exception(message);
  }

  /// GET /api/admin/admins
  /// GET /api/admin/admins?search=...
  Future<List<AdminModel>> getAdmins({String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _apiClient.get(
        ApiEndpoints.admins,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final list = data['data'];
        if (list is List) {
          return list.map((item) => AdminModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      } else if (data is List) {
        return data.map((item) => AdminModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e, 'GET', ApiEndpoints.admins);
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/admin/admins/{id}
  Future<AdminDetailsModel> getAdminDetails(int id) async {
    final endpoint = ApiEndpoints.adminDetails(id);
    try {
      final response = await _apiClient.get(endpoint);
      if (response.data is Map<String, dynamic>) {
        return AdminDetailsModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('استجابة غير متوافقة من الخادم عند جلب تفاصيل المشرف');
    } on DioException catch (e) {
      throw _handleDioError(e, 'GET', endpoint);
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/admin/admins (multipart/form-data)
  Future<AdminModel> createAdmin(CreateAdminRequestModel request) async {
    try {
      final formData = await request.toFormData();
      final response = await _apiClient.post(
        ApiEndpoints.admins,
        data: formData,
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final adminData = data['data'] is Map<String, dynamic> ? data['data'] : data;
        return AdminModel.fromJson(adminData as Map<String, dynamic>);
      }
      throw Exception('استجابة الخادم غير متوافقة عند إنشاء المشرف');
    } on DioException catch (e) {
      throw _handleDioError(e, 'POST', ApiEndpoints.admins);
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/admin/admins/{id} (multipart/form-data)
  Future<AdminModel> updateAdmin(int id, UpdateAdminRequestModel request) async {
    final endpoint = ApiEndpoints.adminDetails(id);
    try {
      final formData = await request.toFormData();
      final response = await _apiClient.post(
        endpoint,
        data: formData,
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final adminData = data['data'] is Map<String, dynamic> ? data['data'] : data;
        return AdminModel.fromJson(adminData as Map<String, dynamic>);
      }
      throw Exception('استجابة الخادم غير متوافقة عند تحديث بيانات المشرف');
    } on DioException catch (e) {
      throw _handleDioError(e, 'POST', endpoint);
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/admin/admin/email/approve/{token}
  Future<String> approveEmailChange(String token) async {
    final endpoint = ApiEndpoints.adminEmailApprove(token);
    try {
      final response = await _apiClient.get(endpoint);
      if (response.data is Map<String, dynamic>) {
        return response.data['message']?.toString() ?? 'تم تفعيل وتحديث بريدك الإلكتروني بنجاح!';
      }
      return 'تم تفعيل وتحديث بريدك الإلكتروني بنجاح!';
    } on DioException catch (e) {
      throw _handleDioError(e, 'GET', endpoint);
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/admin/admin/email/reject/{token}
  Future<String> rejectEmailChange(String token) async {
    final endpoint = ApiEndpoints.adminEmailReject(token);
    try {
      final response = await _apiClient.get(endpoint);
      if (response.data is Map<String, dynamic>) {
        return response.data['message']?.toString() ?? 'تم رفض تغيير البريد الإلكتروني.';
      }
      return 'تم رفض تغيير البريد الإلكتروني.';
    } on DioException catch (e) {
      throw _handleDioError(e, 'GET', endpoint);
    } catch (e) {
      rethrow;
    }
  }
}
