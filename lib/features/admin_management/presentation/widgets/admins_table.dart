import 'package:flutter/material.dart';
import '../../data/models/admin_model.dart';
import 'admin_avatar.dart';
import 'admin_status_badge.dart';

class AdminsTable extends StatelessWidget {
  final List<AdminModel> admins;
  final ValueChanged<AdminModel> onTapDetails;
  final ValueChanged<AdminModel> onEdit;
  final Function(AdminModel admin, bool newStatus) onToggleStatus;

  const AdminsTable({
    super.key,
    required this.admins,
    required this.onTapDetails,
    required this.onEdit,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                    Text(
                      admin.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
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
                        Switch(
                          value: admin.isActive,
                          onChanged: (val) => onToggleStatus(admin, val),
                          activeThumbColor: const Color(0xFF10B981),
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
