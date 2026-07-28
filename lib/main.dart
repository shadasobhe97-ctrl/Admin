import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/service_locator.dart';
import 'core/services/storage_service.dart';
import 'core/theme/cubit/theme_cubit.dart';
import 'core/theme/cubit/theme_state.dart';
import 'features/Auth/logic/admin_auth_cubit.dart';
import 'features/Auth/presentation/screens/admin_splash_screen.dart';
import 'features/Auth/presentation/screens/admin_login_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_overview_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => sl<AdminAuthCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Kids Transport - Admin Panel',
            debugShowCheckedModeBanner: false,
            theme: state.themeData,
            initialRoute: '/',
            locale: const Locale('ar', 'AE'),
            supportedLocales: const [
              Locale('ar', 'AE'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routes: {
              '/': (context) => const AdminSplashScreen(),
              '/login': (context) => const AdminLoginScreen(),
              '/dashboard': (context) => const DashboardOverviewScreen(),
            },
          );
        },
      ),
    );
  }
}