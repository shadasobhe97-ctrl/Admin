class DashboardStatsModel {
  final int totalUsers;
  final int activeDrivers;
  final int activeSubscriptions;
  final int activeTrips;

  DashboardStatsModel({
    required this.totalUsers,
    required this.activeDrivers,
    required this.activeSubscriptions,
    required this.activeTrips,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalUsers: json['total_users'] ?? 0,
      activeDrivers: json['active_drivers'] ?? 0,
      activeSubscriptions: json['active_subscriptions'] ?? 0,
      activeTrips: json['active_trips'] ?? 0,
    );
  }
}
