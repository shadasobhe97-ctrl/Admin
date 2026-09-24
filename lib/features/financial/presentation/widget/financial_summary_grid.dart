import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/financial_summary_model.dart';
import 'financial_summary_card.dart';
import '../../../../core/widgets/admin_ui.dart';

/// شبكة مؤشّرات الملخّص المالي.
/// كل القيم مصدرها [FinancialSummaryModel] القادم من الخادم — لا أرقام ثابتة.
class FinancialSummaryGrid extends StatelessWidget {
  final FinancialSummaryModel summary;
  final VoidCallback? onWithdrawalsTap;

  const FinancialSummaryGrid({
    super.key,
    required this.summary,
    this.onWithdrawalsTap,
  });

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      FinancialSummaryCard(
        title: 'أرباح السائقين المعلّقة',
        value: AdminFormat.money(summary.driverPendingPool),
        icon: Icons.hourglass_bottom_rounded,
        accentColor: context.warningColor,
        subtitle: 'DRIVER_PENDING_POOL',
      ),
      FinancialSummaryCard(
        title: 'أرباح السائقين المتاحة',
        value: AdminFormat.money(summary.driverAvailablePool),
        icon: Icons.account_balance_wallet_rounded,
        accentColor: context.successColor,
        subtitle: 'DRIVER_AVAILABLE_POOL',
      ),
      FinancialSummaryCard(
        title: 'إيرادات المنصة',
        value: AdminFormat.money(summary.platformRevenuePool),
        icon: Icons.trending_up_rounded,
        accentColor: context.primaryColor,
        subtitle: 'PLATFORM_REVENUE_POOL',
      ),
      FinancialSummaryCard(
        title: 'طلبات السحب المعلّقة',
        value: AdminFormat.count(summary.pendingWithdrawalsCount),
        icon: Icons.outbox_rounded,
        accentColor: context.warningColor,
        subtitle: 'بانتظار معالجة المشرف',
        onTap: onWithdrawalsTap,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1280
            ? 4
            : constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 600
                    ? 2
                    : 1;
        const spacing = 12.0;
        final cardWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards)
              SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
}
