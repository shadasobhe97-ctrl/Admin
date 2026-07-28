import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/utils/admin_theme_context.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    return Positioned(
      top: 24,
      left: 24,
      child: IconButton.filledTonal(
        onPressed: () => context.read<ThemeCubit>().toggleTheme(),
        icon: Icon(
          isDark ? Icons.wb_sunny : Icons.nights_stay,
          color: isDark ? Colors.amber : context.primaryColor,
        ),
      ),
    );
  }
}