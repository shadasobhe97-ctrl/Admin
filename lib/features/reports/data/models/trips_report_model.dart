import '../../../../core/utils/json_parsers.dart';
import 'financial_report_model.dart' show ReportDateRange;

/// completion_summary
class TripsCompletionSummary {
  final int totalTrips;
  final int completedTrips;
  final int cancelledTrips;
  final int inProgressTrips;
  final int scheduledTrips;

  /// النسب تأتي محسوبة من الخادم ولا تُعاد حسابتها في الواجهة.
  final double completionRatePercentage;
  final double cancellationRatePercentage;

  const TripsCompletionSummary({
    required this.totalTrips,
    required this.completedTrips,
    required this.cancelledTrips,
    required this.inProgressTrips,
    required this.scheduledTrips,
    required this.completionRatePercentage,
    required this.cancellationRatePercentage,
  });

  factory TripsCompletionSummary.fromJson(Map<String, dynamic> json) {
    return TripsCompletionSummary(
      totalTrips: JsonParsers.intValue(json['total_trips']),
      completedTrips: JsonParsers.intValue(json['completed_trips']),
      cancelledTrips: JsonParsers.intValue(json['cancelled_trips']),
      inProgressTrips: JsonParsers.intValue(json['in_progress_trips']),
      scheduledTrips: JsonParsers.intValue(json['scheduled_trips']),
      completionRatePercentage:
          JsonParsers.doubleValue(json['completion_rate_percentage']),
      cancellationRatePercentage:
          JsonParsers.doubleValue(json['cancellation_rate_percentage']),
    );
  }
}

/// absence_stats.student
class StudentAbsenceStats {
  final int totalRecords;
  final int presentCount;
  final int absentCount;
  final int excusedCount;
  final int unexcusedCount;

  const StudentAbsenceStats({
    required this.totalRecords,
    required this.presentCount,
    required this.absentCount,
    required this.excusedCount,
    required this.unexcusedCount,
  });

  factory StudentAbsenceStats.fromJson(Map<String, dynamic> json) {
    return StudentAbsenceStats(
      totalRecords: JsonParsers.intValue(json['total_records']),
      presentCount: JsonParsers.intValue(json['present_count']),
      absentCount: JsonParsers.intValue(json['absent_count']),
      excusedCount: JsonParsers.intValue(json['excused_count']),
      unexcusedCount: JsonParsers.intValue(json['unexcused_count']),
    );
  }
}

/// absence_stats.driver
class DriverAbsenceStats {
  final int driverCancellationsCount;
  final int driverAbsencesCount;

  const DriverAbsenceStats({
    required this.driverCancellationsCount,
    required this.driverAbsencesCount,
  });

  factory DriverAbsenceStats.fromJson(Map<String, dynamic> json) {
    return DriverAbsenceStats(
      driverCancellationsCount:
          JsonParsers.intValue(json['driver_cancellations_count']),
      driverAbsencesCount: JsonParsers.intValue(json['driver_absences_count']),
    );
  }
}

/// absence_stats
class AbsenceStats {
  final StudentAbsenceStats student;
  final DriverAbsenceStats driver;

  const AbsenceStats({required this.student, required this.driver});

  factory AbsenceStats.fromJson(Map<String, dynamic> json) {
    return AbsenceStats(
      student: StudentAbsenceStats.fromJson(
        JsonParsers.mapValue(json['student']),
      ),
      driver: DriverAbsenceStats.fromJson(
        JsonParsers.mapValue(json['driver']),
      ),
    );
  }
}

/// demand_heatmap.top_schools[] — المدارس وحدها تحمل إحداثيات في العقد.
class TopSchoolDemand {
  final int? schoolId;
  final String? schoolName;
  final int studentsCount;
  final double? lat;
  final double? lng;

  const TopSchoolDemand({
    this.schoolId,
    this.schoolName,
    required this.studentsCount,
    this.lat,
    this.lng,
  });

  factory TopSchoolDemand.fromJson(Map<String, dynamic> json) {
    return TopSchoolDemand(
      schoolId: JsonParsers.optionalInt(json['school_id']),
      schoolName: JsonParsers.optionalString(json['school_name']),
      studentsCount: JsonParsers.intValue(json['students_count']),
      lat: JsonParsers.optionalDouble(json['lat']),
      lng: JsonParsers.optionalDouble(json['lng']),
    );
  }

  /// المدارس بلا إحداثيات لا تُرسم على الخريطة ولا تُخترع لها مواقع.
  bool get hasCoordinates => lat != null && lng != null;
}

/// demand_heatmap.top_zones[] — لا تحتوي إحداثيات في العقد، فتُعرض كقائمة.
class TopZoneDemand {
  final int? zoneId;
  final String? zoneName;
  final int driversCount;

  const TopZoneDemand({
    this.zoneId,
    this.zoneName,
    required this.driversCount,
  });

  factory TopZoneDemand.fromJson(Map<String, dynamic> json) {
    return TopZoneDemand(
      zoneId: JsonParsers.optionalInt(json['zone_id']),
      zoneName: JsonParsers.optionalString(json['zone_name']),
      driversCount: JsonParsers.intValue(json['drivers_count']),
    );
  }
}

/// demand_heatmap
class DemandHeatmap {
  final List<TopSchoolDemand> topSchools;
  final List<TopZoneDemand> topZones;

  const DemandHeatmap({
    this.topSchools = const [],
    this.topZones = const [],
  });

  factory DemandHeatmap.fromJson(Map<String, dynamic> json) {
    return DemandHeatmap(
      topSchools: JsonParsers.listOf(
        json['top_schools'],
        TopSchoolDemand.fromJson,
      ),
      topZones: JsonParsers.listOf(json['top_zones'], TopZoneDemand.fromJson),
    );
  }

  /// المدارس التي يمكن رسمها على الخريطة فعلياً.
  List<TopSchoolDemand> get mappableSchools =>
      topSchools.where((school) => school.hasCoordinates).toList();
}

/// GET /api/admin/reports/trips
class TripsReportModel {
  final ReportDateRange dateRange;
  final TripsCompletionSummary completionSummary;
  final AbsenceStats absenceStats;
  final DemandHeatmap demandHeatmap;

  const TripsReportModel({
    required this.dateRange,
    required this.completionSummary,
    required this.absenceStats,
    required this.demandHeatmap,
  });

  factory TripsReportModel.fromJson(Map<String, dynamic> json) {
    return TripsReportModel(
      dateRange: ReportDateRange.fromJson(
        JsonParsers.mapValue(json['date_range']),
      ),
      completionSummary: TripsCompletionSummary.fromJson(
        JsonParsers.mapValue(json['completion_summary']),
      ),
      absenceStats: AbsenceStats.fromJson(
        JsonParsers.mapValue(json['absence_stats']),
      ),
      demandHeatmap: DemandHeatmap.fromJson(
        JsonParsers.mapValue(json['demand_heatmap']),
      ),
    );
  }
}
