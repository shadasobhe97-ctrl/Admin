import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../logic/drivers_management_cubit.dart';
import '../../logic/drivers_management_state.dart';
import '../widgets/driver_card.dart';
import '../widgets/driver_empty_state.dart';
import '../widgets/driver_filters.dart';
import '../widgets/driver_search_field.dart';
import '../widgets/drivers_table.dart';
import 'driver_details_screen.dart';

class DriversScreen extends StatelessWidget {
  const DriversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DriversManagementCubit>()..fetchDrivers(),
      child: const _DriversScreenContent(),
    );
  }
}

class _DriversScreenContent extends StatefulWidget {
  const _DriversScreenContent();

  @override
  State<_DriversScreenContent> createState() => _DriversScreenContentState();
}

class _DriversScreenContentState extends State<_DriversScreenContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openInspectModal(BuildContext context, int driverId) {
    DriverDetailsScreen.show(context, driverId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<DriversManagementCubit, DriversManagementState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state.successMessage != null &&
                state.successMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<DriversManagementCubit>();

            return RefreshIndicator(
              onRefresh: () async {
                await cubit.fetchDrivers(page: state.meta.currentPage);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header Title Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إدارة السائقين والوثائق',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'اعتماد حسابات السائقين، فحص بيانات الكتيب والرخصة، والتواصل المباشر مع الحافلات',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        IconButton.filledTonal(
                          onPressed: () =>
                              cubit.fetchDrivers(page: state.meta.currentPage),
                          icon: const Icon(Icons.refresh_rounded,
                              color: Color(0xFF2563EB)),
                          tooltip: 'تحديث قائمة السائقين من Backend',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. Search Field & Filters
                    Row(
                      children: [
                        Expanded(
                          child: DriverSearchField(
                            onChanged: (val) {
                              _searchController.text = val;
                              cubit.searchDrivers(val);
                            },
                            onClear: _searchController.text.isNotEmpty
                                ? () {
                                    _searchController.clear();
                                    cubit.fetchDrivers();
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    DriverFiltersWidget(
                      selectedStatus: state.selectedStatus,
                      onStatusSelected: (status) =>
                          cubit.filterByStatus(status),
                    ),
                    const SizedBox(height: 20),

                    // 3. Drivers Data Table or Empty / Loading States
                    if (state.isLoading)
                      const SizedBox(
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF2563EB)),
                        ),
                      )
                    else if (state.isEmpty)
                      DriverEmptyState(
                        onRefresh: () => cubit.fetchDrivers(),
                      )
                    else ...[
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth > 768;

                          if (isDesktop) {
                            return DriversTable(
                              drivers: state.drivers,
                              onTapInspect: (driver) =>
                                  _openInspectModal(context, driver.id),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.drivers.length,
                            itemBuilder: (context, index) {
                              final driver = state.drivers[index];
                              return DriverCard(
                                driver: driver,
                                onTapInspect: () =>
                                    _openInspectModal(context, driver.id),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Pagination controls
                      if (state.meta.lastPage > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'إجمالي السائقين: ${state.meta.total} | الصفحة ${state.meta.currentPage} من ${state.meta.lastPage}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.chevron_right_rounded),
                                    onPressed: state.meta.currentPage > 1
                                        ? () => cubit.goToPage(
                                            state.meta.currentPage - 1)
                                        : null,
                                    tooltip: 'الصفحة السابقة',
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${state.meta.currentPage}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.chevron_left_rounded),
                                    onPressed: state.meta.hasMore
                                        ? () => cubit.goToPage(
                                            state.meta.currentPage + 1)
                                        : null,
                                    tooltip: 'الصفحة التالية',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
