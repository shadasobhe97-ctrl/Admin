import '../../../../core/utils/json_parsers.dart';

/// GET /api/admin/financial/audit-logs
///
/// حقل `metadata` يُعامل كخريطة ديناميكية بالكامل، ولا يُفترض وجود أي مفتاح
/// بداخله؛ كل قارئ يستعمل [metadataValue] الآمنة.
class FinancialAuditLogModel {
  final int id;
  final String referenceNumber;
  final String type;
  final String status;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;

  const FinancialAuditLogModel({
    required this.id,
    required this.referenceNumber,
    required this.type,
    required this.status,
    required this.metadata,
    this.createdAt,
  });

  factory FinancialAuditLogModel.fromJson(Map<String, dynamic> json) {
    return FinancialAuditLogModel(
      id: JsonParsers.intValue(json['id']),
      referenceNumber: JsonParsers.stringValue(json['reference_number']),
      type: JsonParsers.stringValue(json['type']),
      status: JsonParsers.stringValue(json['status']),
      metadata: JsonParsers.mapValue(json['metadata']),
      createdAt: JsonParsers.optionalDate(json['created_at']),
    );
  }

  /// قراءة آمنة لأي مفتاح داخل `metadata` دون افتراض وجوده.
  String? metadataValue(String key) =>
      JsonParsers.optionalString(metadata[key]);

  String? get adminName => metadataValue('admin_name');
  String? get action => metadataValue('action');
  int? get adminId => JsonParsers.optionalInt(metadata['admin_id']);
  int? get entityId => JsonParsers.optionalInt(metadata['entity_id']);

  /// بقية مفاتيح `metadata` غير المعروفة مسبقاً، لعرضها كما هي.
  Map<String, dynamic> get extraMetadata {
    const known = {'admin_id', 'admin_name', 'action', 'entity_id'};
    return Map<String, dynamic>.fromEntries(
      metadata.entries.where((entry) => !known.contains(entry.key)),
    );
  }

  FinancialAuditLogModel copyWith({
    int? id,
    String? referenceNumber,
    String? type,
    String? status,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return FinancialAuditLogModel(
      id: id ?? this.id,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
