import 'package:flutter/material.dart';
import '../../../../core/network/admin_api_service.dart';
import '../../../../core/theme/derbi_colors.dart';

class DriverInspectorView extends StatefulWidget {
  const DriverInspectorView({super.key});

  @override
  State<DriverInspectorView> createState() => _DriverInspectorViewState();
}

class _DriverInspectorViewState extends State<DriverInspectorView> {
  final AdminApiService _apiService = AdminApiService();
  String _selectedTab = 'الكل';
  String _searchQuery = '';
  bool _isLoading = true;
  List<dynamic> _drivers = [];

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    setState(() => _isLoading = true);
    final statusFilter = _selectedTab == 'الكل'
        ? null
        : (_selectedTab == 'بانتظار المراجعة' ? 'Pending' : (_selectedTab == 'معتمد' ? 'Approved' : 'Rejected'));

    final res = await _apiService.getDrivers(status: statusFilter, search: _searchQuery);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res['data'] is List) {
          _drivers = res['data'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Tabs & Search Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: ['الكل', 'بانتظار المراجعة', 'معتمد', 'مرفوض'].map((tab) {
                final isSel = _selectedTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ChoiceChip(
                    label: Text(tab),
                    selected: isSel,
                    selectedColor: DerbiColors.primaryBlue,
                    backgroundColor: DerbiColors.surfaceCard,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : DerbiColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedTab = tab);
                      _loadDrivers();
                    },
                  ),
                );
              }).toList(),
            ),
            SizedBox(
              width: 280,
              child: TextField(
                onChanged: (v) {
                  _searchQuery = v;
                  _loadDrivers();
                },
                style: const TextStyle(fontSize: 12, color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'ابحث باسم السائق أو رقم الهاتف...',
                  prefixIcon: Icon(Icons.search, size: 18, color: DerbiColors.textMuted),
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 20),

        // Drivers List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _drivers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder_off_outlined, size: 60, color: DerbiColors.textMuted),
                          const SizedBox(height: 12),
                          const Text('لا توجد ملفات سائقين في هذه الفئة', style: TextStyle(color: DerbiColors.textSecondary, fontSize: 13)),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: _loadDrivers, child: const Text('تحديث القائمة')),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _drivers.length,
                      itemBuilder: (context, index) {
                        final d = _drivers[index];
                        return _buildDriverDocCard(d);
                      },
                    ),
        )
      ],
    );
  }

  Widget _buildDriverDocCard(Map<String, dynamic> driver) {
    final status = driver['status'] ?? 'Pending';
    Color statusColor = DerbiColors.warningAmber;
    String statusText = 'بانتظار المراجعة';

    if (status == 'Approved') {
      statusColor = DerbiColors.successEmerald;
      statusText = 'معتمد';
    } else if (status == 'Rejected') {
      statusColor = DerbiColors.dangerRose;
      statusText = 'مرفوض';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DerbiColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DerbiColors.borderSlate),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: statusColor.withValues(alpha: 0.15),
            child: Text(
              driver['full_name'] != null && driver['full_name'].toString().isNotEmpty
                  ? driver['full_name'][0]
                  : 'س',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'السائق: ${driver['full_name'] ?? 'بدون اسم'}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: DerbiColors.background,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: DerbiColors.borderSlate),
                      ),
                      child: Text('#DRV-${driver['id']}', style: const TextStyle(fontSize: 10, color: DerbiColors.textMuted, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: DerbiColors.textMuted),
                    const SizedBox(width: 4),
                    Text('الهاتف: ${driver['phone_number'] ?? 'غير محدد'} • البريد: ${driver['email'] ?? ''}', style: const TextStyle(fontSize: 11, color: DerbiColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'الرقم الوطني: ${driver['national_id'] ?? 'غير مدخل'} • رقم الرخصة: ${driver['license_number'] ?? 'غير مدخل'}',
                  style: const TextStyle(fontSize: 11, color: DerbiColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.primaryBlue),
            onPressed: () => _fetchAndShowDriverDetails(driver['id']),
            icon: const Icon(Icons.folder_special, size: 16),
            label: const Text('فحص وتدقيق الوثائق'),
          )
        ],
      ),
    );
  }

  Future<void> _fetchAndShowDriverDetails(dynamic driverId) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    final detailRes = await _apiService.getDriverDetails(driverId);
    if (mounted) {
      Navigator.pop(context); // Dismiss loading
      final driverData = detailRes['data'] ?? {};
      _showVerifyDialog(context, driverData);
    }
  }

  void _showVerifyDialog(BuildContext context, Map<String, dynamic> driverData) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: DerbiColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.verified_user, color: DerbiColors.primaryBlue),
              const SizedBox(width: 10),
              Text('تدقيق وثائق السائق: ${driverData['full_name'] ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: DerbiColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DerbiColors.borderSlate),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.badge_outlined, size: 50, color: DerbiColors.primaryBlue),
                            SizedBox(height: 8),
                            Text('وثيقة رخصة القيادة والكتيب المرفق', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text('تاريخ انتهاء الرخصة: ${driverData['license_expiry'] ?? 'غير معروف'}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                const SizedBox(height: 10),
                const Text('سبب الرفض (مطلوب فقط في حال اختيار الرفض):', style: TextStyle(color: DerbiColors.textMuted, fontSize: 11)),
                const SizedBox(height: 6),
                TextField(
                  controller: reasonController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'اكتب سبب الرفض هنا (مثلاً: صورة الرخصة غير واضحة)...',
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final res = await _apiService.reviewDriver(driverData['id'], action: 'reject', rejectionReason: reasonController.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'تم رفض طلب السائق.'), backgroundColor: DerbiColors.dangerRose),
                );
                _loadDrivers();
              },
              child: const Text('رفض السائق', style: TextStyle(color: DerbiColors.dangerRose, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.successEmerald),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final res = await _apiService.reviewDriver(driverData['id'], action: 'approve');
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'تم قبول وتفعيل حساب السائق بنجاح!'), backgroundColor: DerbiColors.successEmerald),
                );
                _loadDrivers();
              },
              child: const Text('قبول وتفعيل الحساب'),
            ),
          ],
        ),
      ),
    );
  }
}
