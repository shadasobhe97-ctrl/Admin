import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/remote_circle_avatar.dart';
import '../../../../core/permissions/authorization_service.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/admin_model.dart';
import '../../data/models/create_admin_request_model.dart';
import '../../data/models/roles_permissions_model.dart';
import '../../data/models/update_admin_request_model.dart';
import '../../logic/admin_management_cubit.dart';
import '../../logic/admin_management_state.dart';

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
  late final TextEditingController _passwordController;
  late final ScrollController _permissionsScrollController;

  late bool _isActive;
  bool _isPasswordVisible = false;
  int? _selectedRoleId;
  final Set<String> _selectedCustomPermissions = {};

  Uint8List? _avatarBytes;
  String? _avatarFileName;

  String? _serverNameError;
  String? _serverEmailError;
  String? _serverPhoneError;
  String? _serverPasswordError;

  bool get _isEditMode => widget.initialAdmin != null;

  void _clearServerErrors() {
    _serverNameError = null;
    _serverEmailError = null;
    _serverPhoneError = null;
    _serverPasswordError = null;
  }

  void _parseAndSetServerErrorMessage(String? msg) {
    _clearServerErrors();
    if (msg == null || msg.trim().isEmpty) return;

    final lower = msg.toLowerCase();
    if (msg.contains('الاسم') || lower.contains('name')) {
      _serverNameError = msg;
    } else if (msg.contains('البريد') || msg.contains('إيميل') || lower.contains('email')) {
      _serverEmailError = msg;
    } else if (msg.contains('الهاتف') || msg.contains('جوال') || lower.contains('phone') || lower.contains('mobile')) {
      _serverPhoneError = msg;
    } else if (msg.contains('مرور') || lower.contains('password')) {
      _serverPasswordError = msg;
    }
  }

  @override
  void initState() {
    super.initState();
    _permissionsScrollController = ScrollController();
    _nameController =
        TextEditingController(text: widget.initialAdmin?.fullName ?? '');
    _emailController =
        TextEditingController(text: widget.initialAdmin?.email ?? '');
    _phoneController =
        TextEditingController(text: widget.initialAdmin?.phoneNumber ?? '');
    _passwordController = TextEditingController();

    _isActive = widget.initialAdmin?.isActive ?? true;
    _selectedRoleId = widget.initialAdmin?.roleId;

    if (widget.initialAdmin?.customPermissions != null) {
      _selectedCustomPermissions
          .addAll(widget.initialAdmin!.customPermissions);
    }

    _nameController.addListener(_onNameChanged);
    _emailController.addListener(_onEmailChanged);
    _phoneController.addListener(_onPhoneChanged);
    _passwordController.addListener(_onPasswordChanged);

    if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) {
      _parseAndSetServerErrorMessage(widget.errorMessage);
    }
  }

  void _onNameChanged() {
    if (_serverNameError != null) {
      setState(() {
        _serverNameError = null;
      });
      _formKey.currentState?.validate();
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

  void _onPhoneChanged() {
    if (_serverPhoneError != null) {
      setState(() {
        _serverPhoneError = null;
      });
      _formKey.currentState?.validate();
    }
  }

  void _onPasswordChanged() {
    if (_serverPasswordError != null) {
      setState(() {
        _serverPasswordError = null;
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
        _parseAndSetServerErrorMessage(widget.errorMessage);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.validate();
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _emailController.removeListener(_onEmailChanged);
    _phoneController.removeListener(_onPhoneChanged);
    _passwordController.removeListener(_onPasswordChanged);
    _permissionsScrollController.dispose();
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
    setState(() {
      _clearServerErrors();
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (widget.isLoading) return;

    final isCurrentMainAdmin =
        AuthorizationService.hasPermission('admins.manage');
    final passwordText = _passwordController.text.trim();

    if (_isEditMode) {
      final updateReq = UpdateAdminRequestModel(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: passwordText.isNotEmpty ? passwordText : null,
        roleId: _selectedRoleId,
        customPermissions: _selectedCustomPermissions.toList(),
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
        password: passwordText.isNotEmpty ? passwordText : null,
        roleId: _selectedRoleId,
        customPermissions: _selectedCustomPermissions.toList(),
        isActive: _isActive,
        avatarBytes: _avatarBytes,
        avatarFileName: _avatarFileName,
      );
      widget.onCreate(createReq);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrentMainAdmin =
        AuthorizationService.hasPermission('admins.manage');

    return BlocBuilder<AdminManagementCubit, AdminManagementState>(
      builder: (context, state) {
        final roles = state.roles;
        final permissionsTree = state.permissionsTree;

        // إسناد الدور الافتراضي إن لم يُحدد مسبقاً
        if (_selectedRoleId == null && roles.isNotEmpty) {
          _selectedRoleId = roles.first.id;
        }

        RoleModel? currentSelectedRole;
        if (_selectedRoleId != null && roles.isNotEmpty) {
          final found = roles.where((r) => r.id == _selectedRoleId);
          if (found.isNotEmpty) {
            currentSelectedRole = found.first;
          }
        }

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
                  labelText: 'الاسم الثلاثي الكامل (بالعربية)',
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
                  if (_serverNameError != null &&
                      _serverNameError!.isNotEmpty) {
                    return _serverNameError;
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
                  if (_serverEmailError != null &&
                      _serverEmailError!.isNotEmpty) {
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
                  if (_serverPhoneError != null &&
                      _serverPhoneError!.isNotEmpty) {
                    return _serverPhoneError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password (Optional)
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: TextStyle(color: context.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: _isEditMode
                      ? 'كلمة المرور الجديد (اختياري)'
                      : 'كلمة المرور (اختياري)',
                  hintText: _isEditMode
                      ? 'اتركه فارغاً للإبقاء على كلمة المرور الحالية'
                      : 'إذا ترك فارغاً يولد الخادم كلمة مرور عشوائية ويرسلها إلكترونياً',
                  prefixIcon: Icon(Icons.lock_outline_rounded,
                      color: context.primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: context.textTertiary,
                    ),
                    onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    if (val.length < 6) {
                      return 'كلمة المرور يجب أن لا تقل عن 6 خانات وتتضمن أحرفاً إنجليزية.';
                    }
                  }
                  if (_serverPasswordError != null &&
                      _serverPasswordError!.isNotEmpty) {
                    return _serverPasswordError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── 1. اختيار الدور (Roles Selector Dynamic from Backend) ────────
              Text(
                'الدور والتصنيف الوظيفي (Backend Source of Truth):',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (state.isRolesLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(),
                )
              else if (roles.isNotEmpty) ...[
                DropdownButtonFormField<int>(
                  initialValue: _selectedRoleId ?? roles.first.id,
                  style: TextStyle(color: context.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.admin_panel_settings_outlined,
                        color: context.primaryColor),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  items: roles.map((role) {
                    return DropdownMenuItem<int>(
                      value: role.id,
                      child: Text(
                        '${role.name} (${role.key})',
                        style: TextStyle(
                            color: context.textPrimary,
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedRoleId = val;
                      });
                    }
                  },
                ),
                if (currentSelectedRole != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (currentSelectedRole.description != null &&
                            currentSelectedRole.description!.isNotEmpty) ...[
                          Text(
                            currentSelectedRole.description!,
                            style: TextStyle(
                                fontSize: 12, color: context.textSecondary),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          'صلاحيات الدور الأساسية (تُمنح تلقائياً حسب الدور):',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: context.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: currentSelectedRole.permissions.map((p) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    context.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                p,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: context.primaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),

              // ── 2. الصلاحيات المخصصة (Custom Permissions Tree) ──────────────
              if (permissionsTree.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.tune_rounded,
                        size: 18, color: context.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'الصلاحيات المخصصة (إضافات فوق صلاحيات الدور):',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'اختر الصلاحيات الإضافية المطلوب منحها لهذا المشرف تحديداً من شجرة الصلاحيات الديناميكية:',
                  style: TextStyle(fontSize: 12, color: context.textTertiary),
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  decoration: BoxDecoration(
                    color: context.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Scrollbar(
                    controller: _permissionsScrollController,
                    child: ListView.separated(
                      controller: _permissionsScrollController,
                      padding: const EdgeInsets.all(12),
                      shrinkWrap: true,
                      itemCount: permissionsTree.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final group = permissionsTree[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: ExpansionTile(
                            tilePadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            title: Text(
                              group.groupName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              '(${group.groupKey}) • ${group.permissions.length} صلاحيات',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.textTertiary,
                              ),
                            ),
                            children: group.permissions.map((perm) {
                              final isChecked =
                                  _selectedCustomPermissions.contains(perm.key);
                              return CheckboxListTile(
                                dense: true,
                                value: isChecked,
                                activeColor: context.primaryColor,
                                title: Text(
                                  perm.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: context.textPrimary,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (perm.description != null &&
                                        perm.description!.isNotEmpty)
                                      Text(
                                        perm.description!,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: context.textSecondary),
                                      ),
                                    Text(
                                      perm.key,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'monospace',
                                        color: context.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                                onChanged: (bool? selected) {
                                  setState(() {
                                    if (selected == true) {
                                      _selectedCustomPermissions.add(perm.key);
                                    } else {
                                      _selectedCustomPermissions
                                          .remove(perm.key);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Is Active Switch (عند التعديل)
              if (_isEditMode) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

              // Error Alert Banner (Backend validation or server error)
              if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: context.dangerBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.dangerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: context.dangerColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.errorMessage!,
                          style: TextStyle(
                            color: context.dangerColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
