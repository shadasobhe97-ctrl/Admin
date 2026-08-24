import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/admin_model.dart';
import '../../logic/admin_management_cubit.dart';
import 'admin_avatar.dart';
import 'admin_status_badge.dart';
import 'email_verification_waiting_dialog.dart';

class AdminsTable extends StatelessWidget {
  final List<AdminModel> admins;
  final ValueChanged<AdminModel> onTapDetails;
  final ValueChanged<AdminModel> onEdit;
  final ValueChanged<AdminModel> onDelete;
  final Function(AdminModel admin, bool newStatus) onToggleStatus;

  const AdminsTable({
    super.key,
    required this.admins,
    required this.onTapDetails,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  void _showDeleteDialog(BuildContext context, AdminModel admin) {
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
                onDelete(admin);
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
    final currentRoleId = StorageService.getRoleId();
    final isCurrentMainAdmin = currentRoleId == 1;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            horizontalMargin: 24,
            columnSpacing: 28,
            headingRowHeight: 52,
            dataRowMaxHeight: 68,
            headingRowColor: WidgetStateProperty.resolveWith(
              (states) => context.surfaceVariant,
            ),
            columns: [
              DataColumn(
                label: Text(
                  'المشرف',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'البريد الإلكتروني',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'رقم الهاتف',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'الدور',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'الحالة',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'الإجراءات',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
            rows: admins.map((admin) {
              final isTargetMainAdmin = admin.roleId == 1;

              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AdminAvatar(
                          avatarUrl: admin.avatarUrl,
                          fullName: admin.fullName,
                          radius: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          admin.fullName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          admin.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.textTertiary,
                          ),
                        ),
                        if (admin.emailChangePending && admin.pendingNewEmail != null) ...[
                          const SizedBox(height: 4),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.hourglass_top_rounded, size: 12, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'بانتظار تأكيد: ${admin.pendingNewEmail}',
                                      style: const TextStyle(
                                        fontSize: 11,
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
                      ],
                    ),
                  ),
                  DataCell(
                    Text(
                      admin.phoneNumber,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textTertiary,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        admin.roleName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AdminStatusBadge(isActive: admin.isActive),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: isCurrentMainAdmin
                              ? (admin.isActive ? 'تعطيل الحساب' : 'تفعيل الحساب')
                              : 'تغيير حالة تفعيل حسابات المشرفين متاح للمدير الرئيسي فقط',
                          child: Switch(
                            value: admin.isActive,
                            onChanged: isCurrentMainAdmin
                                ? (val) => onToggleStatus(admin, val)
                                : null,
                            activeThumbColor: context.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: 'عرض تفاصيل المشرف',
                          child: IconButton(
                            icon: Icon(Icons.visibility_outlined, size: 20, color: context.primaryColor),
                            onPressed: () => onTapDetails(admin),
                          ),
                        ),
                        Tooltip(
                          message: 'تعديل البيانات',
                          child: IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFFF59E0B)),
                            onPressed: () => onEdit(admin),
                          ),
                        ),
                        if (isCurrentMainAdmin && !isTargetMainAdmin)
                          Tooltip(
                            message: 'حذف المشرف نهائياً',
                            child: IconButton(
                              icon: Icon(Icons.delete_forever_outlined, size: 20, color: context.dangerColor),
                              onPressed: () => _showDeleteDialog(context, admin),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
