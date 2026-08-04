import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_auth_state.dart';
import '../data/models/admin_user_model.dart';
import '../data/models/login_request_model.dart';
import '../data/repositories/admin_auth_repository.dart';
import '../../../core/services/storage_service.dart';

class AdminAuthCubit extends Cubit<AdminAuthState> {
  final AdminAuthRepository _repository;

  AdminAuthCubit(this._repository) : super(const AdminAuthState());

  // دالة فحص الجلسة لشاشة الـ Splash
  Future<bool> checkAuthStatus() async {
    final token = StorageService.getToken();
    final roleId = StorageService.getRoleId();

    // التحقق من وجود توكن وأن الـ Role لأدمن أو مشرف
    if (token != null && token.isNotEmpty && (roleId == 1 || roleId == 2)) {
      emit(state.copyWith(
        currentUser: AdminUserModel(
          id: StorageService.getUserId() ?? 0,
          fullName: StorageService.getUserName() ?? 'الآدمن الرئيسي',
          phoneNumber: StorageService.getUserPhone() ?? '',
          email: StorageService.getUserEmail() ?? 'admin@darby.ly',
          roleId: roleId ?? 1,
          roleName: StorageService.getRoleName() ?? 'مدير النظام',
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
        deviceName: 'admin_web_browser',
        fcmToken: fcmToken ?? 'fcm_token_sample_string',
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
        roleName: user.roleName,
        userId: user.id,
        userName: user.fullName,
        userPhone: user.phoneNumber,
        userEmail: user.email,
      );

      emit(state.copyWith(isLoading: false, currentUser: user, successMessage: 'تم تسجيل الدخول بنجاح!'));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  // طلب استعادة كلمة المرور
  Future<bool> sendPasswordResetCode(String phone) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final res = await _repository.sendPasswordResetCode(phone);
      emit(state.copyWith(
        isLoading: false,
        successMessage: res['message'] ?? 'تم إرسال رمز التحقق بنجاح.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  // إعادة تعيين كلمة المرور
  Future<bool> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final res = await _repository.resetPassword(
        phoneNumber: phone,
        code: code,
        newPassword: newPassword,
      );
      emit(state.copyWith(
        isLoading: false,
        successMessage: res['message'] ?? 'تم إعادة تعيين كلمة المرور بنجاح!',
      ));
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
