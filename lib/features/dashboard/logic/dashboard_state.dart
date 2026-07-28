import '../data/models/dashboard_stats_model.dart';
import '../data/models/active_trip_model.dart';

class DashboardState {
  final bool isLoading;
  final String? errorMessage;
  final DashboardStatsModel? stats;
  final List<ActiveTripModel> activeTrips;

  const DashboardState({
    this.isLoading = false,
    this.errorMessage,
    this.stats,
    this.activeTrips = const [],
  });

  DashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    DashboardStatsModel? stats,
    List<ActiveTripModel>? activeTrips,
    bool clearError = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      stats: stats ?? this.stats,
      activeTrips: activeTrips ?? this.activeTrips,
    );
  }
}
