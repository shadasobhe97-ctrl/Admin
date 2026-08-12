import '../../../../core/models/pagination_meta_model.dart';
import '../../../../core/utils/json_parsers.dart';

/// leaderboard[] — عنصر واحد في ترتيب أداء السائقين.
class DriverLeaderboardEntry {
  final int? rank;
  final int? driverId;
  final String? name;
  final String? phone;
  final String? email;
  final String? status;
  final double? ratingAvg;
  final int completedTripsCount;
  final int activeSubsCount;
  final double? retentionRate;
  final String? vehiclePlate;

  const DriverLeaderboardEntry({
    this.rank,
    this.driverId,
    this.name,
    this.phone,
    this.email,
    this.status,
    this.ratingAvg,
    required this.completedTripsCount,
    required this.activeSubsCount,
    this.retentionRate,
    this.vehiclePlate,
  });

  factory DriverLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return DriverLeaderboardEntry(
      rank: JsonParsers.optionalInt(json['rank']),
      driverId: JsonParsers.optionalInt(json['driver_id']),
      name: JsonParsers.optionalString(json['name']),
      phone: JsonParsers.optionalString(json['phone']),
      email: JsonParsers.optionalString(json['email']),
      status: JsonParsers.optionalString(json['status']),
      ratingAvg: JsonParsers.optionalDouble(json['rating_avg']),
      completedTripsCount:
          JsonParsers.intValue(json['completed_trips_count']),
      activeSubsCount: JsonParsers.intValue(json['active_subs_count']),
      retentionRate: JsonParsers.optionalDouble(json['retention_rate']),
      vehiclePlate: JsonParsers.optionalString(json['vehicle_plate']),
    );
  }
}

/// vehicles_documents_status.expiring_drivers_list[]
class ExpiringDriverDocument {
  final int? driverId;
  final String? name;
  final String? phone;
  final String? licenseExpiry;

  /// أيام متبقية كما يرسلها الخادم.
  final int? daysLeft;

  /// حالة الانتهاء كما يقرّرها الخادم لا الواجهة.
  final bool isExpired;

  const ExpiringDriverDocument({
    this.driverId,
    this.name,
    this.phone,
    this.licenseExpiry,
    this.daysLeft,
    this.isExpired = false,
  });

  factory ExpiringDriverDocument.fromJson(Map<String, dynamic> json) {
    return ExpiringDriverDocument(
      driverId: JsonParsers.optionalInt(json['driver_id']),
      name: JsonParsers.optionalString(json['name']),
      phone: JsonParsers.optionalString(json['phone']),
      licenseExpiry: JsonParsers.optionalString(json['license_expiry']),
      daysLeft: JsonParsers.optionalInt(json['days_left']),
      isExpired: JsonParsers.boolValue(json['is_expired']),
    );
  }
}

/// vehicles_documents_status
class VehiclesDocumentsStatus {
  final int totalVehicles;
  final int validLicenses;
  final int expiringSoonLicenses;
  final int expiredLicenses;
  final List<ExpiringDriverDocument> expiringDriversList;

  const VehiclesDocumentsStatus({
    required this.totalVehicles,
    required this.validLicenses,
    required this.expiringSoonLicenses,
    required this.expiredLicenses,
    this.expiringDriversList = const [],
  });

  factory VehiclesDocumentsStatus.fromJson(Map<String, dynamic> json) {
    return VehiclesDocumentsStatus(
      totalVehicles: JsonParsers.intValue(json['total_vehicles']),
      validLicenses: JsonParsers.intValue(json['valid_licenses']),
      expiringSoonLicenses:
          JsonParsers.intValue(json['expiring_soon_licenses']),
      expiredLicenses: JsonParsers.intValue(json['expired_licenses']),
      expiringDriversList: JsonParsers.listOf(
        json['expiring_drivers_list'],
        ExpiringDriverDocument.fromJson,
      ),
    );
  }
}

/// GET /api/admin/reports/drivers-performance
class DriversPerformanceReportModel {
  final List<DriverLeaderboardEntry> leaderboard;

  /// Pagination الحقيقية من الخادم — لا تُستنتج من طول القائمة.
  final PaginationMetaModel meta;
  final VehiclesDocumentsStatus documentsStatus;

  const DriversPerformanceReportModel({
    this.leaderboard = const [],
    required this.meta,
    required this.documentsStatus,
  });

  factory DriversPerformanceReportModel.fromJson(Map<String, dynamic> json) {
    final leaderboardJson = json['leaderboard'];

    // قد تأتي القائمة مباشرة، أو مغلّفة بـ `{data: [...], meta|pagination: {...}}`.
    final List<DriverLeaderboardEntry> entries;
    Map<String, dynamic>? metaJson;

    if (leaderboardJson is Map) {
      final wrapper = JsonParsers.mapValue(leaderboardJson);
      entries = JsonParsers.listOf(
        wrapper['data'],
        DriverLeaderboardEntry.fromJson,
      );
      metaJson = JsonParsers.extractMeta(wrapper) ?? wrapper;
    } else {
      entries = JsonParsers.listOf(
        leaderboardJson,
        DriverLeaderboardEntry.fromJson,
      );
      metaJson = JsonParsers.extractMeta(json);
    }

    return DriversPerformanceReportModel(
      leaderboard: entries,
      meta: PaginationMetaModel.fromJson(metaJson),
      documentsStatus: VehiclesDocumentsStatus.fromJson(
        JsonParsers.mapValue(json['vehicles_documents_status']),
      ),
    );
  }

  bool get isEmpty => leaderboard.isEmpty;
}
