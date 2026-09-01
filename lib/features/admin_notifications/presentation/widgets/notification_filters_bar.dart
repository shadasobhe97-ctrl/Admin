import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';

class NotificationFiltersBar extends StatelessWidget {
  final bool unreadOnly;
  final ValueChanged<bool> onUnreadOnlyChanged;
  final VoidCallback onRefresh;

  const NotificationFiltersBar({
    super.key,
    required this.unreadOnly,
    required this.onUnreadOnlyChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderSoft),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list_rounded, size: 18),
              const SizedBox(width: 8),
              Text(
                'عرض الإشعارات:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              _buildFilterChip(
                context,
                label: 'كل الإشعارات',
                isSelected: !unreadOnly,
                onTap: () => onUnreadOnlyChanged(false),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                label: 'غير المقروءة فقط',
                isSelected: unreadOnly,
                onTap: () => onUnreadOnlyChanged(true),
              ),
            ],
          ),
          IconButton(
            onPressed: onRefresh,
            icon: Icon(Icons.refresh_rounded, color: context.textSecondary, size: 20),
            tooltip: 'تحديث القائمة',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor : context.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? context.primaryColor : context.borderSoft,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? context.onPrimary : context.textSecondary,
          ),
        ),
      ),
    );
  }
}
