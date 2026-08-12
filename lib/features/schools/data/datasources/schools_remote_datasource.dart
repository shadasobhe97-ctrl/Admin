import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/json_parsers.dart';
import '../../../zones/data/models/zone_model.dart';
import '../models/school_model.dart';
import '../models/school_payload.dart';

/// نتيجة أي عملية كتابة على المدارس: رسالة الخادم كما هي.
class SchoolActionResult {
  final String message;
  final SchoolModel? school;

  const SchoolActionResult({required this.message, this.school});
}

abstract class SchoolsRemoteDataSource {
  Future<List<SchoolModel>> getSchools();
  Future<SchoolModel> getSchoolDetails(int id);
  Future<SchoolActionResult> addSchool(CreateSchoolPayload payload);
  Future<SchoolActionResult> updateSchool(int id, UpdateSchoolPayload payload);
  Future<SchoolActionResult> deleteSchool(int id);
  Future<List<ZoneModel>> getZones();
}

class SchoolsRemoteDataSourceImpl implements SchoolsRemoteDataSource {
  final ApiClient _apiClient;

  SchoolsRemoteDataSourceImpl(this._apiClient);

  void _log(String method, String endpoint, Object error) {
    if (error is DioException) {
      debugPrint(
        '[SCHOOLS API] $method $endpoint | '
        'Status: ${error.response?.statusCode} | Data: ${error.response?.data}',
      );
    } else {
      debugPrint('[SCHOOLS API] $method $endpoint | Error: $error');
    }
  }

  Never _fail(String method, String endpoint, Object error, String fallback) {
    _log(method, endpoint, error);
    throw ApiErrorMapper.map(error, fallbackMessage: fallback);
  }

  /// يتحقق من أن الخادم لم يعلن الفشل داخل جسم استجابة ناجحة الحالة،
  /// ثم يبني النتيجة برسالة الخادم.
  SchoolActionResult _resultFrom(
    Response response, {
    required String fallbackMessage,
    required String errorMessage,
  }) {
    final body = response.data;

    if (JsonParsers.declaresFailure(body)) {
      throw ApiException(
        JsonParsers.extractMessage(body) ?? errorMessage,
        statusCode: response.statusCode,
      );
    }

    final object = JsonParsers.extractObject(body);
    return SchoolActionResult(
      message: JsonParsers.extractMessage(body) ?? fallbackMessage,
      school: object == null ? null : SchoolModel.fromJson(object),
    );
  }

  /// العقد لا يوثّق أي Query Parameters لهذا المسار، فلا تُرسل أي فلاتر.
  @override
  Future<List<SchoolModel>> getSchools() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.schools);
      return JsonParsers.extractList(response.data)
          .map(SchoolModel.fromJson)
          .toList();
    } catch (error) {
      _fail('GET', ApiEndpoints.schools, error, 'تعذّر جلب قائمة المدارس.');
    }
  }

  @override
  Future<SchoolModel> getSchoolDetails(int id) async {
    final endpoint = ApiEndpoints.schoolDetails(id);
    try {
      final response = await _apiClient.get(endpoint);
      final object = JsonParsers.extractObject(response.data);
      if (object == null) {
        throw ApiException(
          JsonParsers.extractMessage(response.data) ??
              'استجابة غير متوافقة من الخادم عند جلب تفاصيل المدرسة.',
          statusCode: response.statusCode,
        );
      }
      return SchoolModel.fromJson(object);
    } catch (error) {
      _fail('GET', endpoint, error, 'تعذّر جلب تفاصيل المدرسة.');
    }
  }

  @override
  Future<SchoolActionResult> addSchool(CreateSchoolPayload payload) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.schools,
        data: payload.toJson(),
      );
      return _resultFrom(
        response,
        fallbackMessage: 'تم إضافة المدرسة بنجاح.',
        errorMessage: 'تعذّر إضافة المدرسة.',
      );
    } catch (error) {
      _fail('POST', ApiEndpoints.schools, error, 'تعذّر إضافة المدرسة.');
    }
  }

  @override
  Future<SchoolActionResult> updateSchool(
    int id,
    UpdateSchoolPayload payload,
  ) async {
    final endpoint = ApiEndpoints.schoolDetails(id);
    try {
      // العقد يحدد PUT كمسار التعديل الأساسي.
      final response = await _apiClient.put(endpoint, data: payload.toJson());
      return _resultFrom(
        response,
        fallbackMessage: 'تم تحديث بيانات المدرسة بنجاح.',
        errorMessage: 'تعذّر تحديث بيانات المدرسة.',
      );
    } catch (error) {
      _fail('PUT', endpoint, error, 'تعذّر تحديث بيانات المدرسة.');
    }
  }

  /// الخادم يمنع الحذف عند وجود أطفال مسجّلين ويردّ بـ 422 مع
  /// `error_code: SCHOOL_IN_USE`؛ رسالته تُعرض للمستخدم كما هي.
  @override
  Future<SchoolActionResult> deleteSchool(int id) async {
    final endpoint = ApiEndpoints.schoolDetails(id);
    try {
      final response = await _apiClient.delete(endpoint);
      return _resultFrom(
        response,
        fallbackMessage: 'تم حذف المدرسة من النظام بنجاح.',
        errorMessage: 'تعذّر حذف المدرسة.',
      );
    } catch (error) {
      _fail('DELETE', endpoint, error, 'تعذّر حذف المدرسة.');
    }
  }

  /// قائمة المناطق مطلوبة لربط المدرسة جغرافياً عبر `zone_id`.
  @override
  Future<List<ZoneModel>> getZones() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.zones);
      return JsonParsers.extractList(response.data)
          .map(ZoneModel.fromJson)
          .toList();
    } catch (error) {
      _fail('GET', ApiEndpoints.zones, error, 'تعذّر جلب قائمة المناطق.');
    }
  }
}
