import 'driver_document_model.dart';
import 'driver_model.dart';
import 'driver_vehicle_model.dart';

/// إحصاءات أداء السائق كما يرسلها الخادم في `statistics`.
class DriverStatistics {
  final double? ratingAvg;
  final int? completedTripsCount;
  final double? retentionRate;

  const DriverStatistics({
    this.ratingAvg,
    this.completedTripsCount,
    this.retentionRate,
  });

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  factory DriverStatistics.fromJson(Map<String, dynamic> json) {
    final trips = json['completed_trips_count'];
    return DriverStatistics(
      ratingAvg: _toDouble(json['rating_avg']),
      completedTripsCount:
          trips is int ? trips : int.tryParse('${trips ?? ''}'),
      retentionRate: _toDouble(json['retention_rate']),
    );
  }
}

/// آخر موقع معروف للسائق (`location`).
class DriverLocation {
  final double? lat;
  final double? lng;
  final String? lastPingAt;

  const DriverLocation({this.lat, this.lng, this.lastPingAt});

  bool get hasPosition => lat != null && lng != null;

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  factory DriverLocation.fromJson(Map<String, dynamic> json) {
    return DriverLocation(
      lat: _toDouble(json['lat']),
      lng: _toDouble(json['lng']),
      lastPingAt: json['last_ping_at']?.toString(),
    );
  }
}

class DriverDetailsModel {
  final DriverModel driver;
  final List<DriverDocumentModel> documents;

  /// كل المركبات المسجّلة — الخادم يرسلها في مصفوفة `vehicles`.
  final List<DriverVehicleModel> vehicles;

  final DriverStatistics? statistics;
  final DriverLocation? location;
  final List<Map<String, dynamic>> approvalHistory;
  final Map<String, dynamic>? extraData;

  DriverDetailsModel({
    required this.driver,
    required this.documents,
    this.vehicles = const [],
    this.statistics,
    this.location,
    this.approvalHistory = const [],
    this.extraData,
  });

  /// المركبة المعروضة والمقصودة بالتعديل: الموثّقة إن وُجدت، وإلا الأولى.
  DriverVehicleModel? get vehicle {
    if (vehicles.isEmpty) return null;
    for (final item in vehicles) {
      if (item.isVerified) return item;
    }
    return vehicles.first;
  }

  factory DriverDetailsModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> driverJson = json;
    if (json['data'] is Map<String, dynamic>) {
      driverJson = json['data'] as Map<String, dynamic>;
    } else if (json['driver'] is Map<String, dynamic>) {
      driverJson = json['driver'] as Map<String, dynamic>;
    }

    List<Map<String, dynamic>> mapList(dynamic raw) {
      if (raw is! List) return const [];
      return raw.whereType<Map<String, dynamic>>().toList();
    }

    final docs = mapList(driverJson['documents'] ?? json['documents'])
        .map(DriverDocumentModel.fromJson)
        .toList();

    // `vehicles` هو الشكل المعتمد؛ `vehicle` المفرد للتوافق الخلفي.
    var vehicleMaps = mapList(driverJson['vehicles'] ?? json['vehicles']);
    if (vehicleMaps.isEmpty) {
      final single = driverJson['vehicle'] ?? json['vehicle'];
      if (single is Map<String, dynamic>) vehicleMaps = [single];
    }

    final statsRaw = driverJson['statistics'] ?? json['statistics'];
    final locationRaw = driverJson['location'] ?? json['location'];

    return DriverDetailsModel(
      driver: DriverModel.fromJson(driverJson),
      documents: docs,
      vehicles: vehicleMaps.map(DriverVehicleModel.fromJson).toList(),
      statistics: statsRaw is Map<String, dynamic>
          ? DriverStatistics.fromJson(statsRaw)
          : null,
      location: locationRaw is Map<String, dynamic>
          ? DriverLocation.fromJson(locationRaw)
          : null,
      approvalHistory:
          mapList(driverJson['approval_history'] ?? json['approval_history']),
      extraData: json,
    );
  }
}
