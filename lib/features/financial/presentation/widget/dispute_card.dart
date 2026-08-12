import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/financial_dispute_model.dart';
import '../../../../core/widgets/admin_ui.dart';

/// عنصر قائمة النزاعات المالية.
class DisputeCard extends StatelessWidget {
  final FinancialDisputeModel dispute;
  final VoidCallback onOpenDetails;

  const DisputeCard({
    super.key,
    required this.dispute,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AdminPanel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  AdminStatusPalette.background(context, dispute.status),
              child: Icon(
                Icons.report_problem_rounded,
                size: 18,
                color: AdminStatusPalette.color(context, dispute.status),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نزاع #${dispute.id}'
                    '${dispute.tripId == null ? '' : ' — رحلة #${dispute.tripId}'}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'ولي الأمر: ${AdminFormat.orDash(dispute.parent?.name)}'
                    '  •  السائق: ${AdminFormat.orDash(dispute.driver?.name)}'
                    '  •  ${AdminFormat.dateTime(dispute.createdAt)}',
                    style: TextStyle(fontSize: 11, color: context.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (dispute.reason != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      'السبب: ${dispute.reason}',
                      style:
                          TextStyle(fontSize: 11, color: context.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AdminFormat.money(dispute.amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            AdminStatusChip(status: dispute.status),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: onOpenDetails,
              icon: const Icon(Icons.open_in_new_rounded, size: 15),
              label: const Text('التفاصيل والحل'),
            ),
          ],
        ),
      ),
    );
  }
}
