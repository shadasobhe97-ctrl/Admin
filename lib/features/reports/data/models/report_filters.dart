import '../../../../core/widgets/admin_ui.dart';

/// الفترات الزمنية التي يقبلها الخادم في فلاتر التقارير.
class ReportPeriod {
  const ReportPeriod._();

  static const String today = 'today';
  static const String week = 'week';
  static const String month = 'month';
  static const String year = 'year';

  /// القيمة الافتراضية حسب العقد.
  static const String defaultPeriod = month;

  static const List<String> all = [today, week, month, year];

  static String label(String period) {
    switch (period) {
      case today:
        return 'اليوم';
      case week:
        return 'الأسبوع';
      case month:
        return 'الشهر';
      case year:
        return 'السنة';
      default:
        return period;
    }
  }
}

/// أوجه الفرز المتاحة في تقرير أداء السائقين.
class DriverSortBy {
  const DriverSortBy._();

  static const String trips = 'trips';
  static const String rating = 'rating';
  static const String retention = 'retention';

  static const String defaultSort = trips;

  static const List<String> all = [trips, rating, retention];

  static String label(String sortBy) {
    switch (sortBy) {
      case trips:
        return 'عدد الرحلات';
      case rating:
        return 'التقييم';
      case retention:
        return 'نسبة الاستبقاء';
      default:
        return sortBy;
    }
  }
}

/// أنواع التقارير القابلة للتصدير.
class ReportType {
  const ReportType._();

  static const String kpi = 'kpi';
  static const String financial = 'financial';
  static const String trips = 'trips';
  static const String subscriptions = 'subscriptions';
  static const String drivers = 'drivers';

  static const List<String> all = [kpi, financial, trips, subscriptions, drivers];

  static String label(String type) {
    switch (type) {
      case kpi:
        return 'مؤشرات الأداء (KPI)';
      case financial:
        return 'التقرير المالي';
      case trips:
        return 'تقرير الرحلات';
      case subscriptions:
        return 'تقرير الاشتراكات';
      case drivers:
        return 'أداء السائقين';
      default:
        return type;
    }
  }

  /// التقارير الزمنية تقبل `period` و`date_from` و`date_to`.
  static bool supportsPeriod(String type) =>
      type == financial || type == trips || type == subscriptions;

  /// تقرير السائقين وحده يقبل `search` و`sort_by` و`per_page`.
  static bool supportsDriverFilters(String type) => type == drivers;
}

/// صيغ التصدير المدعومة.
class ReportFormat {
  const ReportFormat._();

  static const String json = 'json';
  static const String csv = 'csv';

  /// القيمة الافتراضية حسب العقد.
  static const String defaultFormat = json;

  static const List<String> all = [json, csv];

  static String label(String format) => format.toUpperCase();
}

/// نموذج موحّد لفلاتر التقارير.
///
/// كل Endpoint يبني استعلامه عبر الدالة المخصّصة له، فلا يُرسل أي باراميتر
/// إلى مسار لا يدعمه في العقد.
class ReportFilters {
  final String period;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? search;
  final String sortBy;
  final int? perPage;
  final int page;

  const ReportFilters({
    this.period = ReportPeriod.defaultPeriod,
    this.dateFrom,
    this.dateTo,
    this.search,
    this.sortBy = DriverSortBy.defaultSort,
    this.perPage,
    this.page = 1,
  });

  /// نطاق تاريخ مخصّص فعّال فقط عند تحديد الطرفين معاً.
  bool get hasCustomRange => dateFrom != null && dateTo != null;

  bool get hasSearch => search != null && search!.trim().isNotEmpty;

  /// استعلام التقارير الزمنية: financial / trips / subscriptions.
  Map<String, dynamic> toPeriodQuery() {
    return <String, dynamic>{
      'period': period,
      if (hasCustomRange) 'date_from': AdminFormat.queryDate(dateFrom!),
      if (hasCustomRange) 'date_to': AdminFormat.queryDate(dateTo!),
    };
  }

  /// استعلام تقرير أداء السائقين.
  Map<String, dynamic> toDriversQuery() {
    return <String, dynamic>{
      'sort_by': sortBy,
      if (hasSearch) 'search': search!.trim(),
      if (perPage != null) 'per_page': perPage,
      'page': page,
    };
  }

  /// استعلام التصدير: يضيف فقط الفلاتر التي يدعمها نوع التقرير المطلوب.
  Map<String, dynamic> toExportQuery({
    required String type,
    required String format,
  }) {
    return <String, dynamic>{
      'type': type,
      'format': format,
      if (ReportType.supportsPeriod(type)) ...toPeriodQuery(),
      if (ReportType.supportsDriverFilters(type)) ...{
        'sort_by': sortBy,
        if (hasSearch) 'search': search!.trim(),
        if (perPage != null) 'per_page': perPage,
      },
    };
  }

  ReportFilters copyWith({
    String? period,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? search,
    String? sortBy,
    int? perPage,
    int? page,
    bool clearRange = false,
    bool clearSearch = false,
  }) {
    return ReportFilters(
      period: period ?? this.period,
      dateFrom: clearRange ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearRange ? null : (dateTo ?? this.dateTo),
      search: clearSearch ? null : (search ?? this.search),
      sortBy: sortBy ?? this.sortBy,
      perPage: perPage ?? this.perPage,
      page: page ?? this.page,
    );
  }
}
