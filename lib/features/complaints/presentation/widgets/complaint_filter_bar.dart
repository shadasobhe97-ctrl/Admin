import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';

class ComplaintFilterBar extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;
  final String? selectedDriverName;
  final VoidCallback? onClearDriverFilter;

  const ComplaintFilterBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    this.selectedDriverName,
    this.onClearDriverFilter,
  });

  @override
  Widget build(BuildContext context) {
    final statusItems = [
      {'key': 'all', 'label': 'الكل'},
      {'key': 'pending', 'label': 'قيد الانتظار'},
      {'key': 'completed', 'label': 'معالجة / مكتملة'},
      {'key': 'dismissed', 'label': 'مرفوضة / متجاهلة'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: statusItems.map((item) {
                    final key = item['key']!;
                    final label = item['label']!;
                    final isSelected = selectedStatus == key;

                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (_) => onStatusChanged(key),
                        selectedColor: context.primaryColor,
                        backgroundColor: context.surfaceVariant,
                        side: BorderSide(
                          color: isSelected
                              ? context.primaryColor
                              : context.borderSoft,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? context.onPrimary
                              : context.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            if (selectedDriverName != null && selectedDriverName!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: context.primaryColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'السائق: $selectedDriverName',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: onClearDriverFilter,
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
