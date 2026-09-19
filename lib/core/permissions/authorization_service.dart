import '../services/storage_service.dart';

/// نقطة الفحص المركزية الوحيدة للصلاحيات (RBAC V2).
///
/// لا تعرف هذه الخدمة أي شيء عن الأدوار (roleId/roleKey/roleName) — تقرأ
/// فقط `permissions[]` كما وصلت من الخادم (Login أو `/admin/profile`)
/// وتُخزَّن في [StorageService]، والخادم هو المصدر الوحيد للحقيقة.
class AuthorizationService {
  const AuthorizationService._();

  static List<String> get _permissions => StorageService.getPermissions();

  /// `*` (كل الصلاحيات)، `category.*` (كل صلاحيات فئة)، أو تطابق تام.
  static bool hasPermission(String permission) {
    final permissions = _permissions;
    if (permissions.contains('*')) return true;
    if (permissions.contains(permission)) return true;

    final dotIndex = permission.indexOf('.');
    if (dotIndex == -1) return false;
    final category = permission.substring(0, dotIndex);
    return permissions.contains('$category.*');
  }

  static bool hasAnyPermission(List<String> permissions) =>
      permissions.any(hasPermission);

  static bool hasAllPermissions(List<String> permissions) =>
      permissions.every(hasPermission);
}
