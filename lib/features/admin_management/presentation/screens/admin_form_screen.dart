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
import '../widgets/email_verification_waiting_dialog.dart';

class AdminFormScreen extends StatelessWidget {
  final AdminModel? initialAdmin;

  const AdminFormScreen({super.key, this.initialAdmin});

  static void show(BuildContext context,
      {AdminModel? initialAdmin, VoidCallback? onSuccess}) {
    // Kept alive by the caller (admins list screen), unlike the form's own
    // factory cubit which is closed as soon as this dialog pops.
    final callerContext = context;

    showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => sl<AdminManagementCubit>(),
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.all(24),
            child: AdminFormScreen(initialAdmin: initialAdmin),
          ),
        ),
      ),
    ).then((result) {
      if (onSuccess != null) onSuccess();

      if (result != null &&
          result['email_verification'] != null &&
          callerContext.mounted) {
        EmailVerificationWaitingDialog.show(
          callerContext,
          adminId: result['admin_id'] as int,
          newEmail: result['email_verification']['new_email'].toString(),
          onRefresh: () {
            if (onSuccess != null) onSuccess();
          },
        );
      }
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
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: Colors.green),
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
                      isEditMode
                          ? 'تعديل بيانات المشرف'
                          : 'إضافة مشرف جديد للوحة التحكم',
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
                  errorMessage: state.errorMessage,
                  onCreate: (CreateAdminRequestModel createReq) async {
                    final cubit = context.read<AdminManagementCubit>();
                    final result = await cubit.createAdmin(createReq);
                    if (result['success'] == true && context.mounted) {
                      final emailVerification = result['email_verification'];
                      final hasPendingEmail = emailVerification != null &&
                          emailVerification['new_email'] != null;

                      Navigator.pop(context, {
                        'admin_id': result['admin_id'],
                        'email_verification':
                            hasPendingEmail ? emailVerification : null,
                      });
                    }
                  },
                  onUpdate: (UpdateAdminRequestModel updateReq) async {
                    if (initialAdmin == null) return;
                    final cubit = context.read<AdminManagementCubit>();
                    final result =
                        await cubit.updateAdmin(initialAdmin!.id, updateReq);
                    if (result['success'] == true && context.mounted) {
                      final emailVerification = result['email_verification'];
                      final hasPendingEmail = emailVerification != null &&
                          emailVerification['new_email'] != null;

                      // The waiting dialog is opened by [show] after this route
                      // pops, so it runs on a cubit that outlives this form.
                      Navigator.pop(context, {
                        'admin_id': initialAdmin!.id,
                        'email_verification':
                            hasPendingEmail ? emailVerification : null,
                      });
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
