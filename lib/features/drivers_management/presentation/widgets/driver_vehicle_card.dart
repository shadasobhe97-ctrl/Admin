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

  @override
  Widget build(BuildContext context) {
    final imageUrl = MediaUrl.resolve(vehicle.imageUrl);
    final title = '${vehicle.brand} ${vehicle.model}'.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.dividerLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'رقم اللوحة: ${vehicle.plateNumber}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (vehicle.status != null) DriverStatusBadge(status: vehicle.status!),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: context.dividerLine),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 480;
              return GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isWide ? 2.6 : 3.5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 12,
                children: [
                  _PropTile(
                    label: 'الماركة',
                    value: vehicle.brand,
                  ),
                  _PropTile(
                    label: 'الطراز / الموديل',
                    value: vehicle.model,
                  ),
                  _PropTile(
                    label: 'سنة الصنع',
                    value: vehicle.year ?? 'غير محدد',
                  ),
                  _PropTile(
                    label: 'رقم اللوحة',
                    value: vehicle.plateNumber,
                  ),
                  _PropTile(
                    label: 'اللون',
                    value: vehicle.color ?? 'غير محدد',
                  ),
                  _PropTile(
                    label: 'نوع المركبة',
                    value: vehicle.type ?? 'غير محدد',
                  ),
                  _PropTile(
                    label: 'سعة الركاب',
                    value: vehicle.capacity != null
                        ? '${vehicle.capacity} ركاب'
                        : 'غير محدد',
                  ),
                  _PropTile(
                    label: 'التكييف',
                    value: vehicle.hasAc != null
                        ? (vehicle.hasAc! ? 'مكيّفة' : 'بدون تكييف')
                        : 'غير محدد',
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

class _PropTile extends StatelessWidget {
  final String label;
  final String value;

  const _PropTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
