import 'package:flutter/material.dart';
import '../../../../core/theme/derbi_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 1; // 1: Send OTP, 2: Reset Password
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم الهاتف المسجل'), backgroundColor: DerbiColors.dangerRose),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // Smooth UI feel

    if (mounted) {
      setState(() {
        _isLoading = false;
        _currentStep = 2;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إرسال رمز التحقق (OTP) إلى الرقم $phone بنجاح!'), backgroundColor: DerbiColors.successEmerald),
      );
    }
  }

  Future<void> _handleResetPassword() async {
    final code = _codeController.text.trim();
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رمز التحقق المكون من 4 أرقام'), backgroundColor: DerbiColors.dangerRose),
      );
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمة المرور يجب أن لا تقل عن 6 أحرف'), backgroundColor: DerbiColors.dangerRose),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمتا المرور غير متطابقتين'), backgroundColor: DerbiColors.dangerRose),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إعادة تعيين كلمة المرور بنجاح! يمكنك الآن تسجيل الدخول.'), backgroundColor: DerbiColors.successEmerald),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DerbiColors.background,
        body: Stack(
          children: [
            // Background Decorative Elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DerbiColors.primaryBlue.withValues(alpha: 0.15),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DerbiColors.primaryBlue.withValues(alpha: 0.1),
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    color: DerbiColors.surfaceCard,
                    elevation: 16,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: DerbiColors.borderSlate),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(36.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header Icon & Title
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: DerbiColors.primaryBlue.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              size: 40,
                              color: DerbiColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'استعادة كلمة المرور',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentStep == 1
                                ? 'أدخل رقم الهاتف المسجل في النظام لإرسال رمز التأكيد'
                                : 'أدخل رمز التحقق (OTP) وكلمة المرور الجديدة',
                            style: const TextStyle(fontSize: 13, color: DerbiColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          if (_currentStep == 1) ...[
                            // Step 1: Enter Phone Number
                            TextField(
                              controller: _phoneController,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'رقم الهاتف المسجل',
                                hintText: '0910000000',
                                prefixIcon: const Icon(Icons.phone_android, color: DerbiColors.primaryBlue),
                                filled: true,
                                fillColor: DerbiColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: DerbiColors.borderSlate),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DerbiColors.primaryBlue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: _isLoading ? null : _handleSendCode,
                                child: _isLoading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                    : const Text('إرسال رمز التحقق', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                          ] else ...[
                            // Step 2: Enter Code & New Password
                            TextField(
                              controller: _codeController,
                              style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 4),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: InputDecoration(
                                labelText: 'رمز التحقق (OTP)',
                                hintText: '1234',
                                prefixIcon: const Icon(Icons.verified_outlined, color: DerbiColors.successEmerald),
                                filled: true,
                                fillColor: DerbiColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: DerbiColors.borderSlate),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _newPasswordController,
                              obscureText: !_isPasswordVisible,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور الجديدة',
                                prefixIcon: const Icon(Icons.lock_outline, color: DerbiColors.primaryBlue),
                                suffixIcon: IconButton(
                                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: DerbiColors.textMuted),
                                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                ),
                                filled: true,
                                fillColor: DerbiColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: DerbiColors.borderSlate),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: !_isPasswordVisible,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'تأكيد كلمة المرور الجديدة',
                                prefixIcon: const Icon(Icons.lock_outline, color: DerbiColors.primaryBlue),
                                filled: true,
                                fillColor: DerbiColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: DerbiColors.borderSlate),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DerbiColors.successEmerald,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: _isLoading ? null : _handleResetPassword,
                                child: _isLoading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                    : const Text('تأكيد وإعادة التعيين', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),
                          TextButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, size: 16, color: DerbiColors.textMuted),
                            label: const Text('العودة لتسجيل الدخول', style: TextStyle(color: DerbiColors.textMuted, fontSize: 13)),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
