import 'package:flutter/material.dart';
import '../../../../core/network/api_endpoints.dart';

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

  String? _getCleanUrl() {
    if (avatarUrl == null || avatarUrl!.trim().isEmpty) return null;
    
    String url = avatarUrl!.trim();
    
    // If it's a relative path, prefix it with baseUrl host (without /api)
    if (!url.startsWith('http')) {
      final base = ApiEndpoints.baseUrl.replaceAll('/api', '');
      final path = url.startsWith('/') ? url : '/$url';
      return '$base$path';
    }
    
    // If it has http://localhost/ but the app is communicating with localhost:8000
    if (url.startsWith('http://localhost/') && ApiEndpoints.baseUrl.contains(':8000')) {
      url = url.replaceAll('http://localhost/', 'http://127.0.0.1:8000/');
    }
    
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cleanUrl = _getCleanUrl();

    if (cleanUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
        backgroundImage: NetworkImage(cleanUrl),
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
