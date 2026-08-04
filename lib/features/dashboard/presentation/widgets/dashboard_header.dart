import 'package:flutter/material.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/admin_theme_context.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = StorageService.getUserName() ?? 'المسؤول';
    final roleId = StorageService.getRoleId();
    final roleName = roleId == 1 ? 'أدمن' : (roleId == 2 ? 'مشرف' : 'مستخدم');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      color: context.surfaceColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً بك، $userName 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'الصلاحية: $roleName',
                style: TextStyle(
                  fontSize: 14,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: context.primaryColor.withValues(alpha: 0.1),
            child: Icon(Icons.person, color: context.primaryColor),
          ),
        ],
      ),
    );
  }
}
