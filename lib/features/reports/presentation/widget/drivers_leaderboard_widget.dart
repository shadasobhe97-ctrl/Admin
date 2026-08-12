import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/drivers_performance_report_model.dart';
import 'reports_ui.dart';

/// جدول ترتيب أداء السائقين.
/// `rank` يأتي من الخادم ولا يُستنتج من موضع العنصر في القائمة.
class DriversLeaderboardWidget extends StatelessWidget {
  final List<DriverLeaderboardEntry> entries;

  const DriversLeaderboardWidget({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const ReportSectionEmpty(
        message: 'لا توجد نتائج مطابقة في ترتيب السائقين.',
        icon: Icons.emoji_events_outlined,
      );
    }

    return Column(
      children: [
        for (final entry in entries) _LeaderboardTile(entry: entry),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final DriverLeaderboardEntry entry;

  const _LeaderboardTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
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
              _RankBadge(rank: entry.rank),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AdminFormat.orDash(entry.name),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (entry.phone != null) entry.phone!,
                        if (entry.email != null) entry.email!,
                      ].join('  •  '),
                      style: TextStyle(
                        fontSize: 10.5,
                        color: context.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (entry.status != null) AdminStatusChip(status: entry.status),
            ],
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 18,
            runSpacing: 7,
            children: [
              _Stat(
                icon: Icons.star_rounded,
                label: 'التقييم',
                value: entry.ratingAvg == null
                    ? '—'
                    : entry.ratingAvg!.toStringAsFixed(1),
                color: context.warningColor,
              ),
              _Stat(
                icon: Icons.route_rounded,
                label: 'رحلات مكتملة',
                value: AdminFormat.count(entry.completedTripsCount),
                color: context.successColor,
              ),
              _Stat(
                icon: Icons.card_membership_rounded,
                label: 'اشتراكات نشطة',
                value: AdminFormat.count(entry.activeSubsCount),
                color: context.infoColor,
              ),
              _Stat(
                icon: Icons.repeat_rounded,
                label: 'نسبة الاستبقاء',
                value: formatPercentage(entry.retentionRate),
                color: context.primaryColor,
              ),
              if (entry.vehiclePlate != null)
                _Stat(
                  icon: Icons.directions_bus_filled_rounded,
                  label: 'لوحة المركبة',
                  value: entry.vehiclePlate!,
                  color: context.textTertiary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int? rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    // الثلاثة الأوائل يُبرزون بلون الإنجاز، وبقية المراتب بلون محايد.
    final isTop = rank != null && rank! <= 3;
    final color = isTop ? context.warningColor : context.textTertiary;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      alignment: Alignment.center,
      child: Text(
        rank == null ? '—' : '#$rank',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 11, color: context.textMuted),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}
