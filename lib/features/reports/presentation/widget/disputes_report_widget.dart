import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/financial_report_model.dart';
import 'reports_ui.dart';

/// ملخّص النزاعات المالية خلال الفترة.
class DisputesReportWidget extends StatelessWidget {
  final DisputesReport report;

  const DisputesReportWidget({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ReportSectionTitle(
            title: 'النزاعات المالية',
            icon: Icons.gavel_rounded,
          ),
          const SizedBox(height: 14),
          ReportMetricsGrid(
            minCardWidth: 175,
            cards: [
              ReportMetricCard(
                title: 'إجمالي النزاعات',
                value: AdminFormat.count(report.totalDisputes),
                icon: Icons.summarize_rounded,
              ),
              ReportMetricCard(
                title: 'نزاعات مفتوحة',
                value: AdminFormat.count(report.openDisputes),
                icon: Icons.error_outline_rounded,
                accent: report.openDisputes > 0
                    ? context.dangerColor
                    : context.successColor,
              ),
              ReportMetricCard(
                title: 'حُلّت بتعويض ولي الأمر',
                value: AdminFormat.count(report.resolvedRefundedCount),
                icon: Icons.reply_rounded,
                accent: context.infoColor,
              ),
              ReportMetricCard(
                title: 'حُلّت بصرف مبلغ السائق',
                value: AdminFormat.count(report.resolvedDriverCount),
                icon: Icons.local_shipping_rounded,
                accent: context.successColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
