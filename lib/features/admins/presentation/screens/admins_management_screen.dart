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
                                admin['full_name'] != null && admin['full_name'].toString().isNotEmpty
                                    ? admin['full_name'][0]
                                    : 'أ',
                                style: const TextStyle(color: DerbiColors.primaryBlue, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              admin['full_name'] ?? 'مشرف بدون اسم',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                            ),
                            subtitle: Text(
                              'البريد: ${admin['email']} • الدور: ${admin['role'] ?? 'مشرف نظام'}',
                              style: const TextStyle(fontSize: 11, color: DerbiColors.textMuted),
                            ),
                            trailing: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: DerbiColors.borderSlate),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => _showEditAdminModal(context, admin),
                              icon: const Icon(Icons.edit, size: 14),
                              label: const Text('تعديل البيانات'),
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
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: DerbiColors.textMuted))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.primaryBlue),
              onPressed: () async {
                if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                  final messenger = ScaffoldMessenger.of(context);
                  final res = await _apiService.createAdmin({
                    "full_name": nameController.text.trim(),
                    "email": emailController.text.trim(),
                    "phone_number": phoneController.text.trim(),
                    "password": passwordController.text.trim(),
                    "role_id": 1,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  messenger.showSnackBar(
                    SnackBar(content: Text(res['message'] ?? 'تم إضافة المشرف بنجاح!'), backgroundColor: DerbiColors.successEmerald),
                  );
                  _loadAdmins();
                }
              },
              child: const Text('إضافة المشرف'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAdminModal(BuildContext context, Map<String, dynamic> admin) {
    final nameController = TextEditingController(text: admin['full_name']);
    final emailController = TextEditingController(text: admin['email']);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: DerbiColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('تعديل بيانات المشرف: ${admin['full_name']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
                  controller: emailController,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني الجديد'),
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
                final res = await _apiService.updateAdmin(admin['id'], {
                  "full_name": nameController.text.trim(),
                  "email": emailController.text.trim(),
                });
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
}
