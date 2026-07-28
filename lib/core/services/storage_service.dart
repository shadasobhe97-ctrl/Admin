import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _themeKey = 'is_dark_mode';
  static const String _tokenKey = 'auth_token';
  static const String _roleIdKey = 'role_id';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';

  // Theme Mode
  static bool getThemeMode() => _prefs?.getBool(_themeKey) ?? false;

  static Future<bool> saveThemeMode(bool isDark) async {
    return await _prefs?.setBool(_themeKey, isDark) ?? false;
  }

  // Session Data
  static String? getToken() => _prefs?.getString(_tokenKey);
  static int? getRoleId() => _prefs?.getInt(_roleIdKey);
  static int? getUserId() => _prefs?.getInt(_userIdKey);
  static String? getUserName() => _prefs?.getString(_userNameKey);
  static String? getUserPhone() => _prefs?.getString(_userPhoneKey);

  static Future<bool> saveSession({
    required String token,
    required int roleId,
    required int userId,
    required String userName,
    required String userPhone,
  }) async {
    await _prefs?.setString(_tokenKey, token);
    await _prefs?.setInt(_roleIdKey, roleId);
    await _prefs?.setInt(_userIdKey, userId);
    await _prefs?.setString(_userNameKey, userName);
    return await _prefs?.setString(_userPhoneKey, userPhone) ?? false;
  }

  static Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }
}