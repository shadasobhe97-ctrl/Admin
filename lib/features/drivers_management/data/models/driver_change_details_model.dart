class DriverChangeDetailsModel {
  final int id;
  final int? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? changeType;
  final String? status;
  final String? rejectionReason;
  final String? createdAt;
  final Map<String, dynamic> currentData;
  final Map<String, dynamic> proposedData;

  DriverChangeDetailsModel({
    required this.id,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.changeType,
    this.status,
    this.rejectionReason,
    this.createdAt,
    required this.currentData,
    required this.proposedData,
  });

  factory DriverChangeDetailsModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> dataObj = json;
    if (json['data'] is Map<String, dynamic> &&
        (json['data']['id'] != null ||
            json['data']['change_type'] != null ||
            json['data']['old_values'] != null ||
            json['data']['new_values'] != null ||
            json['data']['proposed_data'] != null ||
            json['data']['changes'] != null)) {
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

    dynamic pickFrom(Map<String, dynamic> source, List<String> keys) {
      for (final key in keys) {
        if (source[key] != null) return source[key];
      }
      return null;
    }

    dynamic pick(List<String> keys) {
      final res = pickFrom(dataObj, keys);
      if (res != null) return res;
      return pickFrom(json, keys);
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

    // 1. استخراج البيانات المقترحة الجديدة (Proposed / New Values) أولاً
    Map<String, dynamic> proposedMap = {};
    final proposedRaw = pick(['new_values', 'proposed_data', 'proposed', 'new_data', 'changes', 'pending_changes']);
    if (proposedRaw is Map<String, dynamic>) {
      proposedMap = Map<String, dynamic>.from(proposedRaw);
    } else if (json['data'] is Map<String, dynamic> && dataObj == json['data']) {
      // إذا كان json['data'] يحوي حقول التعديل مباشرة
      final dataContent = Map<String, dynamic>.from(json['data'] as Map<String, dynamic>)
        ..remove('id')
        ..remove('driver_id')
        ..remove('driver_name')
        ..remove('driver_phone')
        ..remove('status')
        ..remove('created_at')
        ..remove('updated_at')
        ..remove('change_type')
        ..remove('rejection_reason');
      if (dataContent.isNotEmpty && !dataContent.containsKey('old_values')) {
        proposedMap = dataContent;
      }
    }

    // 2. استخراج البيانات الحالية القديمة (Current / Old Values)
    Map<String, dynamic> currentMap = {};
    final currentRaw = pick(['old_values', 'current_data', 'current', 'old_data', 'original']);
    if (currentRaw is Map<String, dynamic>) {
      currentMap = Map<String, dynamic>.from(currentRaw);
    }

    // 3. قراءة بيانات السائق لمنع الالتباس
    final driverObj = pick(['driver', 'user', 'driver_data', 'current_driver']);

    final name = pick(['driver_name', 'full_name', 'name', 'driverName'])?.toString() ??
        (driverObj is Map ? driverObj['full_name']?.toString() ?? driverObj['name']?.toString() : null) ??
        (currentMap['full_name']?.toString() ?? currentMap['driver_name']?.toString()) ??
        (proposedMap['full_name']?.toString() ?? proposedMap['driver_name']?.toString());

    final phone = pick(['driver_phone', 'phone_number', 'phone', 'mobile', 'driverPhone'])?.toString() ??
        (driverObj is Map ? driverObj['phone_number']?.toString() ?? driverObj['phone']?.toString() : null) ??
        (currentMap['phone_number']?.toString() ?? currentMap['phone']?.toString()) ??
        (proposedMap['phone_number']?.toString() ?? proposedMap['phone']?.toString());

    return DriverChangeDetailsModel(
      id: finalId,
      driverId: finalDriverId,
      driverName: name,
      driverPhone: phone,
      changeType: pick(['change_type', 'type', 'request_type'])?.toString(),
      status: pick(['status', 'approval_status'])?.toString() ?? 'Pending',
      rejectionReason: pick(['rejection_reason', 'reason'])?.toString(),
      createdAt: pick(['created_at', 'date', 'updated_at'])?.toString(),
      currentData: currentMap,
      proposedData: proposedMap,
    );
  }

  String get translatedType {
    if (changeType != null && changeType!.isNotEmpty) {
      final ct = changeType!.toLowerCase();
      if (ct.contains('vehicle') || ct == 'vehicle_update') return 'تعديل بيانات المركبة';
      if (ct.contains('document') || ct == 'document_update' || ct.contains('doc')) return 'تحديث الوثائق الرسمية';
      if (ct.contains('profile') || ct == 'profile_update' || ct.contains('user')) return 'تعديل بيانات الملف الشخصي';
    }

    final keys = proposedData.keys.map((k) => k.toLowerCase()).toList();
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
