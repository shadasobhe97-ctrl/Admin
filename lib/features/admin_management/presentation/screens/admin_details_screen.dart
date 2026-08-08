import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/admin_model.dart';
import '../../data/models/create_admin_request_model.dart';
import '../../data/models/update_admin_request_model.dart';
import '../../logic/admin_management_cubit.dart';
import '../../logic/admin_management_state.dart';
import '../widgets/admin_avatar.dart';
import '../widgets/admin_form.dart';
import '../widgets/admin_status_badge.dart';

class AdminDetailsScreen extends StatelessWidget {
  final int adminId;

  const AdminDetailsScreen({super.key, required this.adminId});

  static void show(BuildContext context, int adminId) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => sl<AdminManagementCubit>()..fetchAdminDetails(adminId),
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: AdminDetailsScreen(adminId: adminId),
          ),
        ),
      ),
    );
  }

  void _openEditDialog(BuildContext context, AdminModel admin) {
    final currentUserId = StorageService.getUserId() ?? 1;

    showDialog(
      context: context,
      builder: (dialogCtx) => BlocProvider.value(
        value: context.read<AdminManagementCubit>(),
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            padding: const EdgeInsets.all(24),
            child: BlocBuilder<AdminManagementCubit, AdminManagementState>(
              builder: (ctx, state) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'تعديل بيانات المشرف',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(dialogCtx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AdminFormWidget(
                        initialAdmin: admin,
                        currentUserId: currentUserId,
                        isLoading: state.isUpdating,
                        onCreate: (CreateAdminRequestModel createReq) {},
                        onUpdate: (UpdateAdminRequestModel updateReq) async {
                          final ok = await ctx.read<AdminManagementCubit>().updateAdmin(admin.id, updateReq);
                          if (ok && dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                            ctx.read<AdminManagementCubit>().fetchAdminDetails(admin.id);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<AdminManagementCubit, AdminManagementState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          final adminDetails = state.selectedAdmin;
          final admin = adminDetails?.admin;

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تفاصيل حساب المشرف',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (state.isLoading)
                  const SizedBox(
                    height: 250,
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                    ),
                  )
                else if (admin == null)
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: const Center(
                      child: Text('تعذر تحميل تفاصيل المشرف من الخادم.'),
                    ),
                  )
                else
                  Column(
                    children: [
                      // Header Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            AdminAvatar(
                              avatarUrl: admin.avatarUrl,
                              fullName: admin.fullName,
                              radius: 36,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    admin.fullName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'معرّف المشرف (ID): #${admin.id}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AdminStatusBadge(isActive: admin.isActive),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Details List
                      _buildDetailRow(context, Icons.email_outlined, 'البريد الإلكتروني', admin.email),
                      const SizedBox(height: 12),
                      _buildDetailRow(context, Icons.phone_android_rounded, 'رقم الهاتف', admin.phoneNumber),
                      const SizedBox(height: 12),
                      _buildDetailRow(context, Icons.admin_panel_settings_outlined, 'الدور والصلاحية', admin.roleName),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        Icons.calendar_today_rounded,
                        'تاريخ الإنشاء',
                        admin.createdAt != null && admin.createdAt!.isNotEmpty ? admin.createdAt! : 'غير محدد في Backend',
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              side: BorderSide(color: theme.dividerColor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, size: 16),
                            label: const Text('إغلاق'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => _openEditDialog(context, admin),
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('تعديل البيانات', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
