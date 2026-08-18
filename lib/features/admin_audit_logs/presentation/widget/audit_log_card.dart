import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/audit_log_model.dart';
import 'audit_result_chip.dart';

/// سطر واحد في سجل الإجراءات.
/// يعرض: مَن · ماذا · على مَن · متى — والتفاصيل الكاملة عند الضغط.
class AuditLogCard extends StatelessWidget {
  final AuditLogModel log;
  final VoidCallback onTap;

  const AuditLogCard({super.key, required this.log, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: context.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: context.borderSoft),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          log.actionLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        AuditGroupChip(actionGroup: log.actionGroup),
                        if (log.hasResult) AuditResultChip(result: log.result),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_left_rounded,
                    size: 20,
                    color: context.textTertiary,
                  ),
                ],
              ),
              const SizedBox(height: 9),

              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  _Meta(
                    icon: Icons.person_rounded,
                    text: log.adminName,
                    emphasized: true,
                  ),
                  _Meta(
                    icon: Icons.adjust_rounded,
                    text: '${log.entityTypeLabel}: ${log.entityDescription}',
                  ),
                  _Meta(
                    icon: Icons.schedule_rounded,
                    text: AdminFormat.dateTime(log.createdAt),
                  ),
                ],
              ),

              // ملخّص التغييرات يظهر مباشرة دون فتح التفاصيل.
              if (log.hasChanges) ...[
                const SizedBox(height: 9),
                _ChangesSummary(log: log),
              ],

              if (log.hasReason) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 13,
                      color: context.textTertiary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        log.reason!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: context.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// أسماء الحقول المتغيّرة، مع عدّاد لما زاد عن ثلاثة.
class _ChangesSummary extends StatelessWidget {
  final AuditLogModel log;

  const _ChangesSummary({required this.log});

  static const int _visibleLimit = 3;

  @override
  Widget build(BuildContext context) {
    final visible = log.changes.take(_visibleLimit).toList();
    final remaining = log.changes.length - visible.length;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final change in visible)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: context.infoBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: context.infoBorder),
            ),
            child: Text(
              change.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: context.infoColor,
              ),
            ),
          ),
        if (remaining > 0)
          Text(
            '+$remaining حقول أخرى',
            style: TextStyle(fontSize: 10.5, color: context.textTertiary),
          ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool emphasized;

  const _Meta({
    required this.icon,
    required this.text,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: context.textTertiary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: emphasized ? FontWeight.bold : FontWeight.normal,
            color: emphasized ? context.textSecondary : context.textMuted,
          ),
        ),
      ],
    );
  }
}
