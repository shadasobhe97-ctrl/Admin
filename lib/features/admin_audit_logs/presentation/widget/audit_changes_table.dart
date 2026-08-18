import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/audit_log_model.dart';

/// جدول «الحقل | قبل | بعد» — جوهر السجل في إجراءات التعديل.
class AuditChangesTable extends StatelessWidget {
  final List<AuditChangeModel> changes;

  const AuditChangesTable({super.key, required this.changes});

  @override
  Widget build(BuildContext context) {
    if (changes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(),
        const SizedBox(height: 6),
        for (final change in changes) _ChangeRow(change: change),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.bold,
      color: context.textMuted,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('الحقل', style: style)),
          Expanded(flex: 4, child: Text('القيمة السابقة', style: style)),
          const SizedBox(width: 22),
          Expanded(flex: 4, child: Text('القيمة الجديدة', style: style)),
        ],
      ),
    );
  }
}

class _ChangeRow extends StatelessWidget {
  final AuditChangeModel change;

  const _ChangeRow({required this.change});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              change.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: _Value(
              value: change.oldValue,
              // القيمة السابقة تُعرض بلون التحذير لأنها لم تعد سارية.
              color: change.isAddition ? context.textTertiary : context.dangerColor,
              strikethrough: !change.isAddition && change.oldValue != null,
              placeholder: 'لا توجد',
            ),
          ),
          SizedBox(
            width: 22,
            child: Icon(
              Icons.arrow_back_rounded,
              size: 15,
              color: context.textTertiary,
            ),
          ),
          Expanded(
            flex: 4,
            child: _Value(
              value: change.newValue,
              color: change.isRemoval ? context.textTertiary : context.successColor,
              placeholder: 'حُذفت',
            ),
          ),
        ],
      ),
    );
  }
}

class _Value extends StatelessWidget {
  final String? value;
  final Color color;
  final bool strikethrough;
  final String placeholder;

  const _Value({
    required this.value,
    required this.color,
    required this.placeholder,
    this.strikethrough = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == null || value!.isEmpty;

    return Text(
      isEmpty ? placeholder : value!,
      style: TextStyle(
        fontSize: 12,
        fontWeight: isEmpty ? FontWeight.normal : FontWeight.w600,
        fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
        color: isEmpty ? context.textTertiary : color,
        decoration: strikethrough ? TextDecoration.lineThrough : null,
        decorationColor: color,
      ),
    );
  }
}
