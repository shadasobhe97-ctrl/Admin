import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/report_export_model.dart';
import '../../data/models/report_filters.dart';
import '../../data/repositories/reports_repository_impl.dart';
import '../state/reports_state.dart';

/// منطق ميزة التقارير.
///
/// مُسجَّل كـ `Factory`، فتحصل كل شاشة على نسخة مستقلة تستدعي ما يخصّها فقط.
class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepository _repository;

  ReportsCubit(this._repository) : super(const ReportsInitial());

  /// الفلاتر الحالية للشاشة المعروضة.
  ReportFilters _filters = const ReportFilters();

  /// يمنع إطلاق طلبات متزامنة عند الضغط المتكرر على التحديث أو التصدير.
  bool _isFetching = false;
  bool _isExporting = false;
  bool _isSavingFile = false;

  ReportFilters get filters => _filters;
  bool get isExporting => _isExporting;
  bool get isSavingFile => _isSavingFile;

  String _messageOf(Object error) {
    if (error is ApiException) return error.detailedMessage;
    return error.toString().replaceAll('Exception: ', '');
  }

  void _emitIfOpen(ReportsState state) {
    if (!isClosed) emit(state);
  }

  /// يوحّد دورة الجلب: منع التزامن ← Loading ← Loaded / Error.
  Future<void> _fetch({
    required ReportsState loadingState,
    required Future<ReportsState> Function() request,
    required ReportsState Function(String message) onError,
  }) async {
    if (_isFetching) return;
    _isFetching = true;

    _emitIfOpen(loadingState);
    try {
      _emitIfOpen(await request());
    } catch (error) {
      _emitIfOpen(onError(_messageOf(error)));
    } finally {
      _isFetching = false;
    }
  }

  // ── 1. KPI Summary ────────────────────────────────────────────────────────

  Future<void> loadKpiSummary() {
    return _fetch(
      loadingState: const KpiLoading(),
      request: () async => KpiLoaded(await _repository.getKpiSummary()),
      onError: KpiError.new,
    );
  }

  // ── 2. Financial Report ───────────────────────────────────────────────────

  Future<void> loadFinancialReport({ReportFilters? filters}) {
    if (filters != null) _filters = filters;
    return _fetch(
      loadingState: const FinancialReportLoading(),
      request: () async => FinancialReportLoaded(
        await _repository.getFinancialReport(_filters),
        _filters,
      ),
      onError: FinancialReportError.new,
    );
  }

  // ── 3. Trips Report ───────────────────────────────────────────────────────

  Future<void> loadTripsReport({ReportFilters? filters}) {
    if (filters != null) _filters = filters;
    return _fetch(
      loadingState: const TripsReportLoading(),
      request: () async => TripsReportLoaded(
        await _repository.getTripsReport(_filters),
        _filters,
      ),
      onError: TripsReportError.new,
    );
  }

  // ── 4. Subscriptions Report ───────────────────────────────────────────────

  Future<void> loadSubscriptionsReport({ReportFilters? filters}) {
    if (filters != null) _filters = filters;
    return _fetch(
      loadingState: const SubscriptionsReportLoading(),
      request: () async => SubscriptionsReportLoaded(
        await _repository.getSubscriptionsReport(_filters),
        _filters,
      ),
      onError: SubscriptionsReportError.new,
    );
  }

  // ── 5. Drivers Performance ────────────────────────────────────────────────

  Future<void> loadDriversPerformance({ReportFilters? filters}) {
    if (filters != null) _filters = filters;
    return _fetch(
      loadingState: const DriversPerformanceLoading(),
      request: () async => DriversPerformanceLoaded(
        await _repository.getDriversPerformance(_filters),
        _filters,
      ),
      onError: DriversPerformanceError.new,
    );
  }

  /// البحث يُنفَّذ على الخادم عبر `search` ويعيد الترقيم لأول صفحة.
  Future<void> searchDrivers(String? query) {
    return loadDriversPerformance(
      filters: query == null || query.trim().isEmpty
          ? _filters.copyWith(page: 1, clearSearch: true)
          : _filters.copyWith(search: query.trim(), page: 1),
    );
  }

  Future<void> sortDrivers(String sortBy) =>
      loadDriversPerformance(filters: _filters.copyWith(sortBy: sortBy, page: 1));

  Future<void> changeDriversPage(int page) =>
      loadDriversPerformance(filters: _filters.copyWith(page: page));

  // ── فلاتر الفترة الزمنية ──────────────────────────────────────────────────

  /// يغيّر الفترة ويلغي أي نطاق مخصّص، ثم يعيد الجلب عبر [reload].
  Future<void> changePeriod(
    String period,
    Future<void> Function({ReportFilters? filters}) reload,
  ) {
    return reload(
      filters: _filters.copyWith(period: period, clearRange: true),
    );
  }

  /// يطبّق نطاق تاريخ مخصّص (يُرسل مع `period` كما يقبله الخادم).
  Future<void> changeDateRange(
    DateTime from,
    DateTime to,
    Future<void> Function({ReportFilters? filters}) reload,
  ) {
    return reload(filters: _filters.copyWith(dateFrom: from, dateTo: to));
  }

  Future<void> clearDateRange(
    Future<void> Function({ReportFilters? filters}) reload,
  ) {
    return reload(filters: _filters.copyWith(clearRange: true));
  }

  // ── 6. Export ─────────────────────────────────────────────────────────────

  /// يُنفَّذ فقط بضغط المستخدم، ولا يقبل طلبين متزامنين.
  Future<void> exportReport({
    required String type,
    required String format,
    ReportFilters? filters,
  }) async {
    if (_isExporting) return;
    _isExporting = true;

    _emitIfOpen(const ReportExportLoading());
    try {
      final result = await _repository.exportReport(
        type: type,
        format: format,
        filters: filters ?? _filters,
      );
      _emitIfOpen(ReportExportSuccess(result));
    } catch (error) {
      _emitIfOpen(ReportExportError(_messageOf(error)));
    } finally {
      _isExporting = false;
    }
  }

  /// يحفظ التقرير المُصدَّر على الجهاز عبر الـ Repository.
  /// لا يقبل عمليتَي حفظ متزامنتين.
  Future<void> saveExportedReport(ReportExportModel export) async {
    if (_isSavingFile) return;
    _isSavingFile = true;

    _emitIfOpen(ReportExportSaving(export));
    try {
      final result = await _repository.saveExportedReport(export);
      _emitIfOpen(
        result.isSaved
            ? ReportExportSaved(export, path: result.path)
            : ReportExportSaveCancelled(export),
      );
    } catch (error) {
      _emitIfOpen(ReportExportSaveError(export, _messageOf(error)));
    } finally {
      _isSavingFile = false;
    }
  }
}
