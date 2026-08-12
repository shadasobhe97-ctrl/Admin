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
      case 'suspended':
        bgColor = isDark ? const Color(0xFF475569).withValues(alpha: 0.4) : const Color(0xFFF1F5F9);
        textColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        icon = Icons.block_rounded;
        label = 'موقوف';
        break;
      case 'offline':
        bgColor = isDark ? const Color(0xFF334155).withValues(alpha: 0.4) : const Color(0xFFF8FAFC);
        textColor = isDark ? const Color(0xFF64748B) : const Color(0xFF475569);
        icon = Icons.wifi_off_rounded;
        label = 'غير متصل';
        break;
      case 'on_trip':
        bgColor = isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFEFF6FF);
        textColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
        icon = Icons.directions_bus_rounded;
        label = 'في رحلة';
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
