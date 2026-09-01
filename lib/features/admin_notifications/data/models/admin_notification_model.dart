class AdminNotificationModel {
  final String id;
  final String? type;
  final String title;
  final String message;
  final String? actionUrl;
  final String? entityType;
  final String? entityId;
  final String? screen;
  final String? action;
  final Map<String, dynamic>? payload;
  final String? readAt;
  final bool isRead;
  final String? createdAt;

  const AdminNotificationModel({
    required this.id,
    this.type,
    required this.title,
    required this.message,
    this.actionUrl,
    this.entityType,
    this.entityId,
    this.screen,
    this.action,
    this.payload,
    this.readAt,
    required this.isRead,
    this.createdAt,
  });

  factory AdminNotificationModel.fromJson(Map<String, dynamic> json) {
    final rawEntityId = json['entity_id'];
    final entityIdStr = rawEntityId?.toString();

    final readAtStr = json['read_at']?.toString();
    final isReadBool = json['is_read'] == true || (readAtStr?.isNotEmpty == true);

    return AdminNotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString(),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      actionUrl: json['action_url']?.toString(),
      entityType: json['entity_type']?.toString(),
      entityId: entityIdStr,
      screen: json['screen']?.toString(),
      action: json['action']?.toString(),
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : null,
      readAt: readAtStr,
      isRead: isReadBool,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'action_url': actionUrl,
      'entity_type': entityType,
      'entity_id': entityId,
      'screen': screen,
      'action': action,
      'payload': payload,
      'read_at': readAt,
      'is_read': isRead,
      'created_at': createdAt,
    };
  }

  AdminNotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    String? actionUrl,
    String? entityType,
    String? entityId,
    String? screen,
    String? action,
    Map<String, dynamic>? payload,
    String? readAt,
    bool? isRead,
    String? createdAt,
  }) {
    return AdminNotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      actionUrl: actionUrl ?? this.actionUrl,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      screen: screen ?? this.screen,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// هل هذا الإشعار هو طلب غياب سائق (إشعار معلوماتي فقط)؟
  bool get isDriverAbsence {
    return type == 'driver_absence_requested' || entityType == 'driver_absence';
  }
}
