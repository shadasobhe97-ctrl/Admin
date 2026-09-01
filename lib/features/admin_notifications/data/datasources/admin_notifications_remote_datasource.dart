import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/admin_notifications_response.dart';

abstract class AdminNotificationsRemoteDataSource {
  Future<AdminNotificationsResponse> getNotifications({
    int page = 1,
    int perPage = 15,
    bool? unreadOnly,
    String? type,
  });

  Future<int> getUnreadCount();

  Future<String> markAsRead(String id);

  Future<String> markAllAsRead();
}

class AdminNotificationsRemoteDataSourceImpl implements AdminNotificationsRemoteDataSource {
  final ApiClient _apiClient;

  AdminNotificationsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AdminNotificationsResponse> getNotifications({
    int page = 1,
    int perPage = 15,
    bool? unreadOnly,
    String? type,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (unreadOnly != null && unreadOnly) {
      queryParams['unread_only'] = true;
    }

    if (type != null && type.trim().isNotEmpty) {
      queryParams['type'] = type.trim();
    }

    final response = await _apiClient.get(
      ApiEndpoints.adminNotifications,
      queryParameters: queryParams,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return AdminNotificationsResponse.fromJson(data);
    }

    throw Exception('استجابة الخادم غير متوقعة عند جلب الإشعارات.');
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get(
      ApiEndpoints.adminNotificationsUnreadCount,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['unread_count'] is num) {
        return (data['unread_count'] as num).toInt();
      }
      if (data['data'] is Map && data['data']['unread_count'] is num) {
        return (data['data']['unread_count'] as num).toInt();
      }
    }
    return 0;
  }

  @override
  Future<String> markAsRead(String id) async {
    final response = await _apiClient.post(
      ApiEndpoints.adminNotificationMarkAsRead(id),
    );

    final data = response.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    }
    return 'تم تمييز الإشعار كمقروء بنجاح.';
  }

  @override
  Future<String> markAllAsRead() async {
    final response = await _apiClient.post(
      ApiEndpoints.adminNotificationsReadAll,
    );

    final data = response.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    }
    return 'تم تمييز جميع الإشعارات كمقروءة بنجاح.';
  }
}
