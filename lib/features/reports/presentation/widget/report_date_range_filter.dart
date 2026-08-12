import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';

/// اختيار نطاق تاريخ مخصّص يُرسل كـ `date_from` و`date_to`.
/// الطرفان معاً أو لا شيء — الخادم يتوقعهما مجتمعين.
class ReportDateRangeFilter extends StatelessWidget {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool enabled;
  final void Function(DateTime from, DateTime to) onRangeSelected;
  final VoidCallback onCleared;

  const ReportDateRangeFilter({
    super.key,
    this.dateFrom,
    this.dateTo,
    required this.onRangeSelected,
    required this.onCleared,
    this.enabled = true,
  });

  bool get _hasRange => dateFrom != null && dateTo != null;

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: _hasRange
          ? DateTimeRange(start: dateFrom!, end: dateTo!)
          : null,
      builder: (dialogContext, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
    );

    if (picked != null) onRangeSelected(picked.start, picked.end);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: enabled ? () => _pickRange(context) : null,
          icon: const Icon(Icons.date_range_rounded, size: 16),
          label: Text(
            _hasRange
                ? '${AdminFormat.queryDate(dateFrom!)}  ←  ${AdminFormat.queryDate(dateTo!)}'
                : 'نطاق تاريخ مخصّص',
            style: const TextStyle(fontSize: 11.5),
          ),
        ),
        if (_hasRange) ...[
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'إلغاء النطاق المخصّص',
            onPressed: enabled ? onCleared : null,
            icon: Icon(
              Icons.close_rounded,
              size: 17,
              color: context.dangerColor,
            ),
          ),
        ],
      ],
    );
  }
}
