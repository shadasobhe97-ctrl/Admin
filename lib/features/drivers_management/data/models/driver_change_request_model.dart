class DriverChangeRequestModel {
  final int id;
  final int driverId;
  final String? driverName;
  final String changeType;
  final String status;
  final String? createdAt;

  DriverChangeRequestModel({
    required this.id,
    required this.driverId,
    this.driverName,
    required this.changeType,
    required this.status,
    this.createdAt,
  });

  factory DriverChangeRequestModel.fromJson(Map<String, dynamic> json) {
    int parsedId = 0;
    if (json['id'] != null) {
      parsedId = json['id'] is int ? json['id'] : (int.tryParse(json['id'].toString()) ?? 0);
    }

    int parsedDriverId = 0;
    if (json['driver_id'] != null) {
      parsedDriverId = json['driver_id'] is int ? json['driver_id'] : (int.tryParse(json['driver_id'].toString()) ?? 0);
    }

    return DriverChangeRequestModel(
      id: parsedId,
      driverId: parsedDriverId,
      driverName: json['driver_name']?.toString() ?? json['driver']?['full_name']?.toString(),
      changeType: json['change_type']?.toString() ?? json['type']?.toString() ?? 'vehicle_update',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString(),
    );
  }

  String get translatedType {
    switch (changeType) {
      case 'vehicle_update':
        return 'تعديل بيانات المركبة';
      case 'document_update':
        return 'تحديث الوثائق الرسمية';
      case 'profile_update':
        return 'تعديل بيانات الملف الشخصي';
      default:
        return changeType;
    }
  }
}
