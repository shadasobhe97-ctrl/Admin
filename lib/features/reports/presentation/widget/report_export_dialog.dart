import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/report_export_model.dart';
import '../../data/models/report_filters.dart';
import 'report_date_range_filter.dart';
import 'report_period_filter.dart';

/// نتيجة اختيار المستخدم في حوار التصدير.
class ReportExportRequest {
  final String type;
  final String format;
  final ReportFilters filters;

  const ReportExportRequest({
    required this.type,
    required this.format,
    required this.filters,
  });
}

/// حوار إعداد التصدير.
///
/// يعرض فقط الفلاتر التي يدعمها نوع التقرير المختار، ولا ينفّذ أي طلب بنفسه —
/// يعيد الاختيار عبر [Navigator.pop] لتنفّذه الشاشة عبر الـ Cubit.
class ReportExportDialog extends StatefulWidget {
  /// النوع المقترح مسبقاً حسب الشاشة التي فُتح منها الحوار.
  final String initialType;
  final ReportFilters initialFilters;

  const ReportExportDialog({
    super.key,
    required this.initialType,
    required this.initialFilters,
  });

  @override
  State<ReportExportDialog> createState() => _ReportExportDialogState();
}

class _ReportExportDialogState extends State<ReportExportDialog> {
  late String _type;
  late String _format;
  late ReportFilters _filters;
  late final TextEditingController _searchController;
  late final TextEditingController _perPageController;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _format = ReportFormat.defaultFormat;
    _filters = widget.initialFilters;
    _searchController = TextEditingController(text: _filters.search ?? '');
    _perPageController = TextEditingController(
      text: _filters.perPage?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _perPageController.dispose();
    super.dispose();
  }

  void _submit() {
    final perPage = int.tryParse(_perPageController.text.trim());
    final search = _searchController.text.trim();

    Navigator.pop(
      context,
      ReportExportRequest(
        type: _type,
        format: _format,
        filters: _filters.copyWith(
          search: search.isEmpty ? null : search,
          clearSearch: search.isEmpty,
          perPage: perPage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final supportsPeriod = ReportType.supportsPeriod(_type);
    final supportsDriverFilters = ReportType.supportsDriverFilters(_type);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تصدير تقرير',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Label(text: 'نوع التقرير'),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  isExpanded: true,
                  dropdownColor: context.cardColor,
                  style: TextStyle(fontSize: 13, color: context.textPrimary),
                  items: ReportType.all
                      .map(
                        (type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            ReportType.label(type),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _type = value ?? _type),
                ),
                const SizedBox(height: 16),

                _Label(text: 'صيغة الملف'),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final format in ReportFormat.all)
                      ChoiceChip(
                        label: Text(
                          ReportFormat.label(format),
                          style: const TextStyle(fontSize: 12),
                        ),
                        selected: _format == format,
                        onSelected: (_) => setState(() => _format = format),
                      ),
                  ],
                ),

                // الفلاتر الزمنية تظهر فقط للتقارير التي تدعمها في العقد.
                if (supportsPeriod) ...[
                  const SizedBox(height: 8),
                  _Label(text: 'الفترة الزمنية'),
                  ReportPeriodFilter(
                    selected: _filters.period,
                    onSelect: (period) => setState(
                      () => _filters =
                          _filters.copyWith(period: period, clearRange: true),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ReportDateRangeFilter(
                    dateFrom: _filters.dateFrom,
                    dateTo: _filters.dateTo,
                    onRangeSelected: (from, to) => setState(
                      () => _filters =
                          _filters.copyWith(dateFrom: from, dateTo: to),
                    ),
                    onCleared: () => setState(
                      () => _filters = _filters.copyWith(clearRange: true),
                    ),
                  ),
                ],

                // فلاتر السائقين تظهر فقط لتقرير أداء السائقين.
                if (supportsDriverFilters) ...[
                  const SizedBox(height: 8),
                  _Label(text: 'ترتيب النتائج'),
                  DropdownButtonFormField<String>(
                    initialValue: _filters.sortBy,
                    isExpanded: true,
                    dropdownColor: context.cardColor,
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                    items: DriverSortBy.all
                        .map(
                          (sort) => DropdownMenuItem<String>(
                            value: sort,
                            child: Text(
                              DriverSortBy.label(sort),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(
                      () => _filters = _filters.copyWith(sortBy: value),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'بحث (الاسم / البريد / الهاتف)',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _perPageController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 13, color: context.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'عدد السجلات في الصفحة (اختياري)',
                    ),
                  ),
                ],

                if (!supportsPeriod && !supportsDriverFilters) ...[
                  const SizedBox(height: 10),
                  Text(
                    'تقرير مؤشرات الأداء لا يقبل أي فلاتر حسب العقد.',
                    style: TextStyle(fontSize: 11.5, color: context.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              foregroundColor: context.onPrimary,
            ),
            onPressed: _submit,
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('تصدير'),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: context.textSecondary,
        ),
      ),
    );
  }
}

/// يعرض نتيجة التصدير: اسم الملف وحجمه ومعاينة للمحتوى، مع خيارَي
/// الحفظ على الجهاز والنسخ إلى الحافظة.
///
/// الحفظ يُفوَّض عبر [onSave] ولا تعرف هذه الواجهة كيف يُنفَّذ.
class ReportExportResultDialog extends StatelessWidget {
  final ReportExportModel export;
  final VoidCallback? onSave;
  final bool isSaving;

  const ReportExportResultDialog({
    super.key,
    required this.export,
    this.onSave,
    this.isSaving = false,
  });

  static const int _previewCharLimit = 4000;

  @override
  Widget build(BuildContext context) {
    final text = export.asText;
    final preview = text.length > _previewCharLimit
        ? '${text.substring(0, _previewCharLimit)}\n…'
        : text;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 20,
              color: context.successColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'تم تجهيز التقرير',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 620,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AdminInfoRow(label: 'اسم الملف', value: export.fileName),
              AdminInfoRow(label: 'الحجم', value: export.sizeLabel),
              AdminInfoRow(
                label: 'الصيغة',
                value: ReportFormat.label(export.format),
              ),
              if (export.contentType != null)
                AdminInfoRow(
                  label: 'نوع المحتوى',
                  value: export.contentType!,
                ),
              if (export.isCsv)
                AdminInfoRow(
                  label: 'ترميز عربي (BOM)',
                  value: export.hasBom ? 'موجود' : 'غير موجود',
                  valueColor:
                      export.hasBom ? context.successColor : context.warningColor,
                ),
              const SizedBox(height: 14),
              Text(
                'معاينة المحتوى',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 240,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderSoft),
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      preview,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          OutlinedButton.icon(
            onPressed: isSaving
                ? null
                : () async {
                    await Clipboard.setData(ClipboardData(text: text));
                    if (context.mounted) {
                      showAdminSnackBar(
                        context,
                        'تم نسخ محتوى التقرير إلى الحافظة.',
                        isError: false,
                      );
                    }
                  },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('نسخ المحتوى'),
          ),
          if (onSave != null)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: context.onPrimary,
              ),
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.onPrimary,
                      ),
                    )
                  : const Icon(Icons.save_alt_rounded, size: 16),
              label: Text(isSaving ? 'جارٍ الحفظ…' : 'حفظ الملف'),
            ),
        ],
      ),
    );
  }
}
