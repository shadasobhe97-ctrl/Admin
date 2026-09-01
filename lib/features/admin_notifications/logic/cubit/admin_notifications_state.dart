import '../../data/models/admin_notification_model.dart';
import '../../data/models/admin_notifications_response.dart';

class AdminNotificationsState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool isActionLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<AdminNotificationModel> notifications;
  final PaginationModel? pagination;
  final int unreadCount;
  final bool unreadOnlyFilter;
  final String? selectedTypeFilter;

  const AdminNotificationsState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isActionLoading = false,
    this.errorMessage,
    this.successMessage,
    this.notifications = const [],
    this.pagination,
    this.unreadCount = 0,
    this.unreadOnlyFilter = false,
    this.selectedTypeFilter,
  });

  bool get hasMore => pagination?.hasMore ?? false;

  AdminNotificationsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isActionLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    List<AdminNotificationModel>? notifications,
    PaginationModel? pagination,
    int? unreadCount,
    bool? unreadOnlyFilter,
    String? selectedTypeFilter,
    bool clearTypeFilter = false,
  }) {
    return AdminNotificationsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      notifications: notifications ?? this.notifications,
      pagination: pagination ?? this.pagination,
      unreadCount: unreadCount ?? this.unreadCount,
      unreadOnlyFilter: unreadOnlyFilter ?? this.unreadOnlyFilter,
      selectedTypeFilter: clearTypeFilter ? null : (selectedTypeFilter ?? this.selectedTypeFilter),
    );
  }
}
