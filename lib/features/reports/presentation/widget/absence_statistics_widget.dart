import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/trips_report_model.dart';
import 'reports_ui.dart';

/// إحصاءات حضور الطلاب وغياب السائقين.
class AbsenceStatisticsWidget extends StatelessWidget {
  final AbsenceStats stats;

  const AbsenceStatisticsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final student = stats.student;
    final driver = stats.driver;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReportSectionTitle(
                title: 'حضور الطلاب',
                icon: Icons.fact_check_rounded,
                subtitle:
                    'إجمالي السجلات: ${AdminFormat.count(student.totalRecords)}',
              ),
              const SizedBox(height: 14),
              ReportMetricsGrid(
                minCardWidth: 175,
                cards: [
                  ReportMetricCard(
                    title: 'حضور',
                    value: AdminFormat.count(student.presentCount),
                    icon: Icons.how_to_reg_rounded,
                    accent: context.successColor,
                  ),
                  ReportMetricCard(
                    title: 'غياب',
                    value: AdminFormat.count(student.absentCount),
                    icon: Icons.person_off_rounded,
                    accent: context.dangerColor,
                  ),
                  ReportMetricCard(
                    title: 'غياب بعذر',
                    value: AdminFormat.count(student.excusedCount),
                    icon: Icons.assignment_turned_in_rounded,
                    accent: context.infoColor,
                  ),
                  ReportMetricCard(
                    title: 'غياب بدون عذر',
                    value: AdminFormat.count(student.unexcusedCount),
                    icon: Icons.report_problem_rounded,
                    accent: context.warningColor,
                  ),
                ],
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
                title: 'غياب وإلغاءات السائقين',
                icon: Icons.no_transfer_rounded,
              ),
              const SizedBox(height: 14),
              ReportMetricsGrid(
                minCardWidth: 200,
                cards: [
                  ReportMetricCard(
                    title: 'إلغاءات السائقين',
                    value:
                        AdminFormat.count(driver.driverCancellationsCount),
                    icon: Icons.cancel_schedule_send_rounded,
                    accent: driver.driverCancellationsCount > 0
                        ? context.warningColor
                        : context.successColor,
                  ),
                  ReportMetricCard(
                    title: 'حالات غياب السائقين',
                    value: AdminFormat.count(driver.driverAbsencesCount),
                    icon: Icons.person_off_outlined,
                    accent: driver.driverAbsencesCount > 0
                        ? context.dangerColor
                        : context.successColor,
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
