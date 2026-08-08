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

    final parsedPassengers = <TripPassenger>[];
    if (json['passengers'] is List) {
      for (final p in json['passengers']) {
        if (p is Map<String, dynamic>) {
          parsedPassengers.add(TripPassenger(
            id: p['id']?.toString() ?? '',
            childName: p['child_name'] ?? p['childName'] ?? '',
            parentName: p['parent_name'] ?? p['parentName'] ?? '',
            parentPhone: p['parent_phone'] ?? p['parentPhone'] ?? '',
            pickupLocation: p['pickup_location'] ?? p['pickupLocation'] ?? '',
            dropoffLocation: p['dropoff_location'] ?? p['dropoffLocation'] ?? '',
            schoolName: p['school_name'] ?? p['schoolName'] ?? '',
            scheduledTime: p['scheduled_time'] ?? p['scheduledTime'] ?? '',
            status: p['status'] ?? '',
          ));
        }
      }
    }

    return ActiveTripModel(
      tripId: parseInt(json['trip_id'] ?? json['id']),
      driverId: parseInt(json['driver_id'] ?? json['driverId']),
      driverName: json['driver_name']?.toString() ?? json['driverName']?.toString() ?? 'سائق غير معروف',
      status: json['status']?.toString() ?? 'in_progress',
      currentLat: parseDouble(json['current_lat'] ?? json['currentLat'] ?? json['lat']),
      currentLng: parseDouble(json['current_lng'] ?? json['currentLng'] ?? json['lng']),
      studentsCount: parseInt(json['students_count'] ?? json['studentsCount']),
      startedAt: json['started_at']?.toString() ?? json['startedAt']?.toString() ?? '',
      driverPhone: json['driver_phone']?.toString() ?? json['driverPhone']?.toString() ?? '',
      driverAvatar: json['driver_avatar']?.toString() ?? json['driverAvatar']?.toString() ?? '',
      carModel: json['car_model']?.toString() ?? json['carModel']?.toString() ?? 'حافلة السائق',
      carPlate: json['car_plate']?.toString() ?? json['carPlate']?.toString() ?? '',
      rating: parseDouble(json['rating'] ?? 5.0),
      currentLocationName: json['current_location_name']?.toString() ?? json['currentLocationName']?.toString() ?? 'طريق الخدمة الحية',
      speedKmH: parseInt(json['speed_km_h'] ?? json['speedKmH'] ?? 40),
      timeElapsed: json['time_elapsed']?.toString() ?? json['timeElapsed']?.toString() ?? '',
      passengers: parsedPassengers,
    );
  }
}