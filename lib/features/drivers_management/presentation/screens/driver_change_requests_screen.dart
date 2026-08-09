import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../logic/drivers_management_cubit.dart';
import '../../logic/drivers_management_state.dart';
import '../widgets/driver_empty_state.dart';
import '../widgets/driver_status_badge.dart';
import 'driver_change_details_screen.dart';

class DriverChangeRequestsScreen extends StatelessWidget {
  const DriverChangeRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DriversManagementCubit>()..fetchPendingDriverChanges(),
      child: const _DriverChangeRequestsContent(),
    );
  }
}

class _DriverChangeRequestsContent extends StatelessWidget {
  const _DriverChangeRequestsContent();

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
              onRefresh: () async => await cubit.fetchPendingDriverChanges(),
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
                              'طلبات تعديل بيانات السائقين',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'مراجعة الطلبات المقدمة من السائقين لتحديث بيانات المركبة، الكتيب والرخصة مع مقارنة التغييرات',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        IconButton.filledTonal(
                          onPressed: () => cubit.fetchPendingDriverChanges(),
                          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2563EB)),
                          tooltip: 'تحديث طلبات التعديل من Backend',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Content
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
