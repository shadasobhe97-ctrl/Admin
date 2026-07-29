import 'package:flutter/material.dart';
import 'admin_colors.dart';

class AdminTextStyles {
  static TextStyle style({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    TextOverflow? overflow,
  }) {
    return TextStyle(
      fontFamily: 'Tajawal',
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      overflow: overflow,
    );
  }

  static TextStyle heading({required Color color}) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static TextStyle body({required Color color}) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle hintTextStyle() {
    return const TextStyle(
      fontFamily: 'Tajawal',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AdminColors.textMuted,
    );
  }
}
