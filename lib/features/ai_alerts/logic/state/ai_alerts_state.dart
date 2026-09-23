import '../../../../core/models/pagination_meta_model.dart';
import '../../data/models/ai_alert_model.dart';
import '../../data/models/ai_decision_audit_model.dart';

class AiAlertsState {
  final bool isLoading;
  final bool isDetailsLoading;
  final bool isLoadingAudits;
  final bool isResolvingAlert;
  final bool isResettingDriver;

  final List<AiAlertModel> alerts;
  final PaginationMetaModel meta;

  final List<AiDecisionAuditModel> audits;
  final PaginationMetaModel auditsMeta;

  final String selectedRiskLevel; // 'all' | 'CRITICAL' | 'HIGH' | 'MODERATE'
  final bool? selectedIsResolved; // null = الكل
  final int? selectedDriverId;
  final int? selectedDecisionCodeFilter;

  final AiAlertModel? selectedAlertDetails;
  final String? errorMessage;
  final String? successMessage;

  const AiAlertsState({
    this.isLoading = false,
    this.isDetailsLoading = false,
    this.isLoadingAudits = false,
    this.isResolvingAlert = false,
    this.isResettingDriver = false,
    this.alerts = const [],
    this.meta = const PaginationMetaModel(),
    this.audits = const [],
    this.auditsMeta = const PaginationMetaModel(),
    this.selectedRiskLevel = 'all',
    this.selectedIsResolved,
    this.selectedDriverId,
    this.selectedDecisionCodeFilter,
    this.selectedAlertDetails,
    this.errorMessage,
    this.successMessage,
  });

  AiAlertsState copyWith({
    bool? isLoading,
    bool? isDetailsLoading,
    bool? isLoadingAudits,
    bool? isResolvingAlert,
    bool? isResettingDriver,
    List<AiAlertModel>? alerts,
    PaginationMetaModel? meta,
    List<AiDecisionAuditModel>? audits,
    PaginationMetaModel? auditsMeta,
    String? selectedRiskLevel,
    bool? selectedIsResolved,
    bool clearResolvedFilter = false,
    int? selectedDriverId,
    bool clearDriverFilter = false,
    int? selectedDecisionCodeFilter,
    bool clearDecisionCodeFilter = false,
    AiAlertModel? selectedAlertDetails,
    bool clearDetails = false,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return AiAlertsState(
      isLoading: isLoading ?? this.isLoading,
      isDetailsLoading: isDetailsLoading ?? this.isDetailsLoading,
      isLoadingAudits: isLoadingAudits ?? this.isLoadingAudits,
      isResolvingAlert: isResolvingAlert ?? this.isResolvingAlert,
      isResettingDriver: isResettingDriver ?? this.isResettingDriver,
      alerts: alerts ?? this.alerts,
      meta: meta ?? this.meta,
      audits: audits ?? this.audits,
      auditsMeta: auditsMeta ?? this.auditsMeta,
      selectedRiskLevel: selectedRiskLevel ?? this.selectedRiskLevel,
      selectedIsResolved: clearResolvedFilter
          ? null
          : (selectedIsResolved ?? this.selectedIsResolved),
      selectedDriverId:
          clearDriverFilter ? null : (selectedDriverId ?? this.selectedDriverId),
      selectedDecisionCodeFilter: clearDecisionCodeFilter
          ? null
          : (selectedDecisionCodeFilter ?? this.selectedDecisionCodeFilter),
      selectedAlertDetails: clearDetails
          ? null
          : (selectedAlertDetails ?? this.selectedAlertDetails),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
