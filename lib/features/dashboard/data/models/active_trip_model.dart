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
    this.actualTime,
    this.notes,
  });
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
    this.speedKmH = 40,
    this.timeElapsed = '',
    this.passengers = const [],
  });

  String get id => tripId.toString();

  int get ridingCount => passengers.where((p) => p.status == 'راكب').length;
  int get waitingCount => passengers.where((p) => p.status == 'ينتظر').length;
  int get arrivedCount => passengers.where((p) => p.status == 'وصل').length;

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

    // توحيد حالة الراكب مع القيم المستخدمة في الواجهة (راكب / ينتظر / وصل)
    String normalizeStatus(String raw) {
      switch (raw.toLowerCase()) {
        case 'راكب':
        case 'picked_up':
        case 'pickedup':
        case 'on_board':
        case 'onboard':
        case 'boarded':
        case 'riding':
        case 'in_bus':
          return 'راكب';
        case 'وصل':
        case 'dropped_off':
        case 'droppedoff':
        case 'arrived':
        case 'delivered':
        case 'completed':
          return 'وصل';
        default:
          return 'ينتظر';
      }
    }

    final dynamic rawPassengers = json['passengers'] ??
        json['children'] ??
        json['students'] ??
        json['kids'] ??
        json['trip_children'] ??
        json['subscriptions'];

    final parsedPassengers = <TripPassenger>[];
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
          status: 'ينتظر',
        ));
      }
    } else if (rawPassengers is List) {
      for (final item in rawPassengers) {
        if (item is String) {
          // الباك ممكن يبعت أسماء فقط
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
              status: 'ينتظر',
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
          actualTime: pickStr(p, ['actual_time', 'actualTime', 'picked_up_at', 'dropped_off_at']).isEmpty
              ? null
              : pickStr(p, ['actual_time', 'actualTime', 'picked_up_at', 'dropped_off_at']),
          notes: pickStr(p, ['notes']).isEmpty ? null : pickStr(p, ['notes']),
        ));
      }
    }

    final driver = asMap(json['driver']);
    final driverUser = asMap(driver?['user']);
    final driverName = [
      pickStr(json, ['driver_name', 'driverName', 'driver_full_name', 'name']),
      pickStr(driver, ['full_name', 'fullName', 'name']),
      pickStr(driverUser, ['full_name', 'fullName', 'name']),
    ].firstWhere((s) => s.isNotEmpty, orElse: () => 'سائق غير معروف');

    // عدد الأطفال: من الباك، وإلا من طول القائمة
    final countFromApi = parseInt(json['students_count'] ??
        json['studentsCount'] ??
        json['children_count'] ??
        json['childrenCount'] ??
        json['passengers_count'] ??
        json['kids_count']);
    final studentsCount =
        countFromApi > 0 ? countFromApi : parsedPassengers.length;

    return ActiveTripModel(
      tripId: parseInt(json['trip_id'] ?? json['id']),
      driverId: parseInt(json['driver_id'] ?? json['driverId'] ?? driver?['id']),
      driverName: driverName,
      status: json['status']?.toString() ?? 'in_progress',
      currentLat: parseDouble(json['current_lat'] ?? json['currentLat'] ?? json['lat']),
      currentLng: parseDouble(json['current_lng'] ?? json['currentLng'] ?? json['lng']),
      studentsCount: studentsCount,
      startedAt: json['started_at']?.toString() ?? json['startedAt']?.toString() ?? '',
      driverPhone: json['driver_phone']?.toString() ?? json['driverPhone']?.toString() ?? json['phone']?.toString() ?? '',
      driverAvatar: json['driver_avatar']?.toString() ?? json['driverAvatar']?.toString() ?? json['avatar']?.toString() ?? '',
      carModel: json['car_model']?.toString() ?? json['carModel']?.toString() ?? 'حافلة السائق',
      carPlate: json['car_plate']?.toString() ?? json['carPlate']?.toString() ?? '',
      rating: parseDouble(json['rating'] ?? 5.0),
      currentLocationName: json['current_location_name']?.toString() ?? json['currentLocationName']?.toString() ?? json['region']?.toString() ?? 'طريق الخدمة الحية',
      speedKmH: parseInt(json['speed_km_h'] ?? json['speedKmH'] ?? 40),
      timeElapsed: json['time_elapsed']?.toString() ?? json['timeElapsed']?.toString() ?? json['duration']?.toString() ?? '',
      passengers: parsedPassengers,
    );
  }
}