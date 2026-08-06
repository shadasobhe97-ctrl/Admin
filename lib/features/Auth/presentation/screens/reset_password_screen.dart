import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/derbi_colors.dart';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DerbiColors.background,
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: DerbiColors.primaryBlue
                                    .withValues(alpha: 0.15),
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
                              'إعادة تعيين كلمة المرور',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'أدخل البريد الإلكتروني المسجل في النظام لإرسال رمز التحقق',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: DerbiColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'البريد الإلكتروني',
                                hintText: 'admin@darbi.com',
                                prefixIcon: const Icon(Icons.email_outlined,
                                    color: DerbiColors.primaryBlue),
                                labelStyle: const TextStyle(
                                    color: DerbiColors.textSecondary,
                                    fontSize: 13),
                                hintStyle: const TextStyle(
                                    color: DerbiColors.textMuted, fontSize: 13),
                                filled: true,
                                fillColor: DerbiColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                      color: DerbiColors.borderSlate),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                      color: DerbiColors.borderSlate),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                      color: DerbiColors.primaryBlue, width: 2),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'الرجاء إدخال البريد الإلكتروني';
                                }
                                if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(val.trim())) {
                                  return 'البريد الإلكتروني غير صحيح';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),
                            BlocBuilder<AdminPasswordResetCubit,
                                AdminPasswordResetState>(
                              builder: (context, state) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: DerbiColors.primaryBlue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                    ),
                                    onPressed:
                                        state.isLoading ? null : _handleSendOtp,
                                    child: state.isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5),
                                          )
                                        : const Text(
                                            'إرسال رمز التحقق',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            TextButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back,
                                  size: 16, color: DerbiColors.textMuted),
                              label: const Text('العودة لتسجيل الدخول',
                                  style: TextStyle(
                                      color: DerbiColors.textMuted,
                                      fontSize: 13)),
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
