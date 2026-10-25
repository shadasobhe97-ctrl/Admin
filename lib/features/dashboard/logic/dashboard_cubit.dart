import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/active_trip_model.dart';
import '../data/models/dashboard_stats_model.dart';
import '../data/models/emergency_trip_item_model.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/services/radar_tracking_service.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repository;
  final RadarTrackingService _radarTrackingService;

  Timer? _fallbackPollingTimer;
  final Map<int, ActiveTripModel> _tripsMap = {};

  DashboardCubit(
    this._repository, {
    RadarTrackingService? radarTrackingService,
  })  : _radarTrackingService = radarTrackingService ?? RadarTrackingService(),
        super(const DashboardState());

  /// التحميل الأولي للبيانات (الإحصائيات + الرحلات النشطة + الرحلات المعطلة)
  Future<void> fetchDashboardData() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final statsFuture = _repository.getStats();
      final tripsFuture = _repository.getActiveTrips();
      final emergenciesFuture = _repository.getEmergenciesList().catchError((_) => EmergenciesListResult(
            stats: EmergencyStatsModel.fromJson(null),
            items: [],
            total: 0,
            currentPage: 1,
            lastPage: 1,
          ));

      final results = await Future.wait([statsFuture, tripsFuture, emergenciesFuture]);
      final stats = results[0] as DashboardStatsModel;
      final trips = results[1] as List<ActiveTripModel>;
      final emergencies = results[2] as EmergenciesListResult;

      _tripsMap.clear();
      for (final trip in trips) {
        _tripsMap[trip.tripId] = trip;
      }

      emit(state.copyWith(
        isLoading: false,
        stats: stats,
        activeTrips: trips,
        emergencyTrips: emergencies.items,
        emergencyStats: emergencies.stats,
        isRealtimeActive: false,
        isUsingFallbackPolling: false,
      ));

      // خطوة ب: فتح الـ Listener اللحظي على Firestore لكامل كولكشن trips_tracking
      _startRealtimeTracking();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        stats: state.stats ?? DashboardStatsModel.empty(),
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      // تفعيل الـ Fallback في حالة الفشل
      _activateFallbackPolling();
    }
  }

  /// ربط البث المباشر عبر Firebase Firestore مع مزامنة دورية هجينة
  void _startRealtimeTracking() {
    _radarTrackingService.startTracking(
      currentTrips: _tripsMap,
      onTripsUpdated: (updatedTrips) {
        if (!isClosed) {
          emit(state.copyWith(
            activeTrips: updatedTrips,
            isRealtimeActive: true,
            isUsingFallbackPolling: false,
          ));
        }
      },
      onError: (error) {
        if (!isClosed) {
          _activateFallbackPolling();
        }
      },
    );

    // مزامنة دورية هجينة كل 20 ثانية لضمان جلب أي تحديثات من قاعدة بيانات الخادم
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    _fallbackPollingTimer?.cancel();
    _fallbackPollingTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      if (isClosed) return;
      try {
        final freshTrips = await _repository.getActiveTrips();
        for (final fresh in freshTrips) {
          final existing = _tripsMap[fresh.tripId];
          if (existing != null && state.isRealtimeActive && (existing.updatedAt?.isAfter(fresh.updatedAt ?? DateTime(2000)) ?? false)) {
            _tripsMap[fresh.tripId] = fresh.copyWith(
              currentLat: existing.currentLat,
              currentLng: existing.currentLng,
              heading: existing.heading,
              speedKmH: existing.speedKmH,
              isOnline: existing.isOnline,
              lastUpdate: existing.lastUpdate,
            );
          } else {
            _tripsMap[fresh.tripId] = fresh;
          }
        }
        if (!isClosed) {
          emit(state.copyWith(
            activeTrips: _tripsMap.values.toList(),
          ));
        }
      } catch (_) {}
    });
  }

  /// خطوة ج: نظام الاحتياط (Fallback) — عمل Polling كل 15 ثانية على الـ API عند انقطاع الفايربيز
  void _activateFallbackPolling() {
    if (isClosed) return;

    emit(state.copyWith(
      isRealtimeActive: false,
      isUsingFallbackPolling: true,
    ));

    _fallbackPollingTimer?.cancel();
    _fallbackPollingTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (isClosed) return;
      try {
        final freshTrips = await _repository.getActiveTrips();
        _tripsMap.clear();
        for (final trip in freshTrips) {
          _tripsMap[trip.tripId] = trip;
        }
        if (!isClosed) {
          emit(state.copyWith(
            activeTrips: freshTrips,
            isRealtimeActive: false,
            isUsingFallbackPolling: true,
          ));
        }
      } catch (_) {}
    });
  }

  Future<void> generateDailyTrips({String? date}) async {
    emit(state.copyWith(isGenerating: true, clearError: true, clearSuccess: true));
    try {
      final result = await _repository.generateDailyTrips(date: date);
      final count = result['generated_trips_count'] ?? 0;
      final msg = result['message'] ?? 'تم توليد رحلات اليوم بنجاح.';
      final fullMsg = '$msg (عدد الرحلات: $count)';

      emit(state.copyWith(
        isGenerating: false,
        successMessage: fullMsg,
      ));

      // Refresh dashboard stats & trips after generating
      await fetchDashboardData();
    } catch (e) {
      emit(state.copyWith(
        isGenerating: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// تحديث قائمة الرحلات المعطلة فقط
  Future<void> refreshEmergencies() async {
    try {
      final res = await _repository.getEmergenciesList();
      emit(state.copyWith(
        emergencyTrips: res.items,
        emergencyStats: res.stats,
      ));
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _radarTrackingService.stopTracking();
    _fallbackPollingTimer?.cancel();
    _fallbackPollingTimer = null;
    return super.close();
  }
}
