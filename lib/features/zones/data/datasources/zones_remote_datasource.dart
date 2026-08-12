import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../models/geo_action_result.dart';
import '../../../../core/utils/json_parsers.dart';
import '../models/municipality_model.dart';
import '../models/sub_municipality_model.dart';
import '../models/zone_model.dart';

abstract class ZonesRemoteDataSource {
  // المستوى الأول: البلديات الكبرى
  Future<List<MunicipalityModel>> getMunicipalities();
  Future<GeoActionResult> addMunicipality({required String name});
  Future<GeoActionResult> updateMunicipality(int id, {required String name});
  Future<GeoActionResult> deleteMunicipality(int id);

  // المستوى الثاني: البلديات الفرعية / المحلات
  Future<List<SubMunicipalityModel>> getSubMunicipalities();
  Future<GeoActionResult> addSubMunicipality({
    required String name,
    required int municipalityId,
  });
  Future<GeoActionResult> updateSubMunicipality(
    int id, {
    required String name,
    required int municipalityId,
  });
  Future<GeoActionResult> deleteSubMunicipality(int id);

  // المستوى الثالث: المناطق الدقيقة
  Future<List<ZoneModel>> getZones();
  Future<List<MunicipalityModel>> getZonesTree();
  Future<ZoneModel> getZoneDetails(int id);
  Future<GeoActionResult> addZone({
    required String name,
    int? subMunicipalityId,
  });
  Future<GeoActionResult> updateZone(
    int id, {
    required String name,
    int? subMunicipalityId,
  });
  Future<GeoActionResult> deleteZone(int id);
}

class ZonesRemoteDataSourceImpl implements ZonesRemoteDataSource {
  final ApiClient _apiClient;

  ZonesRemoteDataSourceImpl(this._apiClient);

  // ── أدوات داخلية مشتركة ────────────────────────────────────────────────────

  void _log(String method, String endpoint, Object error) {
    if (error is DioException) {
      debugPrint(
        '[GEO API] $method $endpoint | '
        'Status: ${error.response?.statusCode} | Data: ${error.response?.data}',
      );
    } else {
      debugPrint('[GEO API] $method $endpoint | Error: $error');
    }
  }

  Never _fail(String method, String endpoint, Object error, String fallback) {
    _log(method, endpoint, error);
    throw ApiErrorMapper.map(error, fallbackMessage: fallback);
  }

  Future<List<T>> _getList<T>(
    String endpoint, {
    required T Function(Map<String, dynamic> json) parser,
    required String fallbackMessage,
  }) async {
    try {
      final response = await _apiClient.get(endpoint);
      return JsonParsers.extractList(response.data).map(parser).toList();
    } catch (error) {
      _fail('GET', endpoint, error, fallbackMessage);
    }
  }

  Future<GeoActionResult> _write(
    String endpoint, {
    required String method,
    Map<String, dynamic>? body,
    required String fallbackMessage,
    required String errorMessage,
  }) async {
    try {
      final Response response;
      switch (method) {
        case 'POST':
          response = await _apiClient.post(endpoint, data: body ?? const {});
        case 'PUT':
          response = await _apiClient.put(endpoint, data: body ?? const {});
        default:
          response = await _apiClient.delete(endpoint);
      }

      final data = response.data;
      // الخادم يستعمل `status`؛ تُقبل `success` أيضاً لتوافق بقية المسارات.
      if (data is Map && data['status'] == false && data['success'] != true) {
        throw ApiException(
          JsonParsers.extractMessage(data) ?? errorMessage,
          statusCode: response.statusCode,
        );
      }

      return GeoActionResult.fromResponse(data, fallbackMessage: fallbackMessage);
    } catch (error) {
      _fail(method, endpoint, error, errorMessage);
    }
  }

  // ── المستوى الأول: البلديات الكبرى ─────────────────────────────────────────

  @override
  Future<List<MunicipalityModel>> getMunicipalities() {
    return _getList(
      ApiEndpoints.municipalities,
      parser: MunicipalityModel.fromJson,
      fallbackMessage: 'تعذّر جلب قائمة البلديات الكبرى.',
    );
  }

  @override
  Future<GeoActionResult> addMunicipality({required String name}) {
    return _write(
      ApiEndpoints.municipalities,
      method: 'POST',
      body: {'name': name.trim()},
      fallbackMessage: 'تم إضافة البلدية الكبرى بنجاح.',
      errorMessage: 'تعذّر إضافة البلدية الكبرى.',
    );
  }

  @override
  Future<GeoActionResult> updateMunicipality(int id, {required String name}) {
    return _write(
      ApiEndpoints.municipalityDetails(id),
      method: 'PUT',
      body: {'name': name.trim()},
      fallbackMessage: 'تم تحديث اسم البلدية بنجاح.',
      errorMessage: 'تعذّر تحديث البلدية الكبرى.',
    );
  }

  @override
  Future<GeoActionResult> deleteMunicipality(int id) {
    return _write(
      ApiEndpoints.municipalityDetails(id),
      method: 'DELETE',
      fallbackMessage: 'تم حذف البلدية بنجاح.',
      errorMessage: 'تعذّر حذف البلدية الكبرى.',
    );
  }

  // ── المستوى الثاني: البلديات الفرعية / المحلات ─────────────────────────────

  @override
  Future<List<SubMunicipalityModel>> getSubMunicipalities() {
    return _getList(
      ApiEndpoints.subMunicipalities,
      parser: SubMunicipalityModel.fromJson,
      fallbackMessage: 'تعذّر جلب قائمة البلديات الفرعية.',
    );
  }

  @override
  Future<GeoActionResult> addSubMunicipality({
    required String name,
    required int municipalityId,
  }) {
    return _write(
      ApiEndpoints.subMunicipalities,
      method: 'POST',
      body: {'name': name.trim(), 'municipality_id': municipalityId},
      fallbackMessage: 'تم إضافة البلدية الفرعية بنجاح.',
      errorMessage: 'تعذّر إضافة البلدية الفرعية.',
    );
  }

  @override
  Future<GeoActionResult> updateSubMunicipality(
    int id, {
    required String name,
    required int municipalityId,
  }) {
    return _write(
      ApiEndpoints.subMunicipalityDetails(id),
      method: 'PUT',
      body: {'name': name.trim(), 'municipality_id': municipalityId},
      fallbackMessage: 'تم تحديث بيانات البلدية الفرعية بنجاح.',
      errorMessage: 'تعذّر تحديث البلدية الفرعية.',
    );
  }

  @override
  Future<GeoActionResult> deleteSubMunicipality(int id) {
    return _write(
      ApiEndpoints.subMunicipalityDetails(id),
      method: 'DELETE',
      fallbackMessage: 'تم حذف البلدية الفرعية بنجاح.',
      errorMessage: 'تعذّر حذف البلدية الفرعية.',
    );
  }

  // ── المستوى الثالث: المناطق الدقيقة ────────────────────────────────────────

  @override
  Future<List<ZoneModel>> getZones() {
    return _getList(
      ApiEndpoints.zones,
      parser: ZoneModel.fromJson,
      fallbackMessage: 'تعذّر جلب قائمة المناطق.',
    );
  }

  /// الشجرة تأتي جاهزة من الخادم بثلاثة مستويات ولا تُبنى في العميل.
  @override
  Future<List<MunicipalityModel>> getZonesTree() {
    return _getList(
      ApiEndpoints.zonesTree,
      parser: MunicipalityModel.fromJson,
      fallbackMessage: 'تعذّر جلب شجرة الجغرافيا.',
    );
  }

  @override
  Future<ZoneModel> getZoneDetails(int id) async {
    final endpoint = ApiEndpoints.zoneDetails(id);
    try {
      final response = await _apiClient.get(endpoint);
      final object = JsonParsers.extractObject(response.data);
      if (object == null) {
        throw ApiException(
          JsonParsers.extractMessage(response.data) ??
              'استجابة غير متوافقة من الخادم عند جلب تفاصيل المنطقة.',
          statusCode: response.statusCode,
        );
      }
      return ZoneModel.fromJson(object);
    } catch (error) {
      _fail('GET', endpoint, error, 'تعذّر جلب تفاصيل المنطقة.');
    }
  }

  @override
  Future<GeoActionResult> addZone({
    required String name,
    int? subMunicipalityId,
  }) {
    return _write(
      ApiEndpoints.zones,
      method: 'POST',
      body: {
        'name': name.trim(),
        // `sub_municipality_id` اختياري في العقد، فلا يُرسل إن لم يُحدَّد.
        if (subMunicipalityId != null) 'sub_municipality_id': subMunicipalityId,
      },
      fallbackMessage: 'تم إضافة المنطقة بنجاح.',
      errorMessage: 'تعذّر إضافة المنطقة.',
    );
  }

  @override
  Future<GeoActionResult> updateZone(
    int id, {
    required String name,
    int? subMunicipalityId,
  }) {
    return _write(
      ApiEndpoints.zoneDetails(id),
      method: 'PUT',
      body: {
        'name': name.trim(),
        if (subMunicipalityId != null) 'sub_municipality_id': subMunicipalityId,
      },
      fallbackMessage: 'تم تحديث بيانات المنطقة بنجاح.',
      errorMessage: 'تعذّر تحديث المنطقة.',
    );
  }

  @override
  Future<GeoActionResult> deleteZone(int id) {
    return _write(
      ApiEndpoints.zoneDetails(id),
      method: 'DELETE',
      fallbackMessage: 'تم حذف المنطقة من النظام بنجاح.',
      errorMessage: 'تعذّر حذف المنطقة.',
    );
  }
}
