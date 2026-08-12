import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/recharge_model.dart';
import '../../../../core/widgets/admin_ui.dart';

/// عنصر قائمة عمليات شحن محافظ أولياء الأمور.
class RechargeCard extends StatelessWidget {
  final RechargeModel recharge;
  final VoidCallback onOpenDetails;

  const RechargeCard({
    super.key,
    required this.recharge,
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
                  AdminStatusPalette.background(context, recharge.status),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 18,
                color: AdminStatusPalette.color(context, recharge.status),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recharge.parentName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '#${recharge.id}'
                    '  •  ${AdminFormat.orDash(recharge.paymentMethod)}'
                    '  •  ${AdminFormat.orDash(recharge.referenceNumber)}'
                    '  •  ${AdminFormat.dateTime(recharge.createdAt)}',
                    style: TextStyle(fontSize: 11, color: context.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AdminFormat.money(recharge.amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            AdminStatusChip(status: recharge.status),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: onOpenDetails,
              icon: const Icon(Icons.open_in_new_rounded, size: 15),
              label: const Text('التفاصيل والمعالجة'),
            ),
          ],
        ),
      ),
    );
  }
}
