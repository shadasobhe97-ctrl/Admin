import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/admin_model.dart';
import '../../data/models/create_admin_request_model.dart';
import '../../data/models/update_admin_request_model.dart';

class AdminFormWidget extends StatefulWidget {
  final AdminModel? initialAdmin;
  final int currentUserId;
  final bool isLoading;
  final Function(CreateAdminRequestModel createRequest) onCreate;
  final Function(UpdateAdminRequestModel updateRequest) onUpdate;

  const AdminFormWidget({
    super.key,
    this.initialAdmin,
    required this.currentUserId,
    required this.isLoading,
    required this.onCreate,
    required this.onUpdate,
  });

  @override
  State<AdminFormWidget> createState() => _AdminFormWidgetState();
}

class _AdminFormWidgetState extends State<AdminFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  late int _roleId;
  late bool _isActive;
  bool _isPasswordVisible = false;

  Uint8List? _avatarBytes;
  String? _avatarFileName;

  bool get _isEditMode => widget.initialAdmin != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialAdmin?.fullName ?? '');
    _emailController = TextEditingController(text: widget.initialAdmin?.email ?? '');
    _phoneController = TextEditingController(text: widget.initialAdmin?.phoneNumber ?? '');
    _passwordController = TextEditingController();

    _roleId = widget.initialAdmin?.roleId ?? 2;
    _isActive = widget.initialAdmin?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _avatarBytes = bytes;
          _avatarFileName = image.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر اختيار الصورة: ${e.toString()}')),
        );
      }
    }
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (widget.isLoading) return;

    if (_isEditMode) {
      final updateReq = UpdateAdminRequestModel(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text.trim().isNotEmpty ? _passwordController.text.trim() : null,
        roleId: _roleId,
        isActive: _isActive,
        avatarBytes: _avatarBytes,
        avatarFileName: _avatarFileName,
      );
      widget.onUpdate(updateReq);
    } else {
      final createReq = CreateAdminRequestModel(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        roleId: _roleId,
        isActive: _isActive,
        createdBy: widget.currentUserId > 0 ? widget.currentUserId : 1,
        avatarBytes: _avatarBytes,
        avatarFileName: _avatarFileName,
      );
      widget.onCreate(createReq);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Avatar Picker
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  backgroundImage: _avatarBytes != null
                      ? MemoryImage(_avatarBytes!)
                      : (widget.initialAdmin?.avatarUrl != null && widget.initialAdmin!.avatarUrl!.startsWith('http')
                          ? NetworkImage(widget.initialAdmin!.avatarUrl!) as ImageProvider
                          : null),
                  child: (_avatarBytes == null && (widget.initialAdmin?.avatarUrl == null || !widget.initialAdmin!.avatarUrl!.startsWith('http')))
                      ? const Icon(Icons.person, size: 48, color: Color(0xFF2563EB))
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Tooltip(
                    message: 'رفع/تعديل الصورة الشخصية',
                    child: IconButton.filledTonal(
                      onPressed: _pickAvatar,
                      icon: const Icon(Icons.camera_alt_rounded, size: 18, color: Color(0xFF2563EB)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Full Name
          TextFormField(
            controller: _nameController,
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 14),
            decoration: const InputDecoration(
              labelText: 'الاسم الكامل',
              hintText: 'مثال: طه القمودي',
              prefixIcon: Icon(Icons.person_outline_rounded, color: Color(0xFF2563EB)),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'الرجاء إدخال الاسم الكامل';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 14),
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              hintText: 'taha@darby.ly',
              prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF2563EB)),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
              if (!val.contains('@')) return 'بريد إلكتروني غير صحيح';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone Number
          TextFormField(
            controller: _phoneController,
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 14),
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              hintText: '0912223344',
              prefixIcon: Icon(Icons.phone_android_rounded, color: Color(0xFF2563EB)),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'الرجاء إدخال رقم الهاتف';
              if (val.trim().length < 8) return 'رقم هاتف غير صحيح';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 14),
            decoration: InputDecoration(
              labelText: _isEditMode ? 'كلمة المرور الجديدة (اختياري عند التعديل)' : 'كلمة المرور',
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF2563EB)),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            validator: (val) {
              if (!_isEditMode && (val == null || val.trim().isEmpty)) {
                return 'الرجاء إدخال كلمة المرور';
              }
              if (val != null && val.trim().isNotEmpty && val.trim().length < 8) {
                return 'كلمة المرور يجب أن تتكون من 8 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Role Dropdown
          DropdownButtonFormField<int>(
            initialValue: _roleId,
            dropdownColor: theme.cardColor,
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 14),
            decoration: const InputDecoration(
              labelText: 'الدور والصلاحية',
              prefixIcon: Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF2563EB)),
            ),
            items: const [
              DropdownMenuItem(value: 1, child: Text('أدمن نظام (Admin)')),
              DropdownMenuItem(value: 2, child: Text('مشرف عام (Supervisor)')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _roleId = val);
            },
          ),
          const SizedBox(height: 20),

          // Is Active Switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                      color: _isActive ? const Color(0xFF10B981) : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'حالة الحساب:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isActive ? 'نشط (مفعل)' : 'غير نشط (معطل)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _isActive ? const Color(0xFF10B981) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                  activeThumbColor: const Color(0xFF10B981),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: widget.isLoading ? null : _handleSubmit,
              icon: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Icon(_isEditMode ? Icons.save_rounded : Icons.person_add_rounded, size: 20),
              label: Text(
                _isEditMode ? 'حفظ التعديلات في Backend' : 'إضافة المشرف في Backend',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
