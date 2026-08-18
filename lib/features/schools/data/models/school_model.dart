import '../../../../core/utils/json_parsers.dart';

/// المنطقة الجغرافية كما تأتي مختصرة داخل كائن المدرسة.
/// GET /api/admin/schools → data[].zone
class SchoolZoneRef {
  final int id;
  final String name;

  const SchoolZoneRef({required this.id, required this.name});

  factory SchoolZoneRef.fromJson(Map<String, dynamic> json) {
    return SchoolZoneRef(
      id: JsonParsers.intValue(json['id']),
      name: JsonParsers.stringValue(json['name']),
    );
  }

  SchoolZoneRef copyWith({int? id, String? name}) {
    return SchoolZoneRef(id: id ?? this.id, name: name ?? this.name);
  }
}

/// حالات اعتماد المدرسة المسموح بها من الخادم (`in:approved,pending,active,inactive,rejected`).
class SchoolStatus {
  const SchoolStatus._();

  static const String approved = 'approved';
  static const String active = 'active';
  static const String pending = 'pending';
  static const String inactive = 'inactive';
  static const String rejected = 'rejected';

  static const List<String> all = [approved, active, pending, inactive, rejected];

  static String label(String status) {
    switch (status.toLowerCase()) {
      case approved:
        return 'معتمدة';
      case active:
        return 'نشطة';
      case pending:
        return 'قيد الاعتماد';
      case inactive:
        return 'غير نشطة';
      case rejected:
        return 'مرفوضة';
      default:
        return status;
    }
  }
}

/// GET /api/admin/schools
/// GET /api/admin/schools/{id}
///
/// الخادم يرسل الإحداثيات في `lat` / `lng`، والمنطقة ككائن متداخل `zone`.
class SchoolModel {
  final int id;
  final String name;
  final String address;
  final double? lat;
  final double? lng;
  final String status;
  final SchoolZoneRef? zone;

  const SchoolModel({
    required this.id,
    required this.name,
    required this.address,
    this.lat,
    this.lng,
    this.status = SchoolStatus.pending,
    this.zone,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    final zoneJson = JsonParsers.optionalMap(json['zone']);

    return SchoolModel(
      id: JsonParsers.intValue(json['id']),
      name: JsonParsers.stringValue(json['name']),
      address: JsonParsers.stringValue(json['address']),
      lat: JsonParsers.optionalDouble(json['lat']),
      lng: JsonParsers.optionalDouble(json['lng']),
      status: JsonParsers.stringValue(
        json['status'],
        fallback: SchoolStatus.pending,
      ),
      zone: zoneJson == null ? null : SchoolZoneRef.fromJson(zoneJson),
    );
  }

  int? get zoneId => zone?.id;
  String? get zoneName => zone?.name;

  bool get isApproved =>
      status.toLowerCase() == SchoolStatus.approved ||
      status.toLowerCase() == SchoolStatus.active;
  bool get hasCoordinates => lat != null && lng != null;

  String get statusLabel => SchoolStatus.label(status);

  /// الإحداثيات جاهزة للعرض، أو `null` إن لم يرسلها الخادم.
  String? get coordinatesLabel =>
      hasCoordinates ? 'Lat: $lat  •  Lng: $lng' : null;

  SchoolModel copyWith({
    int? id,
    String? name,
    String? address,
    double? lat,
    double? lng,
    String? status,
    SchoolZoneRef? zone,
  }) {
    return SchoolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      status: status ?? this.status,
      zone: zone ?? this.zone,
    );
  }
}
