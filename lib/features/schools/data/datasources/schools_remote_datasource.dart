import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/school_model.dart';
import '../models/zone_model.dart';

abstract class SchoolsRemoteDataSource {
  Future<List<SchoolModel>> getSchools({String? search});
  Future<SchoolModel> getSchoolDetails(int id);
  Future<Map<String, dynamic>> addSchool(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateSchool(int id, Map<String, dynamic> data);
  Future<Map<String, dynamic>> deleteSchool(int id);
  Future<List<ZoneModel>> getZones();
}

class SchoolsRemoteDataSourceImpl implements SchoolsRemoteDataSource {
  final ApiClient _apiClient;

  SchoolsRemoteDataSourceImpl(this._apiClient);

  void _logError(String tag, String method, String endpoint, dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode ?? 'No Status';
      final responseData = error.response?.data;
      debugPrint('[$tag] Method: $method | Endpoint: $endpoint | Status: $statusCode | Data: $responseData');
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
        return 'غير مصرح لك بإجراء هذه العملية (403 Forbidden).';
      }
      if (statusCode == 404) {
        return 'المدرسة المطلوبة غير موجودة (404 Not Found).';
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
        return 'انتهت مهلة الاتصال بالخادم، يرجى التأكد من اتصال الإنترنت.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'تعذر الاتصال بالخادم، يرجى التحقق من الشبكة.';
      }
    }
    return error.toString().replaceAll('Exception: ', '');
  }

  @override
  Future<List<SchoolModel>> getSchools({String? search}) async {
    final query = <String, dynamic>{};
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    try {
      final response = await _apiClient.get(ApiEndpoints.schools, queryParameters: query);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final rawList = data['data'] ?? data['schools'];
        if (rawList is List) {
          return rawList.map((item) => SchoolModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      } else if (data is List) {
        return data.map((item) => SchoolModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      _logError('SCHOOLS API ERROR', 'GET', ApiEndpoints.schools, e);
      throw Exception(_extractErrorMessage(e, 'فشل جلب قائمة المدارس'));
    }
  }

  @override
  Future<SchoolModel> getSchoolDetails(int id) async {
    final endpoint = ApiEndpoints.schoolDetails(id);
    try {
      final response = await _apiClient.get(endpoint);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        if (data['data'] is Map<String, dynamic>) {
          return SchoolModel.fromJson(data['data'] as Map<String, dynamic>);
        } else if (data['id'] != null || data['name'] != null) {
          return SchoolModel.fromJson(data);
        }
      }
      throw Exception('استجابة غير متوافقة من الخادم عند جلب تفاصيل المدرسة');
    } catch (e) {
      _logError('SCHOOL DETAILS API ERROR', 'GET', endpoint, e);
      throw Exception(_extractErrorMessage(e, 'فشل جلب تفاصيل المدرسة'));
    }
  }

  @override
  Future<Map<String, dynamic>> addSchool(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.schools, data: data);
      final resData = response.data;

      if (resData is Map<String, dynamic>) {
        final isSuccess = resData['success'] == true || resData['status'] == true;
        if (isSuccess || resData['data'] != null) {
          return {
            'success': true,
            'message': resData['message']?.toString() ?? 'تم إضافة المدرسة بنجاح.',
            'data': resData['data'],
          };
        }
        throw Exception(resData['message'] ?? 'تعذر إضافة المدرسة');
      }
      throw Exception('استجابة غير متوقعة من الخادم عند إضافة المدرسة');
    } catch (e) {
      _logError('ADD SCHOOL API ERROR', 'POST', ApiEndpoints.schools, e);
      throw Exception(_extractErrorMessage(e, 'تعذر إضافة المدرسة'));
    }
  }

  @override
  Future<Map<String, dynamic>> updateSchool(int id, Map<String, dynamic> data) async {
    final endpoint = ApiEndpoints.schoolDetails(id);
    try {
      final response = await _apiClient.post(endpoint, data: data);
      final resData = response.data;

      if (resData is Map<String, dynamic>) {
        final isSuccess = resData['success'] == true || resData['status'] == true;
        if (isSuccess || resData['message'] != null) {
          return {
            'success': true,
            'message': resData['message']?.toString() ?? 'تم تحديث البيانات بنجاح.',
          };
        }
        throw Exception(resData['message'] ?? 'تعذر تحديث المدرسة');
      }
      throw Exception('استجابة غير متوقعة من الخادم عند تعديل المدرسة');
    } catch (e) {
      _logError('UPDATE SCHOOL API ERROR', 'POST', endpoint, e);
      throw Exception(_extractErrorMessage(e, 'تعذر تحديث البيانات'));
    }
  }

  @override
  Future<Map<String, dynamic>> deleteSchool(int id) async {
    final endpoint = ApiEndpoints.schoolDetails(id);
    try {
      final response = await _apiClient.delete(endpoint);
      final resData = response.data;

      if (resData is Map<String, dynamic>) {
        final isSuccess = resData['success'] == true || resData['status'] == true;
        if (isSuccess || resData['message'] != null) {
          return {
            'success': true,
            'message': resData['message']?.toString() ?? 'تم حذف المدرسة بنجاح.',
          };
        }
        throw Exception(resData['message'] ?? 'تعذر حذف المدرسة');
      }
      throw Exception('استجابة غير متوقعة من الخادم عند حذف المدرسة');
    } catch (e) {
      _logError('DELETE SCHOOL API ERROR', 'DELETE', endpoint, e);
      throw Exception(_extractErrorMessage(e, 'تعذر حذف المدرسة'));
    }
  }

  @override
  Future<List<ZoneModel>> getZones() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.zones);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final rawList = data['data'] ?? data['zones'];
        if (rawList is List) {
          return rawList.map((item) => ZoneModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      } else if (data is List) {
        return data.map((item) => ZoneModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      _logError('ZONES API ERROR', 'GET', ApiEndpoints.zones, e);
      return [];
    }
  }
}
