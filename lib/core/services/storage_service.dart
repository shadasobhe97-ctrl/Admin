import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _themeKey = 'is_dark_mode';
  static const String _tokenKey = 'auth_token';
  static const String _roleIdKey = 'role_id';
  static const String _roleNameKey = 'role_name';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _userEmailKey = 'user_email';

  // Theme Mode
  static bool getThemeMode() => _prefs?.getBool(_themeKey) ?? true;

  static Future<bool> saveThemeMode(bool isDark) async {
    return await _prefs?.setBool(_themeKey, isDark) ?? false;
  }

  // Session Data
  static String? getToken() => _prefs?.getString(_tokenKey);
  static int? getRoleId() => _prefs?.getInt(_roleIdKey);
  static String? getRoleName() => _prefs?.getString(_roleNameKey);
  static int? getUserId() => _prefs?.getInt(_userIdKey);
  static String? getUserName() => _prefs?.getString(_userNameKey);
  static String? getUserPhone() => _prefs?.getString(_userPhoneKey);
  static String? getUserEmail() => _prefs?.getString(_userEmailKey);

  static Future<bool> saveSession({
    required String token,
    required int roleId,
    String roleName = 'مدير النظام',
    required int userId,
    required String userName,
    required String userPhone,
    String userEmail = '',
  }) async {
    await _prefs?.setString(_tokenKey, token);
    await _prefs?.setInt(_roleIdKey, roleId);
    await _prefs?.setString(_roleNameKey, roleName);
    await _prefs?.setInt(_userIdKey, userId);
    await _prefs?.setString(_userNameKey, userName);
    await _prefs?.setString(_userPhoneKey, userPhone);
    return await _prefs?.setString(_userEmailKey, userEmail) ?? false;
  }

  static Future<void> clearSession() async {
    await _prefs?.remove(_tokenKey);
    await _prefs?.remove(_roleIdKey);
    await _prefs?.remove(_roleNameKey);
    await _prefs?.remove(_userIdKey);
    await _prefs?.remove(_userNameKey);
    await _prefs?.remove(_userPhoneKey);
    await _prefs?.remove(_userEmailKey);
  }

  static Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }
}
