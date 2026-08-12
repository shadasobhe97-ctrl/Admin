import '../../../../core/utils/json_parsers.dart';

/// النطاق الزمني الذي طبّقه الخادم فعلياً على التقرير.
class ReportDateRange {
  final String? dateFrom;
  final String? dateTo;
  final String? period;

  const ReportDateRange({this.dateFrom, this.dateTo, this.period});

  factory ReportDateRange.fromJson(Map<String, dynamic> json) {
    return ReportDateRange(
      dateFrom: JsonParsers.optionalString(json['date_from']),
      dateTo: JsonParsers.optionalString(json['date_to']),
      period: JsonParsers.optionalString(json['period']),
    );
  }

  String? get label {
    if (dateFrom == null && dateTo == null) return null;
    return '${dateFrom ?? '—'}  ←  ${dateTo ?? '—'}';
  }
}

/// نقطة واحدة على الرسم البياني للإيرادات (revenue_summary.chart_data[]).
class RevenueChartPoint {
  final String period;
  final double platformCommission;
  final double driverEarnings;
  final double totalVolume;

  const RevenueChartPoint({
    required this.period,
    required this.platformCommission,
    required this.driverEarnings,
    required this.totalVolume,
  });

  factory RevenueChartPoint.fromJson(Map<String, dynamic> json) {
    return RevenueChartPoint(
      period: JsonParsers.stringValue(json['period']),
      platformCommission:
          JsonParsers.doubleValue(json['platform_commission']),
      driverEarnings: JsonParsers.doubleValue(json['driver_earnings']),
      totalVolume: JsonParsers.doubleValue(json['total_volume']),
    );
  }
}

/// revenue_summary
class RevenueSummary {
  final double platformCommission;
  final double driverEarnings;
  final double totalVolume;

  /// قد تصل فارغة، فتُعرض حالة "لا توجد بيانات للرسم" بدل توليد بيانات.
  final List<RevenueChartPoint> chartData;

  const RevenueSummary({
    required this.platformCommission,
    required this.driverEarnings,
    required this.totalVolume,
    this.chartData = const [],
  });

  factory RevenueSummary.fromJson(Map<String, dynamic> json) {
    return RevenueSummary(
      platformCommission:
          JsonParsers.doubleValue(json['platform_commission']),
      driverEarnings: JsonParsers.doubleValue(json['driver_earnings']),
      totalVolume: JsonParsers.doubleValue(json['total_volume']),
      chartData: JsonParsers.listOf(
        json['chart_data'],
        RevenueChartPoint.fromJson,
      ),
    );
  }

  bool get hasChartData => chartData.isNotEmpty;
}

/// recharge_report.payment_methods_breakdown[]
class PaymentMethodBreakdown {
  final String? paymentMethod;
  final int count;
  final double totalAmount;
  final double percentage;

  const PaymentMethodBreakdown({
    this.paymentMethod,
    required this.count,
    required this.totalAmount,
    required this.percentage,
  });

  factory PaymentMethodBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentMethodBreakdown(
      paymentMethod: JsonParsers.optionalString(json['payment_method']),
      count: JsonParsers.intValue(json['count']),
      totalAmount: JsonParsers.doubleValue(json['total_amount']),
      percentage: JsonParsers.doubleValue(json['percentage']),
    );
  }
}

/// recharge_report
class RechargeReport {
  final double totalRecharged;
  final List<PaymentMethodBreakdown> paymentMethodsBreakdown;

  const RechargeReport({
    required this.totalRecharged,
    this.paymentMethodsBreakdown = const [],
  });

  factory RechargeReport.fromJson(Map<String, dynamic> json) {
    return RechargeReport(
      totalRecharged: JsonParsers.doubleValue(json['total_recharged']),
      paymentMethodsBreakdown: JsonParsers.listOf(
        json['payment_methods_breakdown'],
        PaymentMethodBreakdown.fromJson,
      ),
    );
  }
}

/// withdrawal_report
class WithdrawalReport {
  final double processedAmount;
  final double pendingAmount;
  final int processedCount;
  final int pendingCount;

  const WithdrawalReport({
    required this.processedAmount,
    required this.pendingAmount,
    required this.processedCount,
    required this.pendingCount,
  });

  factory WithdrawalReport.fromJson(Map<String, dynamic> json) {
    return WithdrawalReport(
      processedAmount: JsonParsers.doubleValue(json['processed_amount']),
      pendingAmount: JsonParsers.doubleValue(json['pending_amount']),
      processedCount: JsonParsers.intValue(json['processed_count']),
      pendingCount: JsonParsers.intValue(json['pending_count']),
    );
  }
}

/// disputes_report
class DisputesReport {
  final int totalDisputes;
  final int openDisputes;
  final int resolvedRefundedCount;
  final int resolvedDriverCount;

  const DisputesReport({
    required this.totalDisputes,
    required this.openDisputes,
    required this.resolvedRefundedCount,
    required this.resolvedDriverCount,
  });

  factory DisputesReport.fromJson(Map<String, dynamic> json) {
    return DisputesReport(
      totalDisputes: JsonParsers.intValue(json['total_disputes']),
      openDisputes: JsonParsers.intValue(json['open_disputes']),
      resolvedRefundedCount:
          JsonParsers.intValue(json['resolved_refunded_count']),
      resolvedDriverCount: JsonParsers.intValue(json['resolved_driver_count']),
    );
  }
}

/// GET /api/admin/reports/financial
class FinancialReportModel {
  final ReportDateRange dateRange;
  final RevenueSummary revenueSummary;
  final RechargeReport rechargeReport;
  final WithdrawalReport withdrawalReport;
  final DisputesReport disputesReport;

  const FinancialReportModel({
    required this.dateRange,
    required this.revenueSummary,
    required this.rechargeReport,
    required this.withdrawalReport,
    required this.disputesReport,
  });

  factory FinancialReportModel.fromJson(Map<String, dynamic> json) {
    return FinancialReportModel(
      dateRange: ReportDateRange.fromJson(
        JsonParsers.mapValue(json['date_range']),
      ),
      revenueSummary: RevenueSummary.fromJson(
        JsonParsers.mapValue(json['revenue_summary']),
      ),
      rechargeReport: RechargeReport.fromJson(
        JsonParsers.mapValue(json['recharge_report']),
      ),
      withdrawalReport: WithdrawalReport.fromJson(
        JsonParsers.mapValue(json['withdrawal_report']),
      ),
      disputesReport: DisputesReport.fromJson(
        JsonParsers.mapValue(json['disputes_report']),
      ),
    );
  }
}
