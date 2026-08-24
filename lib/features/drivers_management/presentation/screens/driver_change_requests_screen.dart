import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../logic/drivers_management_cubit.dart';
import '../../logic/drivers_management_state.dart';
import '../widgets/driver_empty_state.dart';
import '../widgets/driver_search_field.dart';
import '../widgets/driver_status_badge.dart';
import 'driver_change_details_screen.dart';

class DriverChangeRequestsScreen extends StatelessWidget {
  const DriverChangeRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<DriversManagementCubit>()..fetchPendingDriverChanges(),
      child: const _DriverChangeRequestsContent(),
    );
  }
}

class _DriverChangeRequestsContent extends StatefulWidget {
  const _DriverChangeRequestsContent();

  @override
  State<_DriverChangeRequestsContent> createState() =>
      _DriverChangeRequestsContentState();
}

class _DriverChangeRequestsContentState
    extends State<_DriverChangeRequestsContent> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

            // تصفية طلبات التعديل بناءً على نص البحث
            final filteredChanges = state.pendingChanges.where((change) {
              if (_searchQuery.trim().isEmpty) return true;
              final q = _searchQuery.trim().toLowerCase();
              final driverName = (change.driverName ?? '').toLowerCase();
              final changeType = change.translatedType.toLowerCase();
              final idStr = change.id.toString();
              final driverIdStr = change.driverId.toString();
              return driverName.contains(q) ||
                  changeType.contains(q) ||
                  idStr.contains(q) ||
                  driverIdStr.contains(q);
            }).toList();

            return RefreshIndicator(
              onRefresh: () async => await cubit.fetchPendingDriverChanges(),
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
                              'طلبات تعديل بيانات السائقين',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'مراجعة الطلبات المقدمة من السائقين لتحديث بيانات المركبة، الكتيب والرخصة مع مقارنة التغييرات',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        IconButton.filledTonal(
                          onPressed: () => cubit.fetchPendingDriverChanges(),
                          icon: Icon(Icons.refresh_rounded,
                              color: context.primaryColor),
                          tooltip: 'تحديث طلبات التعديل من Backend',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. Search Field
                    DriverSearchField(
                      hintText: 'ابحث باسم السائق، رقم الطلب، أو نوع التعديل...',
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      onClear: _searchQuery.isNotEmpty
                          ? () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            }
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // 3. Content List / Loading / Empty
                    if (state.isLoading)
                      SizedBox(
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(
                              color: context.primaryColor),
                        ),
                      )
                    else if (state.isPendingChangesEmpty)
                      DriverEmptyState(
                        title: 'لا توجد طلبات تعديل معلقة حالياً',
                        description:
                            'لم يقدم أي سائق طلبات لتحديث بيانات المركبة أو الوثائق حالياً.',
                        onRefresh: () => cubit.fetchPendingDriverChanges(),
                      )
                    else if (filteredChanges.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 48, color: context.textTertiary),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد طلبات تعديل تطابق نتيجة البحث',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'جرب البحث باسم سائق آخر أو نوع تعديل مختلف.',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredChanges.length,
                        itemBuilder: (context, index) {
                          final change = filteredChanges[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.dividerColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: isDark ? 0.2 : 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: context.primaryColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.sync_rounded,
                                    color: context.primaryColor),
                              ),
                              title: Text(
                                'طلب تعديل: ${change.translatedType}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                'السائق: ${change.driverName ?? "#${change.driverId}"}${change.driverPhone != null && change.driverPhone!.isNotEmpty ? " (${change.driverPhone})" : ""} | طلب رقم: #${change.id}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.textTertiary,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DriverStatusBadge(status: change.status),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: context.primaryColor,
                                      foregroundColor: context.onPrimary,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    onPressed: () =>
                                        _openChangeModal(context, change.id),
                                    icon: const Icon(
                                        Icons.compare_arrows_rounded,
                                        size: 16),
                                    label: const Text('مقارنة المقترح والتفعيل',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
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
