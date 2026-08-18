import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/audit_log_filters.dart';
import '../../data/repositories/audit_logs_repository_impl.dart';
import '../state/audit_logs_state.dart';

/// منطق سجل إجراءات المشرفين.
///
/// السجل للقراءة فقط، لذلك لا توجد هنا أي عملية كتابة —
/// فقط جلب وفلترة وتصفّح.
class AuditLogsCubit extends Cubit<AuditLogsState> {
  final AuditLogsRepository _repository;

  AuditLogsCubit(this._repository) : super(const AuditLogsInitial());

  AuditLogFilters _filters = const AuditLogFilters();

  /// يمنع الطلبات المتزامنة عند الضغط المتكرر على التحديث أو الفلاتر.
  bool _isFetching = false;

  /// وصل تغيير فلتر أثناء تنفيذ طلب — يُعاد الجلب بعده بالفلاتر الأحدث
  /// بدل إسقاط اختيار المستخدم بصمت.
  bool _hasPendingReload = false;

  AuditLogFilters get filters => _filters;

  String _messageOf(Object error) {
    if (error is ApiException) return error.detailedMessage;
    return error.toString().replaceAll('Exception: ', '');
  }

  bool _isForbidden(Object error) => error is ApiException && error.isForbidden;

  void _emitIfOpen(AuditLogsState state) {
    if (!isClosed) emit(state);
  }

  // ── القائمة ───────────────────────────────────────────────────────────────

  Future<void> loadLogs({AuditLogFilters? filters}) async {
    // تُحفظ الفلاتر أولاً دائماً، حتى لو كان هناك طلب جارٍ،
    // حتى لا يضيع اختيار المستخدم.
    if (filters != null) _filters = filters;

    if (_isFetching) {
      _hasPendingReload = true;
      return;
    }

    _isFetching = true;
    try {
      // يُعاد الجلب طالما وصل تغيير فلتر أثناء الطلب السابق.
      do {
        _hasPendingReload = false;
        final requestedFilters = _filters;

        _emitIfOpen(const AuditLogsLoading());
        try {
          final result = await _repository.getAuditLogs(requestedFilters);

          // تجاهل نتيجة طلب قديم إن تغيّرت الفلاتر أثناء تنفيذه.
          if (_hasPendingReload) continue;

          if (result.isEmpty) {
            _emitIfOpen(
              AuditLogsEmpty(
                requestedFilters,
                isFiltered: requestedFilters.hasActiveFilters,
              ),
            );
          } else {
            _emitIfOpen(AuditLogsLoaded(result, requestedFilters));
          }
        } catch (error) {
          if (_hasPendingReload) continue;
          _emitIfOpen(
            AuditLogsError(
              _messageOf(error),
              isForbidden: _isForbidden(error),
            ),
          );
        }
      } while (_hasPendingReload);
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refresh() => loadLogs(filters: _filters);

  // ── الفلاتر — كل تغيير يعيد الترقيم لأول صفحة ─────────────────────────────

  Future<void> changePage(int page) =>
      loadLogs(filters: _filters.copyWith(page: page));

  Future<void> filterByAdmin(int? adminId) => loadLogs(
        filters: adminId == null
            ? _filters.copyWith(page: 1, clearAdmin: true)
            : _filters.copyWith(adminId: adminId, page: 1),
      );

  Future<void> filterByEntityType(String? entityType) => loadLogs(
        filters: entityType == null
            ? _filters.copyWith(page: 1, clearEntityType: true)
            : _filters.copyWith(entityType: entityType, page: 1),
      );

  Future<void> filterByActionGroup(String? group) => loadLogs(
        filters: group == null
            ? _filters.copyWith(page: 1, clearActionGroup: true)
            : _filters.copyWith(actionGroup: group, page: 1),
      );

  Future<void> search(String? query) => loadLogs(
        filters: query == null || query.trim().isEmpty
            ? _filters.copyWith(page: 1, clearSearch: true)
            : _filters.copyWith(search: query.trim(), page: 1),
      );

  Future<void> changeDateRange(DateTime from, DateTime to) =>
      loadLogs(filters: _filters.copyWith(dateFrom: from, dateTo: to, page: 1));

  Future<void> clearDateRange() =>
      loadLogs(filters: _filters.copyWith(page: 1, clearDateRange: true));

  Future<void> clearAllFilters() =>
      loadLogs(filters: AuditLogFilters(perPage: _filters.perPage));

  // ── تفاصيل سطر واحد ───────────────────────────────────────────────────────

  Future<void> loadDetails(int id) async {
    _emitIfOpen(const AuditLogDetailsLoading());
    try {
      final log = await _repository.getAuditLogDetails(id);
      _emitIfOpen(AuditLogDetailsLoaded(log));
    } catch (error) {
      _emitIfOpen(
        AuditLogDetailsError(
          _messageOf(error),
          isForbidden: _isForbidden(error),
        ),
      );
    }
  }
}
