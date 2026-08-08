import 'package:flutter/material.dart';
import '../../data/models/driver_model.dart';
import 'driver_avatar.dart';
import 'driver_status_badge.dart';

class DriversTable extends StatelessWidget {
  final List<DriverModel> drivers;
  final ValueChanged<DriverModel> onTapInspect;

  const DriversTable({
    super.key,
    required this.drivers,
    required this.onTapInspect,
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
                  'اسم السائق',
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
                  'المعرف (ID)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'حالة الحساب والوثائق',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'الإجراء والتدقيق',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '#${driver.id}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  DataCell(
                    DriverStatusBadge(status: driver.status),
                  ),
                  DataCell(
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => onTapInspect(driver),
                      icon: const Icon(Icons.badge_outlined, size: 16),
                      label: const Text('فحص الوثائق والتفعيل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
