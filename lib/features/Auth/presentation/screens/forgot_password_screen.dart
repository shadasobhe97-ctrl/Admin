import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/derbi_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../logic/admin_auth_cubit.dart';
import '../../logic/admin_auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // ── Controllers ─────────────────────────────────────────────────────────────
  final _emailCtrl   = TextEditingController();
  final _otpCtrl     = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // ── State ────────────────────────────────────────────────────────────────────
  int  _step             = 1;   // 1 → send-otp | 2 → verify-otp | 3 → reset
  bool _passVisible      = false;
  bool _confirmVisible   = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: DerbiColors.dangerRose),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: DerbiColors.successEmerald),
    );
  }

  // ── Step 1: Send OTP ─────────────────────────────────────────────────────────
  Future<void> _handleSendOtp() async {
    final email = _emailCtrl.text.trim();
    final emailErr = Validators.validateEmail(email);
    if (emailErr != null) {
      _showError(emailErr);
      return;
    }
    final ok = await context.read<AdminAuthCubit>().sendOtp(email);
    if (ok && mounted) {
      _showSuccess('تم إرسال رمز OTP على البريد: $email');
      setState(() => _step = 2);
    }
  }

  // ── Step 2: Verify OTP ───────────────────────────────────────────────────────
  Future<void> _handleVerifyOtp() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length < 4) {
      _showError('الرجاء إدخال رمز التحقق (OTP) المكوّن من 4–6 أرقام');
      return;
    }
    final ok = await context.read<AdminAuthCubit>().verifyOtp(
      _emailCtrl.text.trim(),
      otp,
    );
    if (ok && mounted) setState(() => _step = 3);
  }

  // ── Step 3: Reset Password ───────────────────────────────────────────────────
  Future<void> _handleResetPassword() async {
    final pass    = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    final passErr = Validators.validatePassword(pass);
    if (passErr != null) {
      _showError(passErr);
      return;
    }
    if (pass != confirm) {
      _showError('كلمتا المرور غير متطابقتين');
      return;
    }

    final ok = await context.read<AdminAuthCubit>().resetPassword(
      email:       _emailCtrl.text.trim(),
      otp:         _otpCtrl.text.trim(),
      newPassword: pass,
    );
    if (ok && mounted) {
      _showSuccess('تم إعادة تعيين كلمة المرور بنجاح! يمكنك الآن تسجيل الدخول.');
      Navigator.pop(context);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminAuthCubit, AdminAuthState>(
      listenWhen: (p, c) => c.errorMessage != null && c.errorMessage != p.errorMessage,
      listener:   (_, state) {
        if (state.errorMessage != null) _showError(state.errorMessage!);
      },
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: DerbiColors.background,
            body: Stack(
              children: [
                // ── decorative blobs ─────────────────────────────────────────
                Positioned(
                  top: -100, right: -100,
                  child: _blob(300, DerbiColors.primaryBlue.withValues(alpha: 0.12)),
                ),
                Positioned(
                  bottom: -120, left: -120,
                  child: _blob(350, DerbiColors.primaryBlue.withValues(alpha: 0.08)),
                ),

                // ── content ──────────────────────────────────────────────────
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: _buildCard(state),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Card ─────────────────────────────────────────────────────────────────────
  Widget _buildCard(AdminAuthState state) {
    return Card(
      color:     DerbiColors.surfaceCard,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: DerbiColors.borderSlate),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon + Title ─────────────────────────────────────────────────
            _stepIcon(),
            const SizedBox(height: 20),
            Text(
              _stepTitle(),
              style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _stepSubtitle(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: DerbiColors.textSecondary),
            ),
            const SizedBox(height: 12),

            // ── Step Indicator ────────────────────────────────────────────────
            _stepIndicator(),
            const SizedBox(height: 28),

            // ── Step Content ─────────────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: _buildStepContent(state, key: ValueKey(_step)),
            ),

            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 16, color: DerbiColors.textMuted),
              label: const Text(
                'العودة لتسجيل الدخول',
                style: TextStyle(color: DerbiColors.textMuted, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step Content ──────────────────────────────────────────────────────────────
  Widget _buildStepContent(AdminAuthState state, {required Key key}) {
    switch (_step) {
      // ── Step 1 ───────────────────────────────────────────────────────────────
      case 1:
        return Column(key: key, children: [
          _inputField(
            controller: _emailCtrl,
            label:      'البريد الإلكتروني',
            hint:       'admin@darby.test',
            icon:       Icons.email_outlined,
            type:       TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          _primaryButton(
            label:     'إرسال رمز التحقق',
            icon:      Icons.send_rounded,
            isLoading: state.isLoading,
            onTap:     _handleSendOtp,
            color:     DerbiColors.primaryBlue,
          ),
        ]);

      // ── Step 2 ───────────────────────────────────────────────────────────────
      case 2:
        return Column(key: key, children: [
          // read-only email reminder
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: DerbiColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DerbiColors.borderSlate),
            ),
            child: Row(children: [
              const Icon(Icons.email_outlined, size: 16, color: DerbiColors.primaryBlue),
              const SizedBox(width: 8),
              Text(_emailCtrl.text,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 16),
          _inputField(
            controller: _otpCtrl,
            label:      'رمز التحقق (OTP)',
            hint:       '123456',
            icon:       Icons.verified_outlined,
            type:       TextInputType.number,
            maxLength:  6,
            textAlign:  TextAlign.center,
            letterSpacing: 8,
          ),
          const SizedBox(height: 24),
          _primaryButton(
            label:     'التحقق من الرمز',
            icon:      Icons.check_circle_outline_rounded,
            isLoading: state.isLoading,
            onTap:     _handleVerifyOtp,
            color:     DerbiColors.primaryBlue,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: state.isLoading ? null : _handleSendOtp,
            child: const Text(
              'إعادة إرسال الرمز',
              style: TextStyle(color: DerbiColors.textMuted, fontSize: 12),
            ),
          ),
        ]);

      // ── Step 3 ───────────────────────────────────────────────────────────────
      default:
        return Column(key: key, children: [
          _passwordField(
            controller: _passCtrl,
            label:      'كلمة المرور الجديدة',
            visible:    _passVisible,
            onToggle:   () => setState(() => _passVisible = !_passVisible),
          ),
          const SizedBox(height: 16),
          _passwordField(
            controller: _confirmCtrl,
            label:      'تأكيد كلمة المرور',
            visible:    _confirmVisible,
            onToggle:   () => setState(() => _confirmVisible = !_confirmVisible),
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              '• 8 أحرف على الأقل | • حرف إنجليزي | • رقم واحد',
              style: TextStyle(fontSize: 10, color: DerbiColors.textMuted),
            ),
          ),
          const SizedBox(height: 24),
          _primaryButton(
            label:     'تأكيد وحفظ كلمة المرور',
            icon:      Icons.lock_reset_rounded,
            isLoading: state.isLoading,
            onTap:     _handleResetPassword,
            color:     DerbiColors.successEmerald,
          ),
        ]);
    }
  }

  // ── Reusable Widgets ──────────────────────────────────────────────────────────

  Widget _blob(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _stepIcon() {
    final icons  = [Icons.email_outlined, Icons.verified_user_outlined, Icons.lock_reset_rounded];
    final colors = [DerbiColors.primaryBlue, DerbiColors.warningAmber, DerbiColors.successEmerald];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:  colors[_step - 1].withValues(alpha: 0.15),
        shape:  BoxShape.circle,
      ),
      child: Icon(icons[_step - 1], size: 36, color: colors[_step - 1]),
    );
  }

  String _stepTitle() => [
    'استعادة كلمة المرور',
    'التحقق من الهوية',
    'تعيين كلمة مرور جديدة',
  ][_step - 1];

  String _stepSubtitle() => [
    'أدخل بريدك الإلكتروني المسجل وسنرسل لك رمز OTP',
    'أدخل الرمز المُرسَل إلى بريدك الإلكتروني',
    'اختر كلمة مرور قوية لتأمين حسابك الإداري',
  ][_step - 1];

  Widget _stepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i < _step;
        final current = i == _step - 1;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width:  current ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: active ? DerbiColors.primaryBlue : DerbiColors.borderSlate,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType type        = TextInputType.text,
    int? maxLength,
    TextAlign textAlign       = TextAlign.start,
    double letterSpacing      = 0,
  }) {
    return TextField(
      controller:   controller,
      keyboardType: type,
      maxLength:    maxLength,
      textAlign:    textAlign,
      style: TextStyle(
        color:         Colors.white,
        fontSize:      14,
        letterSpacing: letterSpacing,
      ),
      decoration: InputDecoration(
        labelText:   label,
        hintText:    hint,
        prefixIcon:  Icon(icon, color: DerbiColors.primaryBlue, size: 18),
        filled:      true,
        fillColor:   DerbiColors.background,
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DerbiColors.borderSlate),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DerbiColors.borderSlate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DerbiColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller:  controller,
      obscureText: !visible,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText:  label,
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: DerbiColors.primaryBlue, size: 18),
        suffixIcon: IconButton(
          icon: Icon(
            visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: DerbiColors.textMuted,
            size: 18,
          ),
          onPressed: onToggle,
        ),
        filled:     true,
        fillColor:  DerbiColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DerbiColors.borderSlate),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DerbiColors.borderSlate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DerbiColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required bool isLoading,
    required VoidCallback onTap,
    required Color color,
  }) {
    return SizedBox(
      width:  double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
        ),
        onPressed: isLoading ? null : onTap,
        icon: isLoading
            ? const SizedBox(
                width:  18, height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Icon(icon, size: 18),
        label: Text(
          isLoading ? 'جاري التحميل...' : label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
