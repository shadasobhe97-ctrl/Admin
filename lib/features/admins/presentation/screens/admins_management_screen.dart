import 'package:flutter/material.dart';
import '../../../../core/network/admin_api_service.dart';
import '../../../../core/theme/derbi_colors.dart';

class AdminsManagementScreen extends StatefulWidget {
  const AdminsManagementScreen({super.key});

  @override
  State<AdminsManagementScreen> createState() => _AdminsManagementScreenState();
}

class _AdminsManagementScreenState extends State<AdminsManagementScreen> {
  final AdminApiService _apiService = AdminApiService();
  bool _isLoading = true;
  List<dynamic> _admins = [];

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    setState(() => _isLoading = true);
    final res = await _apiService.getAdmins();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res['data'] != null && res['data']['data'] is List) {
          _admins = res['data']['data'];
        } else if (res['data'] is List) {
          _admins = res['data'];
        }
      });
    }
  }

  String _adminName(Map<String, dynamic> admin) => admin['name'] ?? admin['full_name'] ?? 'مشرف بدون اسم';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'قائمة المشرفين وإدارة الصلاحيات الإدارية',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.primaryBlue),
              onPressed: () => _showAddAdminModal(context),
              icon: const Icon(Icons.add_moderator, size: 16),
              label: const Text('إضافة مشرف جديد'),
            )
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _admins.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.admin_panel_settings_outlined, size: 60, color: DerbiColors.textMuted),
                          const SizedBox(height: 12),
                          const Text('لا يوجد مشرفين مسجلين', style: TextStyle(color: DerbiColors.textMuted)),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: _loadAdmins, child: const Text('إعادة المحاولة')),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _admins.length,
                      itemBuilder: (ctx, index) {
                        final admin = _admins[index];
                        final name = _adminName(admin);
                        return Card(
                          color: DerbiColors.surfaceCard,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: DerbiColors.borderSlate),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: DerbiColors.primaryBlue.withValues(alpha: 0.2),
                              child: Text(
                                name.isNotEmpty ? name[0] : 'أ',
                                style: const TextStyle(color: DerbiColors.primaryBlue, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                            ),
                            subtitle: Text(
                              'البريد: ${admin['email']} • الدور: ${admin['role'] ?? 'مشرف نظام'}',
                              style: const TextStyle(fontSize: 11, color: DerbiColors.textMuted),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: DerbiColors.borderSlate),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => _showEditAdminModal(context, admin),
                                  icon: const Icon(Icons.edit, size: 14),
                                  label: const Text('تعديل البيانات'),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip: 'حذف المشرف',
                                  icon: const Icon(Icons.delete_outline, color: DerbiColors.dangerRose),
                                  onPressed: () => _confirmDeleteAdmin(context, admin),
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

  void _showAddAdminModal(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final passwordConfirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: DerbiColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('إضافة مشرف إداري جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(labelText: 'كلمة المرور'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordConfirmController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: DerbiColors.textMuted))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.primaryBlue),
              onPressed: () async {
                if (nameController.text.isEmpty || emailController.text.isEmpty) return;
                if (passwordController.text != passwordConfirmController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('كلمة المرور وتأكيدها غير متطابقين.'), backgroundColor: DerbiColors.dangerRose),
                  );
                  return;
                }
                final messenger = ScaffoldMessenger.of(context);
                final res = await _apiService.createAdmin({
                  "name": nameController.text.trim(),
                  "email": emailController.text.trim(),
                  "password": passwordController.text.trim(),
                  "password_confirmation": passwordConfirmController.text.trim(),
                  "phone": phoneController.text.trim(),
                });
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'تم إضافة المشرف بنجاح!'), backgroundColor: DerbiColors.successEmerald),
                );
                _loadAdmins();
              },
              child: const Text('إضافة المشرف'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAdminModal(BuildContext context, Map<String, dynamic> admin) {
    final nameController = TextEditingController(text: _adminName(admin));
    final phoneController = TextEditingController(text: admin['phone'] ?? admin['phone_number'] ?? '');
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: DerbiColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('تعديل بيانات المشرف: ${_adminName(admin)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(labelText: 'الاسم الكامل المعدل'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(labelText: 'كلمة مرور جديدة (اختياري)'),
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
                final data = <String, dynamic>{
                  "name": nameController.text.trim(),
                  "phone": phoneController.text.trim(),
                };
                if (passwordController.text.trim().isNotEmpty) {
                  data["password"] = passwordController.text.trim();
                }
                final res = await _apiService.updateAdmin(admin['id'], data);
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'تم تحديث بيانات المشرف بنجاح.'), backgroundColor: DerbiColors.successEmerald),
                );
                _loadAdmins();
              },
              child: const Text('حفظ التعديلات'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAdmin(BuildContext context, Map<String, dynamic> admin) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: DerbiColors.surfaceCard,
          title: const Text('تأكيد حذف المشرف', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text('هل أنت متأكد من رغبتك في حذف المشرف "${_adminName(admin)}"؟', style: const TextStyle(color: DerbiColors.textSecondary, fontSize: 13)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: DerbiColors.textMuted))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.dangerRose),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final res = await _apiService.deleteAdmin(admin['id']);
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'تم حذف المشرف بنجاح.'), backgroundColor: DerbiColors.dangerRose),
                );
                _loadAdmins();
              },
              child: const Text('حذف المشرف'),
            ),
          ],
        ),
      ),
    );
  }
}
