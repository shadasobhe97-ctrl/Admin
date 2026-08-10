import 'package:flutter/material.dart';
import '../../../schools/data/models/zone_model.dart';

class ZoneCard extends StatelessWidget {
  final ZoneModel zone;
  final String? parentName;
  final VoidCallback onAddChild;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ZoneCard({
    super.key,
    required this.zone,
    this.parentName,
    required this.onAddChild,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final subTitleText = zone.parentId == null
        ? 'منطقة رئيسية'
        : 'تابعة لـ: ${parentName ?? "#${zone.parentId}"}';

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
          child: Icon(
            Icons.location_city_rounded,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          zone.name.isNotEmpty ? zone.name : 'منطقة بدون اسم',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subTitleText,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'إضافة منطقة فرعية',
              icon: Icon(
                Icons.add_location_alt_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              onPressed: onAddChild,
            ),
            IconButton(
              tooltip: 'تعديل اسم المنطقة',
              icon: Icon(
                Icons.edit_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'حذف المنطقة',
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
