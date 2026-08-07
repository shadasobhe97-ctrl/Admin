import 'package:flutter/material.dart';
import '../../../../core/network/admin_api_service.dart';
import '../../../../core/theme/derbi_colors.dart';

class SchoolsManagementScreen extends StatefulWidget {
  const SchoolsManagementScreen({super.key});

  @override
  State<SchoolsManagementScreen> createState() => _SchoolsManagementScreenState();
}

class _SchoolsManagementScreenState extends State<SchoolsManagementScreen> {
  final AdminApiService _apiService = AdminApiService();
  bool _isLoading = true;
  List<dynamic> _schools = [];
  List<dynamic> _zones = [];

  @override
  void initState() {
    super.initState();
    _loadSchools();
    _loadZones();
  }

  Future<void> _loadSchools() async {
    setState(() => _isLoading = true);
    final res = await _apiService.getSchools();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res['data'] is List) {
          _schools = res['data'];
        }
      });
    }
  }

  Future<void> _loadZones() async {
    final res = await _apiService.getZones();
    if (mounted && res['data'] is List) {
      setState(() => _zones = res['data']);
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
              'دليل المدارس والربط الجغرافي المعتمد',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.primaryBlue),
              onPressed: () => _showAddSchoolModal(context),
              icon: const Icon(Icons.school, size: 16),
              label: const Text('إضافة مدرسة جديدة'),
            )
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _schools.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school_outlined, size: 60, color: DerbiColors.textMuted),
                          const SizedBox(height: 12),
                          const Text('لا توجد مدارس مسجلة حالياً', style: TextStyle(color: DerbiColors.textMuted)),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: _loadSchools, child: const Text('تحديث البيانات')),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _schools.length,
                      itemBuilder: (ctx, index) {
                        final school = _schools[index];
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
                              child: Icon(Icons.school, color: Colors.white, size: 20),
                            ),
                            title: Text(
                              school['name'] ?? 'مدرسة بدون اسم',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                            ),
                            subtitle: Text(
                              'العنوان: ${school['address'] ?? 'غير محدد'}'
                              '${school['zone_name'] != null ? ' • المنطقة: ${school['zone_name']}' : ''}',
                              style: const TextStyle(fontSize: 11, color: DerbiColors.textMuted),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'تعديل البيانات والموقع',
                                  icon: const Icon(Icons.edit, color: DerbiColors.primaryBlue, size: 20),
                                  onPressed: () => _showEditSchoolModal(context, school),
                                ),
                                IconButton(
                                  tooltip: 'حذف المدرسة',
                                  icon: const Icon(Icons.delete_outline, color: DerbiColors.dangerRose, size: 20),
                                  onPressed: () => _confirmDeleteSchool(context, school),
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

  void _showAddSchoolModal(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final latController = TextEditingController(text: '32.890000');
    final lngController = TextEditingController(text: '13.180000');
    dynamic selectedZoneId = _zones.isNotEmpty ? _zones.first['id'] : null;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            backgroundColor: DerbiColors.surfaceCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('إضافة مدرسة جديدة للنظام', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: const InputDecoration(labelText: 'اسم المدرسة الرسمي'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: const InputDecoration(labelText: 'العنوان الجغرافي (المنطقة والشارع)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<dynamic>(
                    value: selectedZoneId,
                    dropdownColor: DerbiColors.surfaceCard,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: const InputDecoration(labelText: 'المنطقة الجغرافية'),
                    items: _zones.map((z) => DropdownMenuItem(value: z['id'], child: Text(z['name'] ?? '#${z['id']}'))).toList(),
                    onChanged: (val) => setDialogState(() => selectedZoneId = val),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: latController,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          decoration: const InputDecoration(labelText: 'دائرة العرض (Latitude)'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: lngController,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          decoration: const InputDecoration(labelText: 'خط الطول (Longitude)'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: DerbiColors.textMuted))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.primaryBlue),
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final messenger = ScaffoldMessenger.of(context);
                    final res = await _apiService.createSchool({
                      "name": nameController.text.trim(),
                      "address": addressController.text.trim(),
                      "latitude": double.tryParse(latController.text) ?? 32.89,
                      "longitude": double.tryParse(lngController.text) ?? 13.18,
                      "zone_id": selectedZoneId,
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                    messenger.showSnackBar(
                      SnackBar(content: Text(res['message'] ?? 'تم إضافة المدرسة بنجاح!'), backgroundColor: DerbiColors.successEmerald),
                    );
                    _loadSchools();
                  }
                },
                child: const Text('حفظ وإضافة المدرسة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSchoolModal(BuildContext context, Map<String, dynamic> school) {
    final nameController = TextEditingController(text: school['name']);
    final latController = TextEditingController(text: school['latitude'].toString());
    final lngController = TextEditingController(text: school['longitude'].toString());

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: DerbiColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('تعديل مدرسة: ${school['name']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(labelText: 'اسم المدرسة المعدل'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latController,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        decoration: const InputDecoration(labelText: 'Latitude'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: lngController,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        decoration: const InputDecoration(labelText: 'Longitude'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: DerbiColors.textMuted))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.successEmerald),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final res = await _apiService.updateSchool(school['id'], {
                  "name": nameController.text.trim(),
                  "latitude": double.tryParse(latController.text) ?? school['latitude'],
                  "longitude": double.tryParse(lngController.text) ?? school['longitude'],
                });
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'تم تحديث المدرسة بنجاح.'), backgroundColor: DerbiColors.successEmerald),
                );
                _loadSchools();
              },
              child: const Text('حفظ التغييرات'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteSchool(BuildContext context, Map<String, dynamic> school) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: DerbiColors.surfaceCard,
          title: const Text('تأكيد حذف المدرسة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text('هل أنت تأكد من رغبتك في حذف مدرسة "${school['name']}" من النظام نهائياً؟', style: const TextStyle(color: DerbiColors.textSecondary, fontSize: 13)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: DerbiColors.textMuted))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.dangerRose),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final res = await _apiService.deleteSchool(school['id']);
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'تم حذف المدرسة بنجاح.'), backgroundColor: DerbiColors.dangerRose),
                );
                _loadSchools();
              },
              child: const Text('حذف المدرسة'),
            ),
          ],
        ),
      ),
    );
  }
}
