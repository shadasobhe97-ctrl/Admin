import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/drivers_performance_report_model.dart';
import '../../data/models/financial_report_model.dart';
import '../../data/models/kpi_summary_model.dart';
import '../../data/models/report_filters.dart';
import '../../data/models/subscriptions_report_model.dart';
import '../../data/models/trips_report_model.dart';

/// تحميل الخط العربي المدمج مع المشروع لضمان دعم كامل للغة العربية محلياً.
class ReportPdfFonts {
  static pw.Font? _regular;
  static pw.Font? _bold;

  static Future<void> ensureLoaded() async {
    if (_regular != null && _bold != null) return;

    try {
      final regData = await rootBundle.load('lib/fonts/Tajawal-Regular.ttf');
      final boldData = await rootBundle.load('lib/fonts/Tajawal-Bold.ttf');
      _regular = pw.Font.ttf(regData);
      _bold = pw.Font.ttf(boldData);
    } catch (_) {
      try {
        final regFile = File('lib/fonts/Tajawal-Regular.ttf');
        final boldFile = File('lib/fonts/Tajawal-Bold.ttf');
        if (regFile.existsSync()) {
          _regular = pw.Font.ttf(regFile.readAsBytesSync().buffer.asByteData());
          _bold = pw.Font.ttf(boldFile.readAsBytesSync().buffer.asByteData());
        }
      } catch (_) {}
    }
  }

  static pw.Font get regular => _regular ?? pw.Font.helvetica();
  static pw.Font get bold => _bold ?? pw.Font.helveticaBold();
}

/// خدمة توليد تقارير PDF بتصميم منظم واحترافي لجميع أقسام منظومة "دَربِي".
class ReportPdfGenerator {
  const ReportPdfGenerator._();

  static const PdfColor primaryBlue = PdfColor.fromInt(0xFF1E3A8A); // Royal Navy
  static const PdfColor accentCyan = PdfColor.fromInt(0xFF0284C7); // Sky Blue
  static const PdfColor slateDark = PdfColor.fromInt(0xFF0F172A); // Text Primary
  static const PdfColor slateMuted = PdfColor.fromInt(0xFF64748B); // Text Muted
  static const PdfColor cardBg = PdfColor.fromInt(0xFFF8FAFC); // Slate 50
  static const PdfColor borderLight = PdfColor.fromInt(0xFFE2E8F0); // Slate 200
  static const PdfColor successGreen = PdfColor.fromInt(0xFF059669); // Emerald
  static const PdfColor warningAmber = PdfColor.fromInt(0xFFD97706); // Amber
  static const PdfColor dangerRed = PdfColor.fromInt(0xFFDC2626); // Red

  /// توليد بايتات الـ PDF لأي نوع من التقارير.
  static Future<Uint8List> generate({
    required String type,
    required dynamic data,
    required ReportFilters filters,
    String? adminName,
  }) async {
    await ReportPdfFonts.ensureLoaded();

    final pdf = pw.Document();
    final theme = pw.ThemeData.withFont(
      base: ReportPdfFonts.regular,
      bold: ReportPdfFonts.bold,
    );

    final title = ReportType.label(type);
    final nowFormatted = DateFormat('yyyy/MM/dd - hh:mm a', 'ar').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        textDirection: pw.TextDirection.rtl,
        header: (context) => _buildHeader(
          title: title,
          nowFormatted: nowFormatted,
          adminName: adminName,
          filters: filters,
        ),
        footer: (context) => _buildFooter(context),
        build: (context) {
          return [
            pw.SizedBox(height: 12),
            ..._buildContentForType(type: type, data: data),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ── الترويسة الرئيسية ────────────────────────────────────────────────────────
  static pw.Widget _buildHeader({
    required String title,
    required String nowFormatted,
    String? adminName,
    required ReportFilters filters,
  }) {
    String periodText = ReportPeriod.label(filters.period);
    if (filters.dateFrom != null || filters.dateTo != null) {
      final from = filters.dateFrom != null
          ? DateFormat('yyyy/MM/dd').format(filters.dateFrom!)
          : 'البداية';
      final to = filters.dateTo != null
          ? DateFormat('yyyy/MM/dd').format(filters.dateTo!)
          : 'الآن';
      periodText = '$from إلى $to';
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'منظومة دَربِي للنقل المدرسي الذكي',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'لوحة التحكم والإدارة العامة — تقرير رسمي معتمد',
                  style: const pw.TextStyle(fontSize: 10, color: slateMuted),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: pw.BoxDecoration(
                color: cardBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: borderLight),
              ),
              child: pw.Text(
                'DARBY ADMIN REPORTS',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: accentCyan,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          width: double.infinity,
          height: 2,
          color: primaryBlue,
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: cardBg,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.all(color: borderLight),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'نوع التقرير: $title',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: slateDark,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'الفترة الزمنية: $periodText',
                    style: const pw.TextStyle(fontSize: 10, color: slateMuted),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'تاريخ التصدير: $nowFormatted',
                    style: const pw.TextStyle(fontSize: 9.5, color: slateDark),
                  ),
                  if (adminName != null && adminName.isNotEmpty) ...[
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'المشرف: $adminName',
                      style: const pw.TextStyle(fontSize: 9.5, color: slateMuted),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── تذييل الصفحة ────────────────────────────────────────────────────────────
  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 14),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: borderLight, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'وثيقة رسمية داخلية صادرة عن منظومة دَربِي',
            style: const pw.TextStyle(fontSize: 9, color: slateMuted),
          ),
          pw.Text(
            'صفحة ${context.pageNumber} من ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: slateMuted),
          ),
        ],
      ),
    );
  }

  // ── توجيه المحتوى حسب نوع التقرير ─────────────────────────────────────────
  static List<pw.Widget> _buildContentForType({
    required String type,
    required dynamic data,
  }) {
    if (data is FinancialReportModel) {
      return _buildFinancialReport(data);
    } else if (data is TripsReportModel) {
      return _buildTripsReport(data);
    } else if (data is SubscriptionsReportModel) {
      return _buildSubscriptionsReport(data);
    } else if (data is DriversPerformanceReportModel) {
      if (type == ReportType.documents) {
        return _buildDocumentsReport(data);
      }
      return _buildDriversReport(data);
    } else if (data is KpiSummaryModel) {
      return _buildKpiReport(data);
    }
    return [
      pw.Center(
        child: pw.Text(
          'تم استخراج التقرير بنجاح.',
          style: const pw.TextStyle(fontSize: 14),
        ),
      ),
    ];
  }

  // ── 1. التقرير المالي والخزينة ──────────────────────────────────────────────
  static List<pw.Widget> _buildFinancialReport(FinancialReportModel model) {
    return [
      _buildSectionTitle('المؤشرات المالية الرئيسية'),
      pw.Row(
        children: [
          _buildKpiCard(
            label: 'إجمالي حجم التداول',
            value: '${model.revenueSummary.totalVolume.toStringAsFixed(2)} د.ل',
            accent: primaryBlue,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'أرباح السائقين',
            value: '${model.revenueSummary.driverEarnings.toStringAsFixed(2)} د.ل',
            accent: accentCyan,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'عمولة المنصة',
            value: '${model.revenueSummary.platformCommission.toStringAsFixed(2)} د.ل',
            accent: successGreen,
          ),
        ],
      ),
      pw.SizedBox(height: 16),
      _buildSectionTitle('بيانات الشحن وعمليات الدفع الإلكتروني'),
      _buildTable(
        headers: ['#', 'طريقة الدفع', 'عدد العمليات', 'المبلغ الإجمالي', 'النسبة المئوية'],
        rows: model.rechargeReport.paymentMethodsBreakdown.isEmpty
            ? [
                [
                  '1',
                  'إجمالي المبالغ المشحونة',
                  '—',
                  '${model.rechargeReport.totalRecharged.toStringAsFixed(2)} د.ل',
                  '100%'
                ]
              ]
            : model.rechargeReport.paymentMethodsBreakdown.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final item = entry.value;
                return [
                  '$idx',
                  item.paymentMethod ?? 'طريقة دفع غير محددة',
                  '${item.count}',
                  '${item.totalAmount.toStringAsFixed(2)} د.ل',
                  '${item.percentage.toStringAsFixed(1)}%',
                ];
              }).toList(),
      ),
      pw.SizedBox(height: 16),
      _buildSectionTitle('سجل طلبات السحب والنزاعات المالية'),
      pw.Row(
        children: [
          _buildKpiCard(
            label: 'سحوبات منفذة',
            value: '${model.withdrawalReport.processedAmount.toStringAsFixed(2)} د.ل',
            subtext: '${model.withdrawalReport.processedCount} عملية مكتملة',
            accent: successGreen,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'سحوبات معلقة',
            value: '${model.withdrawalReport.pendingAmount.toStringAsFixed(2)} د.ل',
            subtext: '${model.withdrawalReport.pendingCount} طلب قيد الفحص',
            accent: warningAmber,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'النزاعات المالية',
            value: '${model.disputesReport.totalDisputes}',
            subtext: '${model.disputesReport.openDisputes} مفتوح / ${model.disputesReport.resolvedRefundedCount} مسترد',
            accent: dangerRed,
          ),
        ],
      ),
      if (model.revenueSummary.chartData.isNotEmpty) ...[
        pw.SizedBox(height: 16),
        _buildSectionTitle('تفاصيل الإيرادات وحجم التعاملات حسب الفترات الزمنية'),
        _buildTable(
          headers: ['#', 'الفترة الزمنية', 'إجمالي حجم التداول', 'أرباح السائقين', 'عمولة المنصة'],
          rows: model.revenueSummary.chartData.take(30).toList().asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final point = entry.value;
            return [
              '$idx',
              point.period,
              '${point.totalVolume.toStringAsFixed(2)} د.ل',
              '${point.driverEarnings.toStringAsFixed(2)} د.ل',
              '${point.platformCommission.toStringAsFixed(2)} د.ل',
            ];
          }).toList(),
        ),
      ],
    ];
  }

  // ── 2. تقرير الرحلات المدرسية والعمليات ─────────────────────────────────────
  static List<pw.Widget> _buildTripsReport(TripsReportModel model) {
    return [
      _buildSectionTitle('معدلات إنجاز الرحلات المدرسية'),
      pw.Row(
        children: [
          _buildKpiCard(
            label: 'إجمالي الرحلات',
            value: '${model.completionSummary.totalTrips}',
            accent: primaryBlue,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'رحلات مكتملة',
            value: '${model.completionSummary.completedTrips}',
            subtext: '${model.completionSummary.completionRatePercentage.toStringAsFixed(1)}% نسبة النجاح',
            accent: successGreen,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'رحلات ملغاة',
            value: '${model.completionSummary.cancelledTrips}',
            subtext: '${model.completionSummary.cancellationRatePercentage.toStringAsFixed(1)}% نسبة الإلغاء',
            accent: dangerRed,
          ),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        children: [
          _buildKpiCard(
            label: 'رحلات قيد التنفيذ (جارية)',
            value: '${model.completionSummary.inProgressTrips}',
            accent: accentCyan,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'رحلات مجدولة لاحقاً',
            value: '${model.completionSummary.scheduledTrips}',
            accent: warningAmber,
          ),
        ],
      ),
      pw.SizedBox(height: 16),
      _buildSectionTitle('إحصائيات الحضور والغياب للطلاب والسائقين'),
      _buildTable(
        headers: ['#', 'الفئة', 'إجمالي السجلات', 'حضور / مكتمل', 'غياب معتذر', 'غياب غير معتذر'],
        rows: [
          [
            '1',
            'الطلاب',
            '${model.absenceStats.student.totalRecords}',
            '${model.absenceStats.student.presentCount}',
            '${model.absenceStats.student.excusedCount}',
            '${model.absenceStats.student.unexcusedCount}',
          ],
          [
            '2',
            'السائقين',
            '${model.absenceStats.driver.driverCancellationsCount + model.absenceStats.driver.driverAbsencesCount}',
            '—',
            '${model.absenceStats.driver.driverAbsencesCount} غياب',
            '${model.absenceStats.driver.driverCancellationsCount} إلغاء مسار',
          ],
        ],
      ),
      pw.SizedBox(height: 16),
      _buildSectionTitle('أعلى المدارس طلباً في النقل المدرسي'),
      _buildTable(
        headers: ['#', 'اسم المدرسة', 'عدد الطلاب المسجلين', 'الموقع الجغرافي'],
        rows: model.demandHeatmap.topSchools.isEmpty
            ? [
                ['—', 'لا توجد بيانات طلب على المدارس في هذه الفترة', '—', '—']
              ]
            : model.demandHeatmap.topSchools.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final school = entry.value;
                final coords = school.hasCoordinates
                    ? '${school.lat!.toStringAsFixed(4)}, ${school.lng!.toStringAsFixed(4)}'
                    : 'إحداثيات غير مسجلة';
                return [
                  '$index',
                  school.schoolName ?? 'مدرسة',
                  '${school.studentsCount} طالب',
                  coords,
                ];
              }).toList(),
      ),
      pw.SizedBox(height: 16),
      _buildSectionTitle('أعلى المناطق الجغرافية تغطيةً بالسائقين'),
      _buildTable(
        headers: ['#', 'المنطقة الجغرافية', 'عدد السائقين المتوفرين', 'حالة التغطية'],
        rows: model.demandHeatmap.topZones.isEmpty
            ? [
                ['—', 'لا توجد بيانات مناطق مسجلة في هذه الفترة', '—', '—']
              ]
            : model.demandHeatmap.topZones.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final zone = entry.value;
                return [
                  '$index',
                  zone.zoneName ?? 'منطقة',
                  '${zone.driversCount} سائق',
                  zone.driversCount > 0 ? 'مغطاة بنجاح' : 'تحتاج تغطية',
                ];
              }).toList(),
      ),
    ];
  }

  // ── 3. تقرير الاشتراكات والحسابات ──────────────────────────────────────────
  static List<pw.Widget> _buildSubscriptionsReport(SubscriptionsReportModel model) {
    return [
      _buildSectionTitle('حالات وعقود الاشتراكات'),
      pw.Row(
        children: [
          _buildKpiCard(
            label: 'إجمالي العقود',
            value: '${model.statusBreakdown.totalSubs}',
            accent: primaryBlue,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'اشتراكات نشطة',
            value: '${model.statusBreakdown.activeCount}',
            accent: successGreen,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'اشتراكات متوقفة',
            value: '${model.statusBreakdown.pausedCount}',
            accent: warningAmber,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'اشتراكات ملغاة',
            value: '${model.statusBreakdown.cancelledCount}',
            accent: dangerRed,
          ),
        ],
      ),
      pw.SizedBox(height: 16),
      _buildSectionTitle('توزيع باقات وأنواع الاشتراكات'),
      _buildTable(
        headers: ['#', 'نوع الاشتراك', 'عدد العقود', 'النسبة من الإجمالي'],
        rows: [
          ['1', 'اشتراك شهري كامل', '${model.subscriptionTypes.monthlyCount}', '${model.subscriptionTypes.monthlyPercentage.toStringAsFixed(1)}%'],
          ['2', 'اشتراك رحلات يومية', '${model.subscriptionTypes.dailyCount}', '${model.subscriptionTypes.dailyPercentage.toStringAsFixed(1)}%'],
          ['3', 'اشتراك باقة مشتركة', '${model.subscriptionTypes.bothCount}', '${model.subscriptionTypes.bothPercentage.toStringAsFixed(1)}%'],
        ],
      ),
      if (model.expiringSoon.list.isNotEmpty) ...[
        pw.SizedBox(height: 16),
        _buildSectionTitle('عقود قاربت على الانتهاء'),
        _buildTable(
          headers: ['#', 'رقم العقد', 'ولي الأمر', 'الهاتف', 'السائق', 'الأيام المتبقية'],
          rows: model.expiringSoon.list.take(35).toList().asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final contract = entry.value;
            return [
              '$idx',
              contract.contractNumber ?? '—',
              contract.parentName ?? '—',
              contract.parentPhone ?? '—',
              contract.driverName ?? '—',
              '${contract.daysLeft ?? '—'} يوم',
            ];
          }).toList(),
        ),
      ],
    ];
  }

  // ── 4. تقرير أداء السائقين ────────────────────────────────────────────────
  static List<pw.Widget> _buildDriversReport(DriversPerformanceReportModel model) {
    return [
      _buildSectionTitle('مؤشرات تصنيف وأداء السائقين'),
      pw.Row(
        children: [
          _buildKpiCard(
            label: 'إجمالي السائقين المصنفين',
            value: '${model.leaderboard.length}',
            accent: primaryBlue,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'إجمالي الرحلات المكتملة',
            value: '${model.leaderboard.fold<int>(0, (sum, d) => sum + d.completedTripsCount)}',
            accent: successGreen,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'إجمالي العقود النشطة',
            value: '${model.leaderboard.fold<int>(0, (sum, d) => sum + d.activeSubsCount)}',
            accent: accentCyan,
          ),
        ],
      ),
      pw.SizedBox(height: 16),
      _buildSectionTitle('جدول تصنيف ومعدلات أداء السائقين'),
      _buildTable(
        headers: ['#', 'السائق', 'الهاتف', 'رحلات مكتملة', 'اشتراكات', 'التقييم', 'الاستبقاء'],
        rows: model.leaderboard.isEmpty
            ? [
                ['—', 'لا توجد بيانات للسائقين في هذه الفترة', '—', '—', '—', '—', '—']
              ]
            : model.leaderboard.take(50).toList().asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final d = entry.value;
                return [
                  '${d.rank ?? idx}',
                  d.name ?? 'سائق',
                  d.phone ?? '—',
                  '${d.completedTripsCount}',
                  '${d.activeSubsCount}',
                  d.ratingAvg != null ? '${d.ratingAvg!.toStringAsFixed(1)} ★' : '—',
                  d.retentionRate != null ? '${d.retentionRate!.toStringAsFixed(0)}%' : '—',
                ];
              }).toList(),
      ),
    ];
  }

  // ── 4ب. تقرير وثائق وتراخيص المركبات ─────────────────────────────────────────
  static List<pw.Widget> _buildDocumentsReport(DriversPerformanceReportModel model) {
    return [
      _buildSectionTitle('حالة تراخيص ووثائق مركبات الأسطول'),
      pw.Row(
        children: [
          _buildKpiCard(
            label: 'إجمالي المركبات',
            value: '${model.documentsStatus.totalVehicles}',
            accent: primaryBlue,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'تراخيص سارية',
            value: '${model.documentsStatus.validLicenses}',
            accent: successGreen,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'تنتهي قريباً',
            value: '${model.documentsStatus.expiringSoonLicenses}',
            accent: warningAmber,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'تراخيص منتهية',
            value: '${model.documentsStatus.expiredLicenses}',
            accent: dangerRed,
          ),
        ],
      ),
      pw.SizedBox(height: 16),
      _buildSectionTitle('قائمة السائقين وتراخيص المركبات المنتهية أو القريبة من الانتهاء'),
      _buildTable(
        headers: ['#', 'السائق', 'رقم الهاتف', 'تاريخ الانتهاء', 'المتبقي', 'الحالة'],
        rows: model.documentsStatus.expiringDriversList.isEmpty
            ? [
                ['—', 'لا توجد تراخيص أو وثائق منتهية حالياً في الأسطول', '—', '—', '—', 'سارية ومطابقة']
              ]
            : model.documentsStatus.expiringDriversList.take(50).toList().asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final doc = entry.value;
                return [
                  '$idx',
                  doc.name ?? 'سائق',
                  doc.phone ?? '—',
                  doc.licenseExpiry ?? '—',
                  doc.daysLeft != null ? '${doc.daysLeft} يوم' : '—',
                  doc.isExpired ? 'منتهية' : 'تنتهي قريباً',
                ];
              }).toList(),
      ),
    ];
  }

  // ── 5. تقرير مؤشرات الأداء العامة (KPI) ──────────────────────────────────
  static List<pw.Widget> _buildKpiReport(KpiSummaryModel model) {
    return [
      _buildSectionTitle('المستخدمون النشطون في المنظومة'),
      pw.Row(
        children: [
          _buildKpiCard(
            label: 'إجمالي المستخدمين',
            value: '${model.activeUsers.total}',
            accent: primaryBlue,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'أولياء الأمور',
            value: '${model.activeUsers.parents}',
            accent: accentCyan,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'السائقين',
            value: '${model.activeUsers.drivers}',
            accent: successGreen,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'الطلاب المسجلين',
            value: '${model.activeUsers.children}',
            accent: warningAmber,
          ),
        ],
      ),
      pw.SizedBox(height: 16),
      _buildSectionTitle('رحلات اليوم ومؤشرات الإيرادات'),
      pw.Row(
        children: [
          _buildKpiCard(
            label: 'رحلات اليوم المكتملة',
            value: '${model.todayTrips.completed} من ${model.todayTrips.total}',
            accent: successGreen,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'إيرادات الشهر الحالي',
            value: '${model.monthlyRevenue.totalVolume.toStringAsFixed(2)} د.ل',
            accent: primaryBlue,
          ),
          pw.SizedBox(width: 8),
          _buildKpiCard(
            label: 'أرباح المنصة الصافية',
            value: '${model.monthlyRevenue.platformEarnings.toStringAsFixed(2)} د.ل',
            accent: accentCyan,
          ),
        ],
      ),
      pw.SizedBox(height: 16),
      _buildSectionTitle('التنبيهات الإدارية العاجلة'),
      _buildTable(
        headers: ['#', 'نوع التنبيه', 'العدد قيد الانتظار', 'الحالة الإدارية'],
        rows: [
          ['1', 'سائقون بانتظار المراجعة والاعتماد', '${model.urgentAlerts.pendingDrivers}', 'يتطلب تدقيق المستندات'],
          ['2', 'طلبات سحب أرباح معلقة', '${model.urgentAlerts.pendingWithdrawals}', 'تنتظر التحويل المصرفي'],
          ['3', 'نزاعات مالية مفتوحة', '${model.urgentAlerts.openDisputes}', 'تتطلب قرار المشرف'],
          ['4', 'عمليات شحن يدوي معلقة', '${model.urgentAlerts.pendingRecharges}', 'بانتظار التأكيد'],
        ],
      ),
    ];
  }

  // ── عناصر التصميم المساعدة ───────────────────────────────────────────────
  static pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: primaryBlue,
        ),
      ),
    );
  }

  static pw.Widget _buildKpiCard({
    required String label,
    required String value,
    String? subtext,
    required PdfColor accent,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: pw.BoxDecoration(
          color: cardBg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(color: borderLight),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9.5, color: slateMuted),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: accent,
              ),
            ),
            if (subtext != null) ...[
              pw.SizedBox(height: 2),
              pw.Text(
                subtext,
                style: const pw.TextStyle(fontSize: 8, color: slateMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTable({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    // في واجهات اللغة العربية (RTL):
    // الترتيب الطبيعي للقراءة يبدأ من اليمين إلى اليسار.
    // وبما أن pw.Table في مكتبة PDF ترسم خلايا السطر من اليسار إلى اليمين (LTR)،
    // فإن عكس ترتيب عناصر العناوين والصفوف (headers.reversed و row.reversed)
    // يجعل العمود الأول دائماً (# أو المعرّف ID) يظهر في أقصى اليمين،
    // لتتطابق الجداول المطبوعة 100% مع أصول القراءة العربية الصحيحة.
    final rtlHeaders = headers.reversed.toList();

    return pw.Table(
      border: pw.TableBorder.all(color: borderLight, width: 0.5),
      children: [
        // صف العناوين
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: primaryBlue),
          children: rtlHeaders.map((header) {
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: pw.Text(
                header,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 9.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            );
          }).toList(),
        ),
        // صفوف البيانات
        ...rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          final isEven = index % 2 == 0;
          final rtlRow = row.reversed.toList();
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : cardBg,
            ),
            children: rtlRow.map((cell) {
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: pw.Text(
                  cell,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(
                    fontSize: 8.5,
                    color: slateDark,
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
