import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/ai_alert_model.dart';
import '../../data/repositories/ai_alerts_repository.dart';
import '../state/ai_alerts_state.dart';

class AiAlertsCubit extends Cubit<AiAlertsState> {
  final AiAlertsRepository _repository;

  AiAlertsCubit(this._repository) : super(const AiAlertsState());

  Future<void> fetchAlerts({
    String? riskLevel,
    bool? isResolved,
    bool clearResolvedFilter = false,
    int? driverId,
    bool clearDriverFilter = false,
    int page = 1,
  }) async {
    final activeRiskLevel = riskLevel ?? state.selectedRiskLevel;
    final activeIsResolved = clearResolvedFilter
        ? null
        : (isResolved ?? state.selectedIsResolved);
    final activeDriverId =
        clearDriverFilter ? null : (driverId ?? state.selectedDriverId);

    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      selectedRiskLevel: activeRiskLevel,
      selectedIsResolved: activeIsResolved,
      clearResolvedFilter: clearResolvedFilter,
      selectedDriverId: activeDriverId,
      clearDriverFilter: clearDriverFilter,
    ));

    try {
      final result = await _repository.getAlerts(
        riskLevel: activeRiskLevel,
        isResolved: activeIsResolved,
        driverId: activeDriverId,
        page: page,
      );

      emit(state.copyWith(
        isLoading: false,
        alerts: result.alerts,
        meta: result.meta,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void changeRiskLevelFilter(String riskLevel) {
    if (state.selectedRiskLevel == riskLevel) return;
    fetchAlerts(riskLevel: riskLevel, page: 1);
  }

  void changeResolvedFilter(bool? isResolved) {
    if (isResolved == null) {
      fetchAlerts(clearResolvedFilter: true, page: 1);
    } else {
      fetchAlerts(isResolved: isResolved, page: 1);
    }
  }

  void filterByDriverId(int driverId) {
    fetchAlerts(driverId: driverId, page: 1);
  }

  void clearDriverFilter() {
    fetchAlerts(clearDriverFilter: true, page: 1);
  }

  Future<void> fetchAlertDetails(int id) async {
    emit(state.copyWith(
      isDetailsLoading: true,
      clearError: true,
      clearSuccess: true,
      clearDetails: true,
    ));

    try {
      final details = await _repository.getAlertDetails(id);
      emit(state.copyWith(
        isDetailsLoading: false,
        selectedAlertDetails: details,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDetailsLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// تسوية وإغلاق التنبيه في الوقت الفعلي (Optimistic UI Update)
  Future<bool> resolveAlert(int alertId) async {
    if (state.isResolvingAlert) return false;

    // Optimistic Update: تحديث شارة التنبيه في الواجهة فوراً
    final updatedAlerts = state.alerts.map((a) {
      if (a.id == alertId) {
        return AiAlertModel(
          id: a.id,
          driverId: a.driverId,
          riskLevel: a.riskLevel,
          actionsTaken: a.actionsTaken,
          adminMessage: a.adminMessage,
          reasoning: a.reasoning,
          aiMetrics: a.aiMetrics,
          isResolved: true,
          alertType: a.alertType,
          title: a.title,
          message: a.message,
          severity: a.severity,
          actionRequired: a.actionRequired,
          metadata: a.metadata,
          isRead: a.isRead,
          createdAt: a.createdAt,
          updatedAt: a.updatedAt,
          driver: a.driver,
          driverName: a.driverName,
          driverPhone: a.driverPhone,
        );
      }
      return a;
    }).toList();

    emit(state.copyWith(
      isResolvingAlert: true,
      alerts: updatedAlerts,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final msg = await _repository.resolveAlert(alertId);
      emit(state.copyWith(
        isResolvingAlert: false,
        successMessage: msg,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isResolvingAlert: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      // إعادة جلب التنبيهات في حال فشل الطلب
      await fetchAlerts(page: state.meta.currentPage);
      return false;
    }
  }

  /// إعادة تأهيل السائق ورفع الحجب وتصفير التحذيرات (AI Reset)
  Future<bool> resetDriverAi(int driverId) async {
    if (state.isResettingDriver) return false;

    emit(state.copyWith(
      isResettingDriver: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final msg = await _repository.resetDriverAi(driverId);
      emit(state.copyWith(
        isResettingDriver: false,
        successMessage: msg,
      ));

      // إعادة جلب التنبيهات والسجلات فوراً
      await fetchAlerts(page: state.meta.currentPage);
      if (state.audits.isNotEmpty) {
        await fetchAudits(page: state.auditsMeta.currentPage);
      }
      return true;
    } catch (e) {
      emit(state.copyWith(
        isResettingDriver: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  /// جلب سجل تدقيق قرارات الذكاء الاصطناعي (AI Audits)
  Future<void> fetchAudits({
    int? driverId,
    int? decisionCode,
    bool clearDecisionCodeFilter = false,
    int page = 1,
  }) async {
    final activeDecisionCode = clearDecisionCodeFilter
        ? null
        : (decisionCode ?? state.selectedDecisionCodeFilter);

    emit(state.copyWith(
      isLoadingAudits: true,
      clearError: true,
      clearSuccess: true,
      selectedDecisionCodeFilter: activeDecisionCode,
      clearDecisionCodeFilter: clearDecisionCodeFilter,
    ));

    try {
      final result = await _repository.getAudits(
        driverId: driverId ?? state.selectedDriverId,
        decisionCode: activeDecisionCode,
        page: page,
      );

      emit(state.copyWith(
        isLoadingAudits: false,
        audits: result.audits,
        auditsMeta: result.meta,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingAudits: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void changeDecisionCodeFilter(int? decisionCode) {
    if (decisionCode == null) {
      fetchAudits(clearDecisionCodeFilter: true, page: 1);
    } else {
      fetchAudits(decisionCode: decisionCode, page: 1);
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
