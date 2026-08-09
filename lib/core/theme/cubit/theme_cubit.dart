import 'package:flutter_bloc/flutter_bloc.dart';
import '../admin_theme.dart';
import '../../services/storage_service.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(_stateFor(StorageService.getThemeMode()));

  /// يبني الحالة من قيمة واحدة حتى لا يتعارض [ThemeState.themeData]
  /// مع [ThemeState.isDarkMode] عند أول إقلاع.
  static ThemeState _stateFor(bool isDark) => ThemeState(
        themeData: isDark ? AdminTheme.darkTheme : AdminTheme.lightTheme,
        isDarkMode: isDark,
      );

  Future<void> toggleTheme() async {
    final bool newIsDarkMode = !state.isDarkMode;
    emit(_stateFor(newIsDarkMode));
    await StorageService.saveThemeMode(newIsDarkMode);
  }
}
