import 'package:flutter/material.dart';
import '../../data/models/active_trip_model.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/utils/admin_theme_context.dart';

class TripInspectorModal extends StatelessWidget {
  final ActiveTripModel trip;

  const TripInspectorModal({super.key, required this.trip});

  static void show(BuildContext context, ActiveTripModel trip) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AdminColors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: TripInspectorModal(trip: trip),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // مؤشر السحب والترويسة
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.borderStrong,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AdminColors.brandPrimary.withValues(alpha: 0.1),
                        radius: 24,
                        child: const Icon(Icons.person, color: AdminColors.brandPrimary),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(trip.driverName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.textPrimary)),
                          Text('سائق ID: #${trip.driverId} • انطلاق: ${trip.startedAt}', style: TextStyle(fontSize: 13, color: context.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),

        // قائمة الركاب (الأطفال)
        Expanded(
          child: trip.passengers.isEmpty
              ? Center(child: Text('لا يوجد ركاب حالياً في هذه الرحلة', style: TextStyle(color: context.textTertiary)))
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: trip.passengers.length,
                  separatorBuilder: (context, index) => Divider(color: theme.dividerColor, height: 32),
                  itemBuilder: (context, index) {
                    final passenger = trip.passengers[index];
                    return Row(
                      children: [
                        // أيقونة الحالة
                        _buildStatusIcon(passenger.status),
                        const SizedBox(width: 16),
                        
                        // تفاصيل الطفل
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(passenger.childName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.textPrimary)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.school, size: 12, color: AdminColors.textMutedLight),
                                  const SizedBox(width: 4),
                                  Text(passenger.schoolName, style: TextStyle(fontSize: 12, color: context.textTertiary)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 12, color: AdminColors.textMutedLight),
                                  const SizedBox(width: 4),
                                  Text(
                                    passenger.status == 'وصل' ? passenger.dropoffLocation : passenger.pickupLocation, 
                                    style: TextStyle(fontSize: 12, color: context.textTertiary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // زر الاتصال بولي الأمر
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.phone, color: AdminColors.statusSuccess),
                          tooltip: 'الاتصال بولي الأمر (${passenger.parentName})',
                        )
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(String status) {
    Color bgColor;
    Color iconColor;
    IconData icon;

    switch (status) {
      case 'راكب':
        bgColor = AdminColors.successBgLight;
        iconColor = AdminColors.statusSuccess;
        icon = Icons.directions_bus;
        break;
      case 'وصل':
        bgColor = AdminColors.infoBgLight;
        iconColor = AdminColors.statusInfo;
        icon = Icons.check_circle;
        break;
      default: // ينتظر
        bgColor = AdminColors.warningBgLight;
        iconColor = AdminColors.statusWarning;
        icon = Icons.access_time_filled;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}