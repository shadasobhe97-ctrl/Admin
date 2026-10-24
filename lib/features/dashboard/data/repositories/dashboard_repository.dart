import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/dashboard_stats_model.dart';
import '../models/active_trip_model.dart';
import '../models/trip_emergency_detail_model.dart';
import '../models/emergency_trip_item_model.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  void _logError(String method, String endpoint, dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode ?? 'No Status';
      final responseData = error.response?.data;
      debugPrint('[Dashboard API ERROR] $method $endpoint | Status: $statusCode | Data: $responseData');
    } else {
      debugPrint('[Dashboard API ERROR] $method $endpoint | Error: $error');
    }
  }

  String _extractErrorMessage(dynamic error, String defaultMsg) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        if (data['errors'] is Map && (data['errors'] as Map).isNotEmpty) {
          final firstVal = (data['errors'] as Map).values.first;
          if (firstVal is List && firstVal.isNotEmpty) {
            return firstVal.first.toString();
          }
          return firstVal.toString();
        }
        if (data['message'] != null && data['message'].toString().isNotEmpty) {
          return data['message'].toString();
        }
      }
      if (error.response?.statusCode == 401) {
        return 'غير مصرح للوصول (401 Unauthorized)، يرجى إعادة تسجيل الدخول.';
      }
      if (error.response?.statusCode == 403) {
        return 'ليس لديك صلاحية الوصول لوظائف لوحة التحكم (403 Forbidden).';
      }
      if (error.response?.statusCode == 500) {
        return 'حدث خطأ غير متوقع في الخادم (500 Server Error).';
      }
    }
    return error.toString().replaceAll('Exception: ', '');
  }

  /// GET /api/admin/dashboard/stats
  Future<DashboardStatsModel> getStats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.dashboardStats);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final isSuccess = data['success'] == true || data['status'] == true || data['data'] != null;
        if (isSuccess && data['data'] != null) {
          return DashboardStatsModel.fromJson(data['data']);
        }
      }
      throw Exception(data is Map ? data['message'] ?? 'فشل جلب إحصائيات اللوحة' : 'استجابة غير متوافقة من الخادم');
    } catch (e) {
      _logError('GET', ApiEndpoints.dashboardStats, e);
      throw Exception(_extractErrorMessage(e, 'فشل جلب إحصائيات اللوحة'));
    }
  }

  /// GET /api/admin/dashboard/active-trips
  Future<List<ActiveTripModel>> getActiveTrips() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.activeTrips);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final isSuccess = data['success'] == true || data['status'] == true || data['data'] != null;
        if (isSuccess) {
          final List rawList = data['data'] is List ? data['data'] : [];
          return rawList.map((e) => ActiveTripModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      throw Exception(data is Map ? data['message'] ?? 'فشل جلب الرحلات الحية' : 'استجابة غير متوافقة من الخادم');
    } catch (e) {
      _logError('GET', ApiEndpoints.activeTrips, e);
      throw Exception(_extractErrorMessage(e, 'فشل جلب الرحلات الحية'));
    }
  }

  /// POST /api/admin/trips/generate-daily
  Future<Map<String, dynamic>> generateDailyTrips({String? date}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.generateDailyTrips,
        data: date != null ? {'date': date} : {},
      );
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final isSuccess = data['success'] == true || data['status'] == true;
        if (isSuccess) {
          return {
            'success': true,
            'message': data['message'] ?? 'تم توليد رحلات اليوم بنجاح.',
            'generated_trips_count': data['generated_trips_count'] ?? 0,
          };
        }
        throw Exception(data['message'] ?? 'تعذر توليد رحلات اليوم');
      }
      throw Exception('استجابة غير متوقعة من الخادم');
    } catch (e) {
      _logError('POST', ApiEndpoints.generateDailyTrips, e);
      throw Exception(_extractErrorMessage(e, 'تعذر توليد رحلات اليوم'));
    }
  }

  /// GET /api/admin/trips/emergencies/{id}
  Future<TripEmergencyDetailModel> getEmergencyDetails(dynamic id) async {
    try {
      final endpoint = ApiEndpoints.emergencyDetails(id);
      final response = await _apiClient.get(endpoint);
      final data = response.data;

      if (data is Map) {
        final payload = data['data'];
        if (payload is Map) {
          return TripEmergencyDetailModel.fromJson(Map<String, dynamic>.from(payload));
        }
      }
      throw Exception(data is Map ? data['message'] ?? 'فشل جلب تفاصيل الطوارئ' : 'استجابة غير متوافقة من الخادم');
    } catch (e) {
      _logError('GET', ApiEndpoints.emergencyDetails(id), e);
      throw Exception(_extractErrorMessage(e, 'فشل جلب تفاصيل طوارئ الرحلة'));
    }
  }

  /// POST /api/admin/trips/emergencies/{dispatchId}/assign-substitute
  Future<Map<String, dynamic>> assignSubstituteDriver(dynamic dispatchId, int substituteDriverId) async {
    try {
      final endpoint = ApiEndpoints.assignSubstituteDriver(dispatchId);
      final response = await _apiClient.post(
        endpoint,
        data: {'substitute_driver_id': substituteDriverId},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final isSuccess = data['success'] == true || data['status'] == true || data['status'] == 'success';
        if (isSuccess) {
          return data;
        }
        throw Exception(data['message'] ?? 'تعذر تكليف السائق البديل');
      }
      throw Exception('استجابة غير متوقعة من الخادم');
    } catch (e) {
      _logError('POST', ApiEndpoints.assignSubstituteDriver(dispatchId), e);
      throw Exception(_extractErrorMessage(e, 'تعذر تكليف السائق البديل'));
    }
  }

  /// POST /api/admin/trips/emergencies/{dispatchId}/resolve
  Future<Map<String, dynamic>> resolveEmergency(dynamic dispatchId) async {
    try {
      final endpoint = ApiEndpoints.resolveEmergency(dispatchId);
      final response = await _apiClient.post(endpoint, data: {});
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final isSuccess = data['success'] == true || data['status'] == true || data['status'] == 'success';
        if (isSuccess) {
          return data;
        }
        throw Exception(data['message'] ?? 'تعذر حل وإغلاق حالة الطوارئ');
      }
      throw Exception('استجابة غير متوقعة من الخادم');
    } catch (e) {
      _logError('POST', ApiEndpoints.resolveEmergency(dispatchId), e);
      throw Exception(_extractErrorMessage(e, 'تعذر حل وإغلاق حالة الطوارئ'));
    }
  }

  /// GET /api/admin/trips/emergencies
  Future<EmergenciesListResult> getEmergenciesList({int page = 1}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.emergenciesList,
        queryParameters: {'page': page},
      );
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final isSuccess = data['status'] == 'success' || data['status'] == true || data['success'] == true;
        if (isSuccess || data.containsKey('data')) {
          return EmergenciesListResult.fromJson(data);
        }
      }
      throw Exception(data is Map ? data['message'] ?? 'فشل جلب قائمة الرحلات المعطلة' : 'استجابة غير متوافقة من الخادم');
    } catch (e) {
      _logError('GET', ApiEndpoints.emergenciesList, e);
      throw Exception(_extractErrorMessage(e, 'فشل جلب قائمة الرحلات المعطلة'));
    }
  }
}
