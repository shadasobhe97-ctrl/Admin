import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/driver_details_model.dart';

/// شريط إحصاءات السائق: التقييم، الرحلات المكتملة، نسبة الاستمرارية،
/// وآخر تحديث للموقع.
class DriverStatisticsRow extends StatelessWidget {
  final DriverStatistics statistics;
  final DriverLocation? location;

  const DriverStatisticsRow({
    super.key,
    required this.statistics,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      if (statistics.ratingAvg != null)
        _StatTile(
          icon: Icons.star_rounded,
          label: 'متوسط التقييم',
          value: statistics.ratingAvg!.toStringAsFixed(1),
        ),
      if (statistics.completedTripsCount != null)
        _StatTile(
          icon: Icons.route_rounded,
          label: 'رحلات مكتملة',
          value: '${statistics.completedTripsCount}',
        ),
      if (statistics.retentionRate != null)
        _StatTile(
          icon: Icons.trending_up_rounded,
          label: 'نسبة الاستمرارية',
          value: '${statistics.retentionRate!.toStringAsFixed(0)}%',
        ),
      _StatTile(
        icon: Icons.location_on_outlined,
        label: 'آخر موقع',
        value: location?.hasPosition == true
            ? '${location!.lat!.toStringAsFixed(3)}, '
                '${location!.lng!.toStringAsFixed(3)}'
            : 'غير متوفر',
      ),
    ];

    if (tiles.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: tiles,
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.primaryColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: context.primaryColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: context.textTertiary),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
