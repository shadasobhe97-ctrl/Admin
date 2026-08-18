import '../../../../core/widgets/admin_ui.dart';

/// فلاتر `GET /admin/admin-audit-logs` كما يقبلها العقد — كلها اختيارية.
class AuditLogFilters {
  final int? adminId;
  final String? entityType;
  final String? action;
  final String? actionGroup;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? search;
  final int page;

  /// الحد الأقصى الذي يقبله الخادم هو 100.
  final int perPage;

  const AuditLogFilters({
    this.adminId,
    this.entityType,
    this.action,
    this.actionGroup,
    this.dateFrom,
    this.dateTo,
    this.search,
    this.page = 1,
    this.perPage = 20,
  });

  bool get hasDateRange => dateFrom != null && dateTo != null;
  bool get hasSearch => search != null && search!.trim().isNotEmpty;

  bool get hasActiveFilters =>
      adminId != null ||
      entityType != null ||
      action != null ||
      actionGroup != null ||
      hasDateRange ||
      hasSearch;

  Map<String, dynamic> toQuery() {
    return <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (adminId != null) 'admin_id': adminId,
      if (entityType != null && entityType!.isNotEmpty)
        'entity_type': entityType,
      if (action != null && action!.isNotEmpty) 'action': action,
      if (actionGroup != null && actionGroup!.isNotEmpty)
        'action_group': actionGroup,
      if (hasDateRange) 'date_from': AdminFormat.queryDate(dateFrom!),
      if (hasDateRange) 'date_to': AdminFormat.queryDate(dateTo!),
      if (hasSearch) 'search': search!.trim(),
    };
  }

  AuditLogFilters copyWith({
    int? adminId,
    String? entityType,
    String? action,
    String? actionGroup,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? search,
    int? page,
    int? perPage,
    bool clearAdmin = false,
    bool clearEntityType = false,
    bool clearAction = false,
    bool clearActionGroup = false,
    bool clearDateRange = false,
    bool clearSearch = false,
  }) {
    return AuditLogFilters(
      adminId: clearAdmin ? null : (adminId ?? this.adminId),
      entityType: clearEntityType ? null : (entityType ?? this.entityType),
      action: clearAction ? null : (action ?? this.action),
      actionGroup: clearActionGroup ? null : (actionGroup ?? this.actionGroup),
      dateFrom: clearDateRange ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateRange ? null : (dateTo ?? this.dateTo),
      search: clearSearch ? null : (search ?? this.search),
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }
}
