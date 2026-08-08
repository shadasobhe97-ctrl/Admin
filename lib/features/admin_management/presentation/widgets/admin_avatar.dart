import 'package:flutter/material.dart';

class AdminAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String fullName;
  final double radius;

  const AdminAvatar({
    super.key,
    this.avatarUrl,
    required this.fullName,
    this.radius = 20,
  });

  String get _initials {
    if (fullName.trim().isEmpty) return 'أ';
    final parts = fullName.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return fullName.trim()[0];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty && avatarUrl!.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
        backgroundImage: NetworkImage(avatarUrl!),
        onBackgroundImageError: (_, __) {},
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: radius * 0.7,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2563EB),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.2 : 0.1),
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: radius * 0.75,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2563EB),
        ),
      ),
    );
  }
}
