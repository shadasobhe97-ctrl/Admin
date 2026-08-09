import 'package:flutter/material.dart';
import '../../data/models/admin_profile_model.dart';

class ProfileEditForm extends StatefulWidget {
  final AdminProfileModel profile;
  final bool isSaving;
  final Function(Map<String, dynamic> changedFields) onSave;
  final VoidCallback onCancel;

  const ProfileEditForm({
    super.key,
    required this.profile,
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _passCtrl;
  bool _passVisible = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.fullName);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _phoneCtrl = TextEditingController(text: widget.profile.phoneNumber);
    _passCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final newName = _nameCtrl.text.trim();
    final newEmail = _emailCtrl.text.trim();
    final newPhone = _phoneCtrl.text.trim();
    final newPass = _passCtrl.text;

    final changed = <String, dynamic>{};

    if (newName.isNotEmpty && newName != widget.profile.fullName) {
      changed['full_name'] = newName;
    }
    if (newEmail.isNotEmpty && newEmail != widget.profile.email) {
      changed['email'] = newEmail;
    }
    if (newPhone.isNotEmpty && newPhone != widget.profile.phoneNumber) {
      changed['phone_number'] = newPhone;
    }

    if (newPass.isNotEmpty) {
      if (newPass.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('كلمة المرور يجب أن تكون 8 أحرف على الأقل'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      changed['password'] = newPass;
      changed['password_confirmation'] = newPass;
    }

    if (changed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لم تقم بإجراء أي تغييرات على البيانات'),
        ),
      );
      return;
    }

    widget.onSave(changed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'تعديل البيانات الإدارية',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 16),

          // Name Field
          TextField(
            controller: _nameCtrl,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'الاسم الكامل',
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
            ),
          ),
          const SizedBox(height: 14),

          // Email Field
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: const Icon(Icons.email_outlined, size: 18),
            ),
          ),
          const SizedBox(height: 14),

          // Phone Field
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف',
              prefixIcon: const Icon(Icons.phone_outlined, size: 18),
            ),
          ),
          const SizedBox(height: 14),

          // Password Field
          TextField(
            controller: _passCtrl,
            obscureText: !_passVisible,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'كلمة مرور جديدة (اختياري)',
              hintText: 'اتركه فارغاً إذا لم ترغب بتغييرها',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _passVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                ),
                onPressed: () => setState(() => _passVisible = !_passVisible),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '• كلمة المرور يجب أن تكون 8 أحرف على الأقل',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: widget.isSaving ? null : widget.onCancel,
                child: const Text('إلغاء'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: widget.isSaving ? null : _handleSubmit,
                icon: widget.isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 16),
                label: Text(widget.isSaving ? 'جاري الحفظ...' : 'حفظ التغييرات'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
