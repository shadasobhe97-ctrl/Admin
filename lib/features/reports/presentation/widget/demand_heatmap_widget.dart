import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../../../core/widgets/admin_ui.dart';
import '../../data/models/trips_report_model.dart';
import 'reports_ui.dart';

/// خريطة كثافة الطلب.
///
/// المدارس فقط تحمل `lat`/`lng` في العقد فتُرسم على الخريطة، أما المناطق
/// فلا تحمل إحداثيات ولذلك تُعرض كقائمة دون اختراع مواقع جغرافية لها.
class DemandHeatmapWidget extends StatelessWidget {
  final DemandHeatmap heatmap;

  const DemandHeatmapWidget({super.key, required this.heatmap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReportSectionTitle(
                title: 'أعلى المدارس طلباً',
                icon: Icons.school_rounded,
                subtitle: heatmap.topSchools.isEmpty
                    ? null
                    : '${heatmap.topSchools.length} مدرسة',
              ),
              const SizedBox(height: 14),
              if (heatmap.topSchools.isEmpty)
                const ReportSectionEmpty(
                  message: 'لا توجد بيانات طلب على المدارس لهذه الفترة.',
                  icon: Icons.school_outlined,
                )
              else ...[
                _SchoolsMap(schools: heatmap.mappableSchools),
                const SizedBox(height: 14),
                for (final school in heatmap.topSchools)
                  _SchoolRow(school: school),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        AdminPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReportSectionTitle(
                title: 'أعلى المناطق تغطيةً بالسائقين',
                icon: Icons.map_rounded,
                subtitle: 'العقد لا يوفّر إحداثيات للمناطق، لذلك تُعرض كقائمة',
              ),
              const SizedBox(height: 14),
              if (heatmap.topZones.isEmpty)
                const ReportSectionEmpty(
                  message: 'لا توجد بيانات مناطق لهذه الفترة.',
                  icon: Icons.location_off_rounded,
                )
              else
                for (final zone in heatmap.topZones)
                  AdminInfoRow(
                    label: AdminFormat.orDash(zone.zoneName),
                    value: '${AdminFormat.count(zone.driversCount)} سائق',
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

/// خريطة تعرض المدارس التي أرسل الخادم إحداثياتها فقط.
class _SchoolsMap extends StatelessWidget {
  final List<TopSchoolDemand> schools;

  const _SchoolsMap({required this.schools});

  @override
  Widget build(BuildContext context) {
    if (schools.isEmpty) {
      return const ReportSectionEmpty(
        message: 'لم يُرسل الخادم إحداثيات لأي مدرسة، فتعذّر رسم الخريطة.',
        icon: Icons.location_off_rounded,
      );
    }

    final points = schools
        .map((school) => LatLng(school.lat!, school.lng!))
        .toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 300,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: points.first,
            initialZoom: 11.5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.darby.admin_panel',
            ),
            MarkerLayer(
              markers: [
                for (var index = 0; index < schools.length; index++)
                  Marker(
                    point: points[index],
                    width: 46,
                    height: 46,
                    child: _SchoolMarker(school: schools[index]),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SchoolMarker extends StatelessWidget {
  final TopSchoolDemand school;

  const _SchoolMarker({required this.school});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${AdminFormat.orDash(school.schoolName)}\n'
          '${AdminFormat.count(school.studentsCount)} طالب',
      child: Container(
        decoration: BoxDecoration(
          color: context.primaryColor,
          shape: BoxShape.circle,
          border: Border.all(color: context.onPrimary, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          AdminFormat.count(school.studentsCount),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: context.onPrimary,
          ),
        ),
      ),
    );
  }
}

class _SchoolRow extends StatelessWidget {
  final TopSchoolDemand school;

  const _SchoolRow({required this.school});

  @override
  Widget build(BuildContext context) {
    return AdminInfoRow(
      label: AdminFormat.orDash(school.schoolName),
      value: school.hasCoordinates
          ? '${AdminFormat.count(school.studentsCount)} طالب'
          : '${AdminFormat.count(school.studentsCount)} طالب  •  بدون إحداثيات',
      valueColor: school.hasCoordinates ? null : context.warningColor,
    );
  }
}
