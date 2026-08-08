import 'package:flutter/material.dart';
import '../../data/models/admin_model.dart';
import 'admin_avatar.dart';
import 'admin_status_badge.dart';

class AdminCard extends StatelessWidget {
  final AdminModel admin;
  final VoidCallback onTapDetails;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggleStatus;

  const AdminCard({
    super.key,
    required this.admin,
    required this.onTapDetails,
    required this.onEdit,
    required this.onToggleStatus,
  });

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
                AdminAvatar(
                  avatarUrl: admin.avatarUrl,
                  fullName: admin.fullName,
                  radius: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admin.fullName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        admin.roleName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                AdminStatusBadge(isActive: admin.isActive),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: theme.dividerColor),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 15, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    admin.email,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.phone_outlined, size: 15, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Text(
                  admin.phoneNumber,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'الحالة الحالية:',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Switch(
                      value: admin.isActive,
                      onChanged: onToggleStatus,
                      activeThumbColor: const Color(0xFF10B981),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        side: BorderSide(color: theme.dividerColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: onTapDetails,
                      icon: const Icon(Icons.visibility_outlined, size: 14),
                      label: const Text('التفاصيل', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('تعديل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
