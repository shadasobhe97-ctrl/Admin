class ActiveTripModel {
  final int tripId;
  final String driverName;
  final int kidsCount;
  final String destination;
  final String speed;
  final String region;
  final String status;

  ActiveTripModel({
    required this.tripId,
    required this.driverName,
    required this.kidsCount,
    required this.destination,
    required this.speed,
    required this.region,
    required this.status,
  });

  factory ActiveTripModel.fromJson(Map<String, dynamic> json) {
    return ActiveTripModel(
      tripId: json['trip_id'] ?? 0,
      driverName: json['driver_name'] ?? '',
      kidsCount: json['kids_count'] ?? 0,
      destination: json['destination'] ?? '',
      speed: json['speed'] ?? '0 km/h',
      region: json['region'] ?? '',
      status: json['status'] ?? 'غير معروف',
    );
  }
}
