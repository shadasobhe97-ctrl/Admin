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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: context.borderSoft),
                    ),
                    child: Text(
                      trip.carPlate,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // بيانات المركبة والموقع
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.borderSoft),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(trip.carModel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.textPrimary)),
                    Flexible(
                      child: Text(
                        trip.currentLocationName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: context.primaryColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // العدادات الثلاثية
              Row(
                children: [
                  Expanded(child: _buildStatusBadge('🚖 راكب معاه', '${trip.ridingCount} أطفال', context.successBg, context.successBorder, context.successColor)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildStatusBadge('⏳ ينتظر', '${trip.waitingCount} أطفال', context.warningBg, context.warningBorder, context.warningColor)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildStatusBadge('✅ وصل', '${trip.arrivedCount} أطفال', context.infoBg, context.infoBorder, context.infoColor)),
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