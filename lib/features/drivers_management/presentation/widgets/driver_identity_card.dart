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
      return Text(
        'الحساب معطّل',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: context.dangerColor,
        ),
      );
    }
    if (isApproved && driver.isActive) {
      return Text(
        'الحساب مفعّل',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: context.successColor,
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
                avatarUrl: driver.avatarUrl,
                fullName: driver.fullName,
                radius: 36,
                onTap: () => ImageViewerDialog.show(
                  context,
                  title: 'الصورة الشخصية',
                  subtitle: driver.fullName,
                  rawUrl: driver.avatarUrl,
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
                      'رقم الهاتف: ${driver.phoneNumber} | معرّف (ID): #${driver.id}',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textTertiary,
                      ),
                    ),
                    if (driver.createdAt != null)
                      Text(
                        'تاريخ التسجيل: ${driver.createdAt}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textTertiary,
                        ),
                      ),
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
          const SizedBox(height: 14),
          Divider(height: 1, color: context.dividerLine),
          const SizedBox(height: 12),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.badge_outlined,
                label: 'الرقم الوطني',
                value: driver.nationalId,
              ),
              _InfoChip(
                icon: Icons.card_membership_rounded,
                label: 'رقم الرخصة',
                value: driver.licenseNumber,
              ),
              _InfoChip(
                icon: Icons.event_busy_outlined,
                label: 'انتهاء الرخصة',
                value: driver.licenseExpiry,
              ),
            ],
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: context.primaryColor),
        const SizedBox(width: 6),
        Text(
          '$label: ${value ?? "غير متوفر"}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }
}
