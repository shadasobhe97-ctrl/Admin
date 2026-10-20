import '../data/models/dashboard_stats_model.dart';
import '../data/models/active_trip_model.dart';

class DashboardState {
  final bool isLoading;
  final bool isGenerating;
  final String? errorMessage;
  final String? successMessage;
  final DashboardStatsModel? stats;
  final List<ActiveTripModel> activeTrips;
  final bool isRealtimeActive;
  final bool isUsingFallbackPolling;

  const DashboardState({
    this.isLoading = false,
    this.isGenerating = false,
    this.errorMessage,
    this.successMessage,
    this.stats,
    this.activeTrips = const [],
    this.isRealtimeActive = false,
    this.isUsingFallbackPolling = false,
  });

  DashboardState copyWith({
    bool? isLoading,
    bool? isGenerating,
    String? errorMessage,
    String? successMessage,
    DashboardStatsModel? stats,
    List<ActiveTripModel>? activeTrips,
    bool? isRealtimeActive,
    bool? isUsingFallbackPolling,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
      stats: stats ?? this.stats,
      activeTrips: activeTrips ?? this.activeTrips,
      isRealtimeActive: isRealtimeActive ?? this.isRealtimeActive,
      isUsingFallbackPolling: isUsingFallbackPolling ?? this.isUsingFallbackPolling,
    );
  }
}
