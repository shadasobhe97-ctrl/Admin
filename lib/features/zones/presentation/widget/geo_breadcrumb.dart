import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';

/// عنصر واحد في مسار التنقل الجغرافي.
class GeoBreadcrumbItem {
  final String label;

  /// `null` يعني أن هذا هو المستوى الحالي فلا يقبل الضغط.
  final VoidCallback? onTap;

  const GeoBreadcrumbItem({required this.label, this.onTap});
}

/// مسار التنقل بين مستويات الجغرافيا الثلاثة.
class GeoBreadcrumb extends StatelessWidget {
  final List<GeoBreadcrumbItem> items;

  const GeoBreadcrumb({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 18,
                  color: context.textMuted,
                ),
              ),
            _BreadcrumbChip(
              item: items[index],
              isCurrent: index == items.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _BreadcrumbChip extends StatelessWidget {
  final GeoBreadcrumbItem item;
  final bool isCurrent;

  const _BreadcrumbChip({required this.item, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final label = Text(
      item.label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
        color: isCurrent ? context.textPrimary : context.primaryColor,
      ),
    );

    if (item.onTap == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: label,
      );
    }

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: label,
      ),
    );
  }
}
