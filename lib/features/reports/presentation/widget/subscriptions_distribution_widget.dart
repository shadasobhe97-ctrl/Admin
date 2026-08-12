import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/subscriptions_report_model.dart';
import 'reports_ui.dart';

/// توزيع أنواع الاشتراكات وحالاتها.
/// كل النسب تأتي من الخادم ولا يُعاد حسابها في الواجهة.
class SubscriptionsDistributionWidget extends StatelessWidget {
  final SubscriptionTypesBreakdown types;
  final SubscriptionStatusBreakdown statuses;

  const SubscriptionsDistributionWidget({
    super.key,
    required this.types,
    required this.statuses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReportSectionTitle(
                title: 'أنواع الاشتراكات',
                icon: Icons.pie_chart_rounded,
                subtitle:
                    'إجمالي العقود: ${AdminFormat.count(types.totalContracts)}',
              ),
              const SizedBox(height: 14),
              if (!types.hasContracts)
                const ReportSectionEmpty(
                  message: 'لا توجد عقود مسجّلة في هذه الفترة.',
                  icon: Icons.description_outlined,
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 620;
                    final chart = _TypesPieChart(types: types);
                    final rows = _TypesRows(types: types);

                    if (!isWide) {
                      return Column(
                        children: [chart, const SizedBox(height: 16), rows],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 220, child: chart),
                        const SizedBox(width: 24),
                        Expanded(child: rows),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AdminPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReportSectionTitle(
                title: 'حالات الاشتراكات',
                icon: Icons.toggle_on_rounded,
              ),
              const SizedBox(height: 14),
              ReportMetricsGrid(
                minCardWidth: 175,
                cards: [
                  ReportMetricCard(
                    title: 'إجمالي الاشتراكات',
                    value: AdminFormat.count(statuses.totalSubs),
                    icon: Icons.summarize_rounded,
                  ),
                  ReportMetricCard(
                    title: 'نشطة',
                    value: AdminFormat.count(statuses.activeCount),
                    icon: Icons.play_circle_rounded,
                    accent: context.successColor,
                  ),
                  ReportMetricCard(
                    title: 'موقوفة مؤقتاً',
                    value: AdminFormat.count(statuses.pausedCount),
                    icon: Icons.pause_circle_rounded,
                    accent: context.warningColor,
                  ),
                  ReportMetricCard(
                    title: 'ملغاة',
                    value: AdminFormat.count(statuses.cancelledCount),
                    icon: Icons.cancel_rounded,
                    accent: context.dangerColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TypesPieChart extends StatelessWidget {
  final SubscriptionTypesBreakdown types;

  const _TypesPieChart({required this.types});

  @override
  Widget build(BuildContext context) {
    final sections = <PieChartSectionData>[
      if (types.monthlyPercentage > 0)
        _section(context, types.monthlyPercentage, context.primaryColor),
      if (types.dailyPercentage > 0)
        _section(context, types.dailyPercentage, context.successColor),
      if (types.bothPercentage > 0)
        _section(context, types.bothPercentage, context.warningColor),
    ];

    if (sections.isEmpty) {
      return const ReportSectionEmpty(
        message: 'لم يُرسل الخادم نسباً لرسم التوزيع.',
        icon: Icons.pie_chart_outline_rounded,
      );
    }

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 46,
          sections: sections,
        ),
      ),
    );
  }

  PieChartSectionData _section(
    BuildContext context,
    double value,
    Color color,
  ) {
    return PieChartSectionData(
      value: value,
      title: formatPercentage(value),
      color: color,
      radius: 46,
      titleStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: context.onPrimary,
      ),
    );
  }
}

class _TypesRows extends StatelessWidget {
  final SubscriptionTypesBreakdown types;

  const _TypesRows({required this.types});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReportProgressRow(
          label: 'شهري',
          percentage: types.monthlyPercentage,
          valueLabel: '${AdminFormat.count(types.monthlyCount)} عقد '
              '(${formatPercentage(types.monthlyPercentage)})',
          color: context.primaryColor,
        ),
        ReportProgressRow(
          label: 'يومي',
          percentage: types.dailyPercentage,
          valueLabel: '${AdminFormat.count(types.dailyCount)} عقد '
              '(${formatPercentage(types.dailyPercentage)})',
          color: context.successColor,
        ),
        ReportProgressRow(
          label: 'مشترك (شهري ويومي)',
          percentage: types.bothPercentage,
          valueLabel: '${AdminFormat.count(types.bothCount)} عقد '
              '(${formatPercentage(types.bothPercentage)})',
          color: context.warningColor,
        ),
      ],
    );
  }
}
