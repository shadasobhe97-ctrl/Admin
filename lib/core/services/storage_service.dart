import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    avatarUrlListenable.value = getAvatarUrl();
  }

  static const String _themeKey = 'is_dark_mode';
  static const String _tokenKey = 'auth_token';
  static const String _roleIdKey = 'role_id';
  static const String _roleNameKey = 'role_name';
  static const String _roleKeyKey = 'role_key';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _userEmailKey = 'user_email';
  static const String _avatarUrlKey = 'user_avatar_url';
  static const String _permissionsKey = 'user_permissions';
  static const String _customPermissionsKey = 'user_custom_permissions';

  /// صورة الحساب الحالية، ليصل إليها الشريط الجانبي وبقيّة الواجهات
  /// المشتركة ويتحدّث فور تغييرها من شاشة الملف الشخصي.
  static final ValueNotifier<String?> avatarUrlListenable =
      ValueNotifier<String?>(null);

  // Theme Mode
  static bool getThemeMode() => _prefs?.getBool(_themeKey) ?? true;

  static Future<bool> saveThemeMode(bool isDark) async {
    return await _prefs?.setBool(_themeKey, isDark) ?? false;
  }

  // Session Data
  static String? getToken() => _prefs?.getString(_tokenKey);
  static int? getRoleId() => _prefs?.getInt(_roleIdKey);
  static String? getRoleName() => _prefs?.getString(_roleNameKey);
  static String? getRoleKey() => _prefs?.getString(_roleKeyKey);
  static int? getUserId() => _prefs?.getInt(_userIdKey);
  static String? getUserName() => _prefs?.getString(_userNameKey);
  static String? getUserPhone() => _prefs?.getString(_userPhoneKey);
  static String? getUserEmail() => _prefs?.getString(_userEmailKey);
  static String? getAvatarUrl() => _prefs?.getString(_avatarUrlKey);
  static List<String> getPermissions() =>
      _prefs?.getStringList(_permissionsKey) ?? [];
  static List<String> getCustomPermissions() =>
      _prefs?.getStringList(_customPermissionsKey) ?? [];

  static bool hasToken() => getToken() != null && getToken()!.isNotEmpty;

  static Future<void> saveUserSession({
    required String token,
    int? roleId,
    String? roleName,
    String? roleKey,
    List<String> permissions = const [],
    List<String> customPermissions = const [],
    int? userId,
    String? userName,
    String? userPhone,
    String? userEmail,
    String? avatarUrl,
  }) async {
    await _prefs?.setString(_tokenKey, token);
    if (roleId != null) await _prefs?.setInt(_roleIdKey, roleId);
    if (roleName != null) await _prefs?.setString(_roleNameKey, roleName);
    if (roleKey != null) await _prefs?.setString(_roleKeyKey, roleKey);
    await _prefs?.setStringList(_permissionsKey, permissions);
    await _prefs?.setStringList(_customPermissionsKey, customPermissions);
    if (userId != null) await _prefs?.setInt(_userIdKey, userId);
    if (userName != null) await _prefs?.setString(_userNameKey, userName);
    if (userPhone != null) await _prefs?.setString(_userPhoneKey, userPhone);
    if (userEmail != null) await _prefs?.setString(_userEmailKey, userEmail);
    if (avatarUrl != null) await saveAvatarUrl(avatarUrl);
  }

  static Future<void> saveSession({
    required String token,
    int? roleId,
    String? roleName,
    String? roleKey,
    List<String> permissions = const [],
    List<String> customPermissions = const [],
    int? userId,
    String? userName,
    String? userPhone,
    String? userEmail,
    String? avatarUrl,
  }) async {
    await saveUserSession(
      token: token,
      roleId: roleId,
      roleName: roleName,
      roleKey: roleKey,
      permissions: permissions,
      customPermissions: customPermissions,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      userEmail: userEmail,
      avatarUrl: avatarUrl,
    );
  }

  static Future<void> savePermissions({
    String? roleKey,
    List<String> permissions = const [],
    List<String> customPermissions = const [],
  }) async {
    if (roleKey != null) {
      await _prefs?.setString(_roleKeyKey, roleKey);
    }
    await _prefs?.setStringList(_permissionsKey, permissions);
    await _prefs?.setStringList(_customPermissionsKey, customPermissions);
  }

  static Future<void> saveAvatarUrl(String? url, {bool? bustCache}) async {
    if (url != null && url.isNotEmpty) {
      await _prefs?.setString(_avatarUrlKey, url);
      avatarUrlListenable.value = url;
    } else {
      await _prefs?.remove(_avatarUrlKey);
      avatarUrlListenable.value = null;
    }
  }

  static Future<void> updateUserName(String name) async {
    await _prefs?.setString(_userNameKey, name);
  }

  static Future<void> updateUserEmail(String email) async {
    await _prefs?.setString(_userEmailKey, email);
  }

  static Future<void> updateRoleAndPermissions({
    String? roleKey,
    List<String> permissions = const [],
  }) async {
    if (roleKey != null) {
      await _prefs?.setString(_roleKeyKey, roleKey);
    }
    await _prefs?.setStringList(_permissionsKey, permissions);
  }

  static Future<void> clearSession() async {
    await _prefs?.remove(_tokenKey);
    await _prefs?.remove(_roleIdKey);
    await _prefs?.remove(_roleNameKey);
    await _prefs?.remove(_roleKeyKey);
    await _prefs?.remove(_userIdKey);
    await _prefs?.remove(_userNameKey);
    await _prefs?.remove(_userPhoneKey);
    await _prefs?.remove(_userEmailKey);
    await _prefs?.remove(_permissionsKey);
    await _prefs?.remove(_customPermissionsKey);
    await saveAvatarUrl(null);
  }

  static Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }
}
