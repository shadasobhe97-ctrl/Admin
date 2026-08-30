import 'storage_service.dart';

/// الخدمة المركزية الموحدة للتحقق من صلاحيات المشرف الحالي.
///
/// يدعم الـ Super Admin (`role_key == 'super_admin'`, `role_id == 1`, أو الصلاحية `*`)
/// لضمان امتلاك جميع الصلاحيات دون الحاجة لجدول ثابت.
class PermissionHelper {
  const PermissionHelper._();

  /// هل المشرف الحالي هو المدير الرئيسي (Super Admin)؟
  static bool isSuperAdmin() {
    final roleKey = StorageService.getRoleKey()?.toLowerCase();
    if (roleKey == 'super_admin' || roleKey == 'superadmin') return true;

    final roleId = StorageService.getRoleId();
    if (roleId == 1) return true;

    final permissions = StorageService.getPermissions();
    if (permissions.contains('*')) return true;

    final customPermissions = StorageService.getCustomPermissions();
    if (customPermissions.contains('*')) return true;

    return false;
  }

  /// يرجع true إذا كان المشرف يملك الصلاحية المحددة أو يملك `*` أو كان Super Admin.
  static bool hasPermission(String permission) {
    if (permission.trim().isEmpty) return true;
    if (isSuperAdmin()) return true;

    final permissions = StorageService.getPermissions();
    if (permissions.contains(permission) || permissions.contains('*')) {
      return true;
    }

    final customPermissions = StorageService.getCustomPermissions();
    if (customPermissions.contains(permission) ||
        customPermissions.contains('*')) {
      return true;
    }

    return false;
  }

  /// يرجع true إذا كان المشرف يملك أي صلاحية واحدة على الأقل من القائمة الممررة.
  static bool hasAnyPermission(List<String> permissions) {
    if (permissions.isEmpty) return true;
    if (isSuperAdmin()) return true;

    for (final perm in permissions) {
      if (hasPermission(perm)) return true;
    }
    return false;
  }

  /// يرجع true إذا كان المشرف يملك جميع الصلاحيات المحددة في القائمة الممررة.
  static bool hasAllPermissions(List<String> permissions) {
    if (permissions.isEmpty) return true;
    if (isSuperAdmin()) return true;

    for (final perm in permissions) {
      if (!hasPermission(perm)) return false;
    }
    return true;
  }
}
