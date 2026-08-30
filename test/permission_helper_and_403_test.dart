import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:admin_panel/core/services/storage_service.dart';
import 'package:admin_panel/core/services/permission_helper.dart';
import 'package:admin_panel/core/network/api_exception.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PermissionHelper Unit Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.init();
    });

    test('Super Admin detection via roleKey', () async {
      await StorageService.saveSession(
        token: 'test-token',
        userId: 2,
        userName: 'Super Admin',
        userPhone: '0912345678',
        userEmail: 'super@test.com',
        roleId: 2,
        roleName: 'مدير النظام',
        roleKey: 'super_admin',
        permissions: ['*'],
      );

      expect(PermissionHelper.isSuperAdmin(), isTrue);
      expect(PermissionHelper.hasPermission('admins.manage'), isTrue);
      expect(PermissionHelper.hasPermission('any.random.permission'), isTrue);
    });

    test('Super Admin detection via roleId == 1', () async {
      await StorageService.saveSession(
        token: 'test-token',
        userId: 1,
        userName: 'Main Admin',
        userPhone: '0912345678',
        userEmail: 'main@test.com',
        roleId: 1,
        roleName: 'مدير النظام الرئيسي',
        roleKey: 'admin',
        permissions: [],
      );

      expect(PermissionHelper.isSuperAdmin(), isTrue);
      expect(PermissionHelper.hasPermission('drivers.view'), isTrue);
    });

    test('Super Admin detection via wildcard "*"', () async {
      await StorageService.saveSession(
        token: 'test-token',
        userId: 5,
        userName: 'Wildcard Admin',
        userPhone: '0912345678',
        userEmail: 'wild@test.com',
        roleId: 10,
        roleName: 'مشرف عام',
        roleKey: 'custom_role',
        permissions: ['*'],
      );

      expect(PermissionHelper.isSuperAdmin(), isTrue);
      expect(PermissionHelper.hasPermission('financial.manage_withdrawals'), isTrue);
    });

    test('Regular Supervisor base role permissions', () async {
      await StorageService.saveSession(
        token: 'test-token',
        userId: 3,
        userName: 'Fleet Supervisor',
        userPhone: '0912345678',
        userEmail: 'fleet@test.com',
        roleId: 3,
        roleName: 'مشرف السائقين',
        roleKey: 'fleet_supervisor',
        permissions: ['drivers.view', 'drivers.edit_data'],
      );

      expect(PermissionHelper.isSuperAdmin(), isFalse);
      expect(PermissionHelper.hasPermission('drivers.view'), isTrue);
      expect(PermissionHelper.hasPermission('drivers.edit_data'), isTrue);
      expect(PermissionHelper.hasPermission('admins.manage'), isFalse);
    });

    test('Custom Permissions addition and evaluation', () async {
      await StorageService.savePermissions(
        roleKey: 'support_supervisor',
        permissions: ['complaints.view'],
        customPermissions: ['complaints.resolve', 'reports.view'],
      );

      expect(PermissionHelper.hasPermission('complaints.view'), isTrue);
      expect(PermissionHelper.hasPermission('complaints.resolve'), isTrue);
      expect(PermissionHelper.hasPermission('reports.view'), isTrue);
      expect(PermissionHelper.hasPermission('admins.manage'), isFalse);
    });

    test('Custom Permission removal revokes access', () async {
      // Initially granted complaints.resolve via customPermissions
      await StorageService.savePermissions(
        roleKey: 'support_supervisor',
        permissions: ['complaints.view'],
        customPermissions: ['complaints.resolve'],
      );
      expect(PermissionHelper.hasPermission('complaints.resolve'), isTrue);

      // Now custom permission is removed (empty list)
      await StorageService.savePermissions(
        roleKey: 'support_supervisor',
        permissions: ['complaints.view'],
        customPermissions: [],
      );

      expect(PermissionHelper.hasPermission('complaints.view'), isTrue);
      expect(PermissionHelper.hasPermission('complaints.resolve'), isFalse);
    });

    test('hasAnyPermission and hasAllPermissions logic', () async {
      await StorageService.savePermissions(
        roleKey: 'finance_officer',
        permissions: ['financial.view_summary', 'financial.view_ledger'],
        customPermissions: [],
      );

      expect(
        PermissionHelper.hasAnyPermission([
          'financial.view_summary',
          'financial.manage_withdrawals',
        ]),
        isTrue,
      );

      expect(
        PermissionHelper.hasAllPermissions([
          'financial.view_summary',
          'financial.view_ledger',
        ]),
        isTrue,
      );

      expect(
        PermissionHelper.hasAllPermissions([
          'financial.view_summary',
          'financial.manage_withdrawals',
        ]),
        isFalse,
      );
    });
  });

  group('HTTP 403 required_permission Parsing Tests', () {
    test('ApiErrorMapper extracts required_permission from 403 Dio response', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/admin/admins'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/admin/admins'),
          statusCode: 403,
          data: {
            'status': false,
            'message': 'Forbidden',
            'required_permission': 'admins.manage',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final apiException = ApiErrorMapper.map(dioException, fallbackMessage: 'خطأ');

      expect(apiException.statusCode, equals(403));
      expect(
        apiException.message,
        contains('غير مصرح لك بتنفيذ هذه العملية. الصلاحية المطلوبة: admins.manage'),
      );
    });

    test('ApiErrorMapper fallback for 403 without required_permission', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/admin/admins'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/admin/admins'),
          statusCode: 403,
          data: {
            'status': false,
            'message': 'غير مصرح لك لدخول هذه الشاشة.',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final apiException = ApiErrorMapper.map(dioException, fallbackMessage: 'خطأ');

      expect(apiException.statusCode, equals(403));
      expect(apiException.message, equals('غير مصرح لك لدخول هذه الشاشة.'));
    });
  });
}
