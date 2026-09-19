import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/ai_alert_model.dart';
import 'ai_alert_severity_badge.dart';

class AiAlertCard extends StatelessWidget {
  final AiAlertModel alert;
  final VoidCallback onTap;

  const AiAlertCard({
    super.key,
    required this.alert,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final driver = alert.driver;
    final isHidden = driver?.isTrusted == false;

    return Card(
      elevation: 0,
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: alert.isCritical ? context.dangerBorder : context.borderSoft,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      alert.title.isNotEmpty ? alert.title : 'تنبيه ذكاء اصطناعي',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AiAlertSeverityBadge(
                    riskLevel: alert.riskLevel,
                    isCritical: alert.isCritical,
                    isCompact: true,
                  ),
                ],
              ),
              if (alert.message.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  alert.message,
                  style: TextStyle(fontSize: 12.5, color: context.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              Divider(height: 1, color: context.borderSoft),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.directions_bus_outlined,
                      size: 14, color: context.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      driver?.name ?? 'سائق غير معروف',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AiAlertResolvedBadge(isResolved: alert.isResolved),
                ],
              ),
              if (isHidden) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.visibility_off_rounded,
                        size: 13, color: context.dangerColor),
                    const SizedBox(width: 4),
                    Text(
                      'السائق غير موثوق حالياً — مخفي من البحث',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: context.dangerColor,
                      ),
                    ),
                  ],
                ),
              ],
              if (alert.createdAt != null && alert.createdAt!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  alert.createdAt!,
                  style: TextStyle(fontSize: 10.5, color: context.textMuted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
