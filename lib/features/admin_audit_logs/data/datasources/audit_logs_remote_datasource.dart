import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/models/paginated_result.dart';
import '../../../../core/models/pagination_meta_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/json_parsers.dart';
import '../models/audit_log_filters.dart';
import '../models/audit_log_model.dart';

/// المصدر الوحيد لطلبات سجل إجراءات المشرفين.
/// السجل للقراءة فقط — لا توجد أي عملية كتابة أو حذف عليه.
abstract class AuditLogsRemoteDataSource {
  Future<PaginatedResult<AuditLogModel>> getAuditLogs(AuditLogFilters filters);
  Future<AuditLogModel> getAuditLogDetails(int id);
}

class AuditLogsRemoteDataSourceImpl implements AuditLogsRemoteDataSource {
  final ApiClient _apiClient;

  AuditLogsRemoteDataSourceImpl(this._apiClient);

  void _log(String endpoint, Object error) {
    if (error is DioException) {
      debugPrint(
        '[AUDIT LOGS API] GET $endpoint | '
        'Status: ${error.response?.statusCode} | Data: ${error.response?.data}',
      );
    } else {
      debugPrint('[AUDIT LOGS API] GET $endpoint | Error: $error');
    }
  }

  Never _fail(String endpoint, Object error, String fallback) {
    _log(endpoint, error);
    throw ApiErrorMapper.map(error, fallbackMessage: fallback);
  }

  @override
  Future<PaginatedResult<AuditLogModel>> getAuditLogs(
    AuditLogFilters filters,
  ) async {
    const endpoint = ApiEndpoints.adminAuditLogs;
    try {
      final response = await _apiClient.get(
        endpoint,
        queryParameters: filters.toQuery(),
      );

      if (JsonParsers.declaresFailure(response.data)) {
        throw ApiException(
          JsonParsers.extractMessage(response.data) ??
              'تعذّر جلب سجل إجراءات المشرفين.',
          statusCode: response.statusCode,
        );
      }

      return PaginatedResult<AuditLogModel>(
        items: JsonParsers.extractList(response.data)
            .map(AuditLogModel.fromJson)
            .toList(),
        meta: PaginationMetaModel.fromJson(
          JsonParsers.extractMeta(response.data),
        ),
      );
    } catch (error) {
      _fail(endpoint, error, 'تعذّر جلب سجل إجراءات المشرفين.');
    }
  }

  @override
  Future<AuditLogModel> getAuditLogDetails(int id) async {
    final endpoint = ApiEndpoints.adminAuditLogDetails(id);
    try {
      final response = await _apiClient.get(endpoint);
      final object = JsonParsers.extractObject(response.data);

      if (object == null) {
        throw ApiException(
          JsonParsers.extractMessage(response.data) ??
              'استجابة غير متوافقة من الخادم عند جلب تفاصيل السجل.',
          statusCode: response.statusCode,
        );
      }

      return AuditLogModel.fromJson(object);
    } catch (error) {
      _fail(endpoint, error, 'تعذّر جلب تفاصيل سجل الإجراء.');
    }
  }
}
