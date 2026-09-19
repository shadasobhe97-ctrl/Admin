import '../../../../core/utils/json_parsers.dart';

/// GET /api/admin/financial/summary
class FinancialSummaryModel {
  final double parentsEscrowPool;
  final double driverPendingPool;
  final double driverAvailablePool;
  final double platformRevenuePool;
  final int pendingWithdrawalsCount;
  final int pendingRechargesCount;
  final int pendingEscrowsCount;

  const FinancialSummaryModel({
    required this.parentsEscrowPool,
    required this.driverPendingPool,
    required this.driverAvailablePool,
    required this.platformRevenuePool,
    required this.pendingWithdrawalsCount,
    required this.pendingRechargesCount,
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
      pendingWithdrawalsCount:
          JsonParsers.intValue(json['pending_withdrawals_count']),
      pendingRechargesCount:
          JsonParsers.intValue(json['pending_recharges_count']),
      pendingEscrowsCount: JsonParsers.intValue(json['pending_escrows_count']),
    );
  }

  /// مجموع الأرصدة المحتفظ بها في المنصة.
  double get totalPools =>
      parentsEscrowPool +
      driverPendingPool +
      driverAvailablePool +
      platformRevenuePool;

  FinancialSummaryModel copyWith({
    double? parentsEscrowPool,
    double? driverPendingPool,
    double? driverAvailablePool,
    double? platformRevenuePool,
    int? pendingWithdrawalsCount,
    int? pendingRechargesCount,
    int? pendingEscrowsCount,
  }) {
    return FinancialSummaryModel(
      parentsEscrowPool: parentsEscrowPool ?? this.parentsEscrowPool,
      driverPendingPool: driverPendingPool ?? this.driverPendingPool,
      driverAvailablePool: driverAvailablePool ?? this.driverAvailablePool,
      platformRevenuePool: platformRevenuePool ?? this.platformRevenuePool,
      pendingWithdrawalsCount:
          pendingWithdrawalsCount ?? this.pendingWithdrawalsCount,
      pendingRechargesCount:
          pendingRechargesCount ?? this.pendingRechargesCount,
      pendingEscrowsCount: pendingEscrowsCount ?? this.pendingEscrowsCount,
    );
  }
}
