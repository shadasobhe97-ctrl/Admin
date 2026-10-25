class BreakdownLocation {
  final double latitude;
  final double longitude;
  final String mapsUrl;

  BreakdownLocation({
    required this.latitude,
    required this.longitude,
    required this.mapsUrl,
  });

  factory BreakdownLocation.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return BreakdownLocation(latitude: 0, longitude: 0, mapsUrl: '');
    }
    double parseD(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0.0;
    }

    final lat = parseD(json['latitude'] ?? json['lat']);
    final lng = parseD(json['longitude'] ?? json['lng']);
    final mapsUrl = json['maps_url']?.toString() ??
        (lat != 0 && lng != 0 ? 'https://maps.google.com/?q=$lat,$lng' : '');

    return BreakdownLocation(
      latitude: lat,
      longitude: lng,
      mapsUrl: mapsUrl,
    );
  }
}

class EmergencyOriginalTrip {
  final int id;
  final String tripType;
  final String shiftSlot;
  final String tripDate;
  final String routeName;
  final String status;

  EmergencyOriginalTrip({
    required this.id,
    required this.tripType,
    required this.shiftSlot,
    required this.tripDate,
    required this.routeName,
    required this.status,
  });

  factory EmergencyOriginalTrip.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EmergencyOriginalTrip(
        id: 0,
        tripType: '',
        shiftSlot: '',
        tripDate: '',
        routeName: '',
        status: '',
      );
    }
    return EmergencyOriginalTrip(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      tripType: json['trip_type']?.toString() ?? '',
      shiftSlot: json['shift_slot']?.toString() ?? '',
      tripDate: json['trip_date']?.toString() ?? '',
      routeName: json['route_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

class EmergencyVehicle {
  final String brand;
  final String model;
  final String plateNumber;
  final String color;
  final int capacity;

  EmergencyVehicle({
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.color,
    required this.capacity,
  });

  factory EmergencyVehicle.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EmergencyVehicle(
        brand: '',
        model: '',
        plateNumber: '',
        color: '',
        capacity: 0,
      );
    }
    return EmergencyVehicle(
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      plateNumber: json['plate_number']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      capacity: int.tryParse(json['capacity']?.toString() ?? '') ?? 0,
    );
  }

  String get summary {
    final parts = [brand, model, color].where((s) => s.isNotEmpty).toList();
    return parts.join(' - ');
  }
}

class EmergencyDriver {
  final int id;
  final String name;
  final String phone;
  final double currentLat;
  final double currentLng;
  final EmergencyVehicle? vehicle;

  EmergencyDriver({
    required this.id,
    required this.name,
    required this.phone,
    required this.currentLat,
    required this.currentLng,
    this.vehicle,
  });

  factory EmergencyDriver.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EmergencyDriver(
        id: 0,
        name: '',
        phone: '',
        currentLat: 0,
        currentLng: 0,
      );
    }
    double parseD(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0.0;
    }

    return EmergencyDriver(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      currentLat: parseD(json['current_lat'] ?? json['lat']),
      currentLng: parseD(json['current_lng'] ?? json['lng']),
      vehicle: json['vehicle'] is Map
          ? EmergencyVehicle.fromJson(Map<String, dynamic>.from(json['vehicle']))
          : null,
    );
  }
}

class EmergencyChildrenSummary {
  final int totalStrandedCount;
  final int boardedInBusCount;
  final int waitingAtPickupCount;
  final int deliveredCount;

  EmergencyChildrenSummary({
    required this.totalStrandedCount,
    required this.boardedInBusCount,
    required this.waitingAtPickupCount,
    required this.deliveredCount,
  });

  factory EmergencyChildrenSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EmergencyChildrenSummary(
        totalStrandedCount: 0,
        boardedInBusCount: 0,
        waitingAtPickupCount: 0,
        deliveredCount: 0,
      );
    }
    int parseI(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return EmergencyChildrenSummary(
      totalStrandedCount: parseI(json['total_stranded_count']),
      boardedInBusCount: parseI(json['boarded_in_bus_count']),
      waitingAtPickupCount: parseI(json['waiting_at_pickup_count']),
      deliveredCount: parseI(json['delivered_count']),
    );
  }
}

class EmergencyChildSchool {
  final int id;
  final String name;
  final String address;
  final double lat;
  final double lng;

  EmergencyChildSchool({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory EmergencyChildSchool.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EmergencyChildSchool(id: 0, name: '', address: '', lat: 0, lng: 0);
    }
    double parseD(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0.0;
    }

    return EmergencyChildSchool(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      lat: parseD(json['lat']),
      lng: parseD(json['lng']),
    );
  }
}

class EmergencyChildParent {
  final int id;
  final String name;
  final String phone;
  final String alternativePhone;

  EmergencyChildParent({
    required this.id,
    required this.name,
    required this.phone,
    required this.alternativePhone,
  });

  factory EmergencyChildParent.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return EmergencyChildParent(id: 0, name: '', phone: '', alternativePhone: '');
    }
    return EmergencyChildParent(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      alternativePhone: json['alternative_phone']?.toString() ?? '',
    );
  }
}

class EmergencyChildDetail {
  final int childId;
  final String fullName;
  final int grade;
  final String gender;
  final String status;
  final String statusLabel;
  final bool wasInBus;
  final EmergencyChildSchool? school;
  final EmergencyChildParent? parent;
  final String homeAddressLabel;

  EmergencyChildDetail({
    required this.childId,
    required this.fullName,
    required this.grade,
    required this.gender,
    required this.status,
    required this.statusLabel,
    required this.wasInBus,
    this.school,
    this.parent,
    required this.homeAddressLabel,
  });

  bool get isDelivered => status == 'delivered';
  bool get isOnBoardRescueBus => status == 'on_board';
  bool get isStrandedInBrokenBus => status == 'stranded_in_broken_bus';
  bool get isWaitingPickup => status == 'waiting_pickup';

  String get cleanStatusLabel {
    if (isDelivered) return 'تم التوصيل بسلام';
    if (isOnBoardRescueBus) return 'على متن حافلة الإنقاذ البديلة';
    if (isStrandedInBrokenBus) return 'داخل الحافلة المعطلة (بانتظار وصول البديل)';
    if (isWaitingPickup) return 'ينتظر في موقعه (لم يُلتقط بعد)';

    final stripped = statusLabel.replaceAll(RegExp(r'[^\u0600-\u06FF\s\(\)]'), '').trim();
    if (stripped.isNotEmpty) return stripped;

    switch (status.toLowerCase()) {
      case 'on_board':
        return 'على متن الحافلة البديلة';
      case 'waiting_pickup':
        return 'ينتظر في موقعه';
      case 'delivered':
        return 'تم التوصيل بسلام';
      case 'absent':
        return 'غائب';
      case 'stranded_in_broken_bus':
        return 'داخل الحافلة المعطلة';
      default:
        return 'معلق';
    }
  }

  factory EmergencyChildDetail.fromJson(Map<String, dynamic> json) {
    return EmergencyChildDetail(
      childId: int.tryParse(json['child_id']?.toString() ?? '') ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      grade: int.tryParse(json['grade']?.toString() ?? '') ?? 0,
      gender: json['gender']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      wasInBus: json['was_in_bus'] == true,
      school: json['school'] is Map
          ? EmergencyChildSchool.fromJson(Map<String, dynamic>.from(json['school']))
          : null,
      parent: json['parent'] is Map
          ? EmergencyChildParent.fromJson(Map<String, dynamic>.from(json['parent']))
          : null,
      homeAddressLabel: json['home_address'] is Map
          ? (json['home_address']['label']?.toString() ?? '')
          : '',
    );
  }
}

class CandidateDriver {
  final int id;
  final String name;
  final String phone;
  final String plateNumber;

  CandidateDriver({
    required this.id,
    required this.name,
    required this.phone,
    required this.plateNumber,
  });

  factory CandidateDriver.fromJson(Map<String, dynamic> json) {
    String plate = json['plate_number']?.toString() ?? '';
    if (plate.isEmpty && json['vehicle'] is Map) {
      plate = json['vehicle']['plate_number']?.toString() ?? '';
    }

    return CandidateDriver(
      id: int.tryParse(json['id']?.toString() ?? json['driver_id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? json['driver_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['driver_phone']?.toString() ?? '',
      plateNumber: plate,
    );
  }
}

class TripEmergencyDetailModel {
  final int dispatchId;
  final String status;
  final String statusLabel;
  final bool isUnresolved;
  final bool hasSubstituteAccepted;
  final String reason;
  final String dispatchedAt;
  final String? expiresAt;
  final String? acceptedAt;
  final String? completedAt;
  final BreakdownLocation breakdownLocation;
  final EmergencyOriginalTrip originalTrip;
  final EmergencyDriver originalDriver;
  final EmergencyDriver? substituteDriver;
  final EmergencyChildrenSummary childrenSummary;
  final List<EmergencyChildDetail> childrenDetails;
  final List<CandidateDriver> candidates;

  TripEmergencyDetailModel({
    required this.dispatchId,
    required this.status,
    required this.statusLabel,
    required this.isUnresolved,
    required this.hasSubstituteAccepted,
    required this.reason,
    required this.dispatchedAt,
    this.expiresAt,
    this.acceptedAt,
    this.completedAt,
    required this.breakdownLocation,
    required this.originalTrip,
    required this.originalDriver,
    this.substituteDriver,
    required this.childrenSummary,
    required this.childrenDetails,
    required this.candidates,
  });

  bool get isPending => status == 'pending';
  bool get isBroadcasted => status == 'broadcasted';
  bool get isAccepted => status == 'accepted';
  bool get isDeclinedAll => status == 'declined_all';
  bool get isExpired => status == 'expired';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  /// نص نظيف وبسيط لحالة بلاغ الطوارئ بدون إيموجيات
  String get cleanStatusLabel {
    switch (status) {
      case 'pending':
        return 'قيد الإعداد';
      case 'broadcasted':
        return 'جاري البحث وبث الطلب للسائقين البدلاء';
      case 'accepted':
        return 'تم قبول المهمة من سائق بديل وهو في الطريق';
      case 'declined_all':
        return 'رفض جميع المرشحين - استلام يدوي';
      case 'unresolved':
        return 'تعذر إيجاد بديل - تم إشعار أولياء الأمور للاستلام';
      case 'completed':
        return 'مكتملة ومُغلقة بنجاح';
      case 'cancelled':
        return 'تم إلغاء البلاغ (إصلاح العطل)';
      case 'expired':
        return 'انتهت صلاحية الطلب';
      default:
        final stripped = statusLabel.replaceAll(RegExp(r'[^\u0600-\u06FF\s\(\)\-]'), '').trim();
        return stripped.isNotEmpty ? stripped : statusLabel;
    }
  }

  factory TripEmergencyDetailModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? asMap(dynamic v) =>
        v is Map ? Map<String, dynamic>.from(v) : null;

    final rawCandidates = json['candidates'];
    final candidateDrivers = <CandidateDriver>[];
    if (rawCandidates is Map && rawCandidates['drivers'] is List) {
      for (final d in rawCandidates['drivers']) {
        if (d is Map) {
          candidateDrivers.add(CandidateDriver.fromJson(Map<String, dynamic>.from(d)));
        }
      }
    } else if (rawCandidates is List) {
      for (final d in rawCandidates) {
        if (d is Map) {
          candidateDrivers.add(CandidateDriver.fromJson(Map<String, dynamic>.from(d)));
        }
      }
    }

    final childrenList = <EmergencyChildDetail>[];
    if (json['children_details'] is List) {
      for (final c in json['children_details']) {
        if (c is Map) {
          childrenList.add(EmergencyChildDetail.fromJson(Map<String, dynamic>.from(c)));
        }
      }
    }

    return TripEmergencyDetailModel(
      dispatchId: int.tryParse(json['dispatch_id']?.toString() ?? json['id']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? '',
      isUnresolved: json['is_unresolved'] == true,
      hasSubstituteAccepted: json['has_substitute_accepted'] == true,
      reason: json['reason']?.toString() ?? 'توقف الحافلة',
      dispatchedAt: json['dispatched_at']?.toString() ?? '',
      expiresAt: json['expires_at']?.toString(),
      acceptedAt: json['accepted_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
      breakdownLocation: BreakdownLocation.fromJson(asMap(json['breakdown_location'])),
      originalTrip: EmergencyOriginalTrip.fromJson(asMap(json['original_trip'])),
      originalDriver: EmergencyDriver.fromJson(asMap(json['original_driver'])),
      substituteDriver: json['substitute_driver'] is Map
          ? EmergencyDriver.fromJson(asMap(json['substitute_driver']))
          : null,
      childrenSummary: EmergencyChildrenSummary.fromJson(asMap(json['children_summary'])),
      childrenDetails: childrenList,
      candidates: candidateDrivers,
    );
  }
}
