import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSoft),
      ),
      child: ListTile(
        onTap: onTapDetails,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: context.primaryColor.withValues(alpha: 0.12),
          child: Icon(
            Icons.school_rounded,
            color: context.primaryColor,
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                school.name.isNotEmpty ? school.name : 'مدرسة بدون اسم',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _StatusChip(school: school),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                school.address.isNotEmpty ? school.address : 'العنوان غير محدد',
                style: TextStyle(fontSize: 11.5, color: context.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  _MetaLine(
                    icon: Icons.map_rounded,
                    text: school.zoneName ?? 'منطقة غير محددة',
                  ),
                  if (school.coordinatesLabel != null)
                    _MetaLine(
                      icon: Icons.my_location_rounded,
                      text: school.coordinatesLabel!,
                    )
                  else
                    _MetaLine(
                      icon: Icons.location_off_rounded,
                      text: 'بدون إحداثيات',
                      isWarning: true,
                    ),
                ],
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'عرض التفاصيل',
              icon: Icon(
                Icons.info_outline_rounded,
                color: context.primaryColor,
                size: 20,
              ),
              onPressed: onTapDetails,
            ),
            IconButton(
              tooltip: 'تعديل البيانات',
              icon: Icon(
                Icons.edit_outlined,
                color: context.infoColor,
                size: 20,
              ),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'حذف المدرسة',
              icon: Icon(
                Icons.delete_outline_rounded,
                color: context.dangerColor,
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

/// شارة حالة الاعتماد — لونها مشتق من الثيم لا من قيم ثابتة.
class _StatusChip extends StatelessWidget {
  final SchoolModel school;

  const _StatusChip({required this.school});

  @override
  Widget build(BuildContext context) {
    final isApproved = school.isApproved;
    final foreground = isApproved ? context.successColor : context.warningColor;
    final background = isApproved ? context.successBg : context.warningBg;
    final border = isApproved ? context.successBorder : context.warningBorder;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        school.statusLabel,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: foreground,
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isWarning;

  const _MetaLine({
    required this.icon,
    required this.text,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? context.warningColor : context.textTertiary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}
