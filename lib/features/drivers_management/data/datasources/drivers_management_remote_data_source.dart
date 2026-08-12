import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/driver_change_details_model.dart';
import '../models/driver_change_request_model.dart';
import '../models/driver_details_model.dart';
import '../models/driver_model.dart';
import '../models/driver_review_model.dart';
import '../../../../core/models/pagination_meta_model.dart';

class DriversListResult {
  final List<DriverModel> drivers;
  final PaginationMetaModel meta;

  DriversListResult({required this.drivers, required this.meta});
}

class DriversManagementRemoteDataSource {
  final ApiClient _apiClient;

  DriversManagementRemoteDataSource(this._apiClient);

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

    debugPrint('[DRIVERS API ERROR]\nMETHOD: $method\nENDPOINT: $endpoint\nSTATUS: $status\nMESSAGE: $message');
    return Exception(message);
  }

  /// 1. GET /api/admin/drivers
  Future<DriversListResult> getDrivers({
    String? status,
    String? search,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (status != null && status.trim().isNotEmpty && status.trim() != 'all') {
        queryParams['status'] = status.trim();
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _apiClient.get(
        ApiEndpoints.drivers,
        queryParameters: queryParams,
      );

      final data = response.data;
      List<DriverModel> drivers = [];
      PaginationMetaModel meta = PaginationMetaModel(currentPage: page);

      if (data is Map<String, dynamic>) {
        final listRaw = data['data'];
        if (listRaw is List) {
          drivers = listRaw.map((item) => DriverModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        if (data['meta'] is Map<String, dynamic>) {
          meta = PaginationMetaModel.fromJson(data['meta']);
        }
      } else if (data is List) {
        drivers = data.map((item) => DriverModel.fromJson(item as Map<String, dynamic>)).toList();
      }

      return DriversListResult(drivers: drivers, meta: meta);
    } on DioException catch (e) {
      throw _handleDioError(e, 'GET', ApiEndpoints.drivers);
    } catch (e) {
      rethrow;
    }
  }

  /// 2. GET /api/admin/drivers/{id}
  Future<DriverDetailsModel> getDriverDetails(int id) async {
    final endpoint = ApiEndpoints.driverDetails(id);
    try {
      final response = await _apiClient.get(endpoint);
      if (response.data is Map<String, dynamic>) {
        return DriverDetailsModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('استجابة غير متوافقة من الخادم عند جلب تفاصيل السائق');
    } on DioException catch (e) {
      throw _handleDioError(e, 'GET', endpoint);
    } catch (e) {
      rethrow;
    }
  }

  /// 3. POST /api/admin/drivers/{id}/review
  Future<String> reviewDriver({
    required int id,
    required String status, // Approved or Rejected
    String? rejectionReason,
  }) async {
    final endpoint = ApiEndpoints.driverReview(id);
    try {
      final Map<String, dynamic> body = {'status': status};
      if (status == 'Rejected' && rejectionReason != null && rejectionReason.trim().isNotEmpty) {
        body['rejection_reason'] = rejectionReason.trim();
      }

      final response = await _apiClient.post(endpoint, data: body);
      if (response.data is Map<String, dynamic>) {
        return response.data['message']?.toString() ?? 'تمت مراجعة طلب السائق بنجاح.';
      }
      return 'تمت مراجعة طلب السائق بنجاح.';
    } on DioException catch (e) {
      throw _handleDioError(e, 'POST', endpoint);
    } catch (e) {
      rethrow;
    }
  }

  /// 4. GET /api/admin/drivers/pending-changes
  Future<List<DriverChangeRequestModel>> getPendingDriverChanges({int page = 1}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.pendingChanges,
        queryParameters: {'page': page},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final listRaw = data['data'];
        if (listRaw is List) {
          return listRaw.map((item) => DriverChangeRequestModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      } else if (data is List) {
        return data.map((item) => DriverChangeRequestModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e, 'GET', ApiEndpoints.pendingChanges);
    } catch (e) {
      rethrow;
    }
  }

  /// 5. GET /api/admin/drivers/pending-changes/{id}
  Future<DriverChangeDetailsModel> getPendingDriverChangeDetails(int id) async {
    final endpoint = ApiEndpoints.pendingChangeDetails(id);
    try {
      final response = await _apiClient.get(endpoint);
      if (response.data is Map<String, dynamic>) {
        return DriverChangeDetailsModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('استجابة غير متوافقة عند جلب تفاصيل طلب التعديل');
    } on DioException catch (e) {
      throw _handleDioError(e, 'GET', endpoint);
    } catch (e) {
      rethrow;
    }
  }

  /// 6. POST /api/admin/drivers/pending-changes/{id}/review
  Future<String> reviewDriverChange({
    required int id,
    required String decision, // Approved or Rejected
    String? rejectionReason,
  }) async {
    final endpoint = ApiEndpoints.pendingChangeReview(id);
    try {
      final Map<String, dynamic> body = {'decision': decision};
      if (decision == 'Rejected' && rejectionReason != null && rejectionReason.trim().isNotEmpty) {
        body['rejection_reason'] = rejectionReason.trim();
      }

      final response = await _apiClient.post(endpoint, data: body);
      if (response.data is Map<String, dynamic>) {
        return response.data['message']?.toString() ?? 'تمت مراجعة تعديلات السائق بنجاح.';
      }
      return 'تمت مراجعة تعديلات السائق بنجاح.';
    } on DioException catch (e) {
      throw _handleDioError(e, 'POST', endpoint);
    } catch (e) {
      rethrow;
    }
  }

  /// 7. GET /api/admin/driver-reviews/all
  Future<List<DriverReviewModel>> getAllDriverReviews() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.driverReviewsAll);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final listRaw = data['data'];
        if (listRaw is List) {
          return listRaw.map((item) => DriverReviewModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      } else if (data is List) {
        return data.map((item) => DriverReviewModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e, 'GET', ApiEndpoints.driverReviewsAll);
    } catch (e) {
      rethrow;
    }
  }

  /// 8. GET /api/admin/driver-reviews/driver/{driverId}
  Future<List<DriverReviewModel>> getDriverReviewsForDriver(int driverId) async {
    final endpoint = ApiEndpoints.driverReviewsForDriver(driverId);
    try {
      final response = await _apiClient.get(endpoint);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final listRaw = data['data'];
        if (listRaw is List) {
          return listRaw.map((item) => DriverReviewModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      } else if (data is List) {
        return data.map((item) => DriverReviewModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e, 'GET', endpoint);
    } catch (e) {
      rethrow;
    }
  }

  /// 9. DELETE /api/admin/driver-reviews/{id}
  Future<String> deleteDriverReview(int reviewId) async {
    final endpoint = ApiEndpoints.deleteDriverReview(reviewId);
    try {
      final response = await _apiClient.delete(endpoint);
      if (response.data is Map<String, dynamic>) {
        return response.data['message']?.toString() ?? 'تم حذف التقييم بنجاح.';
      }
      return 'تم حذف التقييم بنجاح.';
    } on DioException catch (e) {
      throw _handleDioError(e, 'DELETE', endpoint);
    } catch (e) {
      rethrow;
    }
  }
}
