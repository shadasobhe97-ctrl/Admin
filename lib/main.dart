import 'package:admin_panel/core/theme/cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/storage_service.dart';
import 'core/theme/cubit/theme_cubit.dart';

void main() async {
  // 1. ضمان تهيئة الفلاتر قبل أي خدمة
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تهيئة الـ Storage
  await StorageService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Kids Transport - Admin Panel',
            debugShowCheckedModeBanner: false,
            theme: state.themeData,
            home: const Scaffold(
              body: Center(
                child: Text('Admin Panel Ready! 🚀'),
              ),
            ),
          );
        },
      ),
    );
  }
}