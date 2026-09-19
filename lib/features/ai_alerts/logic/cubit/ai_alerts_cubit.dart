import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/ai_alerts_repository.dart';
import '../state/ai_alerts_state.dart';

/// شاشة مراقبة فقط: الأدمن يتابع ما اكتشفه الذكاء الاصطناعي ونتيجته
/// (تغيّر تقييم، وضع "غير موثوق")، ولا يوجد أي Action يدوي يُنفَّذ من هنا
/// لأن الـ backend لا يوفّر endpoint لذلك حالياً.
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

  void clearMessages() {
    emit(state.copyWith(clearError: true));
  }
}
