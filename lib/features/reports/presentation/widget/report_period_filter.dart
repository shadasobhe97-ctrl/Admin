import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/report_filters.dart';

/// أزرار اختيار الفترة الزمنية بالقيم التي يقبلها الخادم فقط.
class ReportPeriodFilter extends StatelessWidget {
  final String selected;
  final bool enabled;
  final ValueChanged<String> onSelect;

  const ReportPeriodFilter({
    super.key,
    required this.selected,
    required this.onSelect,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final period in ReportPeriod.all)
          _PeriodChip(
            label: ReportPeriod.label(period),
            isSelected: selected == period,
            enabled: enabled,
            onTap: () => onSelect(period),
          ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? context.primaryColor : context.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? context.primaryColor : context.borderSoft,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? context.onPrimary : context.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
