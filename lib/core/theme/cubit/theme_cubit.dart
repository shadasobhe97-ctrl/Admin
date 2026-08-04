import 'package:flutter_bloc/flutter_bloc.dart';
import '../admin_theme.dart';
import '../../services/storage_service.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : super(ThemeState(
          themeData: AdminTheme.lightTheme,
          isDarkMode: StorageService.getThemeMode(),
        )) {
    _loadThemeFromStorage();
  }

  void _loadThemeFromStorage() {
    final bool isDark = StorageService.getThemeMode();
    emit(ThemeState(
      themeData: isDark ? AdminTheme.darkTheme : AdminTheme.lightTheme,
      isDarkMode: isDark,
    ));
  }

  void toggleTheme() async {
    final bool newIsDarkMode = !state.isDarkMode;
    await StorageService.saveThemeMode(newIsDarkMode);

    emit(ThemeState(
      themeData: newIsDarkMode ? AdminTheme.darkTheme : AdminTheme.lightTheme,
      isDarkMode: newIsDarkMode,
    ));
  }
}
