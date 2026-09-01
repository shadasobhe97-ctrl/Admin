import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/admin_notification_model.dart';
import '../../data/repositories/admin_notifications_repository.dart';
import 'admin_notifications_state.dart';

class AdminNotificationsCubit extends Cubit<AdminNotificationsState> {
  final AdminNotificationsRepository _repository;

  AdminNotificationsCubit(this._repository) : super(const AdminNotificationsState());

  /// 1. جلب قائمة الإشعارات الرئيسية (أول صفحة أو إعادة تنشيط)
  Future<void> fetchNotifications({
    bool refresh = false,
    bool? unreadOnly,
    String? type,
  }) async {
    final activeUnreadOnly = unreadOnly ?? state.unreadOnlyFilter;
    final activeType = type ?? state.selectedTypeFilter;

    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      unreadOnlyFilter: activeUnreadOnly,
      selectedTypeFilter: activeType,
    ));

    try {
      final response = await _repository.getAdminNotifications(
        page: 1,
        unreadOnly: activeUnreadOnly,
        type: activeType,
      );

      emit(state.copyWith(
        isLoading: false,
        notifications: response.notifications,
        pagination: response.pagination,
        unreadCount: response.unreadCount,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// 2. جلب الصفحة التالية عند الوصول لنهاية القائمة (Pagination)
  Future<void> loadMoreNotifications() async {
    if (state.isLoadingMore || !state.hasMore) return;

    final currentPage = state.pagination?.currentPage ?? 1;
    final nextPage = currentPage + 1;

    emit(state.copyWith(
      isLoadingMore: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final response = await _repository.getAdminNotifications(
        page: nextPage,
        unreadOnly: state.unreadOnlyFilter,
        type: state.selectedTypeFilter,
      );

      final updatedList = List<AdminNotificationModel>.from(state.notifications)
        ..addAll(response.notifications);

      emit(state.copyWith(
        isLoadingMore: false,
        notifications: updatedList,
        pagination: response.pagination,
        // نحافظ على عدد غير المقروء الأحدث
        unreadCount: response.unreadCount,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// 3. جلب عدد الإشعارات غير المقروءة بشكل مستقل للشارة (Badge)
  Future<void> fetchUnreadCount() async {
    try {
      final count = await _repository.getUnreadNotificationsCount();
      emit(state.copyWith(unreadCount: count));
    } catch (_) {
      // تعذّر الجلب المستقل لا يعطّل باقي اللوحة
    }
  }

  /// 4. تمييز إشعار محدد كمقروء بعد نجاح الـ API فقط
  Future<void> markAsRead(String id) async {
    final index = state.notifications.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final targetItem = state.notifications[index];
    if (targetItem.isRead) return; // مقروء بالفعل

    try {
      await _repository.markNotificationAsRead(id);

      final updatedItem = targetItem.copyWith(
        isRead: true,
        readAt: DateTime.now().toIso8601String(),
      );

      final updatedNotifications = List<AdminNotificationModel>.from(state.notifications);
      updatedNotifications[index] = updatedItem;

      final updatedUnreadCount = (state.unreadCount > 0) ? state.unreadCount - 1 : 0;

      emit(state.copyWith(
        notifications: updatedNotifications,
        unreadCount: updatedUnreadCount,
      ));
    } catch (e) {
      // الحفاظ على الحالة الأصلية وإظهار خطأ بالعربية
      emit(state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// 5. تمييز كافة الإشعارات الحالية كمقروءة
  Future<void> markAllAsRead() async {
    if (state.notifications.every((n) => n.isRead) && state.unreadCount == 0) {
      return;
    }

    emit(state.copyWith(
      isActionLoading: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final msg = await _repository.markAllNotificationsAsRead();

      final updatedNotifications = state.notifications
          .map((n) => n.copyWith(isRead: true, readAt: DateTime.now().toIso8601String()))
          .toList();

      emit(state.copyWith(
        isActionLoading: false,
        notifications: updatedNotifications,
        unreadCount: 0,
        successMessage: msg,
      ));
    } catch (e) {
      emit(state.copyWith(
        isActionLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// 6. تغيير فلتر الإشعارات (الكل / غير المقروءة فقط)
  void changeUnreadFilter(bool unreadOnly) {
    if (state.unreadOnlyFilter == unreadOnly) return;
    fetchNotifications(refresh: true, unreadOnly: unreadOnly);
  }

  /// 7. تنظيف الرسائل المؤقتة
  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
