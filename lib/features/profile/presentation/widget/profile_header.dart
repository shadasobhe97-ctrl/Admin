import 'package:flutter/material.dart';
import '../../../../core/utils/media_url.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/widgets/remote_circle_avatar.dart';
import '../../data/models/admin_profile_model.dart';

class ProfileHeader extends StatelessWidget {
  final AdminProfileModel profile;
  final bool isEditing;
  final VoidCallback onToggleEdit;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.isEditing,
    required this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final initial = profile.fullName.trim().isNotEmpty
        ? profile.fullName.trim()[0].toUpperCase()
        : 'أ';

    final roleText = (profile.roleName != null && profile.roleName!.isNotEmpty)
        ? profile.roleName!
        : 'مشرف النظام';

    final isActive = profile.isActive ?? true;

    final avatarResolvedUrl = MediaUrl.resolve(profile.avatarUrl);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar Section
          Stack(
            children: [
              // تُقرأ الصورة من جلسة الحساب لا من نموذج الملف وحده، حتى
              // تكون هي نفسها المعروضة في الشريط الجانبي والترويسة،
              // وتحمل بصمة الوقت بعد الرفع فتظهر الصورة الجديدة فوراً.
              ValueListenableBuilder<String?>(
                valueListenable: StorageService.avatarUrlListenable,
                builder: (context, sessionAvatar, _) => RemoteCircleAvatar(
                  rawUrl: sessionAvatar ?? avatarResolvedUrl,
                  radius: 40,
                  initials: initial,
                  foregroundColor: primaryColor,
                  backgroundColor: primaryColor.withValues(alpha: 0.15),
                ),
              ),
              Positioned(
                bottom: 2,
                left: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.cardColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // User Info Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName.isNotEmpty ? profile.fullName : 'غير متوفر',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      roleText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      isActive
                          ? Icons.check_circle_outline_rounded
                          : Icons.cancel_outlined,
                      size: 14,
                      color: isActive
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? 'الحساب نشط ومفعّل' : 'الحساب معطّل',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Edit/View Toggle Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isEditing
                  ? theme.colorScheme.surfaceContainerHighest
                  : primaryColor,
              foregroundColor: isEditing
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onToggleEdit,
            icon: Icon(
              isEditing ? Icons.visibility_outlined : Icons.edit_rounded,
              size: 16,
            ),
            label: Text(isEditing ? 'عرض' : 'تعديل'),
          ),
        ],
      ),
    );
  }
}
