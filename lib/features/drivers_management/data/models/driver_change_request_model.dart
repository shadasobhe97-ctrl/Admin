class DriverChangeRequestModel {
  final int id;
  final int driverId;
  final String? driverName;
  final String? driverPhone;
  final String? changeType;
  final String status;
  final String? rejectionReason;
  final Map<String, dynamic> oldValues;
  final Map<String, dynamic> newValues;
  final String? createdAt;

  DriverChangeRequestModel({
    required this.id,
    required this.driverId,
    this.driverName,
    this.driverPhone,
    this.changeType,
    required this.status,
    this.rejectionReason,
    this.oldValues = const {},
    this.newValues = const {},
    this.createdAt,
  });

  factory DriverChangeRequestModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> dataObj = json;
    if (json['data'] is Map<String, dynamic>) {
      dataObj = json['data'] as Map<String, dynamic>;
    } else if (json['change'] is Map<String, dynamic>) {
      dataObj = json['change'] as Map<String, dynamic>;
    } else if (json['request'] is Map<String, dynamic>) {
      dataObj = json['request'] as Map<String, dynamic>;
    }

    int parseId(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString().trim()) ?? 0;
    }

    dynamic pick(List<String> keys) {
      for (final key in keys) {
        if (dataObj[key] != null) return dataObj[key];
        if (json[key] != null) return json[key];
      }
      return null;
    }

    final rawId = parseId(pick([
      'request_id',
      'id',
      'change_id',
      'pending_change_id',
      'change_request_id',
      'id_change',
    ]));

    final rawDriverId = parseId(pick([
      'driver_id',
      'id_driver',
      'user_id',
      'driverId',
    ]));

    final finalId = rawId != 0 ? rawId : rawDriverId;
    final finalDriverId = rawDriverId != 0 ? rawDriverId : rawId;

    Map<String, dynamic> oldMap = {};
    final oldRaw = pick(['old_values', 'current_data', 'current', 'old_data']);
    if (oldRaw is Map<String, dynamic>) {
      oldMap = oldRaw;
    }

    Map<String, dynamic> newMap = {};
    final newRaw = pick(['new_values', 'proposed_data', 'proposed', 'new_data']);
    if (newRaw is Map<String, dynamic>) {
      newMap = newRaw;
    }

    final name = pick(['driver_name', 'full_name', 'name', 'driverName'])?.toString() ??
        (json['driver'] is Map ? json['driver']['full_name']?.toString() ?? json['driver']['name']?.toString() : null) ??
        (dataObj['driver'] is Map ? dataObj['driver']['full_name']?.toString() ?? dataObj['driver']['name']?.toString() : null) ??
        (oldMap['full_name']?.toString() ?? oldMap['driver_name']?.toString()) ??
        (newMap['full_name']?.toString() ?? newMap['driver_name']?.toString());

    final phone = pick(['driver_phone', 'phone_number', 'phone', 'mobile', 'driverPhone'])?.toString() ??
        (json['driver'] is Map ? json['driver']['phone_number']?.toString() ?? json['driver']['phone']?.toString() : null) ??
        (dataObj['driver'] is Map ? dataObj['driver']['phone_number']?.toString() ?? dataObj['driver']['phone']?.toString() : null) ??
        (oldMap['phone_number']?.toString() ?? oldMap['phone']?.toString()) ??
        (newMap['phone_number']?.toString() ?? newMap['phone']?.toString());

    return DriverChangeRequestModel(
      id: finalId,
      driverId: finalDriverId,
      driverName: name,
      driverPhone: phone,
      changeType: pick(['change_type', 'type', 'request_type'])?.toString(),
      status: pick(['status', 'approval_status'])?.toString() ?? 'pending',
      rejectionReason: pick(['rejection_reason', 'reason'])?.toString(),
      oldValues: oldMap,
      newValues: newMap,
      createdAt: pick(['created_at', 'date', 'updated_at'])?.toString(),
    );
  }

  String get translatedType {
    if (changeType != null && changeType!.isNotEmpty) {
      final ct = changeType!.toLowerCase();
      if (ct.contains('vehicle') || ct == 'vehicle_update') return 'تعديل بيانات المركبة';
      if (ct.contains('document') || ct == 'document_update' || ct.contains('doc')) return 'تحديث الوثائق الرسمية';
      if (ct.contains('profile') || ct == 'profile_update' || ct.contains('user')) return 'تعديل بيانات الملف الشخصي';
    }

    final keys = newValues.keys.map((k) => k.toLowerCase()).toList();
    if (keys.any((k) => k.contains('doc_') || k.contains('license') || k.contains('expiry') || k.contains('insurance') || k.contains('stamp'))) {
      return 'تحديث الوثائق الرسمية';
    }
    if (keys.any((k) => k.contains('plate') || k.contains('vehicle') || k.contains('color') || k.contains('year') || k.contains('brand') || k.contains('model'))) {
      return 'تعديل بيانات المركبة';
    }
    if (keys.any((k) => k.contains('name') || k.contains('phone') || k.contains('national_id') || k.contains('avatar'))) {
      return 'تعديل بيانات الملف الشخصي';
    }

    return changeType ?? 'تعديل بيانات المركبة';
  }
}
