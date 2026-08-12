import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';

/// بطاقة موحّدة تُستعمل في المستويات الجغرافية الثلاثة.
/// لا تحتوي أي منطق أعمال — تستقبل بيانات جاهزة و Callbacks فقط.
class GeoNodeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  /// شارات إحصائية جاهزة للعرض (مثل: "3 محلات").
  final List<String> badges;

  /// `null` يعني أن العنصر لا يقبل التصفّح للداخل.
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GeoNodeCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.badges = const [],
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: context.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: context.borderSoft),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 19, color: context.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (badges.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: badges
                            .map((badge) => _GeoBadge(label: badge))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  tooltip: 'تعديل',
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_rounded,
                    size: 17,
                    color: context.infoColor,
                  ),
                ),
              if (onDelete != null)
                IconButton(
                  tooltip: 'حذف',
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: context.dangerColor,
                  ),
                ),
              if (onTap != null)
                Icon(
                  Icons.chevron_left_rounded,
                  size: 20,
                  color: context.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GeoBadge extends StatelessWidget {
  final String label;

  const _GeoBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.infoBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.infoBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: context.infoColor,
        ),
      ),
    );
  }
}
