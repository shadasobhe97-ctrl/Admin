import 'package:flutter/material.dart';

import '../../../../core/widgets/remote_circle_avatar.dart';

/// صورة السائق الشخصية.
///
/// التحميل مفوَّض إلى [RemoteCircleAvatar] الذي يجرّب جلب البايتات ثم وسم
/// `img`، فتظهر الصورة في الويب أيضاً بدل الأحرف الأولى الدائمة.
class DriverAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String fullName;
  final double radius;

  /// يفتح الصورة بالحجم الكامل عند الضغط.
  final VoidCallback? onTap;

  const DriverAvatar({
    super.key,
    this.avatarUrl,
    required this.fullName,
    this.radius = 20,
    this.onTap,
  });

  String get _initials {
    final name = fullName.trim();
    if (name.isEmpty) return 'س';

    final parts = name.split(RegExp(r'\s+'));
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return name[0];
  }

  @override
  Widget build(BuildContext context) {
    return RemoteCircleAvatar(
      rawUrl: avatarUrl,
      radius: radius,
      initials: _initials,
      onTap: onTap,
    );
  }
}
