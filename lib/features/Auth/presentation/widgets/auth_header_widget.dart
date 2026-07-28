import 'package:flutter/material.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/utils/admin_theme_context.dart';

class AuthHeaderWidget extends StatelessWidget {
  final bool isDark;

  const AuthHeaderWidget({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          isDark
              ? 'assets/images/admindark_logo.png'
              : 'assets/images/adminligth_logo.png',
          height: 100,
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            return Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: context.primaryColor,
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          'لوحة تحكم النظام',
          style: AdminTextStyles.heading(
            color: context.primaryColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'تسجيل الدخول للمسؤولين والمشرفين',
          style: AdminTextStyles.hintTextStyle(),
        ),
      ],
    );
  }
}