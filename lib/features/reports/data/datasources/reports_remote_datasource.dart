import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/json_parsers.dart';
import '../models/drivers_performance_report_model.dart';
import '../models/financial_report_model.dart';
import '../models/kpi_summary_model.dart';
import '../models/report_export_model.dart';
import '../models/report_filters.dart';
import '../models/subscriptions_report_model.dart';
import '../models/trips_report_model.dart';

/// المصدر الوحيد لطلبات التقارير.
/// يتصل بـ [ApiClient] فقط، ولا يعيد أي بيانات افتراضية عند الفشل.
abstract class ReportsRemoteDataSource {
  Future<KpiSummaryModel> getKpiSummary();
  Future<FinancialReportModel> getFinancialReport(ReportFilters filters);
  Future<TripsReportModel> getTripsReport(ReportFilters filters);
  Future<SubscriptionsReportModel> getSubscriptionsReport(
    ReportFilters filters,
  );
  Future<DriversPerformanceReportModel> getDriversPerformance(
    ReportFilters filters,
  );
  Future<ReportExportModel> exportReport({
    required String type,
    required String format,
    required ReportFilters filters,
  });
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final ApiClient _apiClient;

  ReportsRemoteDataSourceImpl(this._apiClient);

  void _log(String endpoint, Object error) {
    if (error is DioException) {
      debugPrint(
        '[REPORTS API] GET $endpoint | '
        'Status: ${error.response?.statusCode} | Data: ${error.response?.data}',
      );
    } else {
      debugPrint('[REPORTS API] GET $endpoint | Error: $error');
    }
  }

  Never _fail(String endpoint, Object error, String fallback) {
    _log(endpoint, error);
    throw ApiErrorMapper.map(error, fallbackMessage: fallback);
  }

  /// طلب GET يعيد كائن `data` واحداً ويحوّله إلى النموذج المطلوب.
  Future<T> _getReport<T>(
    String endpoint, {
    Map<String, dynamic>? query,
    required T Function(Map<String, dynamic> json) parser,
    required String fallbackMessage,
  }) async {
    try {
      final response = await _apiClient.get(endpoint, queryParameters: query);
      final body = response.data;

      if (JsonParsers.declaresFailure(body)) {
        throw ApiException(
          JsonParsers.extractMessage(body) ?? fallbackMessage,
          statusCode: response.statusCode,
        );
      }

      final data = JsonParsers.optionalMap(
        body is Map ? body['data'] : null,
      );
      if (data == null) {
        throw ApiException(
          JsonParsers.extractMessage(body) ??
              'استجابة غير متوافقة من الخادم عند جلب التقرير.',
          statusCode: response.statusCode,
        );
      }

      return parser(data);
    } catch (error) {
      _fail(endpoint, error, fallbackMessage);
    }
  }

  // ── 1. KPI Summary — بلا أي Query Parameters حسب العقد ─────────────────────

  @override
  Future<KpiSummaryModel> getKpiSummary() {
    return _getReport(
      ApiEndpoints.reportsKpiSummary,
      parser: KpiSummaryModel.fromJson,
      fallbackMessage: 'تعذّر جلب مؤشرات الأداء السريعة.',
    );
  }

  // ── 2. Financial Report ────────────────────────────────────────────────────

  @override
  Future<FinancialReportModel> getFinancialReport(ReportFilters filters) {
    return _getReport(
      ApiEndpoints.reportsFinancial,
      query: filters.toPeriodQuery(),
      parser: FinancialReportModel.fromJson,
      fallbackMessage: 'تعذّر جلب التقرير المالي.',
    );
  }

  // ── 3. Trips Report ────────────────────────────────────────────────────────

  @override
  Future<TripsReportModel> getTripsReport(ReportFilters filters) {
    return _getReport(
      ApiEndpoints.reportsTrips,
      query: filters.toPeriodQuery(),
      parser: TripsReportModel.fromJson,
      fallbackMessage: 'تعذّر جلب تقرير الرحلات.',
    );
  }

  // ── 4. Subscriptions Report ────────────────────────────────────────────────

  @override
  Future<SubscriptionsReportModel> getSubscriptionsReport(
    ReportFilters filters,
  ) {
    return _getReport(
      ApiEndpoints.reportsSubscriptions,
      query: filters.toPeriodQuery(),
      parser: SubscriptionsReportModel.fromJson,
      fallbackMessage: 'تعذّر جلب تقرير الاشتراكات.',
    );
  }

  // ── 5. Drivers Performance ─────────────────────────────────────────────────

  @override
  Future<DriversPerformanceReportModel> getDriversPerformance(
    ReportFilters filters,
  ) {
    return _getReport(
      ApiEndpoints.reportsDriversPerformance,
      query: filters.toDriversQuery(),
      parser: DriversPerformanceReportModel.fromJson,
      fallbackMessage: 'تعذّر جلب تقرير أداء السائقين.',
    );
  }

  // ── 6. Export ──────────────────────────────────────────────────────────────

  /// يُنزّل التقرير كبايتات خام، فـ CSV ليس JSON ولا يصح تحليله كذلك.
  @override
  Future<ReportExportModel> exportReport({
    required String type,
    required String format,
    required ReportFilters filters,
  }) async {
    const endpoint = ApiEndpoints.reportsExport;
    try {
      final response = await _apiClient.download(
        endpoint,
        queryParameters: filters.toExportQuery(type: type, format: format),
      );

      final bytes = Uint8List.fromList(response.data ?? const <int>[]);
      if (bytes.isEmpty) {
        throw const ApiException('لم يُرجع الخادم أي محتوى للتقرير المطلوب.');
      }

      final headers = response.headers;
      return ReportExportModel(
        type: type,
        format: format,
        bytes: bytes,
        contentType: headers.value(Headers.contentTypeHeader),
        fileName: ReportExportModel.resolveFileName(
          contentDisposition: headers.value('content-disposition'),
          type: type,
          format: format,
          now: DateTime.now(),
        ),
      );
    } catch (error) {
      _fail(endpoint, error, 'تعذّر تصدير التقرير.');
    }
  }
}
