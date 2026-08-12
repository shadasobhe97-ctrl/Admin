import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/kpi_summary_model.dart';
import 'reports_ui.dart';

/// بطاقات مؤشرات الأداء السريعة — كل قيمة تأتي من `GET /reports/kpi-summary`.
class ReportsKpiCards extends StatelessWidget {
  final KpiSummaryModel summary;

  const ReportsKpiCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final users = summary.activeUsers;
    final trips = summary.todayTrips;
    final revenue = summary.monthlyRevenue;
    final alerts = summary.urgentAlerts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ReportSectionTitle(
          title: 'المستخدمون النشطون',
          icon: Icons.groups_rounded,
        ),
        const SizedBox(height: 10),
        ReportMetricsGrid(
          cards: [
            ReportMetricCard(
              title: 'إجمالي المستخدمين',
              value: AdminFormat.count(users.total),
              icon: Icons.people_alt_rounded,
            ),
            ReportMetricCard(
              title: 'أولياء الأمور',
              value: AdminFormat.count(users.parents),
              icon: Icons.family_restroom_rounded,
              accent: context.infoColor,
            ),
            ReportMetricCard(
              title: 'السائقون',
              value: AdminFormat.count(users.drivers),
              icon: Icons.directions_bus_rounded,
              accent: context.successColor,
            ),
            ReportMetricCard(
              title: 'الأطفال',
              value: AdminFormat.count(users.children),
              icon: Icons.child_care_rounded,
              accent: context.warningColor,
            ),
          ],
        ),
        const SizedBox(height: 22),

        const ReportSectionTitle(
          title: 'رحلات اليوم',
          icon: Icons.route_rounded,
        ),
        const SizedBox(height: 10),
        ReportMetricsGrid(
          cards: [
            ReportMetricCard(
              title: 'إجمالي رحلات اليوم',
              value: AdminFormat.count(trips.total),
              icon: Icons.summarize_rounded,
            ),
            ReportMetricCard(
              title: 'مكتملة',
              value: AdminFormat.count(trips.completed),
              icon: Icons.check_circle_rounded,
              accent: context.successColor,
            ),
            ReportMetricCard(
              title: 'قيد التنفيذ',
              value: AdminFormat.count(trips.inProgress),
              icon: Icons.pending_actions_rounded,
              accent: context.infoColor,
            ),
            ReportMetricCard(
              title: 'ملغاة',
              value: AdminFormat.count(trips.cancelled),
              icon: Icons.cancel_rounded,
              accent: context.dangerColor,
            ),
          ],
        ),
        const SizedBox(height: 22),

        ReportSectionTitle(
          title: 'إيرادات الشهر',
          icon: Icons.payments_rounded,
          subtitle: revenue.month == null ? null : 'الشهر: ${revenue.month}',
        ),
        const SizedBox(height: 10),
        ReportMetricsGrid(
          cards: [
            ReportMetricCard(
              title: 'أرباح المنصة',
              value: AdminFormat.money(revenue.platformEarnings),
              icon: Icons.account_balance_wallet_rounded,
              accent: context.successColor,
            ),
            ReportMetricCard(
              title: 'رصيد إيرادات المنصة',
              value: AdminFormat.money(revenue.platformRevenuePool),
              icon: Icons.savings_rounded,
              accent: context.infoColor,
            ),
            ReportMetricCard(
              title: 'إجمالي حجم التعاملات',
              value: AdminFormat.money(revenue.totalVolume),
              icon: Icons.trending_up_rounded,
            ),
          ],
        ),
        const SizedBox(height: 22),

        ReportSectionTitle(
          title: 'تنبيهات عاجلة',
          icon: Icons.priority_high_rounded,
          subtitle: alerts.hasUrgentItems
              ? 'يوجد ${AdminFormat.count(alerts.totalUrgent)} عنصراً بحاجة إلى إجراء'
              : 'لا توجد عناصر عاجلة حالياً',
        ),
        const SizedBox(height: 10),
        ReportMetricsGrid(
          cards: [
            ReportMetricCard(
              title: 'سائقون بانتظار المراجعة',
              value: AdminFormat.count(alerts.pendingDrivers),
              icon: Icons.how_to_reg_rounded,
              accent: alerts.pendingDrivers > 0
                  ? context.warningColor
                  : context.successColor,
            ),
            ReportMetricCard(
              title: 'طلبات سحب معلّقة',
              value: AdminFormat.count(alerts.pendingWithdrawals),
              icon: Icons.account_balance_rounded,
              accent: alerts.pendingWithdrawals > 0
                  ? context.warningColor
                  : context.successColor,
            ),
            ReportMetricCard(
              title: 'نزاعات مفتوحة',
              value: AdminFormat.count(alerts.openDisputes),
              icon: Icons.gavel_rounded,
              accent: alerts.openDisputes > 0
                  ? context.dangerColor
                  : context.successColor,
            ),
            ReportMetricCard(
              title: 'طلبات شحن معلّقة',
              value: AdminFormat.count(alerts.pendingRecharges),
              icon: Icons.account_balance_wallet_outlined,
              accent: alerts.pendingRecharges > 0
                  ? context.warningColor
                  : context.successColor,
            ),
          ],
        ),
      ],
    );
  }
}
