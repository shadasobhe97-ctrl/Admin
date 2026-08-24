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
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _userEmailKey = 'user_email';
  static const String _avatarUrlKey = 'user_avatar_url';

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
  static int? getUserId() => _prefs?.getInt(_userIdKey);
  static String? getUserName() => _prefs?.getString(_userNameKey);
  static String? getUserPhone() => _prefs?.getString(_userPhoneKey);
  static String? getUserEmail() => _prefs?.getString(_userEmailKey);
  static String? getAvatarUrl() => _prefs?.getString(_avatarUrlKey);

  /// يحفظ رابط صورة الحساب ويُخطر المستمعين فوراً.
  /// تمرير قيمة فارغة يمسح الصورة المخزّنة.
  ///
  /// [bustCache] يلزم بعد رفع صورة جديدة: الخادم يعيد الصورة على المسار
  /// نفسه غالباً، فلا يتغيّر النص ولا يُخطَر المستمعون، ويبقى Flutter
  /// يعرض البايتات القديمة من ذاكرة الصور. إضافة بصمة وقت للرابط المعروض
  /// تكسر الحالتين معاً، بينما يبقى المخزَّن نظيفاً.
  static Future<void> saveAvatarUrl(String? url, {bool bustCache = false}) async {
    final value = url?.trim() ?? '';
    if (value.isEmpty) {
      await _prefs?.remove(_avatarUrlKey);
    } else {
      await _prefs?.setString(_avatarUrlKey, value);
    }

    final stored = getAvatarUrl();
    avatarUrlListenable.value = stored == null || !bustCache
        ? stored
        : _withCacheBuster(stored);
  }

  /// عدّاد يضمن اختلاف البصمة حتى لو تتابع حفظان في المللي ثانية نفسها.
  static int _avatarRevision = 0;

  /// يضيف بصمة إلى الرابط لتجاوز ذاكرة الصور.
  static String _withCacheBuster(String url) {
    _avatarRevision++;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}v=${DateTime.now().millisecondsSinceEpoch}'
        '-$_avatarRevision';
  }

  static Future<bool> saveSession({
    required String token,
    required int roleId,
    String roleName = 'مدير النظام',
    required int userId,
    required String userName,
    required String userPhone,
    String userEmail = '',
    String? avatarUrl,
  }) async {
    await _prefs?.setString(_tokenKey, token);
    await _prefs?.setInt(_roleIdKey, roleId);
    await _prefs?.setString(_roleNameKey, roleName);
    await _prefs?.setInt(_userIdKey, userId);
    await _prefs?.setString(_userNameKey, userName);
    await _prefs?.setString(_userPhoneKey, userPhone);
    await saveAvatarUrl(avatarUrl);
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
    await saveAvatarUrl(null);
  }

  static Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }
}
