import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/financial_report_model.dart';
import 'reports_ui.dart';

/// ملخّص طلبات السحب المعالَجة والمعلّقة.
class WithdrawalReportWidget extends StatelessWidget {
  final WithdrawalReport report;

  const WithdrawalReportWidget({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ReportSectionTitle(
            title: 'طلبات سحب الأرباح',
            icon: Icons.account_balance_rounded,
          ),
          const SizedBox(height: 14),
          ReportMetricsGrid(
            minCardWidth: 190,
            cards: [
              ReportMetricCard(
                title: 'المبالغ المصروفة',
                value: AdminFormat.money(report.processedAmount),
                icon: Icons.check_circle_rounded,
                accent: context.successColor,
                subtitle:
                    '${AdminFormat.count(report.processedCount)} طلب معالَج',
              ),
              ReportMetricCard(
                title: 'المبالغ المعلّقة',
                value: AdminFormat.money(report.pendingAmount),
                icon: Icons.hourglass_bottom_rounded,
                accent: report.pendingCount > 0
                    ? context.warningColor
                    : context.successColor,
                subtitle:
                    '${AdminFormat.count(report.pendingCount)} طلب بانتظار المعالجة',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
