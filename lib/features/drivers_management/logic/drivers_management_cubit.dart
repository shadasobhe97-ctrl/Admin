import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/drivers_management_repository.dart';
import 'drivers_management_state.dart';

class DriversManagementCubit extends Cubit<DriversManagementState> {
  final DriversManagementRepository _repository;
  Timer? _debounceTimer;

  DriversManagementCubit(this._repository) : super(const DriversManagementState());

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  /// 1. GET /api/admin/drivers (with status, search, and pagination page)
  Future<void> fetchDrivers({
    String? status,
    String? search,
    int page = 1,
  }) async {
    final activeStatus = status ?? state.selectedStatus;
    final activeSearch = search ?? state.searchQuery;

    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      selectedStatus: activeStatus,
      searchQuery: activeSearch,
    ));

    try {
      final result = await _repository.getDrivers(
        status: activeStatus,
        search: activeSearch,
        page: page,
      );

      emit(state.copyWith(
        isLoading: false,
        drivers: result.drivers,
        meta: result.meta,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Debounced Search (500ms)
  void searchDrivers(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchDrivers(search: query, page: 1);
    });
  }

  /// Filter Status (All, Pending, Approved, Rejected)
  void filterByStatus(String status) {
    fetchDrivers(status: status, page: 1);
  }

  /// Pagination Navigation
  void goToPage(int page) {
    if (page < 1 || page > state.meta.lastPage) return;
    fetchDrivers(page: page);
  }

  /// 2. GET /api/admin/drivers/{id}
  Future<void> fetchDriverDetails(int id) async {
    emit(state.copyWith(
      isLoadingDetails: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final details = await _repository.getDriverDetails(id);
      emit(state.copyWith(
        isLoadingDetails: false,
        selectedDriverDetails: details,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDetails: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// 3. POST /api/admin/drivers/{id}/review
  Future<bool> reviewDriver({
    required int id,
    required String action, // approve or reject
    String? rejectionReason,
  }) async {
    if (state.isSubmittingReview) return false;
    emit(state.copyWith(
      isSubmittingReview: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final msg = await _repository.reviewDriver(
        id: id,
        action: action,
        rejectionReason: rejectionReason,
      );

      emit(state.copyWith(
        isSubmittingReview: false,
        successMessage: msg,
      ));

      // Refresh clean drivers list and details
      await fetchDrivers(page: state.meta.currentPage);
      await fetchDriverDetails(id);
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSubmittingReview: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  /// 4. GET /api/admin/drivers/pending-changes
  Future<void> fetchPendingDriverChanges() async {
    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final changes = await _repository.getPendingDriverChanges();
      emit(state.copyWith(
        isLoading: false,
        pendingChanges: changes,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// 5. GET /api/admin/drivers/pending-changes/{id}
  Future<void> fetchPendingDriverChangeDetails(int id) async {
    emit(state.copyWith(
      isLoadingDetails: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final details = await _repository.getPendingDriverChangeDetails(id);
      emit(state.copyWith(
        isLoadingDetails: false,
        selectedChangeDetails: details,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDetails: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// 6. POST /api/admin/drivers/pending-changes/{id}/review
  Future<bool> reviewDriverChange({
    required int id,
    required String decision, // Approved or Rejected
    String? rejectionReason,
  }) async {
    if (state.isSubmittingReview) return false;
    emit(state.copyWith(
      isSubmittingReview: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final msg = await _repository.reviewDriverChange(
        id: id,
        decision: decision,
        rejectionReason: rejectionReason,
      );

      emit(state.copyWith(
        isSubmittingReview: false,
        successMessage: msg,
      ));

      // Refresh list of pending changes and main list
      await fetchPendingDriverChanges();
      await fetchDrivers(page: state.meta.currentPage);
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSubmittingReview: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  /// 7. GET /api/admin/driver-reviews/all
  Future<void> fetchAllDriverReviews() async {
    emit(state.copyWith(
      isLoadingReviews: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final reviewsList = await _repository.getAllDriverReviews();
      emit(state.copyWith(
        isLoadingReviews: false,
        reviews: reviewsList,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingReviews: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// 8. GET /api/admin/driver-reviews/driver/{driverId}
  Future<void> fetchDriverReviewsForDriver(int driverId) async {
    emit(state.copyWith(
      isLoadingReviews: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final reviewsList = await _repository.getDriverReviewsForDriver(driverId);
      emit(state.copyWith(
        isLoadingReviews: false,
        reviews: reviewsList,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingReviews: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// 9. DELETE /api/admin/driver-reviews/{id}
  Future<bool> deleteDriverReview(int reviewId, {int? driverIdFilter}) async {
    emit(state.copyWith(
      isSubmittingReview: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final msg = await _repository.deleteDriverReview(reviewId);
      emit(state.copyWith(
        isSubmittingReview: false,
        successMessage: msg,
      ));

      if (driverIdFilter != null && driverIdFilter > 0) {
        await fetchDriverReviewsForDriver(driverIdFilter);
      } else {
        await fetchAllDriverReviews();
      }
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSubmittingReview: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
