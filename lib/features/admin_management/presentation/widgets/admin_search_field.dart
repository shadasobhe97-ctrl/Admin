import 'package:flutter/material.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF2563EB),
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
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
        ),
      ),
    );
  }
}
