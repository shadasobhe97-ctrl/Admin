import 'package:flutter/material.dart';

class AdminStatusBadge extends StatelessWidget {
  final bool isActive;

  const AdminStatusBadge({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isActive
        ? (isDark ? const Color(0xFF065F46).withValues(alpha: 0.4) : const Color(0xFFECFDF5))
        : (isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFF1F5F9));

    final textColor = isActive
        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));

    final icon = isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded;
    final label = isActive ? 'نشط' : 'غير نشط';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
