import '../../../../core/utils/json_parsers.dart';

/// GET /api/admin/reports/kpi-summary → data.active_users
class ActiveUsersKpi {
  final int parents;
  final int drivers;
  final int children;
  final int total;

  const ActiveUsersKpi({
    required this.parents,
    required this.drivers,
    required this.children,
    required this.total,
  });

  factory ActiveUsersKpi.fromJson(Map<String, dynamic> json) {
    return ActiveUsersKpi(
      parents: JsonParsers.intValue(json['parents']),
      drivers: JsonParsers.intValue(json['drivers']),
      children: JsonParsers.intValue(json['children']),
      total: JsonParsers.intValue(json['total']),
    );
  }
}

/// data.today_trips
class TodayTripsKpi {
  final int completed;
  final int inProgress;
  final int cancelled;
  final int total;

  const TodayTripsKpi({
    required this.completed,
    required this.inProgress,
    required this.cancelled,
    required this.total,
  });

  factory TodayTripsKpi.fromJson(Map<String, dynamic> json) {
    return TodayTripsKpi(
      completed: JsonParsers.intValue(json['completed']),
      inProgress: JsonParsers.intValue(json['in_progress']),
      cancelled: JsonParsers.intValue(json['cancelled']),
      total: JsonParsers.intValue(json['total']),
    );
  }
}

/// data.monthly_revenue
class MonthlyRevenueKpi {
  final double platformEarnings;
  final double platformRevenuePool;
  final double totalVolume;

  /// الشهر كما يرسله الخادم بصيغة `YYYY-MM`.
  final String? month;

  const MonthlyRevenueKpi({
    required this.platformEarnings,
    required this.platformRevenuePool,
    required this.totalVolume,
    this.month,
  });

  factory MonthlyRevenueKpi.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenueKpi(
      platformEarnings: JsonParsers.doubleValue(json['platform_earnings']),
      platformRevenuePool:
          JsonParsers.doubleValue(json['platform_revenue_pool']),
      totalVolume: JsonParsers.doubleValue(json['total_volume']),
      month: JsonParsers.optionalString(json['month']),
    );
  }
}

/// data.urgent_alerts
class UrgentAlertsKpi {
  final int pendingDrivers;
  final int pendingWithdrawals;
  final int openDisputes;
  final int pendingRecharges;
  final int totalUrgent;

  const UrgentAlertsKpi({
    required this.pendingDrivers,
    required this.pendingWithdrawals,
    required this.openDisputes,
    required this.pendingRecharges,
    required this.totalUrgent,
  });

  factory UrgentAlertsKpi.fromJson(Map<String, dynamic> json) {
    return UrgentAlertsKpi(
      pendingDrivers: JsonParsers.intValue(json['pending_drivers']),
      pendingWithdrawals: JsonParsers.intValue(json['pending_withdrawals']),
      openDisputes: JsonParsers.intValue(json['open_disputes']),
      pendingRecharges: JsonParsers.intValue(json['pending_recharges']),
      totalUrgent: JsonParsers.intValue(json['total_urgent']),
    );
  }

  bool get hasUrgentItems => totalUrgent > 0;
}

/// GET /api/admin/reports/kpi-summary
class KpiSummaryModel {
  final ActiveUsersKpi activeUsers;
  final TodayTripsKpi todayTrips;
  final MonthlyRevenueKpi monthlyRevenue;
  final UrgentAlertsKpi urgentAlerts;

  const KpiSummaryModel({
    required this.activeUsers,
    required this.todayTrips,
    required this.monthlyRevenue,
    required this.urgentAlerts,
  });

  factory KpiSummaryModel.fromJson(Map<String, dynamic> json) {
    return KpiSummaryModel(
      activeUsers: ActiveUsersKpi.fromJson(
        JsonParsers.mapValue(json['active_users']),
      ),
      todayTrips: TodayTripsKpi.fromJson(
        JsonParsers.mapValue(json['today_trips']),
      ),
      monthlyRevenue: MonthlyRevenueKpi.fromJson(
        JsonParsers.mapValue(json['monthly_revenue']),
      ),
      urgentAlerts: UrgentAlertsKpi.fromJson(
        JsonParsers.mapValue(json['urgent_alerts']),
      ),
    );
  }
}
