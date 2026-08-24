import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/derbi_colors.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../logic/admin_password_reset_cubit.dart';
import '../../logic/admin_password_reset_state.dart';
import 'new_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;

    final otp = _otpController.text.trim();
    final cubit = context.read<AdminPasswordResetCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final success = await cubit.verifyOtp(email: widget.email, otp: otp);

    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content:
              Text(cubit.state.successMessage ?? 'تم التحقق من الرمز بنجاح.'),
          backgroundColor: DerbiColors.successEmerald,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              NewPasswordScreen(email: widget.email, otp: otp),
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

  Future<void> _handleResend() async {
    final cubit = context.read<AdminPasswordResetCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final success = await cubit.resendOtp(email: widget.email);

    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (cubit.state.successMessage ??
                  'تم إعادة إرسال رمز التحقق بنجاح.')
              : (cubit.state.errorMessage ??
                  'تعذر إعادة إرسال الرمز، حاول مرة أخرى.'),
        ),
        backgroundColor:
            success ? DerbiColors.successEmerald : DerbiColors.dangerRose,
      ),
    );
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
                  color: context.primaryColor.withValues(alpha: 0.15),
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
                  color: context.primaryColor.withValues(alpha: 0.1),
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
                                color: context.successColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.verified_outlined,
                                size: 40,
                                color: context.successColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'التحقق من الرمز',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'تم إرسال رمز التحقق (OTP) إلى ${widget.email}. أدخل الرمز للمتابعة.',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.textTertiary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _otpController,
                              style: TextStyle(
                                color: context.textPrimary,
                                fontSize: 14,
                                letterSpacing: 4,
                              ),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: InputDecoration(
                                labelText: 'رمز التحقق (OTP)',
                                hintText: '1234',
                                prefixIcon: Icon(Icons.pin_outlined, color: context.successColor),
                              ),
                              validator: (val) {
                                final value = val?.trim() ?? '';
                                if (value.isEmpty) {
                                  return 'الرجاء إدخال رمز التحقق';
                                }
                                if (value.length < 4) {
                                  return 'رمز التحقق يجب أن يكون 4 أرقام على الأقل';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            BlocBuilder<AdminPasswordResetCubit,
                                AdminPasswordResetState>(
                              builder: (context, state) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          DerbiColors.successEmerald,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                    ),
                                    onPressed:
                                        state.isLoading ? null : _handleVerify,
                                    child: state.isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5),
                                          )
                                        : const Text(
                                            'تحقق من الرمز',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _handleResend,
                              child: const Text(
                                'إعادة إرسال الرمز',
                                style: TextStyle(
                                    color: DerbiColors.primaryBlue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
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
