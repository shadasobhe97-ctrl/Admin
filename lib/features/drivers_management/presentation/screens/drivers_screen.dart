import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../logic/drivers_management_cubit.dart';
import '../../logic/drivers_management_state.dart';
import '../widgets/driver_card.dart';
import '../widgets/driver_empty_state.dart';
import '../widgets/driver_filters.dart';
import '../widgets/driver_review_card.dart';
import '../widgets/driver_search_field.dart';
import '../widgets/driver_status_badge.dart';
import '../widgets/drivers_table.dart';
import 'driver_change_details_screen.dart';
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

class _DriversScreenContentState extends State<_DriversScreenContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final cubit = context.read<DriversManagementCubit>();
        if (_tabController.index == 0) {
          cubit.fetchDrivers();
        } else if (_tabController.index == 1) {
          cubit.fetchPendingDriverChanges();
        } else if (_tabController.index == 2) {
          cubit.fetchAllDriverReviews();
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openInspectModal(BuildContext context, int driverId) {
    DriverDetailsScreen.show(context, driverId);
  }

  void _openChangeModal(BuildContext context, int changeId) {
    DriverChangeDetailsScreen.show(context, changeId);
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
                SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
              );
            }
            if (state.successMessage != null && state.successMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.successMessage!), backgroundColor: Colors.green),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<DriversManagementCubit>();

            return RefreshIndicator(
              onRefresh: () async {
                if (_tabController.index == 0) {
                  await cubit.fetchDrivers(page: state.meta.currentPage);
                } else if (_tabController.index == 1) {
                  await cubit.fetchPendingDriverChanges();
                } else {
                  await cubit.fetchAllDriverReviews();
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إدارة السائقين والوثائق والتقييمات',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'اعتماد حسابات السائقين، فحص الكتيب والرخصة، مراجعة تعديلات البيانات، وتقييمات الركاب',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        IconButton.filledTonal(
                          onPressed: () {
                            if (_tabController.index == 0) {
                              cubit.fetchDrivers(page: state.meta.currentPage);
                            } else if (_tabController.index == 1) {
                              cubit.fetchPendingDriverChanges();
                            } else {
                              cubit.fetchAllDriverReviews();
                            }
                          },
                          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2563EB)),
                          tooltip: 'تحديث بيانات القائمة من Backend',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Top Navigation TabBar
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: const Color(0xFF2563EB),
                        unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        indicatorColor: const Color(0xFF2563EB),
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.badge_outlined, size: 18),
                            text: 'سجل السائقين والوثائق',
                          ),
                          Tab(
                            icon: Icon(Icons.sync_rounded, size: 18),
                            text: 'طلبات التعديل المعلقة',
                          ),
                          Tab(
                            icon: Icon(Icons.rate_review_outlined, size: 18),
                            text: 'جميع تقييمات وتعليقات السائقين',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tab 1 Content: Main Drivers List
                    if (_tabController.index == 0) ...[
                      Row(
                        children: [
                          Expanded(
                            child: DriverSearchField(
                              onChanged: (val) => cubit.searchDrivers(val),
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
                        onStatusSelected: (status) => cubit.filterByStatus(status),
                      ),
                      const SizedBox(height: 20),

                      if (state.isLoading)
                        const SizedBox(
                          height: 300,
                          child: Center(
                            child: CircularProgressIndicator(color: Color(0xFF2563EB)),
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
                                onTapInspect: (driver) => _openInspectModal(context, driver.id),
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
                                  onTapInspect: () => _openInspectModal(context, driver.id),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        if (state.meta.lastPage > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.chevron_right_rounded),
                                      onPressed: state.meta.currentPage > 1
                                          ? () => cubit.goToPage(state.meta.currentPage - 1)
                                          : null,
                                      tooltip: 'الصفحة السابقة',
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${state.meta.currentPage}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.chevron_left_rounded),
                                      onPressed: state.meta.hasMore
                                          ? () => cubit.goToPage(state.meta.currentPage + 1)
                                          : null,
                                      tooltip: 'الصفحة التالية',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ]
                    // Tab 2 Content: Pending Driver Change Requests
                    else if (_tabController.index == 1) ...[
                      if (state.isLoading)
                        const SizedBox(
                          height: 300,
                          child: Center(
                            child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                          ),
                        )
                      else if (state.isPendingChangesEmpty)
                        DriverEmptyState(
                          title: 'لا توجد طلبات تعديل معلقة حالياً',
                          description: 'لم يقدم أي سائق طلبات لتحديث بيانات المركبة أو الوثائق حالياً.',
                          onRefresh: () => cubit.fetchPendingDriverChanges(),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.pendingChanges.length,
                          itemBuilder: (context, index) {
                            final change = state.pendingChanges[index];
                            return Card(
                              color: theme.cardColor,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: theme.dividerColor),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.sync_rounded, color: Color(0xFF2563EB)),
                                ),
                                title: Text(
                                  'طلب تعديل: ${change.translatedType}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                subtitle: Text(
                                  'السائق: ${change.driverName ?? "#${change.driverId}"} | طلب رقم: #${change.id}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    DriverStatusBadge(status: change.status),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2563EB),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () => _openChangeModal(context, change.id),
                                      icon: const Icon(Icons.compare_arrows_rounded, size: 16),
                                      label: const Text('مقارنة المقترح والتفعيل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ]
                    // Tab 3 Content: All Platform Driver Reviews
                    else ...[
                      if (state.isLoadingReviews)
                        const SizedBox(
                          height: 300,
                          child: Center(
                            child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                          ),
                        )
                      else if (state.isReviewsEmpty)
                        DriverEmptyState(
                          title: 'لا توجد تقييمات أو تعليقات حالياً',
                          description: 'لم يقم أي ولي أمر أو راكب بتقييم أي سائق حتى الآن.',
                          onRefresh: () => cubit.fetchAllDriverReviews(),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.reviews.length,
                          itemBuilder: (context, index) {
                            final review = state.reviews[index];
                            return DriverReviewCard(
                              review: review,
                              onDelete: (reviewId) => cubit.deleteDriverReview(reviewId),
                            );
                          },
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
