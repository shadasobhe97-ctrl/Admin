import 'package:flutter/material.dart';

class DriverStatusBadge extends StatelessWidget {
  final String status;

  const DriverStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'approved':
      case 'verified':
        bgColor = isDark ? const Color(0xFF065F46).withValues(alpha: 0.4) : const Color(0xFFECFDF5);
        textColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
        icon = Icons.check_circle_rounded;
        label = 'مكتمل / مفعل';
        break;
      case 'rejected':
        bgColor = isDark ? const Color(0xFF881337).withValues(alpha: 0.4) : const Color(0xFFFFF1F2);
        textColor = isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48);
        icon = Icons.cancel_rounded;
        label = 'مرفوض';
        break;
      case 'pending':
      default:
        bgColor = isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFFFBEB);
        textColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
        icon = Icons.pending_rounded;
        label = 'قيد المراجعة';
        break;
    }

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
