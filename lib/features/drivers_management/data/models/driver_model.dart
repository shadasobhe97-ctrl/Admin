/// بيانات السائق الأساسية.
///
/// الخادم يرسلها بشكلين:
/// * قائمة السائقين (`GET /admin/drivers`) — حقول مسطّحة: `full_name`,
///   `phone_number`, `status`, `avatar_url`, `created_at`.
/// * تفاصيل السائق (`GET|PUT /admin/drivers/{id}`) — البيانات الشخصية
///   مغلّفة داخل `user_account`، والحقول المهنية في الجذر.
///
/// [fromJson] تقرأ الشكلين معاً حتى لا تختلف الواجهة باختلاف نقطة النهاية.
class DriverModel {
  final int id;
  final int? userId;
  final String fullName;
  final String phoneNumber;
  final String status;
  final String? approvalStatus;
  final String? nationalId;
  final String? licenseNumber;

  /// تاريخ انتهاء الرخصة بصيغة YYYY-MM-DD كما يرسله الخادم.
  final String? licenseExpiry;
  final String? avatarUrl;
  final String? createdAt;
  final bool isActive;

  DriverModel({
    required this.id,
    this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.status,
    this.approvalStatus,
    this.nationalId,
    this.licenseNumber,
    this.licenseExpiry,
    this.avatarUrl,
    this.createdAt,
    this.isActive = true,
  });

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static String? _toStringOrNull(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty || text == 'null' ? null : text;
  }

  static bool _toBool(dynamic value, {bool fallback = true}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value.toString().toLowerCase();
    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;
    return fallback;
  }

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    // البيانات الشخصية تأتي داخل `user_account` في نقطة التفاصيل.
    final account = json['user_account'] is Map<String, dynamic>
        ? json['user_account'] as Map<String, dynamic>
        : json['user'] is Map<String, dynamic>
            ? json['user'] as Map<String, dynamic>
            : const <String, dynamic>{};

    /// يبحث عن المفتاح في جسم السائق ثم في حساب المستخدم.
    dynamic pick(List<String> keys) {
      for (final key in keys) {
        if (json[key] != null) return json[key];
        if (account[key] != null) return account[key];
      }
      return null;
    }

    final rawStatus = _toStringOrNull(pick(['status', 'approval_status']));
    final rawApproval = _toStringOrNull(pick(['approval_status', 'status']));

    return DriverModel(
      id: _toInt(json['id']) ?? 0,
      userId: _toInt(pick(['user_id', 'id_user'])) ??
          (account.isEmpty ? null : _toInt(account['id'])),
      fullName: _toStringOrNull(pick(['full_name', 'name'])) ?? 'سائق بدون اسم',
      phoneNumber: _toStringOrNull(pick(['phone_number', 'phone'])) ?? '',
      status: rawStatus ?? 'Pending',
      approvalStatus: rawApproval,
      nationalId: _toStringOrNull(pick(['national_id'])),
      licenseNumber: _toStringOrNull(pick(['license_number'])),
      licenseExpiry: _toStringOrNull(pick(['license_expiry'])),
      avatarUrl: _toStringOrNull(pick(['avatar_url', 'avatar', 'photo_url'])),
      createdAt: _toStringOrNull(pick(['created_at'])),
      // `is_active` يأتي من حساب المستخدم في التفاصيل.
      isActive: _toBool(pick(['is_active'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'status': status,
      'approval_status': approvalStatus,
      'national_id': nationalId,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry,
      'avatar_url': avatarUrl,
      'created_at': createdAt,
      'is_active': isActive,
    };
  }
}
