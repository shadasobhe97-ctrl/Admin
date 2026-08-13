import '../../../../core/models/pagination_meta_model.dart';
import '../../data/models/complaint_model.dart';

class ComplaintsState {
  final bool isLoading;
  final bool isDetailsLoading;
  final bool isDriverHistoryLoading;
  final bool isActionLoading;
  final List<ComplaintModel> complaints;
  final PaginationMetaModel meta;
  final String selectedStatus; // 'all' | 'pending' | 'completed' | 'dismissed'
  final dynamic selectedDriverId;
  final String? selectedDriverName;
  final ComplaintModel? selectedComplaintDetails;
  final List<ComplaintModel> driverComplaintsHistory;
  final PaginationMetaModel? driverHistoryMeta;
  final String? errorMessage;
  final String? successMessage;

  const ComplaintsState({
    this.isLoading = false,
    this.isDetailsLoading = false,
    this.isDriverHistoryLoading = false,
    this.isActionLoading = false,
    this.complaints = const [],
    this.meta = const PaginationMetaModel(),
    this.selectedStatus = 'all',
    this.selectedDriverId,
    this.selectedDriverName,
    this.selectedComplaintDetails,
    this.driverComplaintsHistory = const [],
    this.driverHistoryMeta,
    this.errorMessage,
    this.successMessage,
  });

  ComplaintsState copyWith({
    bool? isLoading,
    bool? isDetailsLoading,
    bool? isDriverHistoryLoading,
    bool? isActionLoading,
    List<ComplaintModel>? complaints,
    PaginationMetaModel? meta,
    String? selectedStatus,
    dynamic selectedDriverId,
    bool clearDriverFilter = false,
    String? selectedDriverName,
    ComplaintModel? selectedComplaintDetails,
    bool clearDetails = false,
    List<ComplaintModel>? driverComplaintsHistory,
    PaginationMetaModel? driverHistoryMeta,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return ComplaintsState(
      isLoading: isLoading ?? this.isLoading,
      isDetailsLoading: isDetailsLoading ?? this.isDetailsLoading,
      isDriverHistoryLoading: isDriverHistoryLoading ?? this.isDriverHistoryLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      complaints: complaints ?? this.complaints,
      meta: meta ?? this.meta,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedDriverId: clearDriverFilter ? null : (selectedDriverId ?? this.selectedDriverId),
      selectedDriverName: clearDriverFilter ? null : (selectedDriverName ?? this.selectedDriverName),
      selectedComplaintDetails: clearDetails
          ? null
          : (selectedComplaintDetails ?? this.selectedComplaintDetails),
      driverComplaintsHistory:
          driverComplaintsHistory ?? this.driverComplaintsHistory,
      driverHistoryMeta: driverHistoryMeta ?? this.driverHistoryMeta,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
