import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/service_locator.dart';
import 'core/services/storage_service.dart';
import 'core/theme/derbi_theme.dart';
import 'features/Auth/logic/admin_auth_cubit.dart';
import 'features/Auth/logic/admin_password_reset_cubit.dart';
import 'features/Auth/presentation/screens/admin_login_screen.dart';
import 'features/Auth/presentation/screens/admin_splash_screen.dart';
import 'features/Auth/presentation/screens/reset_password_screen.dart';
import 'features/main_layout/presentation/screens/derbi_main_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await setupServiceLocator();
  runApp(const DerbiApp());
}

/// 🎨 Derbi Main App Entry Point
class DerbiApp extends StatelessWidget {
  const DerbiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AdminAuthCubit>(
          create: (context) => sl<AdminAuthCubit>(),
        ),
        BlocProvider<AdminPasswordResetCubit>(
          create: (context) => sl<AdminPasswordResetCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'دَربِي Derbi - لوحة التحكم الإدارية',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: DerbiTheme.darkTheme,
        darkTheme: DerbiTheme.darkTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'LY'),
          Locale('ar', 'AE'),
        ],
        locale: const Locale('ar', 'LY'),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const AdminSplashScreen(),
          '/login': (context) => const AdminLoginScreen(),
          '/forgot-password': (context) => const ResetPasswordScreen(),
          '/dashboard': (context) => const Directionality(
                textDirection: TextDirection.rtl,
                child: DerbiMainDashboard(),
              ),
        },
      ),
    );
  }
}
