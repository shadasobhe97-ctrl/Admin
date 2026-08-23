import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';
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
    final isDark = theme.brightness == Brightness.dark;

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
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في حذف المشرف (${admin.fullName}) نهائياً من المنصة والسيرفر؟\n\nتنويه: الحذف نهائي وغير قابل للتراجع وتُلغى كل جلسات الدخول فوراً.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
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
              (states) => isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            ),
            columns: [
              DataColumn(
                label: Text(
                  'المشرف',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'البريد الإلكتروني',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'رقم الهاتف',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'الدور',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'الحالة',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'الإجراءات',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        admin.roleName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
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
                            activeThumbColor: const Color(0xFF10B981),
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
                            icon: const Icon(Icons.visibility_outlined, size: 20, color: Color(0xFF2563EB)),
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
                              icon: const Icon(Icons.delete_forever_outlined, size: 20, color: Color(0xFFE11D48)),
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
