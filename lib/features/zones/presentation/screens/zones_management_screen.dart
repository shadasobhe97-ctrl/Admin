import 'package:flutter/material.dart';
import '../../../../core/network/admin_api_service.dart';
import '../../../../core/theme/derbi_colors.dart';

class ZonesManagementScreen extends StatefulWidget {
  const ZonesManagementScreen({super.key});

  @override
  State<ZonesManagementScreen> createState() => _ZonesManagementScreenState();
}

class _ZonesManagementScreenState extends State<ZonesManagementScreen> {
  final AdminApiService _apiService = AdminApiService();
  bool _isLoading = true;
  List<dynamic> _zones = [];

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    setState(() => _isLoading = true);
    final res = await _apiService.getZones();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res['data'] is List) {
          _zones = res['data'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'إدارة المناطق الجغرافية والبلديات في طرابلس',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.primaryBlue),
              onPressed: () => _showAddZoneModal(context),
              icon: const Icon(Icons.add_location_alt, size: 16),
              label: const Text('إضافة منطقة جغرافية جديدة'),
            )
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _zones.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map_outlined, size: 60, color: DerbiColors.textMuted),
                          const SizedBox(height: 12),
                          const Text('لا توجد مناطق جغرافية مسجلة', style: TextStyle(color: DerbiColors.textMuted)),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: _loadZones, child: const Text('تحديث البيانات')),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _zones.length,
                      itemBuilder: (ctx, index) {
                        final zone = _zones[index];
                        return Card(
                          color: DerbiColors.surfaceCard,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: DerbiColors.borderSlate),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: DerbiColors.primaryBlue,
                              child: Icon(Icons.location_city, color: Colors.white, size: 20),
                            ),
                            title: Text(
                              zone['name'] ?? 'منطقة بدون اسم',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                            ),
                            subtitle: Text(
                              'معرّف البلدية الفرعية: ${zone['sub_municipality_id'] ?? 1}',
                              style: const TextStyle(fontSize: 11, color: DerbiColors.textMuted),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'تعديل اسم المنطقة',
                                  icon: const Icon(Icons.edit, color: DerbiColors.primaryBlue, size: 20),
                                  onPressed: () => _showEditZoneModal(context, zone),
                                ),
                                IconButton(
                                  tooltip: 'حذف المنطقة',
                                  icon: const Icon(Icons.delete_outline, color: DerbiColors.dangerRose, size: 20),
                                  onPressed: () => _confirmDeleteZone(context, zone),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        )
      ],
    );
  }

  void _showAddZoneModal(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: DerbiColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('إضافة منطقة جغرافية جديدة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: 380,
            child: TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(labelText: 'اسم المنطقة (مثال: منطقة عين زارة)'),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: DerbiColors.textMuted))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.primaryBlue),
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final messenger = ScaffoldMessenger.of(context);
                  final res = await _apiService.createZone({
                    "name": nameController.text.trim(),
                    "sub_municipality_id": 2,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  messenger.showSnackBar(
                    SnackBar(content: Text(res['message'] ?? 'تم إضافة المنطقة بنجاح!'), backgroundColor: DerbiColors.successEmerald),
                  );
                  _loadZones();
                }
              },
              child: const Text('إضافة المنطقة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditZoneModal(BuildContext context, Map<String, dynamic> zone) {
    final nameController = TextEditingController(text: zone['name']);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: DerbiColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('تعديل المنطقة: ${zone['name']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: 380,
            child: TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(labelText: 'الاسم الجديد للمنطقة'),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: DerbiColors.textMuted))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.successEmerald),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final res = await _apiService.updateZone(zone['id'], nameController.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'تم تعديل المنطقة بنجاح.'), backgroundColor: DerbiColors.successEmerald),
                );
                _loadZones();
              },
              child: const Text('حفظ التعديل'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteZone(BuildContext context, Map<String, dynamic> zone) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: DerbiColors.surfaceCard,
          title: const Text('تأكيد حذف المنطقة الجغرافية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text('هل أنت تأكد من رغبتك في حذف منطقة "${zone['name']}"؟', style: const TextStyle(color: DerbiColors.textSecondary, fontSize: 13)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: DerbiColors.textMuted))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.dangerRose),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final res = await _apiService.deleteZone(zone['id']);
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'تم حذف المنطقة بنجاح.'), backgroundColor: DerbiColors.dangerRose),
                );
                _loadZones();
              },
              child: const Text('حذف المنطقة'),
            ),
          ],
        ),
      ),
    );
  }
}
