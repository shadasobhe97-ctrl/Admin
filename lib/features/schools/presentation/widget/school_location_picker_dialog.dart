import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Dialog تفاعلي لاختيار موقع المدرسة من الخريطة.
class SchoolLocationPickerDialog extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const SchoolLocationPickerDialog({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  static Future<LatLng?> show(
    BuildContext context, {
    double? initialLat,
    double? initialLng,
  }) {
    return showDialog<LatLng>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SchoolLocationPickerDialog(
        initialLat: initialLat,
        initialLng: initialLng,
      ),
    );
  }

  @override
  State<SchoolLocationPickerDialog> createState() =>
      _SchoolLocationPickerDialogState();
}

class _SchoolLocationPickerDialogState
    extends State<SchoolLocationPickerDialog> {
  // طرابلس كقيمة افتراضية إذا لم يكن هناك موقع محدد مسبقاً
  late LatLng _currentCenter;
  LatLng? _selectedPoint;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _selectedPoint = LatLng(widget.initialLat!, widget.initialLng!);
      _currentCenter = _selectedPoint!;
    } else {
      _currentCenter = const LatLng(32.8872, 13.1914); // Tripoli center
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedPoint = point;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 700,
          height: 550,
          child: Column(
            children: [
              // ─── Header ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.map_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تحديد موقع المدرسة',
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

              // ─── Help Text ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'انقر على الخريطة لتحديد الموقع بدقة',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedPoint != null)
                      Text(
                        '${_selectedPoint!.latitude.toStringAsFixed(5)}, ${_selectedPoint!.longitude.toStringAsFixed(5)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ─── Map ────────────────────────────────────────────────────────
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentCenter,
                    initialZoom: 13,
                    onTap: _onMapTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.darbi.admin',
                    ),
                    if (_selectedPoint != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedPoint!,
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.location_pin,
                              color: theme.colorScheme.error,
                              size: 46,
                              shadows: const [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // ─── Footer / Actions ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('إلغاء'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      onPressed: _selectedPoint == null
                          ? null
                          : () => Navigator.of(context).pop(_selectedPoint),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('تأكيد الموقع المختار'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
