import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/derbi_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../logic/admin_password_reset_cubit.dart';
import '../../logic/admin_password_reset_state.dart';
import 'otp_verification_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<AdminPasswordResetCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final success = await cubit.sendOtp(email: _emailController.text.trim());

    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content:
              Text(cubit.state.successMessage ?? 'تم إرسال رمز التحقق بنجاح.'),
          backgroundColor: DerbiColors.successEmerald,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              OtpVerificationScreen(email: _emailController.text.trim()),
        ),
      );
    } else {
      final error = cubit.state.errorMessage;
      if (error != null) {
        messenger.showSnackBar(
          SnackBar(
              content: Text(error), backgroundColor: DerbiColors.dangerRose),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2563EB).withValues(alpha: 0.15),
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
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    color: theme.cardColor,
                    elevation: isDark ? 0 : 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: theme.dividerColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(36.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_reset_rounded,
                                size: 40,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'إعادة تعيين كلمة المرور',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'أدخل البريد الإلكتروني المسجل في النظام لإرسال رمز التحقق',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _emailController,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 14,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'البريد الإلكتروني',
                                hintText: 'admin@darbi.com',
                                prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF2563EB)),
                              ),
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 24),
                            BlocBuilder<AdminPasswordResetCubit, AdminPasswordResetState>(
                              builder: (context, state) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: state.isLoading ? null : _handleSendOtp,
                                    child: state.isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        : const Text(
                                            'إرسال رمز التحقق (OTP)',
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'العودة لتسجيل الدخول',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
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
