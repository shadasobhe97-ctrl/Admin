import '../../../../core/di/service_locator.dart';
import '../models/active_trip_model.dart';
import '../models/dashboard_stats_model.dart';
import '../repositories/dashboard_repository.dart';

class DashboardService {
  final DashboardRepository _repository = sl<DashboardRepository>();

  Future<DashboardStatsModel> fetchDashboardStats() async {
    return await _repository.getStats();
  }

  Future<List<ActiveTripModel>> fetchActiveTrips() async {
    return await _repository.getActiveTrips();
  }

  Future<Map<String, dynamic>> generateDailyTrips({String? date}) async {
    return await _repository.generateDailyTrips(date: date);
  }
}