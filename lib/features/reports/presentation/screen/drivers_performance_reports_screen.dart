import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../../../core/widgets/admin_pagination.dart';
import '../../data/models/report_filters.dart';
import '../../logic/cubit/reports_cubit.dart';
import '../../logic/state/reports_state.dart';
import '../widget/documents_status_widget.dart';
import '../widget/drivers_leaderboard_widget.dart';
import '../widget/reports_ui.dart';
import 'report_export_handler.dart';

class DriversPerformanceReportsScreen extends StatelessWidget {
  const DriversPerformanceReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportsCubit>(
      create: (_) => sl<ReportsCubit>()..loadDriversPerformance(),
      child: const _DriversPerformanceContent(),
    );
  }
}

class _DriversPerformanceContent extends StatefulWidget {
  const _DriversPerformanceContent();

  @override
  State<_DriversPerformanceContent> createState() =>
      _DriversPerformanceContentState();
}

class _DriversPerformanceContentState
    extends State<_DriversPerformanceContent> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<ReportsCubit>().filters.search ?? '',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportsCubit, ReportsState>(
      listener: handleReportExportState,
      builder: (context, state) {
        final cubit = context.read<ReportsCubit>();
        final filters =
            state is DriversPerformanceLoaded ? state.filters : cubit.filters;
        final isBusy = state is DriversPerformanceLoading ||
            state is ReportExportLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportToolbar(
              title: 'أداء السائقين',
              subtitle: 'الترتيب وحالة وثائق المركبات',
              isBusy: isBusy,
              onRefresh: cubit.loadDriversPerformance,
              onExport: () => openReportExportDialog(
                context,
                initialType: ReportType.drivers,
                filters: filters,
              ),
              filters: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      enabled: !isBusy,
                      style:
                          TextStyle(fontSize: 13, color: context.textPrimary),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'بحث بالاسم أو البريد أو الهاتف…',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: context.textTertiary,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: context.textTertiary,
                        ),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 17,
                                  color: context.dangerColor,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  cubit.searchDrivers(null);
                                },
                              ),
                      ),
                      // البحث يُنفَّذ على الخادم عبر `search`، بلا فلترة محلية.
                      onSubmitted: cubit.searchDrivers,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _SortSelector(
                    selected: filters.sortBy,
                    enabled: !isBusy,
                    onSelect: cubit.sortDrivers,
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

    if (state is DriversPerformanceLoading) {
      return const AdminLoadingView(message: 'جارٍ تحميل تقرير أداء السائقين…');
    }

    if (state is DriversPerformanceError) {
      return AdminErrorView(
        message: state.message,
        onRetry: cubit.loadDriversPerformance,
      );
    }

    if (state is DriversPerformanceLoaded) {
      final report = state.report;

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReportSectionTitle(
                    title: 'ترتيب السائقين',
                    icon: Icons.emoji_events_rounded,
                    subtitle: 'الفرز حسب: '
                        '${DriverSortBy.label(state.filters.sortBy)}',
                  ),
                  const SizedBox(height: 14),
                  DriversLeaderboardWidget(entries: report.leaderboard),
                  if (!report.isEmpty) ...[
                    const SizedBox(height: 10),
                    // ترقيم الصفحات يعتمد على `meta` القادمة من الخادم.
                    AdminPagination(
                      meta: report.meta,
                      onPageChanged: cubit.changeDriversPage,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            DocumentsStatusWidget(status: report.documentsStatus),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// اختيار وجه الفرز بالقيم التي يقبلها الخادم فقط.
class _SortSelector extends StatelessWidget {
  final String selected;
  final bool enabled;
  final ValueChanged<String> onSelect;

  const _SortSelector({
    required this.selected,
    required this.enabled,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.borderSoft),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          dropdownColor: context.cardColor,
          isDense: true,
          icon: Icon(
            Icons.sort_rounded,
            size: 18,
            color: context.textTertiary,
          ),
          style: TextStyle(fontSize: 12, color: context.textPrimary),
          items: DriverSortBy.all
              .map(
                (sort) => DropdownMenuItem<String>(
                  value: sort,
                  child: Text(
                    'الفرز: ${DriverSortBy.label(sort)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              )
              .toList(),
          onChanged: enabled
              ? (value) {
                  if (value != null) onSelect(value);
                }
              : null,
        ),
      ),
    );
  }
}
