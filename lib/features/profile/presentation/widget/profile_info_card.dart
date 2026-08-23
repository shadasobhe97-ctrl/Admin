import 'package:flutter/material.dart';
import '../../data/models/admin_profile_model.dart';

class ProfileInfoCard extends StatelessWidget {
  final AdminProfileModel profile;

  const ProfileInfoCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final createdAtStr = profile.createdAt != null && profile.createdAt!.isNotEmpty
        ? profile.createdAt!
        : 'غير متوفر';

    final lastLoginStr = profile.lastLoginAt != null && profile.lastLoginAt!.isNotEmpty
        ? profile.lastLoginAt!
        : 'غير متوفر / لم يسجل من قبل';

    final creatorStr = profile.creatorName != null && profile.creatorName!.isNotEmpty
        ? profile.creatorName!
        : 'غير محدد';

    final isActive = profile.isActive ?? true;

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
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.badge_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'المعلومات التفصيلية والإدارية',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 8),
          if (profile.userId != null)
            _infoRow(
              context,
              label: 'معرّف المستخدم (User ID)',
              value: '#${profile.userId}',
            ),
          _infoRow(
            context,
            label: 'الاسم الكامل',
            value: profile.fullName.isNotEmpty ? profile.fullName : 'غير متوفر',
          ),
          _infoRow(
            context,
            label: 'البريد الإلكتروني',
            value: profile.email.isNotEmpty ? profile.email : 'غير متوفر',
          ),
          _infoRow(
            context,
            label: 'رقم الهاتف',
            value: profile.phoneNumber.isNotEmpty ? profile.phoneNumber : 'غير متوفر',
          ),
          _infoRow(
            context,
            label: 'الصلاحية / الدور',
            value: (profile.roleName != null && profile.roleName!.isNotEmpty)
                ? profile.roleName!
                : 'مشرف',
          ),
          _infoRow(
            context,
            label: 'أنشئ بواسطة',
            value: creatorStr,
          ),
          _infoRow(
            context,
            label: 'تاريخ إنشاء الحساب',
            value: createdAtStr,
          ),
          _infoRow(
            context,
            label: 'آخر تسجيل دخول',
            value: lastLoginStr,
          ),
          _infoRow(
            context,
            label: 'حالة الحساب',
            value: isActive ? 'نشط ومفعّل ✓' : 'معطّل ✗',
            valueColor: isActive
                ? theme.colorScheme.secondary
                : theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          SelectableText(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
