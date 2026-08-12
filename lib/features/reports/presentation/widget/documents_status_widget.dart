import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/drivers_performance_report_model.dart';
import 'reports_ui.dart';

/// حالة رخص ووثائق المركبات.
/// `is_expired` و`days_left` يأتيان من الخادم ولا يُحتسبان محلياً.
class DocumentsStatusWidget extends StatelessWidget {
  final VehiclesDocumentsStatus status;

  const DocumentsStatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ReportSectionTitle(
            title: 'حالة وثائق المركبات',
            icon: Icons.badge_rounded,
          ),
          const SizedBox(height: 14),
          ReportMetricsGrid(
            minCardWidth: 175,
            cards: [
              ReportMetricCard(
                title: 'إجمالي المركبات',
                value: AdminFormat.count(status.totalVehicles),
                icon: Icons.directions_bus_rounded,
              ),
              ReportMetricCard(
                title: 'رخص سارية',
                value: AdminFormat.count(status.validLicenses),
                icon: Icons.verified_rounded,
                accent: context.successColor,
              ),
              ReportMetricCard(
                title: 'قاربت على الانتهاء',
                value: AdminFormat.count(status.expiringSoonLicenses),
                icon: Icons.timer_outlined,
                accent: status.expiringSoonLicenses > 0
                    ? context.warningColor
                    : context.successColor,
              ),
              ReportMetricCard(
                title: 'رخص منتهية',
                value: AdminFormat.count(status.expiredLicenses),
                icon: Icons.dangerous_rounded,
                accent: status.expiredLicenses > 0
                    ? context.dangerColor
                    : context.successColor,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const ReportSectionTitle(
            title: 'سائقون بوثائق تحتاج تجديداً',
            icon: Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 12),
          if (status.expiringDriversList.isEmpty)
            const ReportSectionEmpty(
              message: 'لا يوجد سائقون بوثائق منتهية أو قاربت على الانتهاء.',
              icon: Icons.verified_user_outlined,
            )
          else
            for (final driver in status.expiringDriversList)
              _ExpiringDriverTile(driver: driver),
        ],
      ),
    );
  }
}

class _ExpiringDriverTile extends StatelessWidget {
  final ExpiringDriverDocument driver;

  const _ExpiringDriverTile({required this.driver});

  @override
  Widget build(BuildContext context) {
    final accent =
        driver.isExpired ? context.dangerColor : context.warningColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: driver.isExpired ? context.dangerBg : context.warningBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: driver.isExpired
              ? context.dangerBorder
              : context.warningBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            driver.isExpired
                ? Icons.dangerous_rounded
                : Icons.access_time_rounded,
            size: 18,
            color: accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AdminFormat.orDash(driver.name),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    if (driver.phone != null) driver.phone!,
                    'انتهاء الرخصة: ${AdminFormat.orDash(driver.licenseExpiry)}',
                  ].join('  •  '),
                  style: TextStyle(fontSize: 10.5, color: context.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            driver.isExpired
                ? 'منتهية'
                : (driver.daysLeft == null
                    ? '—'
                    : 'متبقٍ ${AdminFormat.count(driver.daysLeft)} يوم'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
