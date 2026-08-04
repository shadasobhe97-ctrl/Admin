import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/derbi_theme.dart';
import 'features/main_layout/presentation/screens/derbi_main_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DerbiApp());
}

/// 🎨 Derbi Main App Entry Point
class DerbiApp extends StatelessWidget {
  const DerbiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دَربِي Derbi - لوحة التحكم الإدارية',
      debugShowCheckedModeBanner: false,
      // تم تغيير الثيم ليصبح افتراضياً فاتحاً (Light Theme) ليتوافق مع التصميم النظيف الأبيض
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
      ),
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
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: DerbiMainDashboard(),
      ),
    );
  }
}