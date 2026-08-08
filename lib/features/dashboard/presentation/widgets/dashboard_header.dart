import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/theme/cubit/theme_state.dart';

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
              BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, themeState) {
                  final activeDark = themeState.isDarkMode;
                  return Tooltip(
                    message: activeDark ? 'التحويل للوضع النهاري (Light Mode)' : 'التحويل للوضع الليلي (Dark Mode)',
                    child: InkWell(
                      onTap: () => context.read<ThemeCubit>().toggleTheme(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: activeDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: activeDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              activeDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                              color: activeDark ? Colors.amber : const Color(0xFF2563EB),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              activeDark ? '☀️ نهاري' : '🌙 ليلي',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: activeDark ? Colors.amber : const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
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
