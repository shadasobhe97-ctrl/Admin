import 'package:flutter/material.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../../../../core/utils/admin_theme_context.dart';

class StatsCardsWidget extends StatelessWidget {
  final DashboardStatsModel stats;

  const StatsCardsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 2;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.5,
          children: [
            _buildStatCard(
              context,
              'إجمالي المستخدمين',
              stats.totalUsers.toString(),
              Icons.people,
              Colors.blue,
            ),
            _buildStatCard(
              context,
              'السائقين النشطين',
              stats.activeDrivers.toString(),
              Icons.drive_eta,
              Colors.orange,
            ),
            _buildStatCard(
              context,
              'الاشتراكات النشطة',
              stats.activeSubscriptions.toString(),
              Icons.card_membership,
              Colors.green,
            ),
            _buildStatCard(
              context,
              'الرحلات الحية',
              stats.activeTrips.toString(),
              Icons.map,
              Colors.redAccent,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
