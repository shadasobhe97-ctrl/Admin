import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
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

  static const List<_ReportTab> _tabs = [
    _ReportTab('مؤشرات الأداء', Icons.speed_rounded),
    _ReportTab('التقرير المالي', Icons.payments_rounded),
    _ReportTab('الرحلات', Icons.route_rounded),
    _ReportTab('الاشتراكات', Icons.card_membership_rounded),
    _ReportTab('أداء السائقين', Icons.emoji_events_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReportsTabBar(
          tabs: _tabs,
          selectedIndex: _selectedIndex,
          onSelect: (index) => setState(() => _selectedIndex = index),
        ),
        const SizedBox(height: 18),
        Expanded(child: _buildTab()),
      ],
    );
  }

  Widget _buildTab() {
    switch (_selectedIndex) {
      case 1:
        return const FinancialReportsScreen();
      case 2:
        return const TripsReportsScreen();
      case 3:
        return const SubscriptionsReportsScreen();
      case 4:
        return const DriversPerformanceReportsScreen();
      default:
        return const _KpiOverviewTab();
    }
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
              onExport: () => openReportExportDialog(
                context,
                initialType: ReportType.kpi,
                filters: cubit.filters,
              ),
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
  final String label;
  final IconData icon;

  const _ReportTab(this.label, this.icon);
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
