import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/image_viewer_dialog.dart';
import '../../data/models/driver_model.dart';
import 'driver_avatar.dart';
import 'driver_status_badge.dart';

/// بطاقة هوية السائق: الصورة الشخصية، الاسم، الهاتف، والأرقام الرسمية.
///
/// الضغط على الصورة يفتحها بالحجم الكامل.
class DriverIdentityCard extends StatelessWidget {
  final DriverModel driver;

  const DriverIdentityCard({super.key, required this.driver});

  Widget? _buildActiveStatus(BuildContext context) {
    final status = driver.status.toLowerCase();
    final isApproved = status == 'approved' || status == 'verified';
    final isDisabled =
        status == 'disabled' || status == 'inactive' || status == 'معطل';

    if (isDisabled || (!driver.isActive && isApproved)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.dangerColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'الحساب معطّل',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: context.dangerColor,
          ),
        ),
      );
    }
    if (isApproved && driver.isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.successColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'الحساب مفعّل',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: context.successColor,
          ),
        ),
      );
    }
    return null;
  }

  String _formatGender(String? raw) {
    if (raw == null || raw.isEmpty) return 'غير محدد';
    final lower = raw.toLowerCase().trim();
    if (lower == 'male' || lower == 'ذكر') return 'ذكر';
    if (lower == 'female' || lower == 'أنثى') return 'أنثى';
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final avatarImage = driver.resolvedAvatarImage;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xFF1E293B)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DriverAvatar(
                avatarUrl: avatarImage,
                fullName: driver.fullName,
                radius: 36,
                onTap: () => ImageViewerDialog.show(
                  context,
                  title: 'الصورة الشخصية',
                  subtitle: driver.fullName,
                  rawUrl: avatarImage,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.fullName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'معرّف الطلب: #${driver.id} ${driver.userId != null ? "| معرّف الحساب: #${driver.userId}" : ""}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.textTertiary,
                      ),
                    ),
                    if (driver.createdAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'تاريخ التسجيل: ${driver.createdAt}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  DriverStatusBadge(status: driver.status),
                  if (_buildActiveStatus(context) != null) ...[
                    const SizedBox(height: 6),
                    _buildActiveStatus(context)!,
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: context.dividerLine),
          const SizedBox(height: 14),

          // ── حقول الحساب والبيانات الشخصية ──────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              return GridView.count(
                crossAxisCount: isWide ? 2 : 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isWide ? 4.2 : 5.5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 16,
                children: [
                  _InfoChip(
                    icon: Icons.phone_android_rounded,
                    label: 'رقم الهاتف الأساسي',
                    value: driver.phoneNumber.isNotEmpty
                        ? driver.phoneNumber
                        : 'غير محدد',
                  ),
                  _InfoChip(
                    icon: Icons.phone_callback_rounded,
                    label: 'رقم الهاتف البديل',
                    value: driver.alternativePhone ?? 'غير محدد',
                  ),
                  _InfoChip(
                    icon: Icons.email_outlined,
                    label: 'البريد الإلكتروني',
                    value: driver.email ?? 'غير محدد',
                  ),
                  _InfoChip(
                    icon: Icons.wc_rounded,
                    label: 'الجنس',
                    value: _formatGender(driver.gender),
                  ),
                  _InfoChip(
                    icon: Icons.badge_outlined,
                    label: 'الرقم الوطني',
                    value: driver.nationalId ?? 'غير محدد',
                  ),
                  _InfoChip(
                    icon: Icons.card_membership_rounded,
                    label: 'رقم رخصة القيادة',
                    value: driver.licenseNumber ?? 'غير محدد',
                  ),
                  _InfoChip(
                    icon: Icons.event_busy_outlined,
                    label: 'تاريخ انتهاء الرخصة',
                    value: driver.licenseExpiry ?? 'غير محدد',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _InfoChip({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: context.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  color: context.textTertiary,
                ),
              ),
              Text(
                value ?? "غير متوفر",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
