import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_auth_state.dart';
import '../data/models/admin_user_model.dart';
import '../data/models/login_request_model.dart';
import '../data/repositories/admin_auth_repository.dart';
import '../../../core/services/storage_service.dart';

class AdminAuthCubit extends Cubit<AdminAuthState> {
  final AdminAuthRepository _repository;

  AdminAuthCubit(this._repository) : super(const AdminAuthState());

  // دالة فحص الجلسة شاشة الـ Splash
  Future<bool> checkAuthStatus() async {
    final token = StorageService.getToken();
    final roleId = StorageService.getRoleId();

    // التحقق من وجود توكن وأن الـ Role لأدمن أو مشرف (1 أو 2)
    if (token != null && token.isNotEmpty && (roleId == 1 || roleId == 2)) {
      emit(state.copyWith(
        currentUser: AdminUserModel(
          id: StorageService.getUserId() ?? 0,
          fullName: StorageService.getUserName() ?? 'المسؤول',
          phoneNumber: StorageService.getUserPhone() ?? '',
          roleId: roleId ?? 1,
          isActive: true,
          accessToken: token,
        ),
      ));
      return true;
    }
    return false;
  }

  // تسجيل الدخول ورسائل الأخطاء
  Future<bool> login({
    required String phone,
    required String password,
    String? fcmToken,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      final request = LoginRequestModel(
        phoneNumber: phone,
        password: password,
        platform: 'web',
        deviceName: 'Web_Admin_Dashboard',
        fcmToken: fcmToken,
      );

      final user = await _repository.login(request);

      // التحقق من الصلاحيات (Role Check)
      if (user.roleId != 1 && user.roleId != 2) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'هذا الحساب لا يمتلك صلاحية الوصول للوحة التحكم.',
        ));
        return false;
      }

      // حفظ الجلسة في SharedPreferences
      await StorageService.saveSession(
        token: user.accessToken,
        roleId: user.roleId,
        userId: user.id,
        userName: user.fullName,
        userPhone: user.phoneNumber,
      );

      emit(state.copyWith(isLoading: false, currentUser: user));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    emit(state.copyWith(isLoading: true));
    await _repository.logout();
    await StorageService.clearAll();
    emit(const AdminAuthState());
  }
}
