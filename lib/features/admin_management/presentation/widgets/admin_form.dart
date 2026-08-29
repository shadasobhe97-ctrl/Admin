import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/remote_circle_avatar.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/admin_model.dart';
import '../../data/models/create_admin_request_model.dart';
import '../../data/models/update_admin_request_model.dart';

class AdminFormWidget extends StatefulWidget {
  final AdminModel? initialAdmin;
  final int currentUserId;
  final bool isLoading;
  final String? errorMessage;
  final Function(CreateAdminRequestModel createRequest) onCreate;
  final Function(UpdateAdminRequestModel updateRequest) onUpdate;

  const AdminFormWidget({
    super.key,
    this.initialAdmin,
    required this.currentUserId,
    required this.isLoading,
    this.errorMessage,
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

  late bool _isActive;

  Uint8List? _avatarBytes;
  String? _avatarFileName;
  String? _serverEmailError;

  bool get _isEditMode => widget.initialAdmin != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialAdmin?.fullName ?? '');
    _emailController =
        TextEditingController(text: widget.initialAdmin?.email ?? '');
    _phoneController =
        TextEditingController(text: widget.initialAdmin?.phoneNumber ?? '');

    _isActive = widget.initialAdmin?.isActive ?? true;

    _emailController.addListener(_onEmailChanged);
    if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) {
      _serverEmailError = widget.errorMessage;
    }
  }

  void _onEmailChanged() {
    if (_serverEmailError != null) {
      setState(() {
        _serverEmailError = null;
      });
      _formKey.currentState?.validate();
    }
  }

  @override
  void didUpdateWidget(covariant AdminFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage != oldWidget.errorMessage &&
        widget.errorMessage != null &&
        widget.errorMessage!.isNotEmpty) {
      setState(() {
        _serverEmailError = widget.errorMessage;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.validate();
      });
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
    setState(() {
      _serverEmailError = null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (widget.isLoading) return;

    final currentRoleId = StorageService.getRoleId();
    final isCurrentMainAdmin = currentRoleId == 1;

    if (_isEditMode) {
      final updateReq = UpdateAdminRequestModel(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: null,
        isActive: isCurrentMainAdmin ? _isActive : null,
        avatarBytes: _avatarBytes,
        avatarFileName: _avatarFileName,
      );
      widget.onUpdate(updateReq);
    } else {
      final createReq = CreateAdminRequestModel(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: null,
        avatarBytes: _avatarBytes,
        avatarFileName: _avatarFileName,
      );
      widget.onCreate(createReq);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentRoleId = StorageService.getRoleId();
    final isCurrentMainAdmin = currentRoleId == 1;

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
                RemoteCircleAvatar(
                  rawUrl: widget.initialAdmin?.avatarUrl,
                  radius: 44,
                  bytes: _avatarBytes,
                  fallbackIcon: Icons.person,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Tooltip(
                    message: 'رفع/تعديل الصورة الشخصية',
                    child: IconButton.filledTonal(
                      onPressed: _pickAvatar,
                      icon: Icon(Icons.camera_alt_rounded,
                          size: 18, color: context.primaryColor),
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
            style: TextStyle(color: context.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'الاسم الثلاثي الكامل',
              hintText: 'مثال: سارة توفيق العجيلي',
              prefixIcon: Icon(Icons.person_outline_rounded,
                  color: context.primaryColor),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'حقل الاسم الكامل مطلوب، لا يمكنك تركه فارغاً.';
              }
              final words = val.trim().split(RegExp(r'\s+'));
              if (words.length < 3) {
                return 'الرجاء إدخال الاسم الثلاثي للمشرف بالكامل لتوثيق الحساب.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            style: TextStyle(color: context.textPrimary, fontSize: 14),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني',
              hintText: 'sara.supervisor@derbi.ly',
              prefixIcon:
                  Icon(Icons.email_outlined, color: context.primaryColor),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'البريد الإلكتروني حقل إجباري لتسجيل حساب المشرف.';
              }
              if (!val.contains('@') || !val.contains('.')) {
                return 'صيغة البريد الإلكتروني غير صحيحة.';
              }
              if (_serverEmailError != null && _serverEmailError!.isNotEmpty) {
                return _serverEmailError;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone Number
          TextFormField(
            controller: _phoneController,
            style: TextStyle(color: context.textPrimary, fontSize: 14),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف (10 أرقام تبدأ بـ 09)',
              hintText: '0928669900',
              prefixIcon: Icon(Icons.phone_android_rounded,
                  color: context.primaryColor),
            ),
            validator: (val) {
              final trimmed = val?.trim() ?? '';
              if (trimmed.isEmpty) {
                return 'رقم الهاتف مطلوب لاستكمال عملية التسجيل.';
              }
              if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
                return 'رقم الهاتف يجب أن يحتوي على أرقام فقط.';
              }
              if (trimmed.length != 10) {
                return 'رقم الهاتف يجب أن يتكون من 10 أرقام بالضبط.';
              }
              if (!trimmed.startsWith('09')) {
                return 'رقم الهاتف غير صحيح، يجب أن يبدأ بـ 09.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),



          // Is Active Switch (عند التعديل)
          if (_isEditMode) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isActive
                            ? Icons.check_circle_rounded
                            : Icons.pause_circle_rounded,
                        color: _isActive
                            ? context.successColor
                            : context.textTertiary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'حالة تفعيل الحساب:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isActive ? 'نشط (مفعل)' : 'غير نشط (معطل)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _isActive
                              ? context.successColor
                              : context.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  Tooltip(
                    message: isCurrentMainAdmin
                        ? 'تعديل حالة التفعيل'
                        : 'تغيير حالة تفعيل حسابات المشرفين متاح للمدير الرئيسي فقط',
                    child: Switch(
                      value: _isActive,
                      onChanged: isCurrentMainAdmin
                          ? (val) => setState(() => _isActive = val)
                          : null,
                      activeThumbColor: context.successColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: context.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: widget.isLoading ? null : _handleSubmit,
              icon: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Icon(
                      _isEditMode
                          ? Icons.save_rounded
                          : Icons.person_add_rounded,
                      size: 20),
              label: Text(
                _isEditMode ? 'حفظ التعديلات' : 'إضافة المشرف',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
