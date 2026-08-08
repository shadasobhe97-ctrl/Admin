import '../data/models/driver_change_details_model.dart';
import '../data/models/driver_change_request_model.dart';
import '../data/models/driver_details_model.dart';
import '../data/models/driver_model.dart';
import '../data/models/driver_review_model.dart';
import '../data/models/pagination_meta_model.dart';

class DriversManagementState {
  final List<DriverModel> drivers;
  final PaginationMetaModel meta;
  final DriverDetailsModel? selectedDriverDetails;
  final List<DriverChangeRequestModel> pendingChanges;
  final DriverChangeDetailsModel? selectedChangeDetails;
  final List<DriverReviewModel> reviews;
  final bool isLoading;
  final bool isLoadingDetails;
  final bool isLoadingReviews;
  final bool isSubmittingReview;
  final String selectedStatus; // 'all', 'pending', 'Approved', 'Rejected'
  final String? searchQuery;
  final String? errorMessage;
  final String? successMessage;

  const DriversManagementState({
    this.drivers = const [],
    this.meta = const PaginationMetaModel(),
    this.selectedDriverDetails,
    this.pendingChanges = const [],
    this.selectedChangeDetails,
    this.reviews = const [],
    this.isLoading = false,
    this.isLoadingDetails = false,
    this.isLoadingReviews = false,
    this.isSubmittingReview = false,
    this.selectedStatus = 'all',
    this.searchQuery,
    this.errorMessage,
    this.successMessage,
  });

  bool get isEmpty => !isLoading && drivers.isEmpty;
  bool get isPendingChangesEmpty => !isLoading && pendingChanges.isEmpty;
  bool get isReviewsEmpty => !isLoadingReviews && reviews.isEmpty;

  DriversManagementState copyWith({
    List<DriverModel>? drivers,
    PaginationMetaModel? meta,
    DriverDetailsModel? selectedDriverDetails,
    bool clearSelectedDriverDetails = false,
    List<DriverChangeRequestModel>? pendingChanges,
    DriverChangeDetailsModel? selectedChangeDetails,
    bool clearSelectedChangeDetails = false,
    List<DriverReviewModel>? reviews,
    bool? isLoading,
    bool? isLoadingDetails,
    bool? isLoadingReviews,
    bool? isSubmittingReview,
    String? selectedStatus,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return DriversManagementState(
      drivers: drivers ?? this.drivers,
      meta: meta ?? this.meta,
      selectedDriverDetails: clearSelectedDriverDetails ? null : (selectedDriverDetails ?? this.selectedDriverDetails),
      pendingChanges: pendingChanges ?? this.pendingChanges,
      selectedChangeDetails: clearSelectedChangeDetails ? null : (selectedChangeDetails ?? this.selectedChangeDetails),
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      isLoadingReviews: isLoadingReviews ?? this.isLoadingReviews,
      isSubmittingReview: isSubmittingReview ?? this.isSubmittingReview,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
