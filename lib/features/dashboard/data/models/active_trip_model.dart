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

// تم تغيير الاسم هنا إلى ActiveTripModel ليتطابق مع الريبوزيتوري الخاص بك
class ActiveTripModel { 
  final String id;
  final String driverName;
  final String driverPhone;
  final String driverAvatar;
  final String carModel;
  final String carPlate;
  final double rating;
  final String currentLocationName;
  final int speedKmH;
  final String timeElapsed;
  final String status;
  final List<TripPassenger> passengers;

  ActiveTripModel({
    required this.id,
    required this.driverName,
    required this.driverPhone,
    required this.driverAvatar,
    required this.carModel,
    required this.carPlate,
    required this.rating,
    required this.currentLocationName,
    required this.speedKmH,
    required this.timeElapsed,
    required this.status,
    required this.passengers,
  });

  int get ridingCount => passengers.where((p) => p.status == 'راكب').length;
  int get waitingCount => passengers.where((p) => p.status == 'ينتظر').length;
  int get arrivedCount => passengers.where((p) => p.status == 'وصل').length;

  // أضفنا دالة fromJson فارغة مؤقتاً لحل خطأ الريبوزيتوري حتى نقوم بربط الـ API الفعلي
  factory ActiveTripModel.fromJson(Map<String, dynamic> json) {
    return ActiveTripModel(
      id: json['id'] ?? '',
      driverName: json['driverName'] ?? '',
      driverPhone: json['driverPhone'] ?? '',
      driverAvatar: json['driverAvatar'] ?? '',
      carModel: json['carModel'] ?? '',
      carPlate: json['carPlate'] ?? '',
      rating: (json['rating'] ?? 5.0).toDouble(),
      currentLocationName: json['currentLocationName'] ?? '',
      speedKmH: json['speedKmH'] ?? 0,
      timeElapsed: json['timeElapsed'] ?? '',
      status: json['status'] ?? '',
      passengers: [], // سنقوم ببرمجتها لاحقاً عند استلام البيانات الحقيقية
    );
  }
}