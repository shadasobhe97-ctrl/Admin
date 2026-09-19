import '../../../../core/network/api_exception.dart';
import '../datasources/ai_alerts_remote_datasource.dart';
import '../models/ai_alert_model.dart';

abstract class AiAlertsRepository {
  Future<AiAlertsListResult> getAlerts({
    String? riskLevel,
    bool? isResolved,
    int? driverId,
    int page = 1,
  });

  Future<AiAlertModel> getAlertDetails(int id);
}

class AiAlertsRepositoryImpl implements AiAlertsRepository {
  final AiAlertsRemoteDataSource _remoteDataSource;

  AiAlertsRepositoryImpl(this._remoteDataSource);

  @override
  Future<AiAlertsListResult> getAlerts({
    String? riskLevel,
    bool? isResolved,
    int? driverId,
    int page = 1,
  }) async {
    try {
      return await _remoteDataSource.getAlerts(
        riskLevel: riskLevel,
        isResolved: isResolved,
        driverId: driverId,
        page: page,
      );
    } catch (e) {
      throw ApiErrorMapper.map(
        e,
        fallbackMessage: 'فشل في جلب قائمة تنبيهات الذكاء الاصطناعي.',
      );
    }
  }

  @override
  Future<AiAlertModel> getAlertDetails(int id) async {
    try {
      return await _remoteDataSource.getAlertDetails(id);
    } catch (e) {
      throw ApiErrorMapper.map(
        e,
        fallbackMessage: 'فشل في جلب تفاصيل التنبيه.',
      );
    }
  }
}
