import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../Auth/logic/admin_auth_cubit.dart';

class ResponsiveSidebar extends StatelessWidget {
  const ResponsiveSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    return Container(
      width: 250,
      color: context.surfaceColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Image.asset(
              isDark ? 'assets/images/admindark_logo.png' : 'assets/images/adminligth_logo.png',
              height: 60,
              errorBuilder: (_, __, ___) => Icon(Icons.admin_panel_settings, size: 60, color: context.primaryColor),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(context, 'الرئيسية', Icons.dashboard, true),
                _buildNavItem(context, 'السائقين', FontAwesomeIcons.car, false),
                _buildNavItem(context, 'المدارس والمناطق', Icons.school, false),
                _buildNavItem(context, 'الشكاوى', Icons.report_problem, false),
                _buildNavItem(context, 'المالية', Icons.attach_money, false),
              ],
            ),
          ),
          const Divider(),
          _buildThemeToggle(context, isDark),
          _buildLogoutButton(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, bool isActive) {
    final color = isActive ? context.primaryColor : context.colorScheme.onSurface.withValues(alpha: 0.7);
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        // Handle navigation
      },
      selected: isActive,
      selectedTileColor: context.primaryColor.withValues(alpha: 0.1),
    );
  }

  Widget _buildThemeToggle(BuildContext context, bool isDark) {
    return ListTile(
      leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      title: const Text('المظهر'),
      trailing: Switch(
        value: isDark,
        onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
        activeColor: context.primaryColor,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.redAccent),
      title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent)),
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تسجيل الخروج'),
            content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('خروج'),
              ),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          await context.read<AdminAuthCubit>().logout();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      },
    );
  }
}
