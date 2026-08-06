import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/derbi_colors.dart';
import '../../logic/admin_password_reset_cubit.dart';
import '../../logic/admin_password_reset_state.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const NewPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<AdminPasswordResetCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final success = await cubit.resetPassword(
      email: widget.email,
      otp: widget.otp,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(cubit.state.successMessage ??
              'تم إعادة تعيين كلمة المرور بنجاح!'),
          backgroundColor: DerbiColors.successEmerald,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
                                Icons.password_rounded,
                                size: 40,
                                color: DerbiColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'كلمة المرور الجديدة',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'أدخل كلمة المرور الجديدة وتأكيدها لتغيير كلمة المرور الخاصة بك',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: DerbiColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _newPasswordController,
                              obscureText: !_isPasswordVisible,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور الجديدة',
                                hintText: '••••••••',
                                prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: DerbiColors.primaryBlue),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    color: DerbiColors.textMuted,
                                  ),
                                  onPressed: () => setState(() =>
                                      _isPasswordVisible = !_isPasswordVisible),
                                ),
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
                                if (val == null || val.isEmpty) {
                                  return 'الرجاء إدخال كلمة المرور الجديدة';
                                }
                                if (val.length < 6) {
                                  return 'كلمة المرور يجب أن لا تقل عن 6 أحرف';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: !_isPasswordVisible,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'تأكيد كلمة المرور الجديدة',
                                hintText: '••••••••',
                                prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
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
                                if (val == null || val.isEmpty) {
                                  return 'الرجاء تأكيد كلمة المرور';
                                }
                                if (val != _newPasswordController.text) {
                                  return 'كلمتا المرور غير متطابقتين';
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
                                      backgroundColor:
                                          DerbiColors.successEmerald,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                    ),
                                    onPressed:
                                        state.isLoading ? null : _handleReset,
                                    child: state.isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5),
                                          )
                                        : const Text(
                                            'تأكيد وإعادة التعيين',
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
