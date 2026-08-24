/// مركبة مسجّلة للسائق.
///
/// شكل الخادم: `brand`, `model`, `plate_number`, `color`, `type`, `year`,
/// `capacity_manual`, `has_ac`, `vehicle_image_url`, `status`, `is_verified`.
/// الاسم القديم `make` ما يزال مقروءاً للتوافق الخلفي.
class DriverVehicleModel {
  final int? id;
  final String brand;
  final String model;
  final String plateNumber;
  final String? year;
  final String? color;
  final String? type;
  final int? capacity;
  final bool? hasAc;
  final String? imageUrl;
  final String? status;
  final bool isVerified;

  DriverVehicleModel({
    this.id,
    required this.brand,
    required this.model,
    required this.plateNumber,
    this.year,
    this.color,
    this.type,
    this.capacity,
    this.hasAc,
    this.imageUrl,
    this.status,
    this.isVerified = false,
  });

  /// الاسم السابق للحقل — مُبقى حتى لا تنكسر الشاشات التي تستخدمه.
  String get make => brand;

  static String? _text(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty || text == 'null' ? null : text;
  }

  static bool? _boolOrNull(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value.toString().toLowerCase();
    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;
    return null;
  }

  factory DriverVehicleModel.fromJson(Map<String, dynamic> json) {
    final rawCapacity = json['capacity_manual'] ?? json['capacity'];

    return DriverVehicleModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      brand: _text(json['brand']) ?? _text(json['make']) ?? 'غير محدد',
      model: _text(json['model']) ?? 'غير محدد',
      plateNumber:
          _text(json['plate_number']) ?? _text(json['plate']) ?? 'غير محدد',
      year: _text(json['year']),
      color: _text(json['color']),
      type: _text(json['type']),
      capacity: rawCapacity is int
          ? rawCapacity
          : int.tryParse('${rawCapacity ?? ''}'),
      hasAc: _boolOrNull(json['has_ac']),
      imageUrl: _text(json['vehicle_image_url']) ??
          _text(json['image_url']) ??
          _text(json['vehicle_image']),
      status: _text(json['status']),
      isVerified: _boolOrNull(json['is_verified']) ?? false,
    );
  }
}
