import 'package:flutter/material.dart';

import '../../../../core/widgets/remote_circle_avatar.dart';
import '../../data/models/active_trip_model.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/utils/admin_theme_context.dart';

class ActiveDriverCard extends StatelessWidget {
  final ActiveTripModel trip; // تم التعديل هنا ليتطابق مع الموديل الجديد
  final VoidCallback onTapInspect;

  const ActiveDriverCard({
    super.key,
    required this.trip,
    required this.onTapInspect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.borderSoft),
      ),
      color: context.cardColor,
      child: InkWell(
        onTap: onTapInspect,
        borderRadius: BorderRadius.circular(16),
        hoverColor: context.infoBg,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ترويسة السائق
              Row(
                children: [
                  RemoteCircleAvatar(
                    rawUrl: trip.driverAvatar,
                    radius: 20,
                    initials: trip.driverName.trim().isEmpty
                        ? null
                        : trip.driverName.trim()[0],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.driverName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPrimary),
                        ),
                        Text(
                          trip.driverPhone,
                          style: TextStyle(fontSize: 11, color: context.textTertiary),
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: context.borderSoft),
                        ),
                        child: Text(
                          'رحلة #${trip.tripId}',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.primaryColor),
                        ),
                      ),
                      if (trip.status.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AdminColors.successBgLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            trip.status,
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AdminColors.statusSuccess),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // بيانات المركبة والمنطقة والوجهة
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.borderSoft),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 12, color: AdminColors.accentCyan),
                            const SizedBox(width: 4),
                            Text(
                              trip.region.isNotEmpty ? trip.region : trip.currentLocationName,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.textPrimary),
                            ),
                          ],
                        ),
                        if (trip.duration.isNotEmpty || trip.startedAt.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.timer_outlined, size: 12, color: AdminColors.statusWarning),
                              const SizedBox(width: 4),
                              Text(
                                trip.duration.isNotEmpty ? trip.duration : trip.startedAt,
                                style: TextStyle(fontSize: 10, color: context.textSecondary),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (trip.destination.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.school_outlined, size: 12, color: AdminColors.textMutedLight),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              trip.destination,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10, color: context.textTertiary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // العدادات الإحصائية للركاب
              Row(
                children: [
                  Expanded(child: _buildStatusBadge('على المتن', '${trip.ridingCount}', context.successBg, context.successBorder, context.successColor)),
                  const SizedBox(width: 4),
                  Expanded(child: _buildStatusBadge('بانتظار', '${trip.waitingCount}', context.warningBg, context.warningBorder, context.warningColor)),
                  const SizedBox(width: 4),
                  Expanded(child: _buildStatusBadge('تم التوصيل', '${trip.arrivedCount}', context.infoBg, context.infoBorder, context.infoColor)),
                  if (trip.absentStudentsCount > 0) ...[
                    const SizedBox(width: 4),
                    Expanded(child: _buildStatusBadge('غائب', '${trip.absentStudentsCount}', AdminColors.dangerBgLight, AdminColors.statusDanger.withValues(alpha: 0.3), AdminColors.statusDanger)),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // زر الفحص
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onTapInspect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: AdminColors.onBrand,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 14, color: AdminColors.onBrand),
                  label: const Text('عرض ركاب الرحلة الذكية', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String title, String count, Color bgColor, Color borderColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 2),
          Text(count, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: textColor)),
        ],
      ),
    );
  }
}