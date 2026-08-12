import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';

/// شريط فلترة بالحالة مشترك بين قوائم السحوبات والشحنات والنزاعات والفواتير.
/// لا يفلتر محلياً — كل تغيير يُعيد الطلب إلى الخادم عبر [onChanged].
class FinancialStatusFilterBar extends StatelessWidget {
  final Map<String, String> options;
  final String? selected;
  final ValueChanged<String?> onChanged;
  final String hint;

  const FinancialStatusFilterBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.hint = 'الفلترة تُنفَّذ على الخادم عبر المعامل status',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('الكل'),
                selected: selected == null,
                onSelected: (_) => onChanged(null),
              ),
              for (final entry in options.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: selected == entry.key,
                  onSelected: (_) => onChanged(entry.key),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          hint,
          style: TextStyle(fontSize: 11, color: context.textMuted),
        ),
      ],
    );
  }
}
