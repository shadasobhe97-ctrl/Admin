import 'package:flutter/material.dart';

import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/financial_report_model.dart';
import 'reports_ui.dart';

/// توزيع عمليات شحن المحافظ حسب وسيلة الدفع.
/// النِسَب تأتي جاهزة من `percentage` ولا تُحسب هنا.
class RechargeBreakdownWidget extends StatelessWidget {
  final RechargeReport report;

  const RechargeBreakdownWidget({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final breakdown = report.paymentMethodsBreakdown;
    final palette = reportSeriesColors(context);

    return AdminPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ReportSectionTitle(
            title: 'شحن المحافظ',
            icon: Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(height: 14),
          AdminInfoRow(
            label: 'إجمالي المبالغ المشحونة',
            value: AdminFormat.money(report.totalRecharged),
            emphasized: true,
          ),
          const SizedBox(height: 10),
          if (breakdown.isEmpty)
            const ReportSectionEmpty(
              message: 'لا توجد عمليات شحن في هذه الفترة.',
              icon: Icons.credit_card_off_rounded,
            )
          else
            for (var index = 0; index < breakdown.length; index++)
              ReportProgressRow(
                label: '${AdminFormat.orDash(breakdown[index].paymentMethod)}'
                    '  •  ${AdminFormat.count(breakdown[index].count)} عملية',
                percentage: breakdown[index].percentage,
                valueLabel:
                    '${AdminFormat.money(breakdown[index].totalAmount)}'
                    '  (${formatPercentage(breakdown[index].percentage)})',
                color: palette[index % palette.length],
              ),
        ],
      ),
    );
  }
}
