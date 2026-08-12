import '../../../../core/services/file_export_service.dart';
import '../datasources/reports_remote_datasource.dart';
import '../models/drivers_performance_report_model.dart';
import '../models/financial_report_model.dart';
import '../models/kpi_summary_model.dart';
import '../models/report_export_model.dart';
import '../models/report_filters.dart';
import '../models/subscriptions_report_model.dart';
import '../models/trips_report_model.dart';

/// عقد طبقة بيانات التقارير كما يراه الـ Cubit.
abstract class ReportsRepository {
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

  /// يحفظ تقريراً سبق تصديره على جهاز المستخدم.
  Future<FileExportResult> saveExportedReport(ReportExportModel export);
}

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource _remoteDataSource;
  final FileExportService _fileExportService;

  ReportsRepositoryImpl(this._remoteDataSource, this._fileExportService);

  @override
  Future<KpiSummaryModel> getKpiSummary() => _remoteDataSource.getKpiSummary();

  @override
  Future<FinancialReportModel> getFinancialReport(ReportFilters filters) =>
      _remoteDataSource.getFinancialReport(filters);

  @override
  Future<TripsReportModel> getTripsReport(ReportFilters filters) =>
      _remoteDataSource.getTripsReport(filters);

  @override
  Future<SubscriptionsReportModel> getSubscriptionsReport(
    ReportFilters filters,
  ) =>
      _remoteDataSource.getSubscriptionsReport(filters);

  @override
  Future<DriversPerformanceReportModel> getDriversPerformance(
    ReportFilters filters,
  ) =>
      _remoteDataSource.getDriversPerformance(filters);

  @override
  Future<ReportExportModel> exportReport({
    required String type,
    required String format,
    required ReportFilters filters,
  }) =>
      _remoteDataSource.exportReport(
        type: type,
        format: format,
        filters: filters,
      );

  @override
  Future<FileExportResult> saveExportedReport(ReportExportModel export) =>
      _fileExportService.saveBytes(
        fileName: export.fileName,
        bytes: export.bytes,
      );
}
