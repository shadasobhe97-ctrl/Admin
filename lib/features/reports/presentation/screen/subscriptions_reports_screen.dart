import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/report_filters.dart';
import '../../logic/cubit/reports_cubit.dart';
import '../../logic/state/reports_state.dart';
import '../widget/expiring_subscriptions_widget.dart';
import '../widget/report_date_range_filter.dart';
import '../widget/report_period_filter.dart';
import '../widget/reports_ui.dart';
import '../widget/subscriptions_distribution_widget.dart';
import 'report_export_handler.dart';

class SubscriptionsReportsScreen extends StatelessWidget {
  const SubscriptionsReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportsCubit>(
      create: (_) => sl<ReportsCubit>()..loadSubscriptionsReport(),
      child: const _SubscriptionsReportsContent(),
    );
  }
}

class _SubscriptionsReportsContent extends StatelessWidget {
  const _SubscriptionsReportsContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportsCubit, ReportsState>(
      listener: handleReportExportState,
      builder: (context, state) {
        final cubit = context.read<ReportsCubit>();
        final filters =
            state is SubscriptionsReportLoaded ? state.filters : cubit.filters;
        final isBusy = state is SubscriptionsReportLoading ||
            state is ReportExportLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportToolbar(
              title: 'تقرير الاشتراكات',
              subtitle: 'الأنواع والحالات والعقود القريبة من الانتهاء',
              isBusy: isBusy,
              onRefresh: cubit.loadSubscriptionsReport,
              onExport: () => openReportExportDialog(
                context,
                initialType: ReportType.subscriptions,
                filters: filters,
              ),
              filters: Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ReportPeriodFilter(
                    selected: filters.period,
                    enabled: !isBusy,
                    onSelect: (period) => cubit.changePeriod(
                      period,
                      cubit.loadSubscriptionsReport,
                    ),
                  ),
                  ReportDateRangeFilter(
                    dateFrom: filters.dateFrom,
                    dateTo: filters.dateTo,
                    enabled: !isBusy,
                    onRangeSelected: (from, to) => cubit.changeDateRange(
                      from,
                      to,
                      cubit.loadSubscriptionsReport,
                    ),
                    onCleared: () =>
                        cubit.clearDateRange(cubit.loadSubscriptionsReport),
                  ),
                ],
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

    if (state is SubscriptionsReportLoading) {
      return const AdminLoadingView(message: 'جارٍ تحميل تقرير الاشتراكات…');
    }

    if (state is SubscriptionsReportError) {
      return AdminErrorView(
        message: state.message,
        onRetry: cubit.loadSubscriptionsReport,
      );
    }

    if (state is SubscriptionsReportLoaded) {
      final report = state.report;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubscriptionsDistributionWidget(
              types: report.subscriptionTypes,
              statuses: report.statusBreakdown,
            ),
            const SizedBox(height: 18),
            ExpiringSubscriptionsWidget(report: report.expiringSoon),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
