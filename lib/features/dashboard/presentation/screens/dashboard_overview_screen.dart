import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../logic/dashboard_cubit.dart';
import '../../logic/dashboard_state.dart';
import '../widgets/responsive_sidebar.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/stats_cards_widget.dart';
import '../widgets/active_trips_table_widget.dart';
import '../../../../core/utils/admin_theme_context.dart';

class DashboardOverviewScreen extends StatelessWidget {
  const DashboardOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardCubit>()..fetchDashboardData(),
      child: Scaffold(
        body: Row(
          children: [
            // القائمة الجانبية للشاشات الكبيرة
            const ResponsiveSidebar(),
            
            // المحتوى الرئيسي
            Expanded(
              child: Column(
                children: [
                  const DashboardHeader(),
                  Expanded(
                    child: BlocBuilder<DashboardCubit, DashboardState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (state.errorMessage != null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 48, color: context.errorColor),
                                const SizedBox(height: 16),
                                Text(state.errorMessage!),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.read<DashboardCubit>().fetchDashboardData(),
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state.stats == null) {
                          return const Center(child: Text('لا توجد بيانات متاحة'));
                        }

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StatsCardsWidget(stats: state.stats!),
                              const SizedBox(height: 32),
                              ActiveTripsTableWidget(trips: state.activeTrips),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
