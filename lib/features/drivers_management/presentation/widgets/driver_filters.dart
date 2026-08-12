import 'package:flutter/material.dart';

class DriverFiltersWidget extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onStatusSelected;

  const DriverFiltersWidget({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filters = [
      {'key': 'all', 'label': 'جميع السائقين'},
      {'key': 'pending', 'label': 'طلبات جديدة (Pending)'},
      {'key': 'approved', 'label': 'سائقون مفعّلون (Approved)'},
      {'key': 'suspended', 'label': 'حسابات موقوفة (Suspended)'},
      {'key': 'rejected', 'label': 'طلبات مرفوضة (Rejected)'},
      {'key': 'offline', 'label': 'غير متصل (Offline)'},
      {'key': 'on_trip', 'label': 'في رحلة (ON_TRIP)'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filters.map((f) {
        final key = f['key']!;
        final label = f['label']!;
        final isSelected = selectedStatus == key || (key == 'all' && (selectedStatus.isEmpty || selectedStatus == 'all'));

        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onStatusSelected(key),
          selectedColor: const Color(0xFF2563EB),
          backgroundColor: theme.cardColor,
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
          side: BorderSide(
            color: isSelected ? const Color(0xFF2563EB) : theme.dividerColor,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
      }).toList(),
    );
  }
}
