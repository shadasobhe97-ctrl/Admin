import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/audit_dictionaries.dart';

/// شارة نتيجة الإجراء — لونها مشتق من دلالة النتيجة عبر الثيم لا من قيم ثابتة.
class AuditResultChip extends StatelessWidget {
  final String? result;

  const AuditResultChip({super.key, required this.result});

  Color _foreground(BuildContext context) {
    switch (AuditResult.tone(result)) {
      case AuditResultTone.positive:
        return context.successColor;
      case AuditResultTone.negative:
        return context.dangerColor;
      case AuditResultTone.warning:
        return context.warningColor;
      case AuditResultTone.neutral:
        return context.infoColor;
    }
  }

  Color _background(BuildContext context) {
    switch (AuditResult.tone(result)) {
      case AuditResultTone.positive:
        return context.successBg;
      case AuditResultTone.negative:
        return context.dangerBg;
      case AuditResultTone.warning:
        return context.warningBg;
      case AuditResultTone.neutral:
        return context.infoBg;
    }
  }

  Color _border(BuildContext context) {
    switch (AuditResult.tone(result)) {
      case AuditResultTone.positive:
        return context.successBorder;
      case AuditResultTone.negative:
        return context.dangerBorder;
      case AuditResultTone.warning:
        return context.warningBorder;
      case AuditResultTone.neutral:
        return context.infoBorder;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (result == null || result!.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: _background(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border(context)),
      ),
      child: Text(
        AuditResult.label(result),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _foreground(context),
        ),
      ),
    );
  }
}

/// شارة عائلة الإجراء (قرار / تعديل / عملية).
class AuditGroupChip extends StatelessWidget {
  final String? actionGroup;

  const AuditGroupChip({super.key, required this.actionGroup});

  IconData get _icon {
    switch (actionGroup) {
      case AuditActionGroup.decision:
        return Icons.gavel_rounded;
      case AuditActionGroup.update:
        return Icons.edit_note_rounded;
      case AuditActionGroup.operation:
        return Icons.play_circle_outline_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: context.textTertiary),
          const SizedBox(width: 4),
          Text(
            AuditActionGroup.label(actionGroup),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
