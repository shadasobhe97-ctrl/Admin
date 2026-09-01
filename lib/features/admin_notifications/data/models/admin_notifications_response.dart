import 'admin_notification_model.dart';

class PaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  const PaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMore,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    final current = (json['current_page'] as num?)?.toInt() ?? 1;
    final last = (json['last_page'] as num?)?.toInt() ?? 1;
    final per = (json['per_page'] as num?)?.toInt() ?? 15;
    final tot = (json['total'] as num?)?.toInt() ?? 0;
    final hasM = json['has_more'] == true || current < last;

    return PaginationModel(
      currentPage: current,
      lastPage: last,
      perPage: per,
      total: tot,
      hasMore: hasM,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'has_more': hasMore,
    };
  }
}

class AdminNotificationsResponse {
  final List<AdminNotificationModel> notifications;
  final PaginationModel pagination;
  final int unreadCount;

  const AdminNotificationsResponse({
    required this.notifications,
    required this.pagination,
    required this.unreadCount,
  });

  factory AdminNotificationsResponse.fromJson(Map<String, dynamic> json) {
    // Handling possible 'data' wrapper or flat response
    final rawData = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final rawList = rawData['notifications'];
    final notificationsList = <AdminNotificationModel>[];

    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          notificationsList.add(AdminNotificationModel.fromJson(item));
        }
      }
    }

    final rawPagination = rawData['pagination'];
    final paginationObj = rawPagination is Map<String, dynamic>
        ? PaginationModel.fromJson(rawPagination)
        : PaginationModel(
            currentPage: 1,
            lastPage: 1,
            perPage: notificationsList.length,
            total: notificationsList.length,
            hasMore: false,
          );

    final count = (rawData['unread_count'] as num?)?.toInt() ??
        (json['unread_count'] as num?)?.toInt() ??
        notificationsList.where((n) => !n.isRead).length;

    return AdminNotificationsResponse(
      notifications: notificationsList,
      pagination: paginationObj,
      unreadCount: count,
    );
  }
}
