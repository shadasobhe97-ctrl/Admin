import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/subscriptions_report_model.dart';
import 'reports_ui.dart';

/// العقود القريبة من الانتهاء.
/// `days_left` يأتي من الخادم ولا يُحتسب في الواجهة.
class ExpiringSubscriptionsWidget extends StatelessWidget {
  final ExpiringSoonReport report;

  const ExpiringSubscriptionsWidget({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportSectionTitle(
            title: 'اشتراكات على وشك الانتهاء',
            icon: Icons.timer_outlined,
            subtitle: '${AdminFormat.count(report.count)} عقد',
            trailing: report.count > 0
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.warningBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.warningBorder),
                    ),
                    child: Text(
                      'يحتاج متابعة',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: context.warningColor,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 14),
          if (report.list.isEmpty)
            const ReportSectionEmpty(
              message: 'لا توجد عقود على وشك الانتهاء حالياً.',
              icon: Icons.event_available_rounded,
            )
          else
            for (final contract in report.list)
              _ExpiringContractTile(contract: contract),
        ],
      ),
    );
  }
}

class _ExpiringContractTile extends StatelessWidget {
  final ExpiringContract contract;

  const _ExpiringContractTile({required this.contract});

  @override
  Widget build(BuildContext context) {
    final daysLeft = contract.daysLeft;
    final isExpired = contract.isExpired;

    final accent = isExpired
        ? context.dangerColor
        : (daysLeft != null && daysLeft <= 7
            ? context.warningColor
            : context.infoColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AdminFormat.orDash(contract.contractNumber),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withValues(alpha: 0.4)),
                ),
                child: Text(
                  daysLeft == null
                      ? 'المدة غير محددة'
                      : (isExpired
                          ? 'منتهٍ'
                          : 'متبقٍ ${AdminFormat.count(daysLeft)} يوم'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 18,
            runSpacing: 6,
            children: [
              _Meta(
                icon: Icons.family_restroom_rounded,
                text: AdminFormat.orDash(contract.parentName),
              ),
              if (contract.parentPhone != null)
                _Meta(
                  icon: Icons.phone_rounded,
                  text: contract.parentPhone!,
                ),
              _Meta(
                icon: Icons.directions_bus_rounded,
                text: AdminFormat.orDash(contract.driverName),
              ),
              _Meta(
                icon: Icons.category_rounded,
                text: AdminFormat.orDash(contract.subscriptionType),
              ),
              _Meta(
                icon: Icons.date_range_rounded,
                text: '${AdminFormat.orDash(contract.startDate)}'
                    '  ←  ${AdminFormat.orDash(contract.endDate)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: context.textTertiary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: context.textMuted),
        ),
      ],
    );
  }
}
