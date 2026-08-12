import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/withdrawal_model.dart';
import '../../../../core/widgets/admin_ui.dart';

/// عنصر قائمة طلبات سحب الأرباح. لا يعرض إلا ما ورد من الخادم.
class WithdrawalCard extends StatelessWidget {
  final WithdrawalModel withdrawal;
  final VoidCallback onOpenDetails;

  const WithdrawalCard({
    super.key,
    required this.withdrawal,
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
                  AdminStatusPalette.background(context, withdrawal.status),
              child: Icon(
                Icons.account_balance_rounded,
                size: 18,
                color: AdminStatusPalette.color(context, withdrawal.status),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    withdrawal.driverName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '#${withdrawal.id}'
                    '  •  ${AdminFormat.orDash(withdrawal.driverPhone)}'
                    '  •  ${AdminFormat.dateTime(withdrawal.createdAt)}',
                    style: TextStyle(fontSize: 11, color: context.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AdminFormat.money(withdrawal.amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            AdminStatusChip(status: withdrawal.status),
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
