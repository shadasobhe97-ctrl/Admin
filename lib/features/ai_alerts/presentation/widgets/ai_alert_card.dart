import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/ai_alert_model.dart';
import '../../logic/cubit/ai_alerts_cubit.dart';
import 'ai_alert_severity_badge.dart';
import 'ai_explainability_modal.dart';
import 'ai_reset_confirmation_dialog.dart';

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
    final theme = Theme.of(context);
    final cubit = context.read<AiAlertsCubit>();

    final driverName = alert.displayDriverName;
    final driverPhone = alert.displayDriverPhone;
    final driverId = alert.driverId;

    return Card(
      elevation: 0,
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: alert.isCritical
              ? const Color(0xFFFCA5A5)
              : theme.dividerColor,
        ),
      ),
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
                      fontSize: 14.5,
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.directions_bus_outlined,
                    size: 14, color: context.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$driverName ${driverPhone.isNotEmpty ? "($driverPhone)" : ""}',
                    style: TextStyle(
                      fontSize: 12.5,
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
            if (alert.precautionaryTo != null && alert.precautionaryTo!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 13, color: Color(0xFFDC2626)),
                  const SizedBox(width: 4),
                  Text(
                    'حجب وقائي ينتهي في: ${alert.precautionaryTo}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ],
            if (alert.createdAt != null && alert.createdAt!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                alert.createdAt!,
                style: TextStyle(fontSize: 11, color: context.textTertiary),
              ),
            ],
            const SizedBox(height: 12),
            Divider(height: 1, color: theme.dividerColor),
            const SizedBox(height: 10),

            // ── الأزرار والإجراءات ─────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    AiExplainabilityModal.show(context, alert: alert);
                  },
                  icon: const Icon(Icons.analytics_outlined, size: 15),
                  label: const Text(
                    'فحص الأدلة والتفسير',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                ),
                if (!alert.isResolved)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF059669),
                      side: const BorderSide(color: Color(0xFF059669)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      cubit.resolveAlert(alert.id);
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded,
                        size: 15),
                    label: const Text(
                      'تسوية التنبيه',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                if (driverId != null && driverId > 0)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      AiResetConfirmationDialog.show(
                        context,
                        driverId: driverId,
                        driverName: driverName,
                        onConfirm: () {
                          cubit.resetDriverAi(driverId);
                        },
                      );
                    },
                    icon: const Icon(Icons.published_with_changes_rounded,
                        size: 15),
                    label: const Text(
                      'إعادة التأهيل ورفع الحجب',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
