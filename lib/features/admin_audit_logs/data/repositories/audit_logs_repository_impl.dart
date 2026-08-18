import '../../../../core/models/paginated_result.dart';
import '../datasources/audit_logs_remote_datasource.dart';
import '../models/audit_log_filters.dart';
import '../models/audit_log_model.dart';

/// عقد طبقة بيانات سجل الإجراءات كما يراه الـ Cubit.
abstract class AuditLogsRepository {
  Future<PaginatedResult<AuditLogModel>> getAuditLogs(AuditLogFilters filters);
  Future<AuditLogModel> getAuditLogDetails(int id);
}

class AuditLogsRepositoryImpl implements AuditLogsRepository {
  final AuditLogsRemoteDataSource _remoteDataSource;

  AuditLogsRepositoryImpl(this._remoteDataSource);

  @override
  Future<PaginatedResult<AuditLogModel>> getAuditLogs(
    AuditLogFilters filters,
  ) =>
      _remoteDataSource.getAuditLogs(filters);

  @override
  Future<AuditLogModel> getAuditLogDetails(int id) =>
      _remoteDataSource.getAuditLogDetails(id);
}
