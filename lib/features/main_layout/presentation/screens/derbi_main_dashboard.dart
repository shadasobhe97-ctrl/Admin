import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/permissions/authorization_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/admin_fcm_service.dart';
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
import '../../../parents_management/presentation/screens/parents_screen.dart';
import '../../../schools/presentation/screens/schools_management_screen.dart';
import '../../../zones/presentation/screens/zones_management_screen.dart';
import '../../../complaints/presentation/screens/complaints_support_screen.dart';
import '../../../financial/presentation/screen/financial_dashboard_screen.dart';
import '../../../reports/presentation/screen/reports_dashboard_screen.dart';
import '../../../profile/presentation/screen/admin_profile_screen.dart';
import '../../../admin_notifications/logic/cubit/admin_notifications_cubit.dart';
import '../../../admin_notifications/logic/cubit/admin_notifications_state.dart';
import '../../../admin_notifications/presentation/screens/admin_notifications_screen.dart';
import '../../../admin_notifications/presentation/widgets/in_app_notification_banner.dart';
import '../../../ai_alerts/presentation/screens/ai_alerts_screen.dart';

class DerbiMainDashboard extends StatefulWidget {
  const DerbiMainDashboard({super.key});

  @override
  State<DerbiMainDashboard> createState() => _DerbiMainDashboardState();
}

class _DerbiMainDashboardState extends State<DerbiMainDashboard> {
  int _selectedTabIndex = 0;
  bool _isViewingNotifications = false;
  String? _expandedGroupId;
  late String _adminName;
  late String _roleName;
  late List<NavigationItem> _navItems;

  StreamSubscription<RemoteMessage>? _fcmForegroundSubscription;
  StreamSubscription<RemoteMessage>? _fcmClickSubscription;
  Timer? _unreadPollingTimer;

  @override
  void initState() {
    super.initState();
    _adminName = StorageService.getUserName() ?? 'الآدمن الرئيسي';
    _roleName = StorageService.getRoleName() ?? 'مدير النظام';
    _navItems = _buildNavItems();
    _ensureSessionFresh();
    _initNotificationsAndFcm();
  }

  void _initNotificationsAndFcm() {
    // 1. تهيئة خدمة FCM لطلب الإذن وتسجيل التوكن لدى الـ Backend و Firestore
    AdminFcmService().initAdminWebNotifications();

    // 2. الاستماع للإشعارات الفورية القادمة أثناء تصفح اللوحة (Foreground)
    _fcmForegroundSubscription =
        AdminFcmService().onForegroundMessage.listen((message) {
      if (!mounted) return;
      final title = message.notification?.title ?? 'إشعار جديد من نظام دَربِي';
      final body = message.notification?.body ?? 'وصلك إشعار جديد في لوحة التحكم';

      // إظهار تنبيه فوري منبثق أعلى الشاشة
      InAppNotificationBanner.show(
        context,
        title: title,
        body: body,
        onTap: () {
          _openNotificationsTab();
        },
      );
    });

    // 3. الاستماع للنقر على إشعار من الخلفية
    _fcmClickSubscription =
        AdminFcmService().onNotificationClick.listen((message) {
      if (!mounted) return;
      _openNotificationsTab();
    });

    // 4. فحص دوري تلقائي كل 35 ثانية لتحديث عداد الإشعارات غير المقروءة
    _unreadPollingTimer = Timer.periodic(const Duration(seconds: 35), (_) {
      if (mounted) {
        context.read<AdminNotificationsCubit>().fetchUnreadCount();
      }
    });
  }

  @override
  void dispose() {
    _fcmForegroundSubscription?.cancel();
    _fcmClickSubscription?.cancel();
    _unreadPollingTimer?.cancel();
    super.dispose();
  }

  List<NavigationGroup> _buildNavGroups() {
    final can = AuthorizationService.hasPermission;

    final userManagementItems = [
      if (can('drivers.view'))
        NavigationItem(
            'drivers', 'إدارة السائقين', Icons.directions_bus_rounded,
            badge: 0),
      if (can('drivers.review_changes'))
        NavigationItem(
            'updates', 'طلبات تعديل بيانات السائقين', Icons.sync_rounded,
            badge: 3),
      if (can('admins.manage'))
        NavigationItem(
            'admins', 'إدارة المشرفين', Icons.admin_panel_settings_rounded,
            badge: 0),
      if (can('parents.view') || can('admins.manage') || can('drivers.view'))
        NavigationItem(
            'parents', 'عرض أولياء الأمور', Icons.family_restroom_rounded,
            badge: 0),
    ];

    final transportItems = [
      if (can('schools.manage'))
        NavigationItem('schools', 'إدارة المدارس', Icons.school_rounded,
            badge: 0),
      if (can('geography.manage'))
        NavigationItem('zones', 'المناطق الجغرافية', Icons.map_rounded,
            badge: 0),
    ];

    final supportItems = [
      if (can('complaints.view'))
        NavigationItem(
            'complaints', 'الشكاوى والبلاغات', Icons.support_agent_rounded,
            badge: 2),
      if (can('driver_reviews.manage'))
        NavigationItem('reviews', 'تقييمات السائقين', Icons.star_rounded,
            badge: 0),
      NavigationItem(
          'ai_alerts', 'تنبيهات الذكاء الاصطناعي', Icons.smart_toy_outlined,
          badge: 0),
    ];

    final financialAndReportsItems = [
      if (can('financial.view_summary'))
        NavigationItem('financial', 'الإدارة المالية والخزينة',
            Icons.account_balance_wallet_rounded,
            badge: 0),
      if (can('reports.view'))
        NavigationItem(
            'reports', 'التقارير والتحليلات', Icons.analytics_rounded,
            badge: 0),
    ];

    return [
      if (userManagementItems.isNotEmpty)
        NavigationGroup(
          id: 'group_users',
          title: 'إدارة المستخدمين',
          icon: Icons.people_alt_rounded,
          items: userManagementItems,
        ),
      if (transportItems.isNotEmpty)
        NavigationGroup(
          id: 'group_transport',
          title: 'إدارة النقل',
          icon: Icons.alt_route_rounded,
          items: transportItems,
        ),
      if (supportItems.isNotEmpty)
        NavigationGroup(
          id: 'group_support',
          title: 'المتابعة والبلاغات',
          icon: Icons.fact_check_rounded,
          items: supportItems,
        ),
      if (financialAndReportsItems.isNotEmpty)
        NavigationGroup(
          id: 'group_financial_reports',
          title: 'المالية والتقارير',
          icon: Icons.assessment_rounded,
          items: financialAndReportsItems,
        ),
    ];
  }

  /// كل عنصر Sidebar مرتبط بالصلاحية التي يحدّدها الـ Backend (RBAC V2).
  List<NavigationItem> _buildNavItems() {
    final groups = _buildNavGroups();
    final items = <NavigationItem>[
      NavigationItem('profile', 'الملف الشخصي', Icons.person_rounded, badge: 0),
      if (AuthorizationService.hasPermission('dashboard.view_stats'))
        NavigationItem('dashboard', 'الرئيسية', Icons.dashboard_rounded,
            badge: 0),
    ];
    for (final g in groups) {
      items.addAll(g.items);
    }
    return items;
  }

  void _expandGroupContainingItem(String itemId) {
    for (final group in _buildNavGroups()) {
      if (group.items.any((item) => item.id == itemId)) {
        _expandedGroupId = group.id;
        break;
      }
    }
  }

  Future<void> _ensureSessionFresh() async {
    final needsAvatar = StorageService.getAvatarUrl() == null;
    try {
      final profile = await sl<AdminProfileRepository>().getProfile();
      if (needsAvatar) {
        await StorageService.saveAvatarUrl(profile.avatarUrl);
      }
      await StorageService.savePermissions(
        permissions: profile.permissions,
        roleKey: profile.roleKey,
        customPermissions: profile.customPermissions,
      );
      if (mounted) {
        final selectedId = _navItems[_selectedTabIndex].id;
        setState(() {
          _navItems = _buildNavItems();
          final newIndex =
              _navItems.indexWhere((item) => item.id == selectedId);
          _selectedTabIndex = newIndex >= 0 ? newIndex : 0;
          _expandGroupContainingItem(_navItems[_selectedTabIndex].id);
        });
      }
    } catch (_) {}
  }

  /// الضغط على صورة الحساب ينقل إلى تبويب الملف الشخصي.
  void _openProfileTab() {
    final index = _navItems.indexWhere((item) => item.id == 'profile');
    if (index >= 0) {
      setState(() {
        _isViewingNotifications = false;
        _selectedTabIndex = index;
      });
    }
  }

  /// فتح شاشة الإشعارات عند الضغط على جرس الهيدر
  void _openNotificationsTab() {
    setState(() => _isViewingNotifications = true);
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
        setState(() {
          _isViewingNotifications = false;
          _selectedTabIndex = index;
          _expandGroupContainingItem(matchedTabId!);
        });
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
                      InkWell(
                        onTap: _openProfileTab,
                        hoverColor: context.sidebarHover,
                        child: Container(
                          height: 65,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: context.sidebarBg,
                            border: Border(
                                bottom: BorderSide(color: context.sidebarBorder)),
                          ),
                          child: Row(
                            children: [
                              ValueListenableBuilder<String?>(
                                valueListenable:
                                    StorageService.avatarUrlListenable,
                                builder: (context, avatarUrl, _) =>
                                    RemoteCircleAvatar(
                                  rawUrl: avatarUrl,
                                  radius: 16,
                                  initials:
                                      _adminName.isNotEmpty ? _adminName[0] : 'أ',
                                  foregroundColor: context.primaryColor,
                                  backgroundColor: context.primaryColor
                                      .withValues(alpha: 0.15),
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
                              Tooltip(
                                message: 'فتح الملف الشخصي',
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  color: context.textMuted,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Navigation Items List
                      Expanded(
                        child: _buildSidebarContent(context),
                      ),

                      // Admin Footer (Logout only)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(color: context.sidebarBorder)),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          tileColor: context.transparent,
                          hoverColor: context.dangerBg.withValues(alpha: 0.1),
                          onTap: () => _showLogoutDialog(context),
                          leading: Icon(
                            Icons.logout_rounded,
                            color: context.dangerColor,
                            size: 18,
                          ),
                          title: Text(
                            'تسجيل الخروج',
                            style: TextStyle(
                              color: context.dangerColor,
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
                          border: Border(
                              bottom: BorderSide(color: context.sidebarBorder)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _isViewingNotifications
                                  ? Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.arrow_back_rounded),
                                          onPressed: () => setState(() =>
                                              _isViewingNotifications = false),
                                          tooltip: 'العودة للخلف',
                                          color: context.primaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'إشعارات النظام',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: context.textPrimary,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
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
                                BlocBuilder<ThemeCubit, ThemeState>(
                                  builder: (context, themeState) {
                                    final isDark = themeState.isDarkMode;
                                    return Tooltip(
                                      message: isDark
                                          ? 'التحويل للوضع النهاري'
                                          : 'التحويل للوضع الليلي',
                                      child: IconButton(
                                        onPressed: () => context
                                            .read<ThemeCubit>()
                                            .toggleTheme(),
                                        icon: Icon(
                                          isDark
                                              ? Icons.wb_sunny_rounded
                                              : Icons.brightness_3_rounded,
                                          color: isDark
                                              ? context.warningColor
                                              : context.textTertiary,
                                          size: 20,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                // Header Notification Icon with Badge
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _isViewingNotifications ||
                                                unreadCount > 0
                                            ? Icons.notifications_active_rounded
                                            : Icons.notifications_outlined,
                                        color: _isViewingNotifications ||
                                                unreadCount > 0
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: context.dangerColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: context.headerBg,
                                                width: 1.5),
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
                          ],
                        ),
                      ),

                      // Active Dynamic Screen Body
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: _isViewingNotifications
                              ? AdminNotificationsScreen(
                                  onNavigateToScreen:
                                      _handleNotificationNavigation,
                                )
                              : _buildCurrentTabScreen(_selectedTabIndex),
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

  Widget _buildSidebarContent(BuildContext context) {
    final can = AuthorizationService.hasPermission;
    final dashboardItem = can('dashboard.view_stats')
        ? NavigationItem('dashboard', 'الرئيسية', Icons.dashboard_rounded,
            badge: 0)
        : null;
    final groups = _buildNavGroups();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (dashboardItem != null)
          _buildNavigationTile(
            context,
            item: dashboardItem,
            isSubItem: false,
          ),
        for (final group in groups) _buildGroupTile(context, group: group),
      ],
    );
  }

  Widget _buildGroupTile(BuildContext context,
      {required NavigationGroup group}) {
    final isExpanded = _expandedGroupId == group.id;
    final hasSelectedItem = group.items.any(
      (item) =>
          _navItems[_selectedTabIndex].id == item.id &&
          !_isViewingNotifications,
    );
    final isHeaderActive = hasSelectedItem || isExpanded;

    final headerBg = isHeaderActive ? context.sidebarActiveBg : context.transparent;
    final headerFg = isHeaderActive ? context.onSidebarActive : context.sidebarItemText;
    final headerTitleFg = isHeaderActive ? context.onSidebarActive : context.textPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: headerBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: context.transparent,
            hoverColor: isHeaderActive ? context.sidebarActiveBg : context.sidebarHover,
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedGroupId = null;
                } else {
                  _expandedGroupId = group.id;
                }
              });
            },
            leading: Icon(
              group.icon,
              color: headerFg,
              size: 18,
            ),
            title: Text(
              group.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHeaderActive ? FontWeight.bold : FontWeight.w600,
                color: headerTitleFg,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isExpanded && group.totalBadge > 0) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isHeaderActive
                          ? context.onSidebarActive.withValues(alpha: 0.25)
                          : context.dangerBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${group.totalBadge}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isHeaderActive ? context.onSidebarActive : context.dangerColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_left_rounded,
                  color: headerFg,
                  size: 18,
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(right: 12, top: 4, left: 4, bottom: 4),
                    child: Column(
                      children: group.items
                          .map((item) => _buildNavigationTile(
                                context,
                                item: item,
                                isSubItem: true,
                              ))
                          .toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required NavigationItem item,
    required bool isSubItem,
  }) {
    final globalIndex = _navItems.indexWhere((it) => it.id == item.id);
    final isSelected =
        globalIndex == _selectedTabIndex && !_isViewingNotifications;
    final activeBadge = item.badge;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected ? context.sidebarActiveBg : context.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: context.transparent,
        hoverColor: isSelected ? context.sidebarActiveBg : context.sidebarHover,
        onTap: () {
          setState(() {
            _isViewingNotifications = false;
            if (globalIndex >= 0) {
              _selectedTabIndex = globalIndex;
            }
          });
        },
        leading: Icon(
          item.icon,
          color: isSelected
              ? context.onSidebarActive
              : context.sidebarItemText,
          size: isSubItem ? 16 : 18,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: isSubItem ? 11.5 : 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? context.onSidebarActive
                : context.sidebarItemText,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: activeBadge > 0
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.onSidebarActive.withValues(alpha: 0.25)
                      : context.dangerBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$activeBadge',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? context.onSidebarActive
                        : context.dangerColor,
                  ),
                ),
              )
            : null,
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
      case 'parents':
        return const ParentsScreen();
      case 'schools':
        return const SchoolsManagementScreen();
      case 'zones':
        return const ZonesManagementScreen();
      case 'complaints':
        return const ComplaintsSupportView();
      case 'reviews':
        return const DriverReviewsScreen();
      case 'ai_alerts':
        return const AiAlertsScreen();
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
            style:
                TextStyle(color: ctx.textPrimary, fontWeight: FontWeight.bold),
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

class NavigationGroup {
  final String id;
  final String title;
  final IconData icon;
  final List<NavigationItem> items;

  NavigationGroup({
    required this.id,
    required this.title,
    required this.icon,
    required this.items,
  });

  int get totalBadge => items.fold(0, (sum, item) => sum + item.badge);
}

class NavigationItem {
  final String id;
  final String title;
  final IconData icon;
  final int badge;

  NavigationItem(this.id, this.title, this.icon, {this.badge = 0});
}
