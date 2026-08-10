import 'package:flutter/material.dart';
import '../../data/models/school_model.dart';

class SchoolCard extends StatelessWidget {
  final SchoolModel school;
  final VoidCallback onTapDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SchoolCard({
    super.key,
    required this.school,
    required this.onTapDetails,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final zoneText = (school.zoneName != null && school.zoneName!.isNotEmpty)
        ? ' • المنطقة: ${school.zoneName}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTapDetails,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
          child: Icon(
            Icons.school_rounded,
            color: theme.colorScheme.primary,
            size: 22,
          ),
        ),
        title: Text(
          school.name.isNotEmpty ? school.name : 'مدرسة بدون اسم',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'العنوان: ${school.address.isNotEmpty ? school.address : "غير محدد"}$zoneText',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'عرض التفاصيل',
              icon: Icon(
                Icons.info_outline_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              onPressed: onTapDetails,
            ),
            IconButton(
              tooltip: 'تعديل البيانات',
              icon: Icon(
                Icons.edit_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'حذف المدرسة',
              icon: Icon(
                Icons.delete_outline_rounded,
                color: theme.colorScheme.error,
                size: 20,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
