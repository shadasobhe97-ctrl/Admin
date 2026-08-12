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
  final VoidCallback? onRechargesTap;
  final VoidCallback? onDisputesTap;
  final VoidCallback? onEscrowsTap;

  const FinancialSummaryGrid({
    super.key,
    required this.summary,
    this.onWithdrawalsTap,
    this.onRechargesTap,
    this.onDisputesTap,
    this.onEscrowsTap,
  });

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      FinancialSummaryCard(
        title: 'أمانات أولياء الأمور',
        value: AdminFormat.money(summary.parentsEscrowPool),
        icon: Icons.savings_rounded,
        accentColor: context.infoColor,
        subtitle: 'PARENTS_ESCROW_POOL',
      ),
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
        title: 'صندوق الغرامات',
        value: AdminFormat.money(summary.penaltyPool),
        icon: Icons.gavel_rounded,
        accentColor: context.dangerColor,
        subtitle: 'PENALTY_POOL',
      ),
      FinancialSummaryCard(
        title: 'طلبات السحب المعلّقة',
        value: AdminFormat.count(summary.pendingWithdrawalsCount),
        icon: Icons.outbox_rounded,
        accentColor: context.warningColor,
        subtitle: 'بانتظار معالجة المشرف',
        onTap: onWithdrawalsTap,
      ),
      FinancialSummaryCard(
        title: 'طلبات الشحن المعلّقة',
        value: AdminFormat.count(summary.pendingRechargesCount),
        icon: Icons.move_to_inbox_rounded,
        accentColor: context.infoColor,
        subtitle: 'محافظ أولياء الأمور',
        onTap: onRechargesTap,
      ),
      FinancialSummaryCard(
        title: 'النزاعات المعلّقة',
        value: AdminFormat.count(summary.pendingDisputesCount),
        icon: Icons.report_problem_rounded,
        accentColor: context.dangerColor,
        subtitle: 'بانتظار الحل',
        onTap: onDisputesTap,
      ),
      FinancialSummaryCard(
        title: 'الأمانات المعلّقة',
        value: AdminFormat.count(summary.pendingEscrowsCount),
        icon: Icons.lock_clock_rounded,
        accentColor: context.warningColor,
        subtitle: 'بانتظار التحرير',
        onTap: onEscrowsTap,
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
