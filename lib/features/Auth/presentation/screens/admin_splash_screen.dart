import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/derbi_colors.dart';
import '../../logic/admin_auth_cubit.dart';

class AdminSplashScreen extends StatefulWidget {
  const AdminSplashScreen({super.key});

  @override
  State<AdminSplashScreen> createState() => _AdminSplashScreenState();
}

class _AdminSplashScreenState extends State<AdminSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final cubit = context.read<AdminAuthCubit>();
    final isLoggedIn = await cubit.checkAuthStatus();
    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DerbiColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: DerbiColors.primaryBlue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: DerbiColors.primaryBlue.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 80,
                    color: DerbiColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'دَربِي Derbi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'منظومة الربط والنقل الذكي طرابلس',
                style: TextStyle(
                  fontSize: 12,
                  color: DerbiColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 160,
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: DerbiColors.surfaceCard,
                  color: DerbiColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
