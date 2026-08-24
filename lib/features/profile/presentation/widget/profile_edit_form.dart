import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/remote_circle_avatar.dart';
import '../../../../core/utils/media_url.dart';
import '../../data/models/admin_profile_model.dart';
import '../../data/models/profile_update_request.dart';

class ProfileEditForm extends StatefulWidget {
  final AdminProfileModel profile;
  final bool isSaving;
  final Map<String, List<String>>? fieldErrors;
  final Function(ProfileUpdateRequest request) onSave;
  final VoidCallback onCancel;

  const ProfileEditForm({
    super.key,
    required this.profile,
    required this.isSaving,
    this.fieldErrors,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _currentPassCtrl;
  late final TextEditingController _newPassCtrl;
  late final TextEditingController _confirmPassCtrl;

  bool _currentPassVisible = false;
  bool _newPassVisible = false;
  bool _confirmPassVisible = false;

  Uint8List? _avatarBytes;
  String? _avatarFileName;
  String? _avatarFileError;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.fullName);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _phoneCtrl = TextEditingController(text: widget.profile.phoneNumber);
    _currentPassCtrl = TextEditingController();
    _newPassCtrl = TextEditingController();
    _confirmPassCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    setState(() => _avatarFileError = null);
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final ext = image.name.split('.').last.toLowerCase();
        if (ext != 'jpeg' && ext != 'jpg' && ext != 'png') {
          setState(() {
            _avatarFileError = 'امتداد الصورة يجب أن يكون jpeg أو jpg أو png فقط.';
          });
          return;
        }

        final bytes = await image.readAsBytes();
        if (bytes.length > 2 * 1024 * 1024) {
          setState(() {
            _avatarFileError = 'حجم الصورة يتجاوز الحد الأقصى المسموح به (2MB).';
          });
          return;
        }

        setState(() {
          _avatarBytes = bytes;
          _avatarFileName = image.name;
          _avatarFileError = null;
        });
      }
    } catch (e) {
      setState(() {
        _avatarFileError = 'تعذر اختيار الصورة: ${e.toString()}';
      });
    }
  }

  void _removeAvatar() {
    setState(() {
      _avatarBytes = null;
      _avatarFileName = null;
      _avatarFileError = null;
    });
  }

  String? _getFieldError(String fieldName) {
    if (widget.fieldErrors == null || !widget.fieldErrors!.containsKey(fieldName)) {
      return null;
    }
    final errors = widget.fieldErrors![fieldName];
    if (errors != null && errors.isNotEmpty) {
      return errors.first;
    }
    return null;
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (widget.isSaving) return;

    final newName = _nameCtrl.text.trim();
    final newEmail = _emailCtrl.text.trim();
    final newPhone = _phoneCtrl.text.trim();
    final currentPass = _currentPassCtrl.text;
    final newPass = _newPassCtrl.text;
    final confirmPass = _confirmPassCtrl.text;

    // Local Contract Validations:
    // Full Name: Arabic letters and spaces only, min 3 words
    final isArabic = RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(newName);
    if (!isArabic) {
      _showSnack('الاسم الكامل يجب أن يحتوي على أحرف عربية فقط.', isError: true);
      return;
    }

    final wordsCount = newName.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    if (wordsCount < 3) {
      _showSnack('الاسم الكامل يجب أن يتكون من 3 كلمات على الأقل.', isError: true);
      return;
    }

    // Phone Number: 10 digits starting with 09
    if (!RegExp(r'^09\d{8}$').hasMatch(newPhone)) {
      _showSnack('رقم الهاتف يجب أن يتكون من 10 أرقام ويبدأ بـ 09.', isError: true);
      return;
    }

    // Password validation
    if (newPass.isNotEmpty) {
      if (currentPass.isEmpty) {
        _showSnack('يرجى إدخال كلمة المرور الحالية لتتمكن من تغيير كلمة المرور.', isError: true);
        return;
      }
      if (newPass.length < 6) {
        _showSnack('كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل.', isError: true);
        return;
      }
      if (!RegExp(r'[a-zA-Z]').hasMatch(newPass)) {
        _showSnack('كلمة المرور الجديدة يجب أن تحتوي على حرف واحد على الأقل.', isError: true);
        return;
      }
      if (newPass != confirmPass) {
        _showSnack('تأكيد كلمة المرور غير مطابق لكلمة المرور الجديدة.', isError: true);
        return;
      }
    }

    final request = ProfileUpdateRequest(
      fullName: newName != widget.profile.fullName ? newName : null,
      email: newEmail != widget.profile.email ? newEmail : null,
      phoneNumber: newPhone != widget.profile.phoneNumber ? newPhone : null,
      currentPassword: newPass.isNotEmpty ? currentPass : null,
      password: newPass.isNotEmpty ? newPass : null,
      passwordConfirmation: newPass.isNotEmpty ? confirmPass : null,
      avatarBytes: _avatarBytes,
      avatarFileName: _avatarFileName,
    );

    if (request.isEmpty) {
      _showSnack('لم تقم بإجراء أي تغييرات على البيانات.', isError: false);
      return;
    }

    widget.onSave(request);
  }

  void _showSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final avatarResolvedUrl = MediaUrl.resolve(widget.profile.avatarUrl);

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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'تعديل البيانات والملف الشخصي',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),

            // ── Avatar Pick Section ──
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      RemoteCircleAvatar(
                        rawUrl: avatarResolvedUrl,
                        radius: 46,
                        bytes: _avatarBytes,
                        fallbackIcon: Icons.person_rounded,
                        foregroundColor: primaryColor,
                        backgroundColor: primaryColor.withValues(alpha: 0.15),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickAvatar,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.cardColor, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickAvatar,
                        icon: const Icon(Icons.photo_library_rounded, size: 16),
                        label: Text(_avatarBytes != null ? 'تغيير الصورة' : 'اختيار صورة جديدة'),
                      ),
                      if (_avatarBytes != null) ...[
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: _removeAvatar,
                          icon: const Icon(Icons.close_rounded, size: 16, color: Colors.red),
                          label: const Text('إلغاء الصورة', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '• مسموح بصور jpeg, jpg, png بحد أقصى 2MB',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                  if (_avatarFileError != null || _getFieldError('avatar') != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _avatarFileError ?? _getFieldError('avatar')!,
                      style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Full Name ──
            TextFormField(
              controller: _nameCtrl,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: 'الاسم الكامل (عربي فقط - 3 كلمات على الأقل)',
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
                errorText: _getFieldError('full_name'),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'الاسم الكامل مطلوب';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Email ──
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                helperText: 'ملاحظة: تغيير البريد الإلكتروني سيبدأ عملية التأكيد عبر رابط البريد.',
                prefixIcon: const Icon(Icons.email_outlined, size: 18),
                errorText: _getFieldError('email'),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'البريد الإلكتروني مطلوب';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Phone Number ──
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف (10 أرقام يبدأ بـ 09)',
                prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                errorText: _getFieldError('phone_number'),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'رقم الهاتف مطلوب';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // ── Password Section Divider ──
            Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 16, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'تغيير كلمة المرور (اختياري)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 12),

            // ── Current Password ──
            TextFormField(
              controller: _currentPassCtrl,
              obscureText: !_currentPassVisible,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الحالية',
                hintText: 'مطلوبة فقط في حال ترغب بتغيير كلمة المرور',
                prefixIcon: const Icon(Icons.lock_clock_outlined, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(
                    _currentPassVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _currentPassVisible = !_currentPassVisible),
                ),
                errorText: _getFieldError('current_password'),
              ),
            ),
            const SizedBox(height: 14),

            // ── New Password ──
            TextFormField(
              controller: _newPassCtrl,
              obscureText: !_newPassVisible,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                hintText: '6 أحرف على الأقل وتتضمن حرفاً واحداً',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(
                    _newPassVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _newPassVisible = !_newPassVisible),
                ),
                errorText: _getFieldError('password'),
              ),
            ),
            const SizedBox(height: 14),

            // ── Confirm Password ──
            TextFormField(
              controller: _confirmPassCtrl,
              obscureText: !_confirmPassVisible,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: 'تأكيد كلمة المرور الجديدة',
                prefixIcon: const Icon(Icons.lock_reset_rounded, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(
                    _confirmPassVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _confirmPassVisible = !_confirmPassVisible),
                ),
                errorText: _getFieldError('password_confirmation'),
              ),
            ),
            const SizedBox(height: 24),

            // ── Actions ──
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: widget.isSaving ? null : _handleSubmit,
                  icon: widget.isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(widget.isSaving ? 'جاري الحفظ...' : 'حفظ التغييرات'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
