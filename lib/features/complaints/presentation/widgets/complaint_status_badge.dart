import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';

class ComplaintStatusBadge extends StatelessWidget {
  final String status;
  final bool isCompact;

  const ComplaintStatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        bg = context.warningBg;
        fg = context.warningColor;
        border = context.warningBorder;
        label = 'قيد الانتظار';
        icon = Icons.hourglass_top_rounded;
        break;
      case 'completed':
        bg = context.successBg;
        fg = context.successColor;
        border = context.successBorder;
        label = 'معالجة / مكتملة';
        icon = Icons.check_circle_rounded;
        break;
      case 'dismissed':
        bg = context.surfaceVariant;
        fg = context.textMuted;
        border = context.borderSoft;
        label = 'مرفوضة / متجاهلة';
        icon = Icons.block_rounded;
        break;
      default:
        bg = context.surfaceVariant;
        fg = context.textSecondary;
        border = context.borderSoft;
        label = status;
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 12 : 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class ComplaintActionBadge extends StatelessWidget {
  final String actionTaken;

  const ComplaintActionBadge({
    super.key,
    required this.actionTaken,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (actionTaken.toLowerCase()) {
      case 'warning':
        bg = context.warningBg;
        fg = context.warningColor;
        label = 'إنذار رسمي';
        break;
      case 'suspension':
        bg = context.dangerBg;
        fg = context.dangerColor;
        label = 'إيقاف السائق';
        break;
      case 'dismiss':
      case 'none':
      default:
        bg = context.surfaceVariant;
        fg = context.textMuted;
        label = actionTaken == 'dismiss' ? 'تجاهل الشكوى' : 'بدون إجراء';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
