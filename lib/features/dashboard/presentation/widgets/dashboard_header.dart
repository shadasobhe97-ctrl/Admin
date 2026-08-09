import 'package:flutter/material.dart';
import '../../../../core/services/storage_service.dart';

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
                  color: Theme.of(context).textTheme.headlineLarge?.color ?? Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'الصلاحية: $roleName',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                ),
              ),
            ],
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: Color(0xFF2563EB)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
