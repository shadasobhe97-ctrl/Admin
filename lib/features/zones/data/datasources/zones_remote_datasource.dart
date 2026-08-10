import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../schools/data/models/zone_model.dart';

abstract class ZonesRemoteDataSource {
  Future<List<ZoneModel>> getZones();
  Future<List<ZoneModel>> getZonesTree();
  Future<Map<String, dynamic>> addZone(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateZone(int id, Map<String, dynamic> data);
  Future<Map<String, dynamic>> deleteZone(int id);
}

class ZonesRemoteDataSourceImpl implements ZonesRemoteDataSource {
  final ApiClient _apiClient;

  ZonesRemoteDataSourceImpl(this._apiClient);

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
        return 'غير مصرح لك بإجراء تغييرات على المناطق (403 Forbidden).';
      }
      if (statusCode == 404) {
        return 'المنطقة المطلوبة غير موجودة (404 Not Found).';
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
      throw Exception(_extractErrorMessage(e, 'فشل جلب قائمة المناطق'));
    }
  }

  @override
  Future<List<ZoneModel>> getZonesTree() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.zonesTree);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final rawList = data['data'] ?? data['tree'] ?? data['zones'];
        if (rawList is List) {
          return rawList.map((item) => ZoneModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      } else if (data is List) {
        return data.map((item) => ZoneModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      _logError('ZONES TREE API ERROR', 'GET', ApiEndpoints.zonesTree, e);
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> addZone(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.zones, data: data);
      final resData = response.data;

      if (resData is Map<String, dynamic>) {
        final isSuccess = resData['status'] == true || resData['success'] == true;
        if (isSuccess || resData['data'] != null) {
          return {
            'success': true,
            'message': resData['message']?.toString() ?? 'تم إضافة المنطقة بنجاح.',
            'data': resData['data'],
          };
        }
        throw Exception(resData['message'] ?? 'تعذر إضافة المنطقة');
      }
      throw Exception('استجابة غير متوقعة من الخادم عند إضافة المنطقة');
    } catch (e) {
      _logError('ADD ZONE API ERROR', 'POST', ApiEndpoints.zones, e);
      throw Exception(_extractErrorMessage(e, 'تعذر إضافة المنطقة'));
    }
  }

  @override
  Future<Map<String, dynamic>> updateZone(int id, Map<String, dynamic> data) async {
    final endpoint = ApiEndpoints.zoneDetails(id);
    try {
      // Must strictly use PUT as specified by Backend Contract
      final response = await _apiClient.put(endpoint, data: data);
      final resData = response.data;

      if (resData is Map<String, dynamic>) {
        final isSuccess = resData['status'] == true || resData['success'] == true;
        if (isSuccess || resData['message'] != null) {
          return {
            'success': true,
            'message': resData['message']?.toString() ?? 'تم تعديل اسم المنطقة الجغرافية بنجاح.',
          };
        }
        throw Exception(resData['message'] ?? 'تعذر تعديل المنطقة');
      }
      throw Exception('استجابة غير متوقعة من الخادم عند تعديل المنطقة');
    } catch (e) {
      _logError('UPDATE ZONE API ERROR', 'PUT', endpoint, e);
      throw Exception(_extractErrorMessage(e, 'تعذر تعديل المنطقة'));
    }
  }

  @override
  Future<Map<String, dynamic>> deleteZone(int id) async {
    final endpoint = ApiEndpoints.zoneDetails(id);
    try {
      final response = await _apiClient.delete(endpoint);
      final resData = response.data;

      if (resData is Map<String, dynamic>) {
        final isSuccess = resData['status'] == true || resData['success'] == true;
        if (isSuccess || resData['message'] != null) {
          return {
            'success': true,
            'message': resData['message']?.toString() ?? 'تم حذف المنطقة الجغرافية بنجاح.',
          };
        }
        throw Exception(resData['message'] ?? 'تعذر حذف المنطقة');
      }
      throw Exception('استجابة غير متوقعة من الخادم عند حذف المنطقة');
    } catch (e) {
      _logError('DELETE ZONE API ERROR', 'DELETE', endpoint, e);
      throw Exception(_extractErrorMessage(e, 'تعذر حذف المنطقة'));
    }
  }
}
