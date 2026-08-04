class StatItem {
  final String value;
  final int raw;
  final String change;
  final String trend;

  StatItem({
    required this.value,
    required this.raw,
    required this.change,
    required this.trend,
  });

  factory StatItem.fromJson(Map<String, dynamic> json) {
    return StatItem(
      value: json['value']?.toString() ?? '0',
      raw: json['raw'] ?? 0,
      change: json['change']?.toString() ?? '',
      trend: json['trend']?.toString() ?? '',
    );
  }
}

class DashboardStatsModel {
  final StatItem totalUsers;
  final StatItem activeDrivers;
  final StatItem totalParents;
  final StatItem subscribedChildren;
  final StatItem dailySubscriptions;
  final StatItem monthlySubscriptions;
  final StatItem activeTrips;

  DashboardStatsModel({
    required this.totalUsers,
    required this.activeDrivers,
    required this.totalParents,
    required this.subscribedChildren,
    required this.dailySubscriptions,
    required this.monthlySubscriptions,
    required this.activeTrips,
  });

  StatItem get activeSubscriptions => subscribedChildren;

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    // الباك إند يرسل البيانات داخل مفتاح 'data'
    final data = json['data'] ?? json;
    
    return DashboardStatsModel(
      totalUsers: StatItem.fromJson(data['total_users'] ?? {}),
      activeDrivers: StatItem.fromJson(data['active_drivers'] ?? {}),
      totalParents: StatItem.fromJson(data['total_parents'] ?? {}),
      subscribedChildren: StatItem.fromJson(data['subscribed_children'] ?? data['active_subscriptions'] ?? {}),
      dailySubscriptions: StatItem.fromJson(data['daily_subscriptions'] ?? {}),
      monthlySubscriptions: StatItem.fromJson(data['monthly_subscriptions'] ?? {}),
      activeTrips: StatItem.fromJson(data['drivers_with_active_trips'] ?? data['active_trips'] ?? {}),
    );
  }
}