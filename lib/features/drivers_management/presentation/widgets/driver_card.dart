import 'package:flutter/material.dart';
import '../../data/models/driver_model.dart';
import 'driver_avatar.dart';
import 'driver_status_badge.dart';

class DriverCard extends StatelessWidget {
  final DriverModel driver;
  final VoidCallback onTapInspect;
  final Function(String action, String? reason)? onReviewAction;

  /// تعديل سريع لبيانات السائق — يظهر للسائقين قيد الانتظار فقط.
  final VoidCallback? onTapEdit;

  const DriverCard({
    super.key,
    required this.driver,
    required this.onTapInspect,
    this.onReviewAction,
    this.onTapEdit,
  });

  bool get _isPending =>
      driver.status.toLowerCase() == 'pending' ||
      driver.approvalStatus?.toLowerCase() == 'pending';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: theme.cardColor,
      elevation: isDark ? 0 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                DriverAvatar(
                  avatarUrl: driver.avatarUrl,
                  fullName: driver.fullName,
                  radius: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.fullName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'الهاتف: ${driver.phoneNumber}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                DriverStatusBadge(status: driver.status),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: theme.dividerColor),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'معرّف السائق: #${driver.id}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onTapEdit != null && _isPending) ...[
                      IconButton(
                        onPressed: onTapEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                        tooltip: 'تعديل بيانات السائق',
                      ),
                      const SizedBox(width: 4),
                    ],
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: onTapInspect,
                      icon: const Icon(Icons.badge_outlined, size: 16),
                      label: const Text('فحص الوثائق والتفعيل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
