import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';

class AdminSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;

  const AdminSearchField({
    super.key,
    required this.onChanged,
    this.onClear,
    this.hintText = 'ابحث باسم المشرف أو بريده الإلكتروني أو رقم الهاتف...',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 14,
          color: context.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 13,
            color: context.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: context.primaryColor,
          ),
          suffixIcon: onClear != null
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: theme.cardColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}
