import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/driver_model.dart';
import 'driver_avatar.dart';
import 'driver_status_badge.dart';

class DriversTable extends StatelessWidget {
  final List<DriverModel> drivers;
  final ValueChanged<DriverModel> onTapInspect;

  /// تعديل سريع لبيانات السائق — يظهر للسائقين قيد الانتظار فقط.
  final ValueChanged<DriverModel>? onTapEdit;

  const DriversTable({
    super.key,
    required this.drivers,
    required this.onTapInspect,
    this.onTapEdit,
  });

  static bool isPending(DriverModel driver) =>
      driver.status.toLowerCase() == 'pending' ||
      driver.approvalStatus?.toLowerCase() == 'pending';

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
              (states) => context.surfaceVariant,
            ),
            columns: [
              DataColumn(
                label: Text(
                  'اسم السائق',
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
                  'المعرف (ID)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'حالة الحساب والوثائق',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'الإجراء والتدقيق',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
            rows: drivers.map((driver) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DriverAvatar(
                          avatarUrl: driver.avatarUrl,
                          fullName: driver.fullName,
                          radius: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          driver.fullName,
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
                    Text(
                      driver.phoneNumber,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textTertiary,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '#${driver.id}',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textTertiary,
                      ),
                    ),
                  ),
                  DataCell(
                    DriverStatusBadge(status: driver.status),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primaryColor,
                            foregroundColor: context.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => onTapInspect(driver),
                          icon: const Icon(Icons.badge_outlined, size: 16),
                          label: const Text('فحص الوثائق والتفعيل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        if (onTapEdit != null && isPending(driver)) ...[
                          const SizedBox(width: 6),
                          IconButton(
                            onPressed: () => onTapEdit!(driver),
                            icon: Icon(Icons.edit_outlined, size: 18, color: context.primaryColor),
                            tooltip: 'تعديل بيانات السائق',
                          ),
                        ],
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
