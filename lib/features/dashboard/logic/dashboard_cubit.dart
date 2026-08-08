import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_state.dart';
import '../data/repositories/dashboard_repository.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repository;

  DashboardCubit(this._repository) : super(const DashboardState());

  Future<void> fetchDashboardData() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final stats = await _repository.getStats();
      final trips = await _repository.getActiveTrips();

      emit(state.copyWith(
        isLoading: false,
        stats: stats,
        activeTrips: trips,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
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
}
