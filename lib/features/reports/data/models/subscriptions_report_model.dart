import '../../../../core/utils/json_parsers.dart';
import 'financial_report_model.dart' show ReportDateRange;

/// subscription_types — النسب تأتي محسوبة من الخادم.
class SubscriptionTypesBreakdown {
  final int totalContracts;
  final int monthlyCount;
  final int dailyCount;
  final int bothCount;
  final double monthlyPercentage;
  final double dailyPercentage;
  final double bothPercentage;

  const SubscriptionTypesBreakdown({
    required this.totalContracts,
    required this.monthlyCount,
    required this.dailyCount,
    required this.bothCount,
    required this.monthlyPercentage,
    required this.dailyPercentage,
    required this.bothPercentage,
  });

  factory SubscriptionTypesBreakdown.fromJson(Map<String, dynamic> json) {
    return SubscriptionTypesBreakdown(
      totalContracts: JsonParsers.intValue(json['total_contracts']),
      monthlyCount: JsonParsers.intValue(json['monthly_count']),
      dailyCount: JsonParsers.intValue(json['daily_count']),
      bothCount: JsonParsers.intValue(json['both_count']),
      monthlyPercentage: JsonParsers.doubleValue(json['monthly_percentage']),
      dailyPercentage: JsonParsers.doubleValue(json['daily_percentage']),
      bothPercentage: JsonParsers.doubleValue(json['both_percentage']),
    );
  }

  bool get hasContracts => totalContracts > 0;
}

/// status_breakdown
class SubscriptionStatusBreakdown {
  final int activeCount;
  final int pausedCount;
  final int cancelledCount;
  final int totalSubs;

  const SubscriptionStatusBreakdown({
    required this.activeCount,
    required this.pausedCount,
    required this.cancelledCount,
    required this.totalSubs,
  });

  factory SubscriptionStatusBreakdown.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatusBreakdown(
      activeCount: JsonParsers.intValue(json['active_count']),
      pausedCount: JsonParsers.intValue(json['paused_count']),
      cancelledCount: JsonParsers.intValue(json['cancelled_count']),
      totalSubs: JsonParsers.intValue(json['total_subs']),
    );
  }
}

/// expiring_soon.list[]
class ExpiringContract {
  final int? contractId;
  final String? contractNumber;
  final String? parentName;
  final String? parentPhone;
  final String? driverName;
  final String? subscriptionType;
  final String? startDate;
  final String? endDate;

  /// عدد الأيام المتبقية كما يرسله الخادم — لا يُحتسب في الواجهة.
  final int? daysLeft;

  const ExpiringContract({
    this.contractId,
    this.contractNumber,
    this.parentName,
    this.parentPhone,
    this.driverName,
    this.subscriptionType,
    this.startDate,
    this.endDate,
    this.daysLeft,
  });

  factory ExpiringContract.fromJson(Map<String, dynamic> json) {
    return ExpiringContract(
      contractId: JsonParsers.optionalInt(json['contract_id']),
      contractNumber: JsonParsers.optionalString(json['contract_number']),
      parentName: JsonParsers.optionalString(json['parent_name']),
      parentPhone: JsonParsers.optionalString(json['parent_phone']),
      driverName: JsonParsers.optionalString(json['driver_name']),
      subscriptionType: JsonParsers.optionalString(json['subscription_type']),
      startDate: JsonParsers.optionalString(json['start_date']),
      endDate: JsonParsers.optionalString(json['end_date']),
      daysLeft: JsonParsers.optionalInt(json['days_left']),
    );
  }

  /// العقد منتهٍ فعلاً حسب ما أرسله الخادم فقط.
  bool get isExpired => daysLeft != null && daysLeft! <= 0;
}

/// expiring_soon
class ExpiringSoonReport {
  final int count;
  final List<ExpiringContract> list;

  const ExpiringSoonReport({required this.count, this.list = const []});

  factory ExpiringSoonReport.fromJson(Map<String, dynamic> json) {
    return ExpiringSoonReport(
      count: JsonParsers.intValue(json['count']),
      list: JsonParsers.listOf(json['list'], ExpiringContract.fromJson),
    );
  }
}

/// GET /api/admin/reports/subscriptions
class SubscriptionsReportModel {
  final ReportDateRange dateRange;
  final SubscriptionTypesBreakdown subscriptionTypes;
  final SubscriptionStatusBreakdown statusBreakdown;
  final ExpiringSoonReport expiringSoon;

  const SubscriptionsReportModel({
    required this.dateRange,
    required this.subscriptionTypes,
    required this.statusBreakdown,
    required this.expiringSoon,
  });

  factory SubscriptionsReportModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionsReportModel(
      dateRange: ReportDateRange.fromJson(
        JsonParsers.mapValue(json['date_range']),
      ),
      subscriptionTypes: SubscriptionTypesBreakdown.fromJson(
        JsonParsers.mapValue(json['subscription_types']),
      ),
      statusBreakdown: SubscriptionStatusBreakdown.fromJson(
        JsonParsers.mapValue(json['status_breakdown']),
      ),
      expiringSoon: ExpiringSoonReport.fromJson(
        JsonParsers.mapValue(json['expiring_soon']),
      ),
    );
  }
}
