import 'package:flutter/material.dart';
import '../../../../core/network/admin_api_service.dart';
import '../../../../core/services/storage_service.dart';
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
  // ── Services ──────────────────────────────────────────────────────────────
  final _api = AdminApiService();

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isLoading   = true;
  bool _isEditing   = false;
  bool _isSaving    = false;
  Map<String, dynamic>? _profile;

  // ── Controllers ───────────────────────────────────────────────────────────
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _passCtrl;
  bool _passVisible = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _passCtrl  = TextEditingController();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── API Calls ─────────────────────────────────────────────────────────────

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.getProfile();
      final data = res['data'] as Map<String, dynamic>? ?? {};
      setState(() {
        _profile = data;
        _nameCtrl.text  = data['full_name']   ?? widget.adminName;
        _emailCtrl.text = data['email']        ?? '';
        _phoneCtrl.text = data['phone_number'] ?? '';
      });
    } catch (_) {
      // fallback from StorageService if offline
      setState(() {
        _nameCtrl.text  = StorageService.getUserName()  ?? widget.adminName;
        _emailCtrl.text = StorageService.getUserEmail() ?? '';
        _phoneCtrl.text = StorageService.getUserPhone() ?? '';
        _profile = {};
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _snack('الاسم لا يمكن أن يكون فارغاً', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    final adminId = _profile?['id'] ?? StorageService.getUserId() ?? 1;
    final body    = <String, dynamic>{
      'full_name': _nameCtrl.text.trim(),
      'email':     _emailCtrl.text.trim(),
    };
    if (_passCtrl.text.isNotEmpty) {
      if (_passCtrl.text.length < 8) {
        _snack('كلمة المرور يجب أن تكون 8 أحرف على الأقل', isError: true);
        setState(() => _isSaving = false);
        return;
      }
      body['password']              = _passCtrl.text;
      body['password_confirmation'] = _passCtrl.text;
    }

    try {
      await _api.updateProfile(adminId, body);
      widget.onNameChanged(_nameCtrl.text.trim());
      _passCtrl.clear();
      setState(() => _isEditing = false);
      _snack('تم حفظ الملف الشخصي بنجاح ✓');
    } catch (e) {
      _snack('فشل الحفظ: ${e.toString().replaceAll("Exception: ", "")}', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? DerbiColors.dangerRose : DerbiColors.successEmerald,
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: DerbiColors.primaryBlue),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildBannerCard(),
          const SizedBox(height: 20),
          _isEditing ? _buildEditCard() : _buildViewCard(),
          const SizedBox(height: 16),
          if (!_isEditing) _buildSessionCard(),
        ],
      ),
    );
  }

  // ── Banner ────────────────────────────────────────────────────────────────

  Widget _buildBannerCard() {
    final name     = _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'أ';
    final initial  = name[0];
    final roleName = _profile?['role_name'] ?? StorageService.getRoleName() ?? 'مدير النظام';
    final isActive = _profile?['is_active'] ?? true;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [DerbiColors.surfaceCard, DerbiColors.primaryBlue.withValues(alpha: 0.12)],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DerbiColors.borderSlate),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset:     const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: DerbiColors.primaryBlue.withValues(alpha: 0.2),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 34, fontWeight: FontWeight.w900, color: DerbiColors.primaryBlue,
                  ),
                ),
              ),
              Positioned(
                bottom: 2, left: 2,
                child: Container(
                  width: 14, height: 14,
                  decoration: BoxDecoration(
                    color:  isActive ? DerbiColors.successEmerald : DerbiColors.dangerRose,
                    shape:  BoxShape.circle,
                    border: Border.all(color: DerbiColors.surfaceCard, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.shield_rounded, size: 13, color: DerbiColors.primaryBlue),
                  const SizedBox(width: 4),
                  Text(roleName,
                      style: const TextStyle(
                          fontSize: 12, color: DerbiColors.primaryBlue, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(
                    isActive ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                    size:  13,
                    color: isActive ? DerbiColors.successEmerald : DerbiColors.dangerRose,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isActive ? 'الحساب نشط ومفعّل • صلاحيات كاملة' : 'الحساب معطّل',
                    style: const TextStyle(fontSize: 11, color: DerbiColors.textMuted),
                  ),
                ]),
              ],
            ),
          ),

          // Toggle Edit Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isEditing ? DerbiColors.warningAmber : DerbiColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => setState(() {
              _isEditing = !_isEditing;
              _passCtrl.clear();
            }),
            icon: Icon(_isEditing ? Icons.visibility_outlined : Icons.edit_rounded, size: 16),
            label: Text(_isEditing ? 'عرض' : 'تعديل'),
          ),
        ],
      ),
    );
  }

  // ── View Card ─────────────────────────────────────────────────────────────

  Widget _buildViewCard() {
    final createdAt = _profile?['created_at'] as String? ?? '—';
    return _card(
      title: 'المعلومات الشخصية والإدارية',
      icon:  Icons.person_outline_rounded,
      child: Column(children: [
        _infoRow('الاسم الكامل',        _nameCtrl.text.isNotEmpty  ? _nameCtrl.text  : '—'),
        _infoRow('البريد الإلكتروني',   _emailCtrl.text.isNotEmpty ? _emailCtrl.text : '—'),
        _infoRow('رقم الهاتف',          _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : '—'),
        _infoRow('الصلاحية',            _profile?['role_name'] ?? '—'),
        _infoRow('تاريخ إنشاء الحساب',  createdAt.length > 10 ? createdAt.substring(0, 10) : createdAt),
        _infoRow('حالة الحساب',
          (_profile?['is_active'] ?? true) ? 'نشط ✓' : 'معطّل ✗',
          valueColor: (_profile?['is_active'] ?? true)
              ? DerbiColors.successEmerald
              : DerbiColors.dangerRose,
        ),
      ]),
    );
  }

  // ── Edit Card ─────────────────────────────────────────────────────────────

  Widget _buildEditCard() {
    return _card(
      title: 'تعديل البيانات الإدارية',
      icon:  Icons.edit_rounded,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _field(_nameCtrl,  'الاسم الكامل',       Icons.person_outline_rounded),
        const SizedBox(height: 14),
        _field(_emailCtrl, 'البريد الإلكتروني',  Icons.email_outlined,
            type: TextInputType.emailAddress),
        const SizedBox(height: 14),
        _field(_phoneCtrl, 'رقم الهاتف',         Icons.phone_outlined,
            type: TextInputType.phone),
        const SizedBox(height: 14),

        // Password (optional)
        TextField(
          controller:  _passCtrl,
          obscureText: !_passVisible,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            labelText:  'كلمة مرور جديدة (اختياري)',
            hintText:   'اتركه فارغاً إذا لم تريد التغيير',
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: DerbiColors.primaryBlue, size: 18),
            suffixIcon: IconButton(
              icon: Icon(
                _passVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: DerbiColors.textMuted, size: 18,
              ),
              onPressed: () => setState(() => _passVisible = !_passVisible),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '• كلمة المرور يجب أن تكون 8 أحرف على الأقل',
          style: TextStyle(fontSize: 10, color: DerbiColors.textMuted),
        ),
        const SizedBox(height: 24),

        // Actions
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(
            onPressed: () => setState(() { _isEditing = false; _passCtrl.clear(); }),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: DerbiColors.borderSlate),
            ),
            child: const Text('إلغاء', style: TextStyle(color: DerbiColors.textMuted)),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: DerbiColors.successEmerald,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isSaving ? null : _saveProfile,
            icon: _isSaving
                ? const SizedBox(width: 14, height: 14,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.check_rounded, size: 16),
            label: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ التغييرات'),
          ),
        ]),
      ]),
    );
  }

  // ── Session Card ──────────────────────────────────────────────────────────

  Widget _buildSessionCard() {
    return _card(
      title: 'الجلسة الحالية والأمان',
      icon:  Icons.security_rounded,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: DerbiColors.primaryBlue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.laptop_mac_rounded,
              color: DerbiColors.primaryBlue, size: 20),
        ),
        title: const Text(
          'لوحة التحكم الإدارية – متصفح الويب',
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          'جلسة نشطة الآن • محمية بـ Sanctum Bearer Token',
          style: TextStyle(fontSize: 11, color: DerbiColors.textMuted),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color:        DerbiColors.successEmerald.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border:       Border.all(color: DerbiColors.successEmerald.withValues(alpha: 0.3)),
          ),
          child: const Text(
            'متصل',
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: DerbiColors.successEmerald,
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _card({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:        DerbiColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: DerbiColors.borderSlate),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: DerbiColors.primaryBlue),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
        ]),
        const SizedBox(height: 6),
        const Divider(color: DerbiColors.borderSlate),
        const SizedBox(height: 8),
        child,
      ]),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: DerbiColors.textMuted)),
          Text(
            value,
            style: TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.bold,
              color:      valueColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller:   ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText:  label,
        prefixIcon: Icon(icon, color: DerbiColors.primaryBlue, size: 18),
      ),
    );
  }
}
