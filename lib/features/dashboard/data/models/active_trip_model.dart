class TripPassenger {
  final String id;
  final String childName;
  final int? childAge;
  final String parentName;
  final String parentPhone;
  final String pickupLocation;
  final String dropoffLocation;
  final String schoolName;
  final String scheduledTime;
  final String status;
  final String? statusLabel;
  final String? actualTime;
  final String? notes;

  TripPassenger({
    required this.id,
    required this.childName,
    this.childAge,
    required this.parentName,
    required this.parentPhone,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.schoolName,
    required this.scheduledTime,
    required this.status,
    this.statusLabel,
    this.actualTime,
    this.notes,
  });

  bool get isOnBoard => status == 'on_board' || status == 'راكب';
  bool get isPending => status == 'pending' || status == 'ينتظر' || status == 'waiting_pickup';
  bool get isDelivered => status == 'delivered' || status == 'وصل';
  bool get isAbsent => status == 'absent' || status == 'غائب';
  bool get isStranded => status == 'stranded_in_broken_bus';

  String get displayStatus {
    if (statusLabel != null && statusLabel!.trim().isNotEmpty) {
      // إزالة الإيموجيات للحفاظ على البساطة المطلقة
      final stripped = statusLabel!.replaceAll(RegExp(r'[^\u0600-\u06FF\s\(\)\-]'), '').trim();
      if (stripped.isNotEmpty) return stripped;
      return statusLabel!.trim();
    }
    if (isStranded) return 'داخل الحافلة المعطلة (بانتظار وصول البديل)';
    if (isOnBoard) return 'على متن الحافلة (مع السائق)';
    if (isDelivered) return 'تم التوصيل';
    if (isAbsent) return 'غائب';
    return 'بانتظار الاستلام (لم يُصعد بعد)';
  }
}

class ActiveTripModel {
  final int tripId;
  final int driverId;
  final String driverName;
  final String status;
  final double currentLat;
  final double currentLng;
  final int studentsCount;
  final String startedAt;

  // Extra optional fields for UI compatibility
  final String driverPhone;
  final String driverAvatar;
  final String carModel;
  final String carPlate;
  final double rating;
  final String currentLocationName;
  final int speedKmH;
  final String timeElapsed;
  final List<TripPassenger> passengers;

  // Realtime Live Radar & Tracking fields (Firebase & Backend Hybrid)
  final double heading;
  final bool isOnline;
  final String destination;
  final String firestoreDoc;
  final String lastUpdate;
  final DateTime? updatedAt;
  final double? mapX;
  final double? mapY;

  // New rich metrics and fields from backend
  final int totalChildrenCount;
  final int childrenOnBoardCount;
  final int pendingPickupCount;
  final int deliveredCount;
  final int absentCount;
  final String region;
  final String duration;
  final String childrenSummary;

  // Emergency & Status Key fields
  final String statusKey;
  final bool isEmergency;
  final Map<String, dynamic>? emergencyDetails;

  ActiveTripModel({
    required this.tripId,
    required this.driverId,
    required this.driverName,
    required this.status,
    required this.currentLat,
    required this.currentLng,
    required this.studentsCount,
    required this.startedAt,
    this.driverPhone = '',
    this.driverAvatar = '',
    this.carModel = 'سيارة السائق',
    this.carPlate = 'ليبيا',
    this.rating = 5.0,
    this.currentLocationName = 'الموقع الميداني الحقيقي',
    this.speedKmH = 0,
    this.timeElapsed = '',
    this.passengers = const [],
    this.heading = 0.0,
    this.isOnline = true,
    this.destination = '',
    this.firestoreDoc = '',
    this.lastUpdate = '',
    this.updatedAt,
    this.mapX,
    this.mapY,
    this.totalChildrenCount = 0,
    this.childrenOnBoardCount = 0,
    this.pendingPickupCount = 0,
    this.deliveredCount = 0,
    this.absentCount = 0,
    this.region = '',
    this.duration = '',
    this.childrenSummary = '',
    this.statusKey = '',
    this.isEmergency = false,
    this.emergencyDetails,
  });

  String get id => tripId.toString();

  /// فحص هل انقطعت إشارة الـ GPS لأكثر من دقيقتين
  bool get isSignalWeak {
    if (updatedAt == null) return false;
    return DateTime.now().difference(updatedAt!).inMinutes >= 2;
  }

  /// هل الرحلة معطلة وبها حالة طوارئ؟
  bool get isBreakdown =>
      statusKey == 'suspended_breakdown' ||
      isEmergency ||
      status.contains('عطل');

  /// هل الرحلة نشطة وطبيعية في الطريق؟
  bool get isInProgress =>
      statusKey == 'in_progress' ||
      (!isBreakdown && statusKey != 'suspended_breakdown');

  /// معرف بلاغ الطوارئ المرتبط إن وجد
  int? get emergencyDispatchId => emergencyDetails?['dispatch_id'] != null
      ? int.tryParse(emergencyDetails!['dispatch_id'].toString())
      : null;

  /// حالة بلاغ الطوارئ المرتبط
  String? get emergencyDispatchStatus =>
      emergencyDetails?['dispatch_status']?.toString();

  /// نص الحالة النقي والمباشر بدون إيموجيات مشوشة
  String get cleanStatus {
    if (isBreakdown) {
      final stripped = status.replaceAll(RegExp(r'[^\u0600-\u06FF0-9\s\:\-]'), '').trim();
      return stripped.isNotEmpty ? stripped : 'عطل طارئ: توقف الحافلة';
    }
    final stripped = status.replaceAll(RegExp(r'[^\u0600-\u06FF0-9\s\:\-]'), '').trim();
    return stripped.isNotEmpty ? stripped : 'في الطريق للاستلام';
  }

  ActiveTripModel copyWith({
    int? tripId,
    int? driverId,
    String? driverName,
    String? status,
    double? currentLat,
    double? currentLng,
    int? studentsCount,
    String? startedAt,
    String? driverPhone,
    String? driverAvatar,
    String? carModel,
    String? carPlate,
    double? rating,
    String? currentLocationName,
    int? speedKmH,
    String? timeElapsed,
    List<TripPassenger>? passengers,
    double? heading,
    bool? isOnline,
    String? destination,
    String? firestoreDoc,
    String? lastUpdate,
    DateTime? updatedAt,
    double? mapX,
    double? mapY,
    int? totalChildrenCount,
    int? childrenOnBoardCount,
    int? pendingPickupCount,
    int? deliveredCount,
    int? absentCount,
    String? region,
    String? duration,
    String? childrenSummary,
    String? statusKey,
    bool? isEmergency,
    Map<String, dynamic>? emergencyDetails,
  }) {
    return ActiveTripModel(
      tripId: tripId ?? this.tripId,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      status: status ?? this.status,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      studentsCount: studentsCount ?? this.studentsCount,
      startedAt: startedAt ?? this.startedAt,
      driverPhone: driverPhone ?? this.driverPhone,
      driverAvatar: driverAvatar ?? this.driverAvatar,
      carModel: carModel ?? this.carModel,
      carPlate: carPlate ?? this.carPlate,
      rating: rating ?? this.rating,
      currentLocationName: currentLocationName ?? this.currentLocationName,
      speedKmH: speedKmH ?? this.speedKmH,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      passengers: passengers ?? this.passengers,
      heading: heading ?? this.heading,
      isOnline: isOnline ?? this.isOnline,
      destination: destination ?? this.destination,
      firestoreDoc: firestoreDoc ?? this.firestoreDoc,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      updatedAt: updatedAt ?? this.updatedAt,
      mapX: mapX ?? this.mapX,
      mapY: mapY ?? this.mapY,
      totalChildrenCount: totalChildrenCount ?? this.totalChildrenCount,
      childrenOnBoardCount: childrenOnBoardCount ?? this.childrenOnBoardCount,
      pendingPickupCount: pendingPickupCount ?? this.pendingPickupCount,
      deliveredCount: deliveredCount ?? this.deliveredCount,
      absentCount: absentCount ?? this.absentCount,
      region: region ?? this.region,
      duration: duration ?? this.duration,
      childrenSummary: childrenSummary ?? this.childrenSummary,
      statusKey: statusKey ?? this.statusKey,
      isEmergency: isEmergency ?? this.isEmergency,
      emergencyDetails: emergencyDetails ?? this.emergencyDetails,
    );
  }

  int get ridingCount => childrenOnBoardCount > 0
      ? childrenOnBoardCount
      : passengers.where((p) => p.isOnBoard).length;

  int get waitingCount => pendingPickupCount > 0
      ? pendingPickupCount
      : passengers.where((p) => p.isPending).length;

  int get arrivedCount => deliveredCount > 0
      ? deliveredCount
      : passengers.where((p) => p.isDelivered).length;

  int get absentStudentsCount => absentCount > 0
      ? absentCount
      : passengers.where((p) => p.isAbsent).length;


  factory ActiveTripModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      return int.tryParse(val?.toString() ?? '') ?? 0;
    }

    double parseDouble(dynamic val) {
      if (val is num) return val.toDouble();
      return double.tryParse(val?.toString() ?? '') ?? 0.0;
    }

    // يرجّع أول قيمة نصية غير فارغة من المفاتيح المعطاة
    String pickStr(Map? m, List<String> keys) {
      if (m == null) return '';
      for (final k in keys) {
        final v = m[k];
        if (v == null || v is Map || v is List) continue;
        final s = v.toString().trim();
        if (s.isNotEmpty && s != 'null') return s;
      }
      return '';
    }

    Map? asMap(dynamic v) => v is Map ? v : null;

    // توحيد حالة الراكب مع القيم المستخدمة في الواجهة
    String normalizeStatus(String raw) {
      switch (raw.toLowerCase().trim()) {
        case 'on_board':
        case 'onboard':
        case 'راكب':
        case 'picked_up':
        case 'pickedup':
        case 'riding':
        case 'boarded':
        case 'in_bus':
          return 'on_board';
        case 'delivered':
        case 'وصل':
        case 'dropped_off':
        case 'droppedoff':
        case 'arrived':
        case 'completed':
          return 'delivered';
        case 'absent':
        case 'غائب':
        case 'cancelled':
          return 'absent';
        case 'stranded_in_broken_bus':
          return 'stranded_in_broken_bus';
        case 'waiting_pickup':
          return 'waiting_pickup';
        case 'pending':
        case 'ينتظر':
        case 'waiting':
        default:
          return 'pending';
      }
    }

    final parsedPassengers = <TripPassenger>[];

    // 1. الأولوية الأولى: تفاصيل الطلاب المنفصلة (children_details)
    final dynamic rawDetails = json['children_details'] ??
        json['childrenDetails'] ??
        json['students_details'] ??
        json['passengers_details'];

    if (rawDetails is List && rawDetails.isNotEmpty) {
      for (final item in rawDetails) {
        final p = asMap(item);
        if (p == null) continue;
        final child = asMap(p['child']) ?? asMap(p['student']);
        final parent = asMap(p['parent']) ?? asMap(child?['parent']);
        final parentUser = asMap(parent?['user']);
        final school = asMap(p['school']) ?? asMap(child?['school']);

        final childId = [
          pickStr(p, ['child_id', 'id', 'student_id']),
          pickStr(child, ['id']),
        ].firstWhere((s) => s.isNotEmpty, orElse: () => '');

        final childName = [
          pickStr(p, ['child_name', 'name', 'student_name', 'studentName', 'full_name', 'fullName']),
          pickStr(child, ['full_name', 'fullName', 'name']),
        ].firstWhere((s) => s.isNotEmpty, orElse: () => 'طالب');

        final ageStr = pickStr(p, ['child_age', 'childAge', 'age']).isNotEmpty
            ? pickStr(p, ['child_age', 'childAge', 'age'])
            : pickStr(child, ['age']);

        final parentName = [
          pickStr(p, ['parent_name', 'parentName', 'guardian_name']),
          pickStr(parent, ['full_name', 'fullName', 'name']),
          pickStr(parentUser, ['full_name', 'fullName', 'name']),
        ].firstWhere((s) => s.isNotEmpty, orElse: () => '');

        final parentPhone = [
          pickStr(p, ['parent_phone', 'parentPhone', 'phone', 'mobile']),
          pickStr(parent, ['phone', 'phone_number']),
          pickStr(parentUser, ['phone', 'phone_number']),
        ].firstWhere((s) => s.isNotEmpty, orElse: () => '');

        final schoolName = [
          pickStr(p, ['school_name', 'schoolName', 'school']),
          pickStr(school, ['name']),
        ].firstWhere((s) => s.isNotEmpty, orElse: () => '');

        final pickupLocation = pickStr(p, ['pickup_location', 'pickupLocation', 'pickup_address', 'home_address', 'address']);
        final dropoffLocation = pickStr(p, ['dropoff_location', 'dropoffLocation', 'dropoff_address']).isNotEmpty
            ? pickStr(p, ['dropoff_location', 'dropoffLocation', 'dropoff_address'])
            : (schoolName.isNotEmpty ? schoolName : pickStr(school, ['name', 'address']));

        final rawStatus = pickStr(p, ['status', 'child_status', 'boarding_status', 'pivot_status']);
        final statusLabel = pickStr(p, ['status_label', 'statusLabel', 'label']);

        parsedPassengers.add(TripPassenger(
          id: childId,
          childName: childName,
          childAge: int.tryParse(ageStr),
          parentName: parentName,
          parentPhone: parentPhone,
          pickupLocation: pickupLocation,
          dropoffLocation: dropoffLocation,
          schoolName: schoolName,
          scheduledTime: pickStr(p, ['scheduled_time', 'scheduledTime', 'pickup_time']),
          status: normalizeStatus(rawStatus),
          statusLabel: statusLabel.isNotEmpty ? statusLabel : null,
          actualTime: pickStr(p, ['actual_time', 'actualTime', 'picked_up_at', 'dropped_off_at']).isEmpty
              ? null
              : pickStr(p, ['actual_time', 'actualTime', 'picked_up_at', 'dropped_off_at']),
          notes: pickStr(p, ['notes']).isEmpty ? null : pickStr(p, ['notes']),
        ));
      }
    } else {
      // 2. بديل احتياطي: عند عدم وجود children_details نعتمد على الحقول السابقة
      final dynamic rawPassengers = json['passengers'] ??
          json['children'] ??
          json['students'] ??
          json['kids'] ??
          json['trip_children'] ??
          json['subscriptions'];

      if (rawPassengers is String) {
        // الباك يبعت الأسماء نص واحد مفصول بـ " و " مثل: "علي و مروة"
        final destination = pickStr(json, ['destination']);
        final names = rawPassengers
            .split(RegExp(r'\s+و\s+|[,،]'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty && s != 'غير محدد');
        for (final name in names) {
          parsedPassengers.add(TripPassenger(
            id: '',
            childName: name,
            parentName: '',
            parentPhone: '',
            pickupLocation: '',
            dropoffLocation: destination,
            schoolName: destination,
            scheduledTime: '',
            status: 'pending',
            statusLabel: 'بانتظار الاستلام',
          ));
        }
      } else if (rawPassengers is List) {
        for (final item in rawPassengers) {
          if (item is String) {
            if (item.trim().isNotEmpty) {
              parsedPassengers.add(TripPassenger(
                id: '',
                childName: item.trim(),
                parentName: '',
                parentPhone: '',
                pickupLocation: '',
                dropoffLocation: '',
                schoolName: '',
                scheduledTime: '',
                status: 'pending',
                statusLabel: 'بانتظار الاستلام',
              ));
            }
            continue;
          }
          final p = asMap(item);
          if (p == null) continue;
          final child = asMap(p['child']) ?? asMap(p['student']);
          final parent = asMap(p['parent']) ?? asMap(child?['parent']);
          final parentUser = asMap(parent?['user']);
          final school = asMap(p['school']) ?? asMap(child?['school']);

          final ageStr = pickStr(p, ['child_age', 'childAge', 'age']).isNotEmpty
              ? pickStr(p, ['child_age', 'childAge', 'age'])
              : pickStr(child, ['age']);

          parsedPassengers.add(TripPassenger(
            id: pickStr(p, ['id', 'child_id', 'childId']).isNotEmpty
                ? pickStr(p, ['id', 'child_id', 'childId'])
                : pickStr(child, ['id']),
            childName: [
              pickStr(p, ['child_name', 'childName', 'student_name', 'studentName', 'full_name', 'fullName', 'name']),
              pickStr(child, ['full_name', 'fullName', 'name']),
            ].firstWhere((s) => s.isNotEmpty, orElse: () => 'طفل'),
            childAge: int.tryParse(ageStr),
            parentName: [
              pickStr(p, ['parent_name', 'parentName']),
              pickStr(parent, ['full_name', 'fullName', 'name']),
              pickStr(parentUser, ['full_name', 'fullName', 'name']),
            ].firstWhere((s) => s.isNotEmpty, orElse: () => ''),
            parentPhone: [
              pickStr(p, ['parent_phone', 'parentPhone']),
              pickStr(parent, ['phone', 'phone_number']),
              pickStr(parentUser, ['phone', 'phone_number']),
            ].firstWhere((s) => s.isNotEmpty, orElse: () => ''),
            pickupLocation: pickStr(p, ['pickup_location', 'pickupLocation', 'pickup_address', 'home_address', 'address']),
            dropoffLocation: pickStr(p, ['dropoff_location', 'dropoffLocation', 'dropoff_address']).isNotEmpty
                ? pickStr(p, ['dropoff_location', 'dropoffLocation', 'dropoff_address'])
                : pickStr(school, ['name', 'address']),
            schoolName: pickStr(p, ['school_name', 'schoolName']).isNotEmpty
                ? pickStr(p, ['school_name', 'schoolName'])
                : pickStr(school, ['name']),
            scheduledTime: pickStr(p, ['scheduled_time', 'scheduledTime', 'pickup_time']),
            status: normalizeStatus(pickStr(p, ['status', 'child_status', 'boarding_status', 'pivot_status'])),
            statusLabel: pickStr(p, ['status_label', 'statusLabel', 'label']).isNotEmpty
                ? pickStr(p, ['status_label', 'statusLabel', 'label'])
                : null,
            actualTime: pickStr(p, ['actual_time', 'actualTime', 'picked_up_at', 'dropped_off_at']).isEmpty
                ? null
                : pickStr(p, ['actual_time', 'actualTime', 'picked_up_at', 'dropped_off_at']),
            notes: pickStr(p, ['notes']).isEmpty ? null : pickStr(p, ['notes']),
          ));
        }
      }
    }

    final driver = asMap(json['driver']);
    final driverUser = asMap(driver?['user']);
    final driverName = [
      pickStr(json, ['name', 'driver_name', 'driverName', 'driver_full_name']),
      pickStr(driver, ['full_name', 'fullName', 'name']),
      pickStr(driverUser, ['full_name', 'fullName', 'name']),
    ].firstWhere((s) => s.isNotEmpty, orElse: () => 'سائق غير معروف');

    // العدادات الإحصائية للطلاب
    final totalChildrenCount = parseInt(json['total_children_count'] ?? json['totalChildrenCount']);
    final childrenOnBoardCount = parseInt(json['children_on_board_count'] ?? json['childrenOnBoardCount']);
    final pendingPickupCount = parseInt(json['pending_pickup_count'] ?? json['pendingPickupCount']);
    final deliveredCount = parseInt(json['delivered_count'] ?? json['deliveredCount']);
    final absentCount = parseInt(json['absent_count'] ?? json['absentCount']);

    // عدد الأطفال الكلي
    final countFromApi = parseInt(json['students_count'] ??
        json['studentsCount'] ??
        json['children_count'] ??
        json['childrenCount'] ??
        json['passengers_count'] ??
        json['total_children_count'] ??
        json['kids_count']);
    final studentsCount = countFromApi > 0
        ? countFromApi
        : (totalChildrenCount > 0 ? totalChildrenCount : parsedPassengers.length);

    int parseSpeed(dynamic val) {
      if (val is num) return val.round();
      if (val is String) {
        final match = RegExp(r'\d+').firstMatch(val);
        if (match != null) {
          return int.tryParse(match.group(0)!) ?? 0;
        }
      }
      return 0;
    }

    final heading = parseDouble(json['heading']);
    final isOnline = json['is_online'] == null
        ? true
        : (json['is_online'] == true ||
            json['is_online'].toString() == '1' ||
            json['is_online'].toString() == 'true');
    final destination = pickStr(json, ['destination', 'dropoff_location', 'school_name']);
    final firestoreDoc = pickStr(json, ['firestore_doc', 'firestoreDoc']);
    final lastUpdate = pickStr(json, ['last_update', 'lastUpdate']);
    DateTime? updatedAt;
    if (json['updated_at'] != null) {
      updatedAt = DateTime.tryParse(json['updated_at'].toString());
    }
    final mapX = json['map_x'] != null ? parseDouble(json['map_x']) : null;
    final mapY = json['map_y'] != null ? parseDouble(json['map_y']) : null;

    final rawSpeed = json['speed'] ?? json['speed_km_h'] ?? json['speedKmH'];
    final speedKmH = rawSpeed != null ? parseSpeed(rawSpeed) : 0;

    final region = pickStr(json, ['region', 'current_location_name', 'currentLocationName']);
    final duration = pickStr(json, ['duration', 'time_elapsed', 'timeElapsed']);
    final childrenSummary = json['children'] is String ? json['children'].toString().trim() : '';

    final rawStatusKey = pickStr(json, ['status_key', 'statusKey']);
    final rawStatusStr = json['status']?.toString() ?? 'in_progress';
    final isEmergency = json['is_emergency'] == true ||
        json['is_emergency']?.toString() == '1' ||
        json['is_emergency']?.toString() == 'true' ||
        rawStatusKey == 'suspended_breakdown' ||
        rawStatusStr.contains('عطل');

    final resolvedStatusKey = rawStatusKey.isNotEmpty
        ? rawStatusKey
        : (isEmergency ? 'suspended_breakdown' : 'in_progress');

    Map<String, dynamic>? emergencyDetails;
    if (json['emergency_details'] is Map) {
      emergencyDetails = Map<String, dynamic>.from(json['emergency_details']);
    } else if (json['emergencyDetails'] is Map) {
      emergencyDetails = Map<String, dynamic>.from(json['emergencyDetails']);
    }

    return ActiveTripModel(
      tripId: parseInt(json['trip_id'] ?? json['id']),
      driverId: parseInt(json['driver_id'] ?? json['driverId'] ?? driver?['id']),
      driverName: driverName,
      status: rawStatusStr,
      currentLat: parseDouble(json['current_lat'] ?? json['currentLat'] ?? json['lat'] ?? json['driver_lat']),
      currentLng: parseDouble(json['current_lng'] ?? json['currentLng'] ?? json['lng'] ?? json['driver_lng']),
      studentsCount: studentsCount,
      startedAt: json['started_at']?.toString() ?? json['startedAt']?.toString() ?? '',
      driverPhone: pickStr(json, ['phone', 'driver_phone', 'driverPhone']),
      driverAvatar: pickStr(json, ['avatar', 'driver_avatar', 'driverAvatar']),
      carModel: json['car_model']?.toString() ?? json['carModel']?.toString() ?? 'حافلة السائق',
      carPlate: json['car_plate']?.toString() ?? json['carPlate']?.toString() ?? '',
      rating: parseDouble(json['rating'] ?? 5.0),
      currentLocationName: region.isNotEmpty ? region : 'طريق الخدمة الحية',
      speedKmH: speedKmH,
      timeElapsed: duration.isNotEmpty ? duration : '',
      passengers: parsedPassengers,
      heading: heading,
      isOnline: isOnline,
      destination: destination,
      firestoreDoc: firestoreDoc,
      lastUpdate: lastUpdate,
      updatedAt: updatedAt,
      mapX: mapX,
      mapY: mapY,
      totalChildrenCount: totalChildrenCount > 0 ? totalChildrenCount : studentsCount,
      childrenOnBoardCount: childrenOnBoardCount,
      pendingPickupCount: pendingPickupCount,
      deliveredCount: deliveredCount,
      absentCount: absentCount,
      region: region,
      duration: duration,
      childrenSummary: childrenSummary,
      statusKey: resolvedStatusKey,
      isEmergency: isEmergency,
      emergencyDetails: emergencyDetails,
    );
  }
}