import 'package:flutter/material.dart';

import '../../../../core/widgets/remote_circle_avatar.dart';

/// صورة المشرف الشخصية.
///
/// معالجة الرابط النسبي وتحميل الصورة مفوَّضان إلى [RemoteCircleAvatar]
/// حتى تسلك الصور مساراً واحداً يعمل في الويب وسطح المكتب.
class AdminAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String fullName;
  final double radius;
  final VoidCallback? onTap;

  const AdminAvatar({
    super.key,
    this.avatarUrl,
    required this.fullName,
    this.radius = 20,
    this.onTap,
  });

  String get _initials {
    final name = fullName.trim();
    if (name.isEmpty) return 'أ';

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
