import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/report_filters.dart';
import '../../logic/cubit/reports_cubit.dart';
import '../../logic/state/reports_state.dart';
import '../widget/financial_report_section.dart';
import '../widget/report_date_range_filter.dart';
import '../widget/report_period_filter.dart';
import '../widget/reports_ui.dart';
import 'report_export_handler.dart';

class FinancialReportsScreen extends StatelessWidget {
  const FinancialReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportsCubit>(
      create: (_) => sl<ReportsCubit>()..loadFinancialReport(),
      child: const _FinancialReportsContent(),
    );
  }
}

class _FinancialReportsContent extends StatelessWidget {
  const _FinancialReportsContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportsCubit, ReportsState>(
      listener: handleReportExportState,
      builder: (context, state) {
        final cubit = context.read<ReportsCubit>();
        final filters = state is FinancialReportLoaded
            ? state.filters
            : cubit.filters;
        final isBusy = state is FinancialReportLoading ||
            state is ReportExportLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportToolbar(
              title: 'التقرير المالي',
              subtitle: 'الإيرادات والشحن والسحوبات والنزاعات',
              isBusy: isBusy,
              onRefresh: cubit.loadFinancialReport,
              onExport: () => openReportExportDialog(
                context,
                initialType: ReportType.financial,
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
                      cubit.loadFinancialReport,
                    ),
                  ),
                  ReportDateRangeFilter(
                    dateFrom: filters.dateFrom,
                    dateTo: filters.dateTo,
                    enabled: !isBusy,
                    onRangeSelected: (from, to) => cubit.changeDateRange(
                      from,
                      to,
                      cubit.loadFinancialReport,
                    ),
                    onCleared: () =>
                        cubit.clearDateRange(cubit.loadFinancialReport),
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

    if (state is FinancialReportLoading) {
      return const AdminLoadingView(message: 'جارٍ تحميل التقرير المالي…');
    }

    if (state is FinancialReportError) {
      return AdminErrorView(
        message: state.message,
        onRetry: cubit.loadFinancialReport,
      );
    }

    if (state is FinancialReportLoaded) {
      return SingleChildScrollView(
        child: FinancialReportSection(report: state.report),
      );
    }

    return const SizedBox.shrink();
  }
}
