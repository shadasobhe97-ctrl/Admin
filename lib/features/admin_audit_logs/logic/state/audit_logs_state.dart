import '../../../../core/models/paginated_result.dart';
import '../../data/models/audit_log_filters.dart';
import '../../data/models/audit_log_model.dart';

abstract class AuditLogsState {
  const AuditLogsState();
}

class AuditLogsInitial extends AuditLogsState {
  const AuditLogsInitial();
}

class AuditLogsLoading extends AuditLogsState {
  const AuditLogsLoading();
}

class AuditLogsLoaded extends AuditLogsState {
  final PaginatedResult<AuditLogModel> result;
  final AuditLogFilters filters;

  const AuditLogsLoaded(this.result, this.filters);
}

class AuditLogsEmpty extends AuditLogsState {
  final AuditLogFilters filters;

  /// `true` عندما تكون القائمة فارغة بسبب الفلاتر لا لعدم وجود سجلات.
  final bool isFiltered;

  const AuditLogsEmpty(this.filters, {this.isFiltered = false});
}

class AuditLogsError extends AuditLogsState {
  final String message;

  /// `true` عند 403 — لعرض رسالة صلاحية بدل رسالة خطأ عامة.
  final bool isForbidden;

  const AuditLogsError(this.message, {this.isForbidden = false});
}

// ── تفاصيل سطر واحد ─────────────────────────────────────────────────────────

class AuditLogDetailsLoading extends AuditLogsState {
  const AuditLogDetailsLoading();
}

class AuditLogDetailsLoaded extends AuditLogsState {
  final AuditLogModel log;
  const AuditLogDetailsLoaded(this.log);
}

class AuditLogDetailsError extends AuditLogsState {
  final String message;
  final bool isForbidden;

  const AuditLogDetailsError(this.message, {this.isForbidden = false});
}
