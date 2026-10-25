import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../models/dashboard_stats_model.dart';
import '../models/active_trip_model.dart';

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
    return ApiErrorMapper.map(error, fallbackMessage: defaultMsg).message;
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
}
