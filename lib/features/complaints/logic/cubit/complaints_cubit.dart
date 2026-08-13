import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/complaints_repository.dart';
import '../state/complaints_state.dart';

class ComplaintsCubit extends Cubit<ComplaintsState> {
  final ComplaintsRepository _repository;

  ComplaintsCubit(this._repository) : super(const ComplaintsState());

  /// 1. جلب قائمة الشكاوى مع الفلترة وتنقل الصفحات
  Future<void> fetchComplaints({
    String? status,
    dynamic driverId,
    String? driverName,
    int page = 1,
  }) async {
    final activeStatus = status ?? state.selectedStatus;
    final activeDriverId = driverId ?? state.selectedDriverId;
    final activeDriverName = driverName ?? state.selectedDriverName;

    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      selectedStatus: activeStatus,
      selectedDriverId: activeDriverId,
      selectedDriverName: activeDriverName,
    ));

    try {
      final result = await _repository.getComplaints(
        status: activeStatus,
        driverId: activeDriverId,
        page: page,
      );

      emit(state.copyWith(
        isLoading: false,
        complaints: result.complaints,
        meta: result.meta,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// تغيير فلتر الحالة (الكل، قيد الانتظار، مكتملة، مرفوضة) وإعادة الضبط للصفحة 1
  void changeStatusFilter(String status) {
    if (state.selectedStatus == status) return;
    fetchComplaints(status: status, page: 1);
  }

  /// فلترة الشكاوى حسب سائق محدد
  void filterByDriver(dynamic driverId, String? driverName) {
    fetchComplaints(driverId: driverId, driverName: driverName, page: 1);
  }

  /// إزالة فلتر السائق
  void clearDriverFilter() {
    emit(state.copyWith(clearDriverFilter: true));
    fetchComplaints(driverId: null, driverName: null, page: 1);
  }

  /// 2. جلب تفاصيل شكوى محددة
  Future<void> fetchComplaintDetails(dynamic id) async {
    emit(state.copyWith(
      isDetailsLoading: true,
      clearError: true,
      clearSuccess: true,
      clearDetails: true,
    ));

    try {
      final details = await _repository.getComplaintDetails(id);
      emit(state.copyWith(
        isDetailsLoading: false,
        selectedComplaintDetails: details,
      ));

      // جلب سجل شكاوى السائق تلقائياً إذا كان مفتاح السائق متاحاً
      if (details.driver != null && details.driver!.id > 0) {
        fetchDriverComplaints(details.driver!.id);
      }
    } catch (e) {
      emit(state.copyWith(
        isDetailsLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// 3. جلب تاريخ شكاوى سائق محدد
  Future<void> fetchDriverComplaints(dynamic driverId, {int page = 1}) async {
    emit(state.copyWith(isDriverHistoryLoading: true));

    try {
      final result = await _repository.getDriverComplaints(driverId, page: page);
      emit(state.copyWith(
        isDriverHistoryLoading: false,
        driverComplaintsHistory: result.complaints,
        driverHistoryMeta: result.meta,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDriverHistoryLoading: false,
        // لا نعطل الصفحة الرئيسية في حال فشل تاريخ السائق المساعد
      ));
    }
  }

  /// 4. اتخاذ القرار الإداري (Warning, Suspension, Dismiss)
  Future<bool> reviewComplaint(
    dynamic id, {
    required String action,
    String? actionDetails,
  }) async {
    emit(state.copyWith(
      isActionLoading: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final result = await _repository.reviewComplaint(
        id,
        action: action,
        actionDetails: actionDetails,
      );

      emit(state.copyWith(
        isActionLoading: false,
        successMessage: result.message,
      ));

      // تحديث التفاصيل والقائمة الرئيسية فور نجاح العملية
      if (result.complaint != null) {
        emit(state.copyWith(selectedComplaintDetails: result.complaint));
      } else {
        fetchComplaintDetails(id);
      }

      // تحديث القائمة العامة بنفس الصفحة والفلترة المطبقة
      fetchComplaints(page: state.meta.currentPage);
      return true;
    } catch (e) {
      emit(state.copyWith(
        isActionLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  /// مسح رسائل الخطأ والنجاح المؤقتة
  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
