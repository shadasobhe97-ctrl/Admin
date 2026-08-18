import '../../../../core/utils/json_parsers.dart';
import 'audit_dictionaries.dart';

/// تغيير واحد على حقل — عنصر من `changes[]`.
class AuditChangeModel {
  final String field;

  /// التسمية العربية يرسلها الخادم جاهزة؛ يُستعمل اسم الحقل كبديل عند غيابها.
  final String label;
  final String? oldValue;
  final String? newValue;

  const AuditChangeModel({
    required this.field,
    required this.label,
    this.oldValue,
    this.newValue,
  });

  factory AuditChangeModel.fromJson(Map<String, dynamic> json) {
    final field = JsonParsers.stringValue(json['field']);
    return AuditChangeModel(
      field: field,
      label: JsonParsers.optionalString(json['label']) ?? field,
      oldValue: JsonParsers.optionalString(json['old_value']),
      newValue: JsonParsers.optionalString(json['new_value']),
    );
  }

  /// إضافة قيمة جديدة لم تكن موجودة (يحدث في إجراءات الإنشاء).
  bool get isAddition => oldValue == null && newValue != null;

  /// إزالة قيمة (يحدث في إجراءات الحذف).
  bool get isRemoval => oldValue != null && newValue == null;
}

/// GET /api/admin/admin-audit-logs
/// GET /api/admin/admin-audit-logs/{id}
class AuditLogModel {
  final int id;
  final int? adminId;
  final String adminName;
  final String? adminRole;

  final String action;

  /// التسمية العربية للإجراء — يرسلها الخادم جاهزة.
  final String actionLabel;
  final String? actionGroup;

  final String? entityType;
  final int? entityId;
  final String? entityName;

  final String? result;
  final String? reason;
  final List<AuditChangeModel> changes;
  final DateTime? createdAt;

  const AuditLogModel({
    required this.id,
    this.adminId,
    required this.adminName,
    this.adminRole,
    required this.action,
    required this.actionLabel,
    this.actionGroup,
    this.entityType,
    this.entityId,
    this.entityName,
    this.result,
    this.reason,
    this.changes = const [],
    this.createdAt,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    final action = JsonParsers.stringValue(json['action']);
    return AuditLogModel(
      id: JsonParsers.intValue(json['id']),
      adminId: JsonParsers.optionalInt(json['admin_id']),
      adminName: JsonParsers.stringValue(json['admin_name']),
      adminRole: JsonParsers.optionalString(json['admin_role']),
      action: action,
      // الخادم يرسل التسمية جاهزة؛ يُستعمل رمز الإجراء كبديل آمن عند غيابها.
      actionLabel: JsonParsers.optionalString(json['action_label']) ?? action,
      actionGroup: JsonParsers.optionalString(json['action_group']),
      entityType: JsonParsers.optionalString(json['entity_type']),
      entityId: JsonParsers.optionalInt(json['entity_id']),
      entityName: JsonParsers.optionalString(json['entity_name']),
      result: JsonParsers.optionalString(json['result']),
      reason: JsonParsers.optionalString(json['reason']),
      changes: JsonParsers.listOf(json['changes'], AuditChangeModel.fromJson),
      createdAt: JsonParsers.optionalDate(json['created_at']),
    );
  }

  bool get hasChanges => changes.isNotEmpty;
  bool get hasResult => result != null && result!.isNotEmpty;
  bool get hasReason => reason != null && reason!.trim().isNotEmpty;

  String get resultLabel => AuditResult.label(result);
  AuditResultTone get resultTone => AuditResult.tone(result);
  String get entityTypeLabel => AuditEntityType.label(entityType);
  String get actionGroupLabel => AuditActionGroup.label(actionGroup);

  /// وصف العنصر المتأثر جاهزاً للعرض، مع رقمه عند غياب الاسم.
  String get entityDescription {
    if (entityName != null && entityName!.isNotEmpty) return entityName!;
    if (entityId != null) return '${AuditEntityType.label(entityType)} #$entityId';
    return AuditEntityType.label(entityType);
  }

  AuditLogModel copyWith({
    int? id,
    int? adminId,
    String? adminName,
    String? adminRole,
    String? action,
    String? actionLabel,
    String? actionGroup,
    String? entityType,
    int? entityId,
    String? entityName,
    String? result,
    String? reason,
    List<AuditChangeModel>? changes,
    DateTime? createdAt,
  }) {
    return AuditLogModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      adminRole: adminRole ?? this.adminRole,
      action: action ?? this.action,
      actionLabel: actionLabel ?? this.actionLabel,
      actionGroup: actionGroup ?? this.actionGroup,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      entityName: entityName ?? this.entityName,
      result: result ?? this.result,
      reason: reason ?? this.reason,
      changes: changes ?? this.changes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
