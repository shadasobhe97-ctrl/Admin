import '../../../../core/utils/json_parsers.dart';

/// GET /api/admin/financial/contracts/pending-settlements
class SettlementContractModel {
  final int contractId;
  final String contractNumber;
  final String? parent;
  final String? driver;
  final double totalAmount;
  final double executedAmount;
  final double pendingAmount;
  final int completedTrips;
  final String settlementStatus;

  const SettlementContractModel({
    required this.contractId,
    required this.contractNumber,
    this.parent,
    this.driver,
    required this.totalAmount,
    required this.executedAmount,
    required this.pendingAmount,
    required this.completedTrips,
    required this.settlementStatus,
  });

  factory SettlementContractModel.fromJson(Map<String, dynamic> json) {
    return SettlementContractModel(
      contractId: JsonParsers.intValue(json['contract_id']),
      contractNumber: JsonParsers.stringValue(json['contract_number']),
      parent: JsonParsers.optionalString(json['parent']),
      driver: JsonParsers.optionalString(json['driver']),
      totalAmount: JsonParsers.doubleValue(json['total_amount']),
      executedAmount: JsonParsers.doubleValue(json['executed_amount']),
      pendingAmount: JsonParsers.doubleValue(json['pending_amount']),
      completedTrips: JsonParsers.intValue(json['completed_trips']),
      settlementStatus: JsonParsers.stringValue(json['settlement_status']),
    );
  }

  /// نسبة التنفيذ من إجمالي قيمة العقد، تُحسب من بيانات الخادم فقط.
  double get executionRatio =>
      totalAmount <= 0 ? 0 : (executedAmount / totalAmount).clamp(0, 1);

  SettlementContractModel copyWith({
    int? contractId,
    String? contractNumber,
    String? parent,
    String? driver,
    double? totalAmount,
    double? executedAmount,
    double? pendingAmount,
    int? completedTrips,
    String? settlementStatus,
  }) {
    return SettlementContractModel(
      contractId: contractId ?? this.contractId,
      contractNumber: contractNumber ?? this.contractNumber,
      parent: parent ?? this.parent,
      driver: driver ?? this.driver,
      totalAmount: totalAmount ?? this.totalAmount,
      executedAmount: executedAmount ?? this.executedAmount,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      completedTrips: completedTrips ?? this.completedTrips,
      settlementStatus: settlementStatus ?? this.settlementStatus,
    );
  }
}

/// نتيجة POST /api/admin/financial/contracts/{contractId}/settle-monthly
class MonthlySettlementResultModel {
  final String contractNumber;
  final double finalSettledAmount;
  final double rolloverRefundCredit;

  const MonthlySettlementResultModel({
    required this.contractNumber,
    required this.finalSettledAmount,
    required this.rolloverRefundCredit,
  });

  factory MonthlySettlementResultModel.fromJson(Map<String, dynamic> json) {
    return MonthlySettlementResultModel(
      contractNumber: JsonParsers.stringValue(json['contract_number']),
      finalSettledAmount:
          JsonParsers.doubleValue(json['final_settled_amount']),
      rolloverRefundCredit:
          JsonParsers.doubleValue(json['rollover_refund_credit']),
    );
  }
}
