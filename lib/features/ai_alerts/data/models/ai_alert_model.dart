import '../../../../core/models/pagination_meta_model.dart';

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

bool? _toBoolOrNull(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return null;
}

String? _toStringOrNull(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty || text == 'null' ? null : text;
}

Map<String, dynamic>? _toMapOrNull(dynamic value) {
  return value is Map<String, dynamic> ? value : null;
}

/// بيانات السائق المرفقة بتنبيه الذكاء الاصطناعي.
///
/// الخادم يرسلها بشكلين مختلفين حسب نقطة النهاية:
/// * القائمة (`GET /v1/admin/ai-alerts`): `driver.rating_avg` +
///   `driver.user.full_name`/`phone_number`/`is_trusted` (متداخلة).
/// * التفاصيل (`GET /v1/admin/ai-alerts/{id}`): `driver.name`/`phone`/
///   `current_rating`/`is_trusted`/`status` (مسطّحة).
///
/// [fromJson] تتحقق من الاحتمالين معاً دون افتراض أيهما فقط.
class AiAlertDriverModel {
  final int id;
  final String? name;
  final String? phone;
  final double? rating;
  final bool? isTrusted;
  final String? status;

  const AiAlertDriverModel({
    required this.id,
    this.name,
    this.phone,
    this.rating,
    this.isTrusted,
    this.status,
  });

  factory AiAlertDriverModel.fromJson(Map<String, dynamic> json) {
    final user = _toMapOrNull(json['user']);

    return AiAlertDriverModel(
      id: _toInt(json['id']) ?? 0,
      name: _toStringOrNull(json['name']) ??
          _toStringOrNull(user?['full_name']),
      phone: _toStringOrNull(json['phone']) ??
          _toStringOrNull(user?['phone_number']),
      rating: _toDouble(json['current_rating']) ??
          _toDouble(json['rating_avg']),
      isTrusted:
          _toBoolOrNull(json['is_trusted']) ?? _toBoolOrNull(user?['is_trusted']),
      status: _toStringOrNull(json['status']),
    );
  }
}

/// تنبيه ذكاء اصطناعي واحد (`ai_critical` أو `ai_warning`) عن نمط سلوك
/// مكتشَف آلياً للسائق. الأدمن يراقب فقط — لا Action يدوي من هذه الشاشة.
class AiAlertModel {
  final int id;
  final int? driverId;
  final String riskLevel; // 'CRITICAL' | 'HIGH'
  final String? actionsTaken;
  final String? adminMessage;
  final String? reasoning;
  final Map<String, dynamic>? aiMetrics;
  final bool isResolved;
  final String alertType; // 'ai_critical' | 'ai_warning'
  final String title;
  final String message;
  final int? severity; // 3 => ai_critical, 2 => ai_warning (قد تغيب بالتفاصيل)
  final String? actionRequired;
  final Map<String, dynamic>? metadata;
  final bool? isRead;
  final String? createdAt;
  final String? updatedAt;
  final AiAlertDriverModel? driver;

  const AiAlertModel({
    required this.id,
    this.driverId,
    required this.riskLevel,
    this.actionsTaken,
    this.adminMessage,
    this.reasoning,
    this.aiMetrics,
    required this.isResolved,
    required this.alertType,
    required this.title,
    required this.message,
    this.severity,
    this.actionRequired,
    this.metadata,
    this.isRead,
    this.createdAt,
    this.updatedAt,
    this.driver,
    this.driverName,
    this.driverPhone,
  });

  /// هل هذا تنبيه حرج؟ يُستدل عليه من `alert_type` أو `risk_level`.
  bool get isCritical =>
      alertType == 'ai_critical' ||
      alertType == 'ai_admin_review_required' ||
      riskLevel.toUpperCase() == 'CRITICAL';

  String get displayDriverName =>
      driver?.name ?? _toStringOrNull(driverName) ?? 'سائقغير معروف';

  String get displayDriverPhone =>
      driver?.phone ?? _toStringOrNull(driverPhone) ?? '';

  String? get precautionaryTo =>
      _toStringOrNull(metadata?['precautionary_to']) ??
      _toStringOrNull(metadata?['suspended_until']);

  final String? driverName;
  final String? driverPhone;

  factory AiAlertModel.fromJson(Map<String, dynamic> json) {
    // معرّف التنبيه: `alert_id` في الاستجابة الجديدة، أو `id` في الاستجابة السابقة.
    final id = _toInt(json['alert_id']) ?? _toInt(json['id']) ?? 0;

    final driverJson = _toMapOrNull(json['driver']);
    final driver =
        driverJson != null ? AiAlertDriverModel.fromJson(driverJson) : null;

    final dName = _toStringOrNull(json['driver_name']) ?? driver?.name;
    final dPhone = _toStringOrNull(json['driver_phone']) ?? driver?.phone;
    final dId = _toInt(json['driver_id']) ?? driver?.id;

    final effectiveDriver = driver ??
        (dId != null || dName != null
            ? AiAlertDriverModel(
                id: dId ?? 0,
                name: dName,
                phone: dPhone,
              )
            : null);

    return AiAlertModel(
      id: id,
      driverId: dId,
      riskLevel: _toStringOrNull(json['risk_level']) ?? '',
      actionsTaken: _toStringOrNull(json['actions_taken']),
      adminMessage: _toStringOrNull(json['admin_message']),
      reasoning: _toStringOrNull(json['reasoning']),
      aiMetrics: _toMapOrNull(json['ai_metrics']),
      isResolved: _toBoolOrNull(json['is_resolved']) ?? false,
      alertType: _toStringOrNull(json['alert_type']) ?? '',
      title: _toStringOrNull(json['title']) ?? '',
      message: _toStringOrNull(json['message']) ?? '',
      severity: _toInt(json['severity']) ?? _toInt(json['metadata']?['severity']),
      actionRequired: _toStringOrNull(json['action_required']),
      metadata: _toMapOrNull(json['metadata']),
      isRead: _toBoolOrNull(json['is_read']),
      createdAt: _toStringOrNull(json['created_at']),
      updatedAt: _toStringOrNull(json['updated_at']),
      driver: effectiveDriver,
      driverName: dName,
      driverPhone: dPhone,
    );
  }
}

class AiAlertsListResult {
  final List<AiAlertModel> alerts;
  final PaginationMetaModel meta;

  const AiAlertsListResult({
    required this.alerts,
    required this.meta,
  });

  factory AiAlertsListResult.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<AiAlertModel> items = [];
    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          items.add(AiAlertModel.fromJson(item));
        }
      }
    }

    return AiAlertsListResult(
      alerts: items,
      meta: PaginationMetaModel.fromJson(_toMapOrNull(json['meta'])),
    );
  }
}
