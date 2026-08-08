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

  factory StatItem.fromDynamic(dynamic json, {String defaultLabel = ''}) {
    if (json is Map<String, dynamic>) {
      return StatItem(
        value: json['value']?.toString() ?? json['raw']?.toString() ?? '0',
        raw: json['raw'] is int ? json['raw'] : (int.tryParse(json['raw']?.toString() ?? '') ?? 0),
        change: json['change']?.toString() ?? '',
        trend: json['trend']?.toString() ?? '',
      );
    } else if (json is num) {
      return StatItem(
        value: json.toString(),
        raw: json.toInt(),
        change: '',
        trend: '',
      );
    }
    return StatItem(value: json?.toString() ?? '0', raw: 0, change: '', trend: '');
  }
}

class DashboardStatsModel {
  final int totalUsers;
  final int totalDrivers;
  final int pendingDrivers;
  final int totalParents;
  final int activeSubscriptions;
  final int activeTripsToday;
  final double totalRevenueDinar;

  DashboardStatsModel({
    required this.totalUsers,
    required this.totalDrivers,
    required this.pendingDrivers,
    required this.totalParents,
    required this.activeSubscriptions,
    required this.activeTripsToday,
    required this.totalRevenueDinar,
  });

  // Backward compatibility StatItem getters
  StatItem get statTotalUsers => StatItem(value: totalUsers.toString(), raw: totalUsers, change: '', trend: 'up');
  StatItem get statActiveDrivers => StatItem(value: totalDrivers.toString(), raw: totalDrivers, change: '', trend: 'up');
  StatItem get statPendingDrivers => StatItem(value: pendingDrivers.toString(), raw: pendingDrivers, change: '', trend: 'warning');
  StatItem get statTotalParents => StatItem(value: totalParents.toString(), raw: totalParents, change: '', trend: 'info');
  StatItem get statActiveSubscriptions => StatItem(value: activeSubscriptions.toString(), raw: activeSubscriptions, change: '', trend: 'up');
  StatItem get statActiveTripsToday => StatItem(value: activeTripsToday.toString(), raw: activeTripsToday, change: '', trend: 'live');
  StatItem get statTotalRevenue => StatItem(value: '${totalRevenueDinar.toStringAsFixed(2)} د.ل', raw: totalRevenueDinar.toInt(), change: '', trend: 'info');

  // Compatibility aliases
  StatItem get activeDrivers => statActiveDrivers;
  StatItem get subscribedChildren => statActiveSubscriptions;
  StatItem get dailySubscriptions => StatItem(value: '0', raw: 0, change: '', trend: 'info');
  StatItem get monthlySubscriptions => StatItem(value: '0', raw: 0, change: '', trend: 'info');
  StatItem get activeTrips => statActiveTripsToday;

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    // Handling response wrappers if passed root json or data key
    final Map<String, dynamic> data = (json['data'] is Map<String, dynamic>)
        ? json['data']
        : json;

    int parseNum(dynamic val) {
      if (val is num) return val.toInt();
      if (val is Map && val['raw'] is num) return (val['raw'] as num).toInt();
      if (val is Map && val['value'] != null) return int.tryParse(val['value'].toString()) ?? 0;
      return int.tryParse(val?.toString() ?? '') ?? 0;
    }

    double parseDouble(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is Map && val['raw'] is num) return (val['raw'] as num).toDouble();
      if (val is Map && val['value'] != null) return double.tryParse(val['value'].toString()) ?? 0.0;
      return double.tryParse(val?.toString() ?? '') ?? 0.0;
    }

    return DashboardStatsModel(
      totalUsers: parseNum(data['total_users']),
      totalDrivers: parseNum(data['total_drivers'] ?? data['active_drivers']),
      pendingDrivers: parseNum(data['pending_drivers']),
      totalParents: parseNum(data['total_parents']),
      activeSubscriptions: parseNum(data['active_subscriptions'] ?? data['subscribed_children']),
      activeTripsToday: parseNum(data['active_trips_today'] ?? data['active_trips'] ?? data['drivers_with_active_trips']),
      totalRevenueDinar: parseDouble(data['total_revenue_dinar']),
    );
  }
}