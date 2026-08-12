import '../../../../core/utils/json_parsers.dart';

/// GET /api/admin/financial/recharges
/// GET /api/admin/financial/recharges/{id}
class RechargeModel {
  final int id;
  final int? parentId;
  final String parentName;
  final String? parentPhone;
  final double amount;
  final String? paymentMethod;
  final String? referenceNumber;
  final String status;
  final String? failureReason;
  final DateTime? createdAt;
  final DateTime? processedAt;
  final String? adminName;

  const RechargeModel({
    required this.id,
    this.parentId,
    required this.parentName,
    this.parentPhone,
    required this.amount,
    this.paymentMethod,
    this.referenceNumber,
    required this.status,
    this.failureReason,
    this.createdAt,
    this.processedAt,
    this.adminName,
  });

  factory RechargeModel.fromJson(Map<String, dynamic> json) {
    return RechargeModel(
      id: JsonParsers.intValue(json['id']),
      parentId: JsonParsers.optionalInt(json['parent_id']),
      parentName: JsonParsers.stringValue(json['parent_name']),
      parentPhone: JsonParsers.optionalString(json['parent_phone']),
      amount: JsonParsers.doubleValue(json['amount']),
      paymentMethod: JsonParsers.optionalString(json['payment_method']),
      referenceNumber: JsonParsers.optionalString(json['reference_number']),
      status: JsonParsers.stringValue(json['status']),
      failureReason: JsonParsers.optionalString(json['failure_reason']),
      createdAt: JsonParsers.optionalDate(json['created_at']),
      processedAt: JsonParsers.optionalDate(json['processed_at']),
      adminName: JsonParsers.optionalString(json['admin_name']),
    );
  }

  bool get isPending => status.toLowerCase() == 'pending';

  RechargeModel copyWith({
    int? id,
    int? parentId,
    String? parentName,
    String? parentPhone,
    double? amount,
    String? paymentMethod,
    String? referenceNumber,
    String? status,
    String? failureReason,
    DateTime? createdAt,
    DateTime? processedAt,
    String? adminName,
  }) {
    return RechargeModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      status: status ?? this.status,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      adminName: adminName ?? this.adminName,
    );
  }
}
