import '../../../../core/utils/json_parsers.dart';

/// GET /api/admin/financial/summary
class FinancialSummaryModel {
  final double parentsEscrowPool;
  final double driverPendingPool;
  final double driverAvailablePool;
  final double platformRevenuePool;
  final double penaltyPool;
  final int pendingWithdrawalsCount;
  final int pendingRechargesCount;
  final int pendingDisputesCount;
  final int pendingEscrowsCount;

  const FinancialSummaryModel({
    required this.parentsEscrowPool,
    required this.driverPendingPool,
    required this.driverAvailablePool,
    required this.platformRevenuePool,
    required this.penaltyPool,
    required this.pendingWithdrawalsCount,
    required this.pendingRechargesCount,
    required this.pendingDisputesCount,
    required this.pendingEscrowsCount,
  });

  factory FinancialSummaryModel.fromJson(Map<String, dynamic> json) {
    return FinancialSummaryModel(
      parentsEscrowPool: JsonParsers.doubleValue(json['parents_escrow_pool']),
      driverPendingPool: JsonParsers.doubleValue(json['driver_pending_pool']),
      driverAvailablePool:
          JsonParsers.doubleValue(json['driver_available_pool']),
      platformRevenuePool:
          JsonParsers.doubleValue(json['platform_revenue_pool']),
      penaltyPool: JsonParsers.doubleValue(json['penalty_pool']),
      pendingWithdrawalsCount:
          JsonParsers.intValue(json['pending_withdrawals_count']),
      pendingRechargesCount:
          JsonParsers.intValue(json['pending_recharges_count']),
      pendingDisputesCount:
          JsonParsers.intValue(json['pending_disputes_count']),
      pendingEscrowsCount: JsonParsers.intValue(json['pending_escrows_count']),
    );
  }

  /// مجموع الأرصدة المحتفظ بها في المنصة.
  double get totalPools =>
      parentsEscrowPool +
      driverPendingPool +
      driverAvailablePool +
      platformRevenuePool +
      penaltyPool;

  FinancialSummaryModel copyWith({
    double? parentsEscrowPool,
    double? driverPendingPool,
    double? driverAvailablePool,
    double? platformRevenuePool,
    double? penaltyPool,
    int? pendingWithdrawalsCount,
    int? pendingRechargesCount,
    int? pendingDisputesCount,
    int? pendingEscrowsCount,
  }) {
    return FinancialSummaryModel(
      parentsEscrowPool: parentsEscrowPool ?? this.parentsEscrowPool,
      driverPendingPool: driverPendingPool ?? this.driverPendingPool,
      driverAvailablePool: driverAvailablePool ?? this.driverAvailablePool,
      platformRevenuePool: platformRevenuePool ?? this.platformRevenuePool,
      penaltyPool: penaltyPool ?? this.penaltyPool,
      pendingWithdrawalsCount:
          pendingWithdrawalsCount ?? this.pendingWithdrawalsCount,
      pendingRechargesCount:
          pendingRechargesCount ?? this.pendingRechargesCount,
      pendingDisputesCount: pendingDisputesCount ?? this.pendingDisputesCount,
      pendingEscrowsCount: pendingEscrowsCount ?? this.pendingEscrowsCount,
    );
  }
}
