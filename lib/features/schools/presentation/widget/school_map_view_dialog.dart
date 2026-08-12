import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Dialog يعرض موقع المدرسة على الخريطة.
/// يُستخدم عند الضغط على خانة الإحداثيات في شاشة التفاصيل.
class SchoolMapViewDialog extends StatelessWidget {
  final double lat;
  final double lng;
  final String schoolName;

  const SchoolMapViewDialog({
    super.key,
    required this.lat,
    required this.lng,
    required this.schoolName,
  });

  /// فتح الـ Dialog من أي مكان.
  static Future<void> show(
    BuildContext context, {
    required double lat,
    required double lng,
    required String schoolName,
  }) {
    return showDialog(
      context: context,
      builder: (_) => SchoolMapViewDialog(
        lat: lat,
        lng: lng,
        schoolName: schoolName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final center = LatLng(lat, lng);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 600,
          height: 480,
          child: Column(
            children: [
              // ─── Header ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'موقع المدرسة على الخريطة',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // ─── Coordinates Label ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      schoolName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Lat: ${lat.toStringAsFixed(5)}  •  Lng: ${lng.toStringAsFixed(5)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ─── Map ────────────────────────────────────────────────────────
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.darbi.admin',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: center,
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.location_pin,
                              color: theme.colorScheme.primary,
                              size: 42,
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
