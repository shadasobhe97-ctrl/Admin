import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../../admin_audit_logs/presentation/screen/audit_logs_screen.dart';
import '../../data/models/admin_model.dart';
import '../../logic/admin_management_cubit.dart';
import '../../logic/admin_management_state.dart';
import '../widgets/admin_card.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_search_field.dart';
import '../widgets/admins_table.dart';
import 'admin_details_screen.dart';
import 'admin_form_screen.dart';

class AdminsScreen extends StatelessWidget {
  const AdminsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (StorageService.getRoleId() != 1) {
      return Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_person_rounded, size: 56, color: context.warningColor),
                  const SizedBox(height: 16),
                  Text(
                    'صلاحية غير كافية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'صفحة إدارة المشرفين مخصصة لمدير النظام (الأدمن) فقط.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: context.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => sl<AdminManagementCubit>()..fetchAdmins(),
      child: const _AdminsScreenContent(),
    );
  }
}

class _AdminsScreenContent extends StatefulWidget {
  const _AdminsScreenContent();

  @override
  State<_AdminsScreenContent> createState() => _AdminsScreenContentState();
}

class _AdminsScreenContentState extends State<_AdminsScreenContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddModal(BuildContext context) {
    final cubit = context.read<AdminManagementCubit>();
    AdminFormScreen.show(
      context,
      onSuccess: () => cubit.fetchAdmins(search: _searchController.text.trim()),
    );
  }

  void _openEditModal(BuildContext context, AdminModel admin) {
    final cubit = context.read<AdminManagementCubit>();
    AdminFormScreen.show(
      context,
      initialAdmin: admin,
      onSuccess: () => cubit.fetchAdmins(search: _searchController.text.trim()),
    );
  }

  void _openDetailsModal(BuildContext context, AdminModel admin) {
    AdminDetailsScreen.show(context, admin.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<AdminManagementCubit, AdminManagementState>(
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
            final cubit = context.read<AdminManagementCubit>();

            return RefreshIndicator(
              onRefresh: () async {
                await cubit.fetchAdmins(search: _searchController.text.trim());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إدارة المشرفين وصلاحيات الحسابات',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // سجل الإجراءات للأدمن العام فقط؛ الحماية الفعلية
                            // على الخادم (403) وهذا الإخفاء لتجربة المستخدم.
                            if (canViewAuditLogs()) ...[
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AuditLogsScreen(),
                                  ),
                                ),
                                icon: const Icon(Icons.history_rounded, size: 18),
                                label: const Text(
                                  'سجل إجراءات المشرفين',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.primaryColor,
                                foregroundColor: context.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => _openAddModal(context),
                              icon: const Icon(Icons.person_add_rounded,
                                  size: 18),
                              label: const Text(
                                'إضافة مشرف جديد',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Search & Filter Action Bar
                    Row(
                      children: [
                        Expanded(
                          child: AdminSearchField(
                            onChanged: (val) => cubit.searchAdmins(val),
                            onClear: _searchController.text.isNotEmpty
                                ? () {
                                    _searchController.clear();
                                    cubit.fetchAdmins();
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          onPressed: () => cubit.fetchAdmins(
                              search: _searchController.text.trim()),
                          icon: Icon(Icons.refresh_rounded,
                              color: context.primaryColor),
                          tooltip: 'تحديث بيانات القائمة من Backend',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Loading Indicator State
                    if (state.isLoading)
                      SizedBox(
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(
                              color: context.primaryColor),
                        ),
                      )
                    // Empty State
                    else if (state.isEmpty)
                      AdminEmptyState(
                        onAddAdmin: () => _openAddModal(context),
                      )
                    // Responsive Table or Cards Grid
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth > 768;

                          if (isDesktop) {
                            return AdminsTable(
                              admins: state.admins,
                              onTapDetails: (admin) =>
                                  _openDetailsModal(context, admin),
                              onEdit: (admin) => _openEditModal(context, admin),
                              onDelete: (admin) => cubit.deleteAdmin(admin.id),
                              onToggleStatus: (admin, newStatus) {
                                cubit.toggleAdminStatus(
                                    admin.id, !admin.isActive);
                              },
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.admins.length,
                            itemBuilder: (context, index) {
                              final admin = state.admins[index];
                              return AdminCard(
                                admin: admin,
                                onTapDetails: () =>
                                    _openDetailsModal(context, admin),
                                onEdit: () => _openEditModal(context, admin),
                                onDelete: () => cubit.deleteAdmin(admin.id),
                                onToggleStatus: (newStatus) {
                                  cubit.toggleAdminStatus(
                                      admin.id, !admin.isActive);
                                },
                              );
                            },
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
