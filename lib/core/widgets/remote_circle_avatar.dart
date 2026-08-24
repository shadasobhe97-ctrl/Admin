import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'remote_image.dart';

/// صورة شخصية دائرية تُحمَّل من الخادم.
///
/// تتجنّب `CircleAvatar.backgroundImage` عمداً: ذلك الحقل يأخذ `ImageProvider`
/// فيُجبَر التحميل على مسار جلب البايتات وحده، ولا يمكنه السقوط إلى وسم `img`
/// عند فشل CORS — وهو سبب اختفاء الصور في الويب. [RemoteImage] يوفّر المسارين.
///
/// [bytes] يعرض صورة مختارة للتوّ من الجهاز قبل رفعها، وله الأولوية.
class RemoteCircleAvatar extends StatelessWidget {
  final String? rawUrl;
  final double radius;

  /// النص البديل عند غياب الصورة (الأحرف الأولى من الاسم عادةً).
  final String? initials;

  /// أيقونة بديلة تُستخدم بدل [initials] عند تمريرها.
  final IconData? fallbackIcon;

  final Color? backgroundColor;
  final Color? foregroundColor;

  /// بايتات صورة محلية مختارة للتوّ — تُعرض فوراً دون مرور بالشبكة.
  final Uint8List? bytes;

  final VoidCallback? onTap;

  const RemoteCircleAvatar({
    super.key,
    required this.rawUrl,
    this.radius = 20,
    this.initials,
    this.fallbackIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.bytes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = foregroundColor ?? const Color(0xFF2563EB);
    final background = backgroundColor ?? accent.withValues(alpha: 0.12);

    final fallback = Center(
      child: fallbackIcon != null
          ? Icon(fallbackIcon, size: radius, color: accent)
          : Text(
              initials?.trim().isNotEmpty == true ? initials! : '؟',
              style: TextStyle(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
    );

    Widget content;
    if (bytes != null && bytes!.isNotEmpty) {
      content = ClipOval(
        child: Image.memory(
          bytes!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback,
        ),
      );
    } else {
      content = ClipOval(
        child: RemoteImage(
          rawUrl: rawUrl,
          width: radius * 2,
          height: radius * 2,
          fallback: fallback,
        ),
      );
    }

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: background,
      child: content,
    );

    if (onTap != null) {
      avatar = InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatar,
      );
    }

    return avatar;
  }
}
