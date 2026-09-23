import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/ai_decision_audit_model.dart';
import 'ai_explainability_modal.dart';

class AiAuditCard extends StatelessWidget {
  final AiDecisionAuditModel audit;
  final VoidCallback? onResetDriver;

  const AiAuditCard({
    super.key,
    required this.audit,
    this.onResetDriver,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color badgeBg;
    Color badgeText;

    switch (audit.decisionCode) {
      case DecisionCode.adminReviewRequired:
      case DecisionCode.permanentSuspension:
        badgeBg = isDark
            ? const Color(0xFF881337).withValues(alpha: 0.4)
            : const Color(0xFFFFF1F2);
        badgeText = isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48);
        break;
      case DecisionCode.formalWarning:
      case DecisionCode.moderateViolation:
        badgeBg = isDark
            ? const Color(0xFF78350F).withValues(alpha: 0.4)
            : const Color(0xFFFFFBEB);
        badgeText = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
        break;
      case DecisionCode.reward:
        badgeBg = isDark
            ? const Color(0xFF065F46).withValues(alpha: 0.4)
            : const Color(0xFFECFDF5);
        badgeText = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
        break;
      case DecisionCode.noAction:
        badgeBg = isDark
            ? const Color(0xFF334155).withValues(alpha: 0.4)
            : const Color(0xFFF1F5F9);
        badgeText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        break;
    }

    final confidencePercent = (audit.confidence * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: badgeText.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      audit.decisionCode.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: badgeText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'نسبة الثقة: $confidencePercent%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.textTertiary,
                    ),
                  ),
                ],
              ),
              if (audit.createdAt != null)
                Text(
                  audit.createdAt!,
                  style: TextStyle(fontSize: 11.5, color: context.textTertiary),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'السائق: ',
                style:
                    TextStyle(fontSize: 13, color: context.textTertiary),
              ),
              Text(
                audit.driverName ?? 'سائق غير معرف',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              if (audit.driverPhone != null &&
                  audit.driverPhone!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '(${audit.driverPhone})',
                  style: TextStyle(fontSize: 12, color: context.textTertiary),
                ),
              ],
            ],
          ),
          if (audit.reviewComment != null &&
              audit.reviewComment!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'السبب / ملاحظة ولي الأمر: ${audit.reviewComment!}',
              style: TextStyle(fontSize: 12.5, color: context.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Divider(height: 1, color: theme.dividerColor),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  AiExplainabilityModal.show(context, audit: audit);
                },
                icon: const Icon(Icons.analytics_outlined, size: 15),
                label: const Text(
                  'فحص الأدلة والتفسير',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
