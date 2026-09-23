import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/ai_alert_model.dart';
import '../models/ai_decision_audit_model.dart';

abstract class AiAlertsRemoteDataSource {
  Future<AiAlertsListResult> getAlerts({
    String? riskLevel,
    bool? isResolved,
    int? driverId,
    int page = 1,
  });

  Future<AiAlertModel> getAlertDetails(int id);

  Future<String> resolveAlert(int alertId);

  Future<String> resetDriverAi(int driverId);

  Future<AiAuditsListResult> getAudits({
    int? driverId,
    int? decisionCode,
    int page = 1,
  });
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

  @override
  Future<String> resolveAlert(int alertId) async {
    final endpoint = ApiEndpoints.aiAlertResolve(alertId);
    final response = await _apiClient.post(endpoint);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? 'تمت تسوية التنبيه بنجاح.';
    }
    return 'تمت تسوية التنبيه بنجاح.';
  }

  @override
  Future<String> resetDriverAi(int driverId) async {
    final endpoint = ApiEndpoints.driverAiReset(driverId);
    final response = await _apiClient.post(endpoint);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ??
          'تمت إعادة تأهيل السائق ورفع الحجب وتصفير التحذيرات بنجاح.';
    }
    return 'تمت إعادة تأهيل السائق ورفع الحجب وتصفير التحذيرات بنجاح.';
  }

  @override
  Future<AiAuditsListResult> getAudits({
    int? driverId,
    int? decisionCode,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
    };

    if (driverId != null) {
      queryParams['driver_id'] = driverId;
    }
    if (decisionCode != null) {
      queryParams['decision_code'] = decisionCode;
    }

    final response = await _apiClient.get(
      ApiEndpoints.aiAudits,
      queryParameters: queryParams,
    );

    final data = response.data as Map<String, dynamic>;
    return AiAuditsListResult.fromJson(data);
  }
}
