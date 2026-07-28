import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/utils/admin_theme_context.dart';
import '../../logic/admin_auth_cubit.dart';
import '../../logic/admin_auth_state.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/custom_web_text_field.dart';
import '../widgets/theme_toggle_button.dart';

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
      final cubit = sl<AdminAuthCubit>();
      final success = await cubit.login(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (mounted) {
        final error = cubit.state.errorMessage;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: context.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AuthHeaderWidget(isDark: isDark),
                          const SizedBox(height: 32),
                          CustomWebTextField(
                            controller: _phoneController,
                            labelText: 'رقم الهاتف',
                            hintText: '0912345678',
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone_android),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'الرجاء إدخال رقم الهاتف';
                              }
                              if (!RegExp(r'^09\d{8}$').hasMatch(val.trim())) {
                                return 'رقم هاتف ليبي غير صحيح (مثال: 0912345678)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomWebTextField(
                            controller: _passwordController,
                            labelText: 'كلمة المرور',
                            obscureText: !_isPasswordVisible,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? 'الرجاء إدخال كلمة المرور'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/forgot-password');
                              },
                              child: const Text('نسيت كلمة المرور؟'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<AdminAuthCubit, AdminAuthState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: state.isLoading ? null : _handleLogin,
                                  child: state.isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
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
    );
  }
}