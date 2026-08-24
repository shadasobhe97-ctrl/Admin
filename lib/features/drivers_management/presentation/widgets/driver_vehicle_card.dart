import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/utils/media_url.dart';
import '../../../../core/widgets/image_viewer_dialog.dart';
import '../../../../core/widgets/remote_image.dart';
import '../../data/models/driver_vehicle_model.dart';
import 'driver_status_badge.dart';

/// بطاقة مركبة واحدة مع صورتها القابلة للعرض بالحجم الكامل.
class DriverVehicleCard extends StatelessWidget {
  final DriverVehicleModel vehicle;

  const DriverVehicleCard({super.key, required this.vehicle});

  /// السطر الثانوي: اللوحة والسنة والسعة والتكييف — بلا حقول فارغة.
  String _describe() {
    final parts = <String>[
      'رقم اللوحة: ${vehicle.plateNumber}',
      if (vehicle.year != null) 'سنة: ${vehicle.year}',
      if (vehicle.capacity != null) 'السعة: ${vehicle.capacity} راكب',
      if (vehicle.color != null) 'اللون: ${vehicle.color}',
      if (vehicle.type != null) 'النوع: ${vehicle.type}',
      if (vehicle.hasAc != null)
        vehicle.hasAc! ? 'مكيّفة' : 'بدون تكييف',
    ];
    return parts.join(' | ');
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = MediaUrl.resolve(vehicle.imageUrl);
    final title = '${vehicle.brand} ${vehicle.model}'.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerLine),
      ),
      child: Row(
        children: [
          _VehicleImage(url: imageUrl, title: title),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _describe(),
                  style: TextStyle(fontSize: 12.5, color: context.textTertiary),
                ),
                if (vehicle.isVerified)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: context.successColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'مركبة موثّقة',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: context.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (vehicle.status != null) DriverStatusBadge(status: vehicle.status!),
        ],
      ),
    );
  }
}

class _VehicleImage extends StatelessWidget {
  final String? url;
  final String title;

  const _VehicleImage({required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    final link = url;

    if (link == null) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: context.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.directions_bus_rounded,
          size: 30,
          color: context.primaryColor,
        ),
      );
    }

    return InkWell(
      onTap: () => ImageViewerDialog.show(
        context,
        title: 'صورة المركبة',
        subtitle: title,
        rawUrl: link,
      ),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: context.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: RemoteImage(
          rawUrl: link,
          fallback: Icon(
            Icons.directions_bus_rounded,
            size: 30,
            color: context.primaryColor,
          ),
        ),
      ),
    );
  }
}
