import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/admin_model.dart';
import '../../data/models/create_admin_request_model.dart';
import '../../data/models/update_admin_request_model.dart';
import '../../logic/admin_management_cubit.dart';
import '../../logic/admin_management_state.dart';
import '../widgets/admin_form.dart';

class AdminFormScreen extends StatelessWidget {
  final AdminModel? initialAdmin;

  const AdminFormScreen({super.key, this.initialAdmin});

  static void show(BuildContext context, {AdminModel? initialAdmin, VoidCallback? onSuccess}) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => sl<AdminManagementCubit>(),
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.all(24),
            child: AdminFormScreen(initialAdmin: initialAdmin),
          ),
        ),
      ),
    ).then((_) {
      if (onSuccess != null) onSuccess();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUserId = StorageService.getUserId() ?? 1;
    final isEditMode = initialAdmin != null;

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
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditMode ? 'تعديل بيانات المشرف' : 'إضافة مشرف جديد للوحة التحكم',
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
                const SizedBox(height: 16),
                AdminFormWidget(
                  initialAdmin: initialAdmin,
                  currentUserId: currentUserId,
                  isLoading: state.isCreating || state.isUpdating,
                  onCreate: (CreateAdminRequestModel createReq) async {
                    final ok = await context.read<AdminManagementCubit>().createAdmin(createReq);
                    if (ok && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  onUpdate: (UpdateAdminRequestModel updateReq) async {
                    if (initialAdmin == null) return;
                    final ok = await context.read<AdminManagementCubit>().updateAdmin(initialAdmin!.id, updateReq);
                    if (ok && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
