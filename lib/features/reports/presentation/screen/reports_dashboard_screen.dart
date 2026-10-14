import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/permissions/authorization_service.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/report_filters.dart';
import '../../logic/cubit/reports_cubit.dart';
import '../../logic/state/reports_state.dart';
import '../widget/reports_kpi_cards.dart';
import '../widget/reports_ui.dart';
import 'drivers_performance_reports_screen.dart';
import 'financial_reports_screen.dart';
import 'report_export_handler.dart';
import 'subscriptions_reports_screen.dart';
import 'trips_reports_screen.dart';

/// نقطة الدخول لميزة التقارير.
///
/// تعرض مؤشرات الأداء السريعة (KPI) وتتيح الانتقال إلى التقارير التفصيلية،
/// بنفس أسلوب التنقل المتبع في بقية الميزات (تبويبات داخلية).
class ReportsDashboardScreen extends StatefulWidget {
  const ReportsDashboardScreen({super.key});

  @override
  State<ReportsDashboardScreen> createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen> {
  int _selectedIndex = 0;

  List<_ReportTab> _getVisibleTabs() {
    final can = AuthorizationService.hasPermission;
    final isSuperAdmin = can('*') || can('admins.manage');

    final allTabs = [
      // التقرير المالي: للمشرف المالي والإدارة العامة فقط
      _ReportTab(
        id: 'financial',
        label: 'التقرير المالي',
        icon: Icons.payments_rounded,
        screen: const FinancialReportsScreen(),
        isVisible: isSuperAdmin || can('reports.financial') || can('financial.view_summary'),
      ),
      // مؤشرات الأداء: تظهر للإدارة العامة
      _ReportTab(
        id: 'kpi',
        label: 'مؤشرات الأداء',
        icon: Icons.speed_rounded,
        screen: const _KpiOverviewTab(),
        isVisible: isSuperAdmin,
      ),
      // تقارير الرحلات: لمشرف العمليات والإدارة العامة
      _ReportTab(
        id: 'trips',
        label: 'الرحلات',
        icon: Icons.route_rounded,
        screen: const TripsReportsScreen(),
        isVisible: isSuperAdmin ||
            can('reports.trips') ||
            can('trips.view') ||
            can('trips.generate_daily'),
      ),
      // تقارير الاشتراكات: لمشرف العمليات والإدارة العامة
      _ReportTab(
        id: 'subscriptions',
        label: 'الاشتراكات',
        icon: Icons.card_membership_rounded,
        screen: const SubscriptionsReportsScreen(),
        isVisible: isSuperAdmin ||
            can('reports.subscriptions') ||
            can('subscriptions.view') ||
            can('trips.generate_daily'),
      ),
      // تقارير أداء السائقين: لمشرف الأسطول ومشرف الدعم والإدارة العامة
      _ReportTab(
        id: 'drivers',
        label: 'أداء السائقين',
        icon: Icons.emoji_events_rounded,
        screen: const DriversPerformanceReportsScreen(),
        isVisible: isSuperAdmin ||
            can('reports.drivers') ||
            can('drivers.suspend') ||
            can('complaints.view') ||
            can('drivers.review_initial'),
      ),
    ];

    final visible = allTabs.where((t) {
      if (isSuperAdmin) return true;
      // إذا كان المستخدم مشرف مالية: يرى التقرير المالي فقط
      final isFinance = can('financial.view_summary') &&
          !can('trips.generate_daily') &&
          !can('complaints.view') &&
          !can('drivers.suspend');
      if (isFinance) {
        return t.id == 'financial';
      }
      return t.isVisible;
    }).toList();

    if (visible.isEmpty) {
      return [allTabs.first];
    }
    return visible;
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthorizationService.hasPermission('reports.view')) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_person_rounded, size: 56, color: context.warningColor),
              const SizedBox(height: 16),
              Text(
                'صلاحية غير كافية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'استعراض قسم التقارير يتطلب صلاحية عرض التقارير.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: context.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    final visibleTabs = _getVisibleTabs();
    final clampedIndex = _selectedIndex.clamp(0, visibleTabs.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReportsTabBar(
          tabs: visibleTabs,
          selectedIndex: clampedIndex,
          onSelect: (index) => setState(() => _selectedIndex = index),
        ),
        const SizedBox(height: 18),
        Expanded(child: visibleTabs[clampedIndex].screen),
      ],
    );
  }
}

/// تبويب مؤشرات الأداء — يعتمد على `GET /reports/kpi-summary` بلا فلاتر.
class _KpiOverviewTab extends StatelessWidget {
  const _KpiOverviewTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportsCubit>(
      create: (_) => sl<ReportsCubit>()..loadKpiSummary(),
      child: const _KpiOverviewContent(),
    );
  }
}

class _KpiOverviewContent extends StatelessWidget {
  const _KpiOverviewContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportsCubit, ReportsState>(
      listener: handleReportExportState,
      builder: (context, state) {
        final cubit = context.read<ReportsCubit>();
        final isBusy = state is KpiLoading || state is ReportExportLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportToolbar(
              title: 'مؤشرات الأداء السريعة',
              subtitle: 'نظرة عامة على المستخدمين والرحلات والإيرادات',
              isBusy: isBusy,
              onRefresh: cubit.loadKpiSummary,
              onExport: AuthorizationService.hasPermission('reports.export')
                  ? () => openReportExportDialog(
                        context,
                        initialType: ReportType.kpi,
                        filters: cubit.filters,
                      )
                  : null,
            ),
            const SizedBox(height: 18),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ReportsState state) {
    final cubit = context.read<ReportsCubit>();

    if (state is KpiLoading) {
      return const AdminLoadingView(message: 'جارٍ تحميل مؤشرات الأداء…');
    }

    if (state is KpiError) {
      return AdminErrorView(
        message: state.message,
        onRetry: cubit.loadKpiSummary,
      );
    }

    if (state is KpiLoaded) {
      return SingleChildScrollView(
        child: ReportsKpiCards(summary: state.summary),
      );
    }

    return const SizedBox.shrink();
  }
}

class _ReportTab {
  final String id;
  final String label;
  final IconData icon;
  final Widget screen;
  final bool isVisible;

  const _ReportTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.screen,
    required this.isVisible,
  });
}

/// شريط تبويبات أفقي قابل للتمرير على الشاشات الأضيق.
class _ReportsTabBar extends StatelessWidget {
  final List<_ReportTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _ReportsTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < tabs.length; index++) ...[
            _TabChip(
              tab: tabs[index],
              isSelected: selectedIndex == index,
              onTap: () => onSelect(index),
            ),
            if (index != tabs.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final _ReportTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor : context.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.primaryColor : context.borderSoft,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab.icon,
              size: 16,
              color: isSelected ? context.onPrimary : context.textTertiary,
            ),
            const SizedBox(width: 7),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? context.onPrimary : context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
