import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';
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
import '../../../financial/presentation/screens/financial_cashout_screen.dart';
import '../../../treasury/presentation/screens/treasury_ledger_screen.dart';
import '../../../reports/presentation/screens/analytical_reports_screen.dart';
import '../../../profile/presentation/screen/admin_profile_screen.dart';

class DerbiMainDashboard extends StatefulWidget {
  const DerbiMainDashboard({super.key});

  @override
  State<DerbiMainDashboard> createState() => _DerbiMainDashboardState();
}

class _DerbiMainDashboardState extends State<DerbiMainDashboard> {
  int _selectedTabIndex = 0;
  late String _adminName;
  late String _roleName;

  @override
  void initState() {
    super.initState();
    _adminName = StorageService.getUserName() ?? 'الآدمن الرئيسي';
    _roleName = StorageService.getRoleName() ?? 'مدير النظام';
  }

  final List<NavigationItem> _navItems = [
    NavigationItem('dashboard', 'الرئيسية والمتابعة الحية', Icons.dashboard_rounded, badge: 0),
    NavigationItem('drivers', 'إدارة السائقين', Icons.directions_bus_rounded, badge: 0),
    NavigationItem('updates', 'طلبات تعديل بيانات السائقين', Icons.sync_rounded, badge: 3),
    NavigationItem('admins', 'إدارة المشرفين', Icons.admin_panel_settings_rounded, badge: 0),
    NavigationItem('schools', 'إدارة المدارس', Icons.school_rounded, badge: 0),
    NavigationItem('zones', 'المناطق والجغرافيا', Icons.map_rounded, badge: 0),
    NavigationItem('complaints', 'الشكاوى والبلاغات', Icons.support_agent_rounded, badge: 2),
    NavigationItem('reviews', 'تقييمات السائقين', Icons.star_rounded, badge: 0),
    NavigationItem('financial', 'المالية والعمليات', Icons.account_balance_wallet_rounded, badge: 5),
    NavigationItem('treasury', 'الخزينة ودفتر الحسابات', Icons.account_balance_rounded, badge: 0),
    NavigationItem('reports', 'التقارير التحليلية', Icons.analytics_rounded, badge: 0),
    NavigationItem('profile', 'الملف الشخصي', Icons.person_rounded, badge: 0),
  ];

  @override
  Widget build(BuildContext context) {
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
                // Brand Header
                Container(
                  height: 65,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: context.sidebarBorder)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: BlocBuilder<ThemeCubit, ThemeState>(
                          builder: (context, themeState) {
                            final isDark = themeState.isDarkMode;
                            return Image.asset(
                              isDark ? 'assets/images/admindark_logo.png' : 'assets/images/adminligth_logo.png',
                              height: 38,
                              alignment: Alignment.centerRight,
                              errorBuilder: (_, __, ___) => Text(
                                'دَربِي Derbi',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: context.textPrimary,
                                ),
                              ),
                            );
                          },
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
                                size: 20,
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
                          trailing: item.badge > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AdminColors.onBrandOverlay
                                        : context.dangerBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${item.badge}',
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

                // Admin Footer Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: context.sidebarBorder)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: context.primaryColor,
                        child: Text(
                          _adminName.isNotEmpty ? _adminName[0] : 'أ',
                          style: TextStyle(color: context.onPrimary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
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
                              style: TextStyle(fontSize: 9, color: context.textMuted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.logout_rounded, color: context.dangerColor, size: 18),
                        onPressed: () => _showLogoutDialog(context),
                      )
                    ],
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                              IconButton(
                                icon: Icon(Icons.notifications_outlined, color: context.textTertiary, size: 20),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('تنبيهات النظام متصلة بالخادم الرئيسي'),
                                      backgroundColor: context.primaryColor,
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(color: context.dangerColor, shape: BoxShape.circle),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: context.successBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: context.successBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(radius: 3, backgroundColor: context.successColor),
                                const SizedBox(width: 6),
                                Text(
                                  'السيرفر متصل (Sanctum Auth)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: context.successColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
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
  }

  Widget _buildCurrentTabScreen(int index) {
    switch (index) {
      case 0:
        return const DashboardOverviewScreen();
      case 1:
        return const DriversScreen();
      case 2:
        return const DriverChangeRequestsScreen();
      case 3:
        return const AdminsScreen();
      case 4:
        return const SchoolsManagementScreen();
      case 5:
        return const ZonesManagementScreen();
      case 6:
        return const ComplaintsSupportView();
      case 7:
        return const DriverReviewsScreen();
      case 8:
        return const FinancialCashoutView();
      case 9:
        return const TreasuryLedgerView();
      case 10:
        return const AnalyticalReportsView();
      case 11:
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