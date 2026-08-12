import '../../data/models/drivers_performance_report_model.dart';
import '../../data/models/financial_report_model.dart';
import '../../data/models/kpi_summary_model.dart';
import '../../data/models/report_export_model.dart';
import '../../data/models/report_filters.dart';
import '../../data/models/subscriptions_report_model.dart';
import '../../data/models/trips_report_model.dart';

abstract class ReportsState {
  const ReportsState();
}

class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

// ── KPI ──────────────────────────────────────────────────────────────────────

class KpiLoading extends ReportsState {
  const KpiLoading();
}

class KpiLoaded extends ReportsState {
  final KpiSummaryModel summary;
  const KpiLoaded(this.summary);
}

class KpiError extends ReportsState {
  final String message;
  const KpiError(this.message);
}

// ── Financial Report ─────────────────────────────────────────────────────────

class FinancialReportLoading extends ReportsState {
  const FinancialReportLoading();
}

class FinancialReportLoaded extends ReportsState {
  final FinancialReportModel report;
  final ReportFilters filters;
  const FinancialReportLoaded(this.report, this.filters);
}

class FinancialReportError extends ReportsState {
  final String message;
  const FinancialReportError(this.message);
}

// ── Trips Report ─────────────────────────────────────────────────────────────

class TripsReportLoading extends ReportsState {
  const TripsReportLoading();
}

class TripsReportLoaded extends ReportsState {
  final TripsReportModel report;
  final ReportFilters filters;
  const TripsReportLoaded(this.report, this.filters);
}

class TripsReportError extends ReportsState {
  final String message;
  const TripsReportError(this.message);
}

// ── Subscriptions Report ─────────────────────────────────────────────────────

class SubscriptionsReportLoading extends ReportsState {
  const SubscriptionsReportLoading();
}

class SubscriptionsReportLoaded extends ReportsState {
  final SubscriptionsReportModel report;
  final ReportFilters filters;
  const SubscriptionsReportLoaded(this.report, this.filters);
}

class SubscriptionsReportError extends ReportsState {
  final String message;
  const SubscriptionsReportError(this.message);
}

// ── Drivers Performance ──────────────────────────────────────────────────────

class DriversPerformanceLoading extends ReportsState {
  const DriversPerformanceLoading();
}

class DriversPerformanceLoaded extends ReportsState {
  final DriversPerformanceReportModel report;
  final ReportFilters filters;
  const DriversPerformanceLoaded(this.report, this.filters);
}

class DriversPerformanceError extends ReportsState {
  final String message;
  const DriversPerformanceError(this.message);
}

// ── Export ───────────────────────────────────────────────────────────────────

class ReportExportLoading extends ReportsState {
  const ReportExportLoading();
}

class ReportExportSuccess extends ReportsState {
  final ReportExportModel export;
  const ReportExportSuccess(this.export);
}

class ReportExportError extends ReportsState {
  final String message;
  const ReportExportError(this.message);
}

// ── حفظ الملف المُصدَّر على الجهاز ────────────────────────────────────────────

class ReportExportSaving extends ReportsState {
  final ReportExportModel export;
  const ReportExportSaving(this.export);
}

class ReportExportSaved extends ReportsState {
  final ReportExportModel export;

  /// مسار الحفظ، أو `null` على الويب حيث يتولى المتصفح التنزيل.
  final String? path;

  const ReportExportSaved(this.export, {this.path});
}

/// أغلق المستخدم نافذة الحفظ دون اختيار وجهة.
class ReportExportSaveCancelled extends ReportsState {
  final ReportExportModel export;
  const ReportExportSaveCancelled(this.export);
}

class ReportExportSaveError extends ReportsState {
  final ReportExportModel export;
  final String message;
  const ReportExportSaveError(this.export, this.message);
}
