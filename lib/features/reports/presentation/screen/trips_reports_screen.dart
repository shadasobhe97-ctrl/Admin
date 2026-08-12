import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/report_filters.dart';
import '../../logic/cubit/reports_cubit.dart';
import '../../logic/state/reports_state.dart';
import '../widget/absence_statistics_widget.dart';
import '../widget/demand_heatmap_widget.dart';
import '../widget/report_date_range_filter.dart';
import '../widget/report_period_filter.dart';
import '../widget/reports_ui.dart';
import '../widget/trips_completion_widget.dart';
import 'report_export_handler.dart';

class TripsReportsScreen extends StatelessWidget {
  const TripsReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportsCubit>(
      create: (_) => sl<ReportsCubit>()..loadTripsReport(),
      child: const _TripsReportsContent(),
    );
  }
}

class _TripsReportsContent extends StatelessWidget {
  const _TripsReportsContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportsCubit, ReportsState>(
      listener: handleReportExportState,
      builder: (context, state) {
        final cubit = context.read<ReportsCubit>();
        final filters =
            state is TripsReportLoaded ? state.filters : cubit.filters;
        final isBusy =
            state is TripsReportLoading || state is ReportExportLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportToolbar(
              title: 'تقرير الرحلات',
              subtitle: 'الإنجاز والغياب وكثافة الطلب',
              isBusy: isBusy,
              onRefresh: cubit.loadTripsReport,
              onExport: () => openReportExportDialog(
                context,
                initialType: ReportType.trips,
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
                    onSelect: (period) =>
                        cubit.changePeriod(period, cubit.loadTripsReport),
                  ),
                  ReportDateRangeFilter(
                    dateFrom: filters.dateFrom,
                    dateTo: filters.dateTo,
                    enabled: !isBusy,
                    onRangeSelected: (from, to) =>
                        cubit.changeDateRange(from, to, cubit.loadTripsReport),
                    onCleared: () =>
                        cubit.clearDateRange(cubit.loadTripsReport),
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

    if (state is TripsReportLoading) {
      return const AdminLoadingView(message: 'جارٍ تحميل تقرير الرحلات…');
    }

    if (state is TripsReportError) {
      return AdminErrorView(
        message: state.message,
        onRetry: cubit.loadTripsReport,
      );
    }

    if (state is TripsReportLoaded) {
      final report = state.report;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TripsCompletionWidget(summary: report.completionSummary),
            const SizedBox(height: 18),
            AbsenceStatisticsWidget(stats: report.absenceStats),
            const SizedBox(height: 18),
            DemandHeatmapWidget(heatmap: report.demandHeatmap),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
