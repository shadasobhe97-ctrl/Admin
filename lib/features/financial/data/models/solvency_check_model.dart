import '../../../../core/utils/json_parsers.dart';

/// GET /api/admin/financial/solvency-check
///
/// حالة الملاءة تأتي من الخادم عبر `is_solvent` و`discrepancy_cents`،
/// ولا تُحتسب أو تُفترض في الواجهة.
class SolvencyCheckModel {
  /// رسالة الخادم كما هي (تُعرض للمستخدم دون تعديل).
  final String? message;
  final bool isSolvent;
  final int discrepancyCents;
  final double parentsEscrowPool;
  final double driverPendingPool;
  final double driverAvailablePool;
  final double platformRevenuePool;
  final double totalCalculatedDinar;

  const SolvencyCheckModel({
    this.message,
    required this.isSolvent,
    required this.discrepancyCents,
    required this.parentsEscrowPool,
    required this.driverPendingPool,
    required this.driverAvailablePool,
    required this.platformRevenuePool,
    required this.totalCalculatedDinar,
  });

  factory SolvencyCheckModel.fromJson(
    Map<String, dynamic> json, {
    String? message,
  }) {
    return SolvencyCheckModel(
      message: message,
      isSolvent: JsonParsers.boolValue(json['is_solvent']),
      discrepancyCents: JsonParsers.intValue(json['discrepancy_cents']),
      parentsEscrowPool: JsonParsers.doubleValue(json['parents_escrow_pool']),
      driverPendingPool: JsonParsers.doubleValue(json['driver_pending_pool']),
      driverAvailablePool:
          JsonParsers.doubleValue(json['driver_available_pool']),
      platformRevenuePool:
          JsonParsers.doubleValue(json['platform_revenue_pool']),
      totalCalculatedDinar:
          JsonParsers.doubleValue(json['total_calculated_dinar']),
    );
  }

  /// فرق الملاءة بالدينار (الخادم يرسله بالسنت).
  double get discrepancyDinar => discrepancyCents / 100;

  SolvencyCheckModel copyWith({
    String? message,
    bool? isSolvent,
    int? discrepancyCents,
    double? parentsEscrowPool,
    double? driverPendingPool,
    double? driverAvailablePool,
    double? platformRevenuePool,
    double? totalCalculatedDinar,
  }) {
    return SolvencyCheckModel(
      message: message ?? this.message,
      isSolvent: isSolvent ?? this.isSolvent,
      discrepancyCents: discrepancyCents ?? this.discrepancyCents,
      parentsEscrowPool: parentsEscrowPool ?? this.parentsEscrowPool,
      driverPendingPool: driverPendingPool ?? this.driverPendingPool,
      driverAvailablePool: driverAvailablePool ?? this.driverAvailablePool,
      platformRevenuePool: platformRevenuePool ?? this.platformRevenuePool,
      totalCalculatedDinar: totalCalculatedDinar ?? this.totalCalculatedDinar,
    );
  }
}
