class DriverVehicleModel {
  final String make;
  final String model;
  final String plateNumber;
  final String? year;
  final String? color;
  final int? capacity;

  DriverVehicleModel({
    required this.make,
    required this.model,
    required this.plateNumber,
    this.year,
    this.color,
    this.capacity,
  });

  factory DriverVehicleModel.fromJson(Map<String, dynamic> json) {
    int? parsedCapacity;
    final rawCap = json['capacity_manual'] ?? json['capacity'];
    if (rawCap != null) {
      parsedCapacity = rawCap is int ? rawCap : int.tryParse(rawCap.toString());
    }

    return DriverVehicleModel(
      make: json['make']?.toString() ?? json['brand']?.toString() ?? 'غير محدد',
      model: json['model']?.toString() ?? 'غير محدد',
      plateNumber: json['plate_number']?.toString() ?? json['plate']?.toString() ?? 'غير محدد',
      year: json['year']?.toString(),
      color: json['color']?.toString(),
      capacity: parsedCapacity,
    );
  }
}
