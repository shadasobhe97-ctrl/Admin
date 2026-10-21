import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/utils/admin_theme_context.dart';

/// Dialog لعرض العنوان الافتراضي لولي الأمر على الخريطة بشكل تفاعلي وأنيق.
class ParentAddressMapDialog extends StatefulWidget {
  final double lat;
  final double lng;
  final String addressLabel;
  final String parentName;

  const ParentAddressMapDialog({
    super.key,
    required this.lat,
    required this.lng,
    required this.addressLabel,
    required this.parentName,
  });

  /// فتح النافذة المنبثقة من أي شاشة بسهولة
  static Future<void> show(
    BuildContext context, {
    required double lat,
    required double lng,
    required String addressLabel,
    required String parentName,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ParentAddressMapDialog(
        lat: lat,
        lng: lng,
        addressLabel: addressLabel,
        parentName: parentName,
      ),
    );
  }

  @override
  State<ParentAddressMapDialog> createState() => _ParentAddressMapDialogState();
}

class _ParentAddressMapDialogState extends State<ParentAddressMapDialog> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _centerMap() {
    _mapController.move(
      LatLng(widget.lat, widget.lng),
      16,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final targetLocation = LatLng(widget.lat, widget.lng);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: 720,
          height: 560,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: context.cardColor,
          ),
          child: Column(
            children: [
              // ─── Header ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: theme.dividerColor)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.map_rounded,
                        color: context.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'موقع ولي الأمر على الخريطة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.parentName.isNotEmpty
                                ? widget.parentName
                                : 'ولي الأمر',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'إغلاق',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // ─── Address Info Bar ────────────────────────────────
              if (widget.addressLabel.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: context.surfaceVariant,
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: context.primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.addressLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              // ─── Map View ─────────────────────────────────────────
              Expanded(
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: targetLocation,
                        initialZoom: 15.5,
                        minZoom: 4,
                        maxZoom: 19,
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
                              point: targetLocation,
                              width: 60,
                              height: 60,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: context.primaryColor.withValues(alpha: 0.3),
                                          blurRadius: 10,
                                          spreadRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.location_pin,
                                      color: context.dangerColor,
                                      size: 46,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Controls Overlay (Zoom In, Zoom Out, Re-center)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMapActionButton(
                            icon: Icons.my_location_rounded,
                            tooltip: 'إعادة التمركز',
                            onPressed: _centerMap,
                          ),
                          const SizedBox(height: 8),
                          _buildMapActionButton(
                            icon: Icons.add_rounded,
                            tooltip: 'تكبير',
                            onPressed: () {
                              final currentZoom = _mapController.camera.zoom;
                              _mapController.move(
                                _mapController.camera.center,
                                (currentZoom + 1).clamp(4.0, 19.0),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildMapActionButton(
                            icon: Icons.remove_rounded,
                            tooltip: 'تصغير',
                            onPressed: () {
                              final currentZoom = _mapController.camera.zoom;
                              _mapController.move(
                                _mapController.camera.center,
                                (currentZoom - 1).clamp(4.0, 19.0),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Footer ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  border: Border(top: BorderSide(color: theme.dividerColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('إغلاق'),
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

  Widget _buildMapActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Theme.of(context).cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: context.textPrimary),
          ),
        ),
      ),
    );
  }
}
