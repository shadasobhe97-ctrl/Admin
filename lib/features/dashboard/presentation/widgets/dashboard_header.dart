import 'package:flutter/material.dart';

import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/widgets/remote_circle_avatar.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = StorageService.getUserName() ?? 'المسؤول';
    final roleId = StorageService.getRoleId();
    final roleName = roleId == 1 ? 'أدمن' : (roleId == 2 ? 'مشرف' : 'مستخدم');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      color: Theme.of(context).cardColor,
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
                  color: Theme.of(context).textTheme.headlineLarge?.color ?? AdminColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'الصلاحية: $roleName',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color ?? AdminColors.grey,
                ),
              ),
            ],
          ),
          Row(
            children: [
              ValueListenableBuilder<String?>(
                valueListenable: StorageService.avatarUrlListenable,
                builder: (context, avatarUrl, _) => RemoteCircleAvatar(
                  rawUrl: avatarUrl,
                  radius: 20,
                  initials: userName.trim().isEmpty ? null : userName.trim()[0],
                  foregroundColor: AdminColors.brandPrimary,
                  backgroundColor:
                      AdminColors.brandPrimary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
