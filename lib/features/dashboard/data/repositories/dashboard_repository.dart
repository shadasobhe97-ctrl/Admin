import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/dashboard_stats_model.dart';
import '../models/active_trip_model.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<DashboardStatsModel> getStats() async {
    final response = await _apiClient.get(ApiEndpoints.dashboardStats);
    
    if (response.data['status'] == true) {
      return DashboardStatsModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'فشل جلب إحصائيات اللوحة');
    }
  }

  Future<List<ActiveTripModel>> getActiveTrips() async {
    final response = await _apiClient.get(ApiEndpoints.activeTrips);
    
    if (response.data['status'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => ActiveTripModel.fromJson(e)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'فشل جلب الرحلات الحية');
    }
  }
}
