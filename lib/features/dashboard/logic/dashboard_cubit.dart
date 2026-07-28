import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_state.dart';
import '../data/repositories/dashboard_repository.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repository;

  DashboardCubit(this._repository) : super(const DashboardState());

  Future<void> fetchDashboardData() async {
    emit(state.copyWith(isLoading: true, clearError: true));
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
}
