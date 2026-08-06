import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/derbi_colors.dart';
import '../../logic/admin_auth_cubit.dart';
import '../../logic/admin_auth_state.dart';
import 'reset_password_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<AdminAuthCubit>();
      final messenger = ScaffoldMessenger.of(context);

      final success = await cubit.login(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(cubit.state.successMessage ?? 'تم تسجيل الدخول بنجاح!'),
            backgroundColor: DerbiColors.successEmerald,
          ),
        );
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (mounted) {
        final error = cubit.state.errorMessage;
        if (error != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: DerbiColors.dangerRose,
            ),
          );
        }
      }
    }
  }

  void _fillDemoCredentials() {
    setState(() {
      _phoneController.text = '0910000000';
      _passwordController.text = 'password123';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DerbiColors.background,
        body: Stack(
          children: [
            // Ambient Radial Gradients Background
            Positioned(
              top: -120,
              right: -120,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DerbiColors.primaryBlue.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DerbiColors.primaryBlue.withValues(alpha: 0.08),
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    color: DerbiColors.surfaceCard,
                    elevation: 16,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      side: const BorderSide(color: DerbiColors.borderSlate),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(36.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Brand Logo Header
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: DerbiColors.primaryBlue.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.admin_panel_settings_rounded,
                                size: 54,
                                color: DerbiColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'دَربِي Derbi',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'لوحة التحكم الإدارية للمسؤولين والمشرفين',
                              style: TextStyle(
                                fontSize: 13,
                                color: DerbiColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Phone Field
                            TextFormField(
                              controller: _phoneController,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'رقم الهاتف',
                                hintText: '0910000000',
                                prefixIcon: const Icon(Icons.phone_android_rounded, color: DerbiColors.primaryBlue),
                                filled: true,
                                fillColor: DerbiColors.background,
                                labelStyle: const TextStyle(color: DerbiColors.textSecondary, fontSize: 13),
                                hintStyle: const TextStyle(color: DerbiColors.textMuted, fontSize: 13),
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
                                  borderSide: const BorderSide(color: DerbiColors.primaryBlue, width: 2),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'الرجاء إدخال رقم الهاتف';
                                }
                                if (val.trim().length < 8) {
                                  return 'رقم هاتف غير صحيح';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: DerbiColors.primaryBlue),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                    color: DerbiColors.textMuted,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: DerbiColors.background,
                                labelStyle: const TextStyle(color: DerbiColors.textSecondary, fontSize: 13),
                                hintStyle: const TextStyle(color: DerbiColors.textMuted, fontSize: 13),
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
                                  borderSide: const BorderSide(color: DerbiColors.primaryBlue, width: 2),
                                ),
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'الرجاء إدخال كلمة المرور' : null,
                            ),
                            const SizedBox(height: 12),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
                                  );
                                },
                                child: const Text(
                                  'نسيت كلمة المرور؟',
                                  style: TextStyle(
                                    color: DerbiColors.primaryBlue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            BlocBuilder<AdminAuthCubit, AdminAuthState>(
                              builder: (context, state) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: DerbiColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      elevation: 4,
                                      shadowColor: DerbiColors.primaryBlue.withValues(alpha: 0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: state.isLoading ? null : _handleLogin,
                                    child: state.isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                          )
                                        : const Text(
                                            'تسجيل الدخول',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),

                            // Demo Quick Fill Preset Button
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: DerbiColors.borderSlate),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              onPressed: _fillDemoCredentials,
                              icon: const Icon(Icons.flash_on_rounded, size: 16, color: DerbiColors.warningAmber),
                              label: const Text(
                                'تعبئة بيانات التجربة السريعة (0910000000)',
                                style: TextStyle(fontSize: 11, color: DerbiColors.textSecondary),
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
