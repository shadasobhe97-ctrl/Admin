import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/ai_alert_model.dart';

abstract class AiAlertsRemoteDataSource {
  Future<AiAlertsListResult> getAlerts({
    String? riskLevel,
    bool? isResolved,
    int? driverId,
    int page = 1,
  });

  Future<AiAlertModel> getAlertDetails(int id);
}

class AiAlertsRemoteDataSourceImpl implements AiAlertsRemoteDataSource {
  final ApiClient _apiClient;

  AiAlertsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AiAlertsListResult> getAlerts({
    String? riskLevel,
    bool? isResolved,
    int? driverId,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
    };

    if (riskLevel != null && riskLevel.isNotEmpty && riskLevel != 'all') {
      queryParams['risk_level'] = riskLevel;
    }
    if (isResolved != null) {
      queryParams['is_resolved'] = isResolved;
    }
    if (driverId != null) {
      queryParams['driver_id'] = driverId;
    }

    final response = await _apiClient.get(
      ApiEndpoints.aiAlerts,
      queryParameters: queryParams,
    );

    final data = response.data as Map<String, dynamic>;
    return AiAlertsListResult.fromJson(data);
  }

  @override
  Future<AiAlertModel> getAlertDetails(int id) async {
    final response = await _apiClient.get(
      ApiEndpoints.aiAlertDetails(id),
    );

    final data = response.data as Map<String, dynamic>;
    final itemData = data['data'] as Map<String, dynamic>?;
    return AiAlertModel.fromJson(itemData ?? const {});
  }
}
