import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';

class AdminEmptyState extends StatelessWidget {
  final VoidCallback onAddAdmin;
  final String title;
  final String description;

  const AdminEmptyState({
    super.key,
    required this.onAddAdmin,
    this.title = 'لا يوجد مشرفون حالياً في النظام',
    this.description =
        'يمكنك إضافة مشرف جديد وتعيين صلاحيات الوصول والبريد الإلكتروني للبدء.',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.supervisor_account_outlined,
              size: 56,
              color: context.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: context.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
