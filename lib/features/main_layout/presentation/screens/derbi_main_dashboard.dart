import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/widgets/remote_circle_avatar.dart';
import '../../../profile/data/repositories/admin_profile_repository.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/theme/cubit/theme_state.dart';
import '../../../Auth/logic/admin_auth_cubit.dart';

import '../../../dashboard/presentation/screens/dashboard_overview_screen.dart';
import '../../../drivers_management/presentation/screens/drivers_screen.dart';
import '../../../drivers_management/presentation/screens/driver_change_requests_screen.dart';
import '../../../drivers_management/presentation/screens/driver_reviews_screen.dart';
import '../../../admin_management/presentation/screens/admins_screen.dart';
import '../../../schools/presentation/screens/schools_management_screen.dart';
import '../../../zones/presentation/screens/zones_management_screen.dart';
import '../../../complaints/presentation/screens/complaints_support_screen.dart';
import '../../../financial/presentation/screen/financial_dashboard_screen.dart';
import '../../../reports/presentation/screen/reports_dashboard_screen.dart';
import '../../../profile/presentation/screen/admin_profile_screen.dart';
import '../../../admin_notifications/logic/cubit/admin_notifications_cubit.dart';
import '../../../admin_notifications/logic/cubit/admin_notifications_state.dart';
import '../../../admin_notifications/presentation/screens/admin_notifications_screen.dart';

class DerbiMainDashboard extends StatefulWidget {
  const DerbiMainDashboard({super.key});

  @override
  State<DerbiMainDashboard> createState() => _DerbiMainDashboardState();
}

class _DerbiMainDashboardState extends State<DerbiMainDashboard> {
  int _selectedTabIndex = 0;
  late String _adminName;
  late String _roleName;
  late List<NavigationItem> _navItems;

  @override
  void initState() {
    super.initState();
    _adminName = StorageService.getUserName() ?? 'الآدمن الرئيسي';
    _roleName = StorageService.getRoleName() ?? 'مدير النظام';
    _ensureAvatarLoaded();

    final roleId = StorageService.getRoleId();
    final isAdmin = roleId == 1;

    _navItems = [
      NavigationItem('profile', 'الملف الشخصي', Icons.person_rounded, badge: 0),
      NavigationItem('dashboard', 'الرئيسية والمتابعة الحية', Icons.dashboard_rounded, badge: 0),
      NavigationItem('notifications', 'إشعارات النظام', Icons.notifications_rounded, badge: 0),
      NavigationItem('drivers', 'إدارة السائقين', Icons.directions_bus_rounded, badge: 0),
      NavigationItem('updates', 'طلبات تعديل بيانات السائقين', Icons.sync_rounded, badge: 3),
      if (isAdmin)
        NavigationItem('admins', 'إدارة المشرفين', Icons.admin_panel_settings_rounded, badge: 0),
      NavigationItem('schools', 'إدارة المدارس', Icons.school_rounded, badge: 0),
      NavigationItem('zones', 'المناطق الجغرافية', Icons.map_rounded, badge: 0),
      NavigationItem('complaints', 'الشكاوى والبلاغات', Icons.support_agent_rounded, badge: 2),
      NavigationItem('reviews', 'تقييمات السائقين', Icons.star_rounded, badge: 0),
      NavigationItem('financial', 'الإدارة المالية والخزينة', Icons.account_balance_wallet_rounded, badge: 0),
      NavigationItem('reports', 'التقارير والتحليلات', Icons.analytics_rounded, badge: 0),
    ];
  }

  /// استجابة تسجيل الدخول لا تحمل صورة الحساب، فتُجلب مرة واحدة من
  /// `/admin/profile` عند أول دخول وتُخزَّن في الجلسة. بعدها يحدّثها
  /// [ProfileCubit] عند كل تعديل، فلا يتكرّر الطلب.
  Future<void> _ensureAvatarLoaded() async {
    if (StorageService.getAvatarUrl() != null) return;

    try {
      final profile = await sl<AdminProfileRepository>().getProfile();
      await StorageService.saveAvatarUrl(profile.avatarUrl);
    } catch (_) {
      // تعذّر الجلب لا يمنع عرض اللوحة — تبقى الأحرف الأولى بديلاً.
    }
  }

  /// الضغط على صورة الحساب ينقل إلى تبويب الملف الشخصي.
  void _openProfileTab() {
    final index = _navItems.indexWhere((item) => item.id == 'profile');
    if (index >= 0) setState(() => _selectedTabIndex = index);
  }

  /// فتح تبويب الإشعارات عند الضغط على جرس الهيدر
  void _openNotificationsTab() {
    final index = _navItems.indexWhere((item) => item.id == 'notifications');
    if (index >= 0) setState(() => _selectedTabIndex = index);
  }

  /// توجيه الإشعار عند الضغط عليه إذا كانت الشاشة موجودة
  void _handleNotificationNavigation(
    String targetScreen,
    Map<String, dynamic>? payload,
    String? entityId,
  ) {
    String? matchedTabId;

    switch (targetScreen.toUpperCase()) {
      case 'ADMIN_COMPLAINT_REVIEW':
      case 'COMPLAINTS':
        matchedTabId = 'complaints';
        break;
      case 'ADMIN_DRIVER_REVIEW':
      case 'DRIVERS':
        matchedTabId = 'drivers';
        break;
      case 'ADMIN_DRIVER_CHANGE':
      case 'UPDATES':
        matchedTabId = 'updates';
        break;
      case 'ADMIN_FINANCIAL':
      case 'FINANCIAL':
        matchedTabId = 'financial';
        break;
      case 'SCHOOLS':
        matchedTabId = 'schools';
        break;
      case 'ZONES':
        matchedTabId = 'zones';
        break;
      case 'REPORTS':
        matchedTabId = 'reports';
        break;
      default:
        matchedTabId = null;
        break;
    }

    if (matchedTabId != null) {
      final index = _navItems.indexWhere((item) => item.id == matchedTabId);
      if (index >= 0) {
        setState(() => _selectedTabIndex = index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminNotificationsCubit>(
      create: (context) => sl<AdminNotificationsCubit>()..fetchUnreadCount(),
      child: BlocBuilder<AdminNotificationsCubit, AdminNotificationsState>(
        builder: (context, notifState) {
          final unreadCount = notifState.unreadCount;

          return Scaffold(
            backgroundColor: context.scaffoldBackgroundColor,
            body: Row(
              children: [
                // Sidebar Navigation
                Container(
                  width: 260,
                  color: context.sidebarBg,
                  child: Column(
                    children: [
                      // Admin Profile Header
                      Container(
                        height: 65,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: context.sidebarBorder)),
                        ),
                        child: Row(
                          children: [
                            ValueListenableBuilder<String?>(
                              valueListenable: StorageService.avatarUrlListenable,
                              builder: (context, avatarUrl, _) => RemoteCircleAvatar(
                                rawUrl: avatarUrl,
                                radius: 16,
                                initials: _adminName.isNotEmpty ? _adminName[0] : 'أ',
                                foregroundColor: context.primaryColor,
                                onTap: _openProfileTab,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _adminName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _roleName,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: context.textMuted,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            BlocBuilder<ThemeCubit, ThemeState>(
                              builder: (context, themeState) {
                                final isDark = themeState.isDarkMode;
                                return Tooltip(
                                  message: isDark ? 'التحويل للوضع النهاري' : 'التحويل للوضع الليلي',
                                  child: IconButton(
                                    onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                                    icon: Icon(
                                      isDark ? Icons.wb_sunny_rounded : Icons.brightness_3_rounded,
                                      color: isDark ? context.warningColor : context.textTertiary,
                                      size: 18,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Navigation Items List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _navItems.length,
                          itemBuilder: (context, index) {
                            final item = _navItems[index];
                            final isSelected = _selectedTabIndex == index;
                            final activeBadge = item.id == 'notifications' ? unreadCount : item.badge;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: ListTile(
                                selected: isSelected,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                selectedTileColor: context.sidebarActiveBg,
                                tileColor: context.transparent,
                                hoverColor: context.sidebarHover,
                                onTap: () => setState(() => _selectedTabIndex = index),
                                leading: Icon(
                                  item.icon,
                                  color: isSelected ? context.onSidebarActive : context.sidebarItemText,
                                  size: 18,
                                ),
                                title: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? context.onSidebarActive : context.sidebarItemText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: activeBadge > 0
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AdminColors.onBrandOverlay
                                              : context.dangerBg,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '$activeBadge',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? context.onSidebarActive : context.dangerColor,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),

                      // Admin Footer (Logout only)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: context.sidebarBorder)),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          tileColor: context.transparent,
                          hoverColor: context.dangerBg.withValues(alpha: 0.1),
                          onTap: () => _showLogoutDialog(context),
                          leading: const Icon(
                            Icons.logout_rounded,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          title: const Text(
                            'تسجيل الخروج',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                VerticalDivider(width: 1, color: context.sidebarBorder),

                // Main Content Area
                Expanded(
                  child: Column(
                    children: [
                      // Top Header Bar
                      Container(
                        height: 65,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: context.headerBg,
                          border: Border(bottom: BorderSide(color: context.sidebarBorder)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _navItems[_selectedTabIndex].title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: context.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Header Notification Icon with Badge
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    unreadCount > 0
                                        ? Icons.notifications_active_rounded
                                        : Icons.notifications_outlined,
                                    color: unreadCount > 0
                                        ? context.primaryColor
                                        : context.textTertiary,
                                    size: 20,
                                  ),
                                  onPressed: _openNotificationsTab,
                                  tooltip: 'مركز الإشعارات',
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: context.dangerColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: context.headerBg, width: 1.5),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Text(
                                        '$unreadCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Active Dynamic Screen Body
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: _buildCurrentTabScreen(_selectedTabIndex),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentTabScreen(int index) {
    if (index < 0 || index >= _navItems.length) {
      return const DashboardOverviewScreen();
    }
    final itemId = _navItems[index].id;
    switch (itemId) {
      case 'dashboard':
        return const DashboardOverviewScreen();
      case 'notifications':
        return AdminNotificationsScreen(
          onNavigateToScreen: _handleNotificationNavigation,
        );
      case 'drivers':
        return const DriversScreen();
      case 'updates':
        return const DriverChangeRequestsScreen();
      case 'admins':
        return const AdminsScreen();
      case 'schools':
        return const SchoolsManagementScreen();
      case 'zones':
        return const ZonesManagementScreen();
      case 'complaints':
        return const ComplaintsSupportView();
      case 'reviews':
        return const DriverReviewsScreen();
      case 'financial':
        return const FinancialDashboardScreen();
      case 'reports':
        return const ReportsDashboardScreen();
      case 'profile':
        return AdminProfileView(
          adminName: _adminName,
          onNameChanged: (newName) => setState(() => _adminName = newName),
        );
      default:
        return const DashboardOverviewScreen();
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: ctx.cardColor,
          title: Text(
            'تأكيد تسجيل الخروج',
            style: TextStyle(color: ctx.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل أنت تأكد من رغبتك في تسجيل الخروج من لوحة تحكم منظومة "دَربِي"؟',
            style: TextStyle(color: ctx.textSecondary, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: TextStyle(color: ctx.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ctx.dangerColor,
                foregroundColor: ctx.onPrimary,
              ),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(context);
                if (ctx.mounted) Navigator.pop(ctx);
                await context.read<AdminAuthCubit>().logout();
                messenger.showSnackBar(
                  SnackBar(
                    content: const Text('تم تسجيل الخروج بنجاح'),
                    backgroundColor: AdminColors.dangerFgLight,
                  ),
                );
                nav.pushReplacementNamed('/login');
              },
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final String id;
  final String title;
  final IconData icon;
  final int badge;

  NavigationItem(this.id, this.title, this.icon, {this.badge = 0});
}