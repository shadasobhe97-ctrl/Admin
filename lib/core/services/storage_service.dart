import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _themeKey = 'is_dark_mode';
  static const String _tokenKey = 'auth_token';

  // Theme Mode
  static bool getThemeMode() {
    return _prefs?.getBool(_themeKey) ?? false;
  }

  static Future<bool> saveThemeMode(bool isDark) async {
    return await _prefs?.setBool(_themeKey, isDark) ?? false;
  }

  // Auth Token
  static String? getToken() => _prefs?.getString(_tokenKey);

  static Future<bool> saveToken(String token) async {
    return await _prefs?.setString(_tokenKey, token) ?? false;
  }

  static Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }
}