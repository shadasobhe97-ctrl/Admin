import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/admin_model.dart';
import '../../logic/admin_management_cubit.dart';
import 'admin_avatar.dart';
import 'admin_status_badge.dart';
import 'email_verification_waiting_dialog.dart';

class AdminCard extends StatelessWidget {
  final AdminModel admin;
  final VoidCallback onTapDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleStatus;

  const AdminCard({
    super.key,
    required this.admin,
    required this.onTapDetails,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  void _showDeleteDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'تأكيد حذف المشرف',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: context.textPrimary,
            ),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في حذف المشرف (${admin.fullName}) نهائياً من المنصة والسيرفر؟\n\nتنويه: الحذف نهائي وغير قابل للتراجع وتُلغى كل جلسات الدخول فوراً.',
            style: TextStyle(
              fontSize: 13,
              color: context.textTertiary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.dangerColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(dialogCtx);
                onDelete();
              },
              icon: const Icon(Icons.delete_forever_rounded, size: 16),
              label: const Text('حذف المشرف', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTargetMainAdmin = admin.roleId == 1;
    final currentRoleId = StorageService.getRoleId();
    final isCurrentMainAdmin = currentRoleId == 1;

    return Card(
      color: theme.cardColor,
      elevation: isDark ? 0 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                AdminAvatar(
                  avatarUrl: admin.avatarUrl,
                  fullName: admin.fullName,
                  radius: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admin.fullName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        admin.roleName,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                AdminStatusBadge(isActive: admin.isActive),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: theme.dividerColor),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 15, color: context.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    admin.email,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textTertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.phone_outlined, size: 15, color: context.textTertiary),
                const SizedBox(width: 6),
                Text(
                  admin.phoneNumber,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textTertiary,
                  ),
                ),
              ],
            ),
            if (admin.emailChangePending && admin.pendingNewEmail != null) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  EmailVerificationWaitingDialog.show(
                    context,
                    adminId: admin.id,
                    newEmail: admin.pendingNewEmail!,
                    onRefresh: () {
                      context.read<AdminManagementCubit>().fetchAdmins();
                    },
                  );
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hourglass_top_rounded, size: 13, color: Colors.amber),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'بانتظار تأكيد: ${admin.pendingNewEmail}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'الحالة الحالية:',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Tooltip(
                      message: isCurrentMainAdmin
                          ? (admin.isActive ? 'تعطيل الحساب' : 'تفعيل الحساب')
                          : 'تغيير حالة تفعيل حسابات المشرفين متاح للمدير الرئيسي فقط',
                      child: Switch(
                        value: admin.isActive,
                        onChanged: isCurrentMainAdmin ? onToggleStatus : null,
                        activeThumbColor: context.successColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        side: BorderSide(color: theme.dividerColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: onTapDetails,
                      icon: const Icon(Icons.visibility_outlined, size: 14),
                      label: const Text('التفاصيل', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        foregroundColor: context.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('تعديل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    if (isCurrentMainAdmin && !isTargetMainAdmin) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: 'حذف المشرف نهائياً',
                        icon: Icon(Icons.delete_forever_outlined, color: context.dangerColor, size: 20),
                        onPressed: () => _showDeleteDialog(context),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
