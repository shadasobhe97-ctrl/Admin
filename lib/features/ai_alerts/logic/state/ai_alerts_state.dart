import '../../../../core/models/pagination_meta_model.dart';
import '../../data/models/ai_alert_model.dart';

class AiAlertsState {
  final bool isLoading;
  final bool isDetailsLoading;
  final List<AiAlertModel> alerts;
  final PaginationMetaModel meta;
  final String selectedRiskLevel; // 'all' | 'CRITICAL' | 'HIGH'
  final bool? selectedIsResolved; // null = الكل
  final int? selectedDriverId;
  final AiAlertModel? selectedAlertDetails;
  final String? errorMessage;

  const AiAlertsState({
    this.isLoading = false,
    this.isDetailsLoading = false,
    this.alerts = const [],
    this.meta = const PaginationMetaModel(),
    this.selectedRiskLevel = 'all',
    this.selectedIsResolved,
    this.selectedDriverId,
    this.selectedAlertDetails,
    this.errorMessage,
  });

  AiAlertsState copyWith({
    bool? isLoading,
    bool? isDetailsLoading,
    List<AiAlertModel>? alerts,
    PaginationMetaModel? meta,
    String? selectedRiskLevel,
    bool? selectedIsResolved,
    bool clearResolvedFilter = false,
    int? selectedDriverId,
    bool clearDriverFilter = false,
    AiAlertModel? selectedAlertDetails,
    bool clearDetails = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AiAlertsState(
      isLoading: isLoading ?? this.isLoading,
      isDetailsLoading: isDetailsLoading ?? this.isDetailsLoading,
      alerts: alerts ?? this.alerts,
      meta: meta ?? this.meta,
      selectedRiskLevel: selectedRiskLevel ?? this.selectedRiskLevel,
      selectedIsResolved: clearResolvedFilter
          ? null
          : (selectedIsResolved ?? this.selectedIsResolved),
      selectedDriverId:
          clearDriverFilter ? null : (selectedDriverId ?? this.selectedDriverId),
      selectedAlertDetails: clearDetails
          ? null
          : (selectedAlertDetails ?? this.selectedAlertDetails),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
