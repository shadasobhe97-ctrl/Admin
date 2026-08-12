import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/trips_report_model.dart';
import 'reports_ui.dart';

/// ملخّص إنجاز الرحلات — النسب تأتي محسوبة من الخادم.
class TripsCompletionWidget extends StatelessWidget {
  final TripsCompletionSummary summary;

  const TripsCompletionWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReportMetricsGrid(
          minCardWidth: 200,
          cards: [
            ReportMetricCard(
              title: 'إجمالي الرحلات',
              value: AdminFormat.count(summary.totalTrips),
              icon: Icons.summarize_rounded,
            ),
            ReportMetricCard(
              title: 'مكتملة',
              value: AdminFormat.count(summary.completedTrips),
              icon: Icons.check_circle_rounded,
              accent: context.successColor,
            ),
            ReportMetricCard(
              title: 'ملغاة',
              value: AdminFormat.count(summary.cancelledTrips),
              icon: Icons.cancel_rounded,
              accent: context.dangerColor,
            ),
            ReportMetricCard(
              title: 'قيد التنفيذ',
              value: AdminFormat.count(summary.inProgressTrips),
              icon: Icons.pending_actions_rounded,
              accent: context.infoColor,
            ),
            ReportMetricCard(
              title: 'مجدولة',
              value: AdminFormat.count(summary.scheduledTrips),
              icon: Icons.event_available_rounded,
              accent: context.warningColor,
            ),
          ],
        ),
        const SizedBox(height: 18),
        AdminPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReportSectionTitle(
                title: 'معدّلات الإنجاز والإلغاء',
                icon: Icons.percent_rounded,
              ),
              const SizedBox(height: 12),
              ReportProgressRow(
                label: 'معدّل الإنجاز',
                percentage: summary.completionRatePercentage,
                color: context.successColor,
              ),
              ReportProgressRow(
                label: 'معدّل الإلغاء',
                percentage: summary.cancellationRatePercentage,
                color: context.dangerColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
