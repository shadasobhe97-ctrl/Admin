import '../../../../core/utils/json_parsers.dart';

/// GET /api/admin/financial/escrows
class EscrowSummaryModel {
  final double pendingAmount;
  final double eligibleAmount;
  final int tripsCount;
  final int eligibleCount;
  final DateTime? oldestEscrow;

  const EscrowSummaryModel({
    required this.pendingAmount,
    required this.eligibleAmount,
    required this.tripsCount,
    required this.eligibleCount,
    this.oldestEscrow,
  });

  factory EscrowSummaryModel.fromJson(Map<String, dynamic> json) {
    return EscrowSummaryModel(
      pendingAmount: JsonParsers.doubleValue(json['pending_amount']),
      eligibleAmount: JsonParsers.doubleValue(json['eligible_amount']),
      tripsCount: JsonParsers.intValue(json['trips_count']),
      eligibleCount: JsonParsers.intValue(json['eligible_count']),
      oldestEscrow: JsonParsers.optionalDate(json['oldest_escrow']),
    );
  }

  /// لا يُسمح بتحرير الأمانات ما لم يوجد ما هو مستحق فعلاً حسب بيانات الخادم.
  bool get hasReleasableEscrows => eligibleCount > 0 || eligibleAmount > 0;

  EscrowSummaryModel copyWith({
    double? pendingAmount,
    double? eligibleAmount,
    int? tripsCount,
    int? eligibleCount,
    DateTime? oldestEscrow,
  }) {
    return EscrowSummaryModel(
      pendingAmount: pendingAmount ?? this.pendingAmount,
      eligibleAmount: eligibleAmount ?? this.eligibleAmount,
      tripsCount: tripsCount ?? this.tripsCount,
      eligibleCount: eligibleCount ?? this.eligibleCount,
      oldestEscrow: oldestEscrow ?? this.oldestEscrow,
    );
  }
}
