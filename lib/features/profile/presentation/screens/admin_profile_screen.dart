import 'package:flutter/material.dart';
import '../../../../core/theme/derbi_colors.dart';

class AdminProfileView extends StatefulWidget {
  final String adminName;
  final ValueChanged<String> onNameChanged;

  const AdminProfileView({
    super.key,
    required this.adminName,
    required this.onNameChanged,
  });

  @override
  State<AdminProfileView> createState() => _AdminProfileViewState();
}

class _AdminProfileViewState extends State<AdminProfileView> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.adminName);
    _emailController = TextEditingController(text: 'admin@derbi.ly');
    _phoneController = TextEditingController(text: '091-1234567');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Banner Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: DerbiColors.surfaceCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: DerbiColors.borderSlate),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: DerbiColors.primaryBlue,
                  child: Text(
                    widget.adminName.isNotEmpty ? widget.adminName[0] : 'ع',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.adminName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'مدير عام المنظومة والربط المركزي • طرابلس',
                        style: TextStyle(fontSize: 12, color: DerbiColors.primaryBlue, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: const [
                          Icon(Icons.security, size: 14, color: DerbiColors.successEmerald),
                          SizedBox(width: 6),
                          Text('مستوى الأمان: صلاحيات كاملة 2FA مفعل', style: TextStyle(fontSize: 11, color: DerbiColors.textMuted)),
                        ],
                      )
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEditing ? DerbiColors.warningAmber : DerbiColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                  onPressed: () => setState(() => _isEditing = !_isEditing),
                  icon: Icon(_isEditing ? Icons.visibility : Icons.edit, size: 16),
                  label: Text(_isEditing ? 'معاينة العرض الاحترافي' : 'تعديل البيانات'),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Display or Edit Mode Content
          if (!_isEditing) ...[
            // Read-Only Professional View Mode
            Card(
              color: DerbiColors.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: DerbiColors.borderSlate),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('المعلومات الشخصية والإدارية', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                    const Divider(color: DerbiColors.borderSlate, height: 24),
                    ProfileDetailRow(title: 'الاسم الكامل للمسؤول', value: widget.adminName),
                    ProfileDetailRow(title: 'البريد الإلكتروني الرسمي', value: _emailController.text),
                    ProfileDetailRow(title: 'رقم الهاتف المحمول', value: _phoneController.text),
                    ProfileDetailRow(title: 'المقر المكتبي الرئيسي', value: 'طرابلس - حي الأندلس'),
                    ProfileDetailRow(title: 'حالة الحساب والأمان', value: 'نشط • 2FA مشفر بالكامل'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Active Sessions & Devices
            Card(
              color: DerbiColors.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: DerbiColors.borderSlate),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الأجهزة المتصلة وسجل النشاط الأخير', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                    const Divider(color: DerbiColors.borderSlate, height: 24),
                    ListTile(
                      leading: const Icon(Icons.laptop_mac, color: DerbiColors.primaryBlue),
                      title: const Text('متصفح Chrome - Windows Desktop', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: const Text('طرابلس، ليبيا • النشاط الحالي الآن (هذه الجلسة)', style: TextStyle(fontSize: 11, color: DerbiColors.textMuted)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: DerbiColors.successEmerald.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                        child: const Text('متصل الان', style: TextStyle(fontSize: 10, color: DerbiColors.successEmerald, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ] else ...[
            // Interactive Edit Mode Form
            Card(
              color: DerbiColors.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: DerbiColors.borderSlate),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('تعديل اسم المسؤول والبيانات الإدارية', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'اسم المسؤول الكامل',
                        prefixIcon: Icon(Icons.person, color: DerbiColors.primaryBlue),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني الرسمي',
                        prefixIcon: Icon(Icons.email, color: DerbiColors.primaryBlue),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف المحمول',
                        prefixIcon: Icon(Icons.phone, color: DerbiColors.primaryBlue),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => setState(() => _isEditing = false),
                          child: const Text('إلغاء', style: TextStyle(color: DerbiColors.textMuted)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: DerbiColors.successEmerald),
                          onPressed: () {
                            widget.onNameChanged(_nameController.text);
                            setState(() => _isEditing = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم حفظ وتحديث بيانات الملف الشخصي بنجاح!'), backgroundColor: DerbiColors.successEmerald),
                            );
                          },
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('حفظ التغييرات'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}

class ProfileDetailRow extends StatelessWidget {
  final String title;
  final String value;

  const ProfileDetailRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: DerbiColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
