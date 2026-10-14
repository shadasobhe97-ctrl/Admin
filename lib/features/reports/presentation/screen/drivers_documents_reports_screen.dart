import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/permissions/authorization_service.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/drivers_performance_report_model.dart';
import '../../data/models/report_filters.dart';
import '../../logic/cubit/reports_cubit.dart';
import '../../logic/state/reports_state.dart';
import '../widget/documents_status_widget.dart';
import '../widget/reports_ui.dart';
import 'report_export_handler.dart';

/// شاشة مخصّصة ومستقلة لمتابعة حالة وثائق وتراخيص مركبات الأسطول.
class DriversDocumentsReportsScreen extends StatelessWidget {
  const DriversDocumentsReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportsCubit>(
      create: (_) => sl<ReportsCubit>()..loadDriversPerformance(),
      child: const _DriversDocumentsContent(),
    );
  }
}

class _DriversDocumentsContent extends StatefulWidget {
  const _DriversDocumentsContent();

  @override
  State<_DriversDocumentsContent> createState() =>
      _DriversDocumentsContentState();
}

class _DriversDocumentsContentState extends State<_DriversDocumentsContent> {
  DriversPerformanceReportModel? _lastReport;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportsCubit, ReportsState>(
      listener: handleReportExportState,
      builder: (context, state) {
        if (state is DriversPerformanceLoaded) {
          _lastReport = state.report;
        }

        final cubit = context.read<ReportsCubit>();
        final filters =
            state is DriversPerformanceLoaded ? state.filters : cubit.filters;
        final isBusy = state is DriversPerformanceLoading ||
            state is ReportExportLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportToolbar(
              title: 'وثائق وتراخيص المركبات',
              subtitle:
                  'متابعة سريان تراخيص القيادة وتأمين المركبات وتنبيهات الانتهاء للأسطول',
              isBusy: isBusy,
              onRefresh: cubit.loadDriversPerformance,
              onExport: (AuthorizationService.hasPermission('reports.export') ||
                      AuthorizationService.hasPermission('reports.view') ||
                      AuthorizationService.hasPermission('reports.drivers') ||
                      AuthorizationService.hasPermission('drivers.view'))
                  ? () => openReportExportDialog(
                        context,
                        initialType: ReportType.documents,
                        filters: filters,
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

    if (state is DriversPerformanceLoading && _lastReport == null) {
      return const AdminLoadingView(
        message: 'جارٍ فحص وتحميل وثائق وتراخيص الأسطول…',
      );
    }

    if (state is DriversPerformanceError && _lastReport == null) {
      return AdminErrorView(
        message: state.message,
        onRetry: cubit.loadDriversPerformance,
      );
    }

    final report = state is DriversPerformanceLoaded
        ? state.report
        : _lastReport;

    if (report != null) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DocumentsStatusWidget(status: report.documentsStatus),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
