import '../../../../core/network/api_exception.dart';
import '../datasources/admin_notifications_remote_datasource.dart';
import '../models/admin_notifications_response.dart';

abstract class AdminNotificationsRepository {
  Future<AdminNotificationsResponse> getAdminNotifications({
    int page = 1,
    int perPage = 15,
    bool? unreadOnly,
    String? type,
  });

  Future<int> getUnreadNotificationsCount();

  Future<String> markNotificationAsRead(String id);

  Future<String> markAllNotificationsAsRead();
}

class AdminNotificationsRepositoryImpl implements AdminNotificationsRepository {
  final AdminNotificationsRemoteDataSource _remoteDataSource;

  AdminNotificationsRepositoryImpl(this._remoteDataSource);

  @override
  Future<AdminNotificationsResponse> getAdminNotifications({
    int page = 1,
    int perPage = 15,
    bool? unreadOnly,
    String? type,
  }) async {
    try {
      return await _remoteDataSource.getNotifications(
        page: page,
        perPage: perPage,
        unreadOnly: unreadOnly,
        type: type,
      );
    } catch (e) {
      throw ApiErrorMapper.map(
        e,
        fallbackMessage: 'فشل في جلب قائمة إشعارات الأدمن.',
      );
    }
  }

  @override
  Future<int> getUnreadNotificationsCount() async {
    try {
      return await _remoteDataSource.getUnreadCount();
    } catch (e) {
      throw ApiErrorMapper.map(
        e,
        fallbackMessage: 'فشل في جلب عدد الإشعارات غير المقروءة.',
      );
    }
  }

  @override
  Future<String> markNotificationAsRead(String id) async {
    try {
      return await _remoteDataSource.markAsRead(id);
    } catch (e) {
      throw ApiErrorMapper.map(
        e,
        fallbackMessage: 'فشل في تمييز الإشعار كمقروء.',
      );
    }
  }

  @override
  Future<String> markAllNotificationsAsRead() async {
    try {
      return await _remoteDataSource.markAllAsRead();
    } catch (e) {
      throw ApiErrorMapper.map(
        e,
        fallbackMessage: 'فشل في تمييز جميع الإشعارات كمقروءة.',
      );
    }
  }
}
