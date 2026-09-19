import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';

/// شارة مستوى الخطورة: تعتمد على `alert_type` (متوفر دوماً بالقائمة
/// والتفاصيل) وليس على `severity` (قد تغيب في استجابة التفاصيل).
class AiAlertSeverityBadge extends StatelessWidget {
  final String riskLevel; // 'CRITICAL' | 'HIGH'
  final bool isCritical;
  final bool isCompact;

  const AiAlertSeverityBadge({
    super.key,
    required this.riskLevel,
    required this.isCritical,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isCritical ? context.dangerBg : context.warningBg;
    final fg = isCritical ? context.dangerColor : context.warningColor;
    final border = isCritical ? context.dangerBorder : context.warningBorder;
    final icon = isCritical ? Icons.dangerous_rounded : Icons.warning_amber_rounded;

    final label = switch (riskLevel.toUpperCase()) {
      'CRITICAL' => 'خطر حرج',
      'HIGH' => 'خطر مرتفع',
      _ => riskLevel,
    };

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

/// شارة حالة التنبيه (تم الحل / قيد المتابعة).
class AiAlertResolvedBadge extends StatelessWidget {
  final bool isResolved;

  const AiAlertResolvedBadge({super.key, required this.isResolved});

  @override
  Widget build(BuildContext context) {
    final bg = isResolved ? context.successBg : context.surfaceVariant;
    final fg = isResolved ? context.successColor : context.textMuted;
    final label = isResolved ? 'تم الحل' : 'قيد المتابعة';
    final icon = isResolved ? Icons.check_circle_rounded : Icons.hourglass_top_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
          ),
        ],
      ),
    );
  }
}
