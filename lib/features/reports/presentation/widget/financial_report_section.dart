import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/financial_report_model.dart';
import 'disputes_report_widget.dart';
import 'recharge_breakdown_widget.dart';
import 'reports_ui.dart';
import 'revenue_chart.dart';
import 'withdrawal_report_widget.dart';

/// المحتوى الكامل للتقرير المالي، مركّب من الأقسام الفرعية.
class FinancialReportSection extends StatelessWidget {
  final FinancialReportModel report;

  const FinancialReportSection({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final revenue = report.revenueSummary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (report.dateRange.label != null) ...[
          Row(
            children: [
              Icon(
                Icons.event_rounded,
                size: 15,
                color: context.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'النطاق المطبّق: ${report.dateRange.label}',
                style: TextStyle(fontSize: 11.5, color: context.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],

        ReportMetricsGrid(
          cards: [
            ReportMetricCard(
              title: 'عمولة المنصة',
              value: AdminFormat.money(revenue.platformCommission),
              icon: Icons.account_balance_wallet_rounded,
              accent: context.primaryColor,
            ),
            ReportMetricCard(
              title: 'أرباح السائقين',
              value: AdminFormat.money(revenue.driverEarnings),
              icon: Icons.directions_bus_rounded,
              accent: context.successColor,
            ),
            ReportMetricCard(
              title: 'إجمالي حجم التعاملات',
              value: AdminFormat.money(revenue.totalVolume),
              icon: Icons.trending_up_rounded,
              accent: context.infoColor,
            ),
          ],
        ),
        const SizedBox(height: 18),

        AdminPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReportSectionTitle(
                title: 'منحنى الإيرادات',
                icon: Icons.stacked_line_chart_rounded,
              ),
              const SizedBox(height: 14),
              RevenueChart(chartData: revenue.chartData),
            ],
          ),
        ),
        const SizedBox(height: 18),

        RechargeBreakdownWidget(report: report.rechargeReport),
        const SizedBox(height: 18),

        WithdrawalReportWidget(report: report.withdrawalReport),
        const SizedBox(height: 18),

        DisputesReportWidget(report: report.disputesReport),
      ],
    );
  }
}
