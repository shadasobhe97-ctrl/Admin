import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_password_reset_state.dart';
import '../data/models/reset_password_request_model.dart';
import '../data/models/send_otp_request_model.dart';
import '../data/models/verify_otp_request_model.dart';
import '../data/repositories/admin_password_reset_repository.dart';

class AdminPasswordResetCubit extends Cubit<AdminPasswordResetState> {
  final AdminPasswordResetRepository _repository;

  AdminPasswordResetCubit(this._repository) : super(const AdminPasswordResetState());

  // الخطوة 1: إرسال طلب إعادة تعيين كلمة المرور (Send OTP)
  Future<bool> sendOtp({required String email}) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final res = await _repository.sendOtp(SendOtpRequestModel(email: email));
      emit(state.copyWith(
        isLoading: false,
        successMessage: res.message.isNotEmpty ? res.message : 'تم إرسال رمز التحقق بنجاح إلى بريدك الإلكتروني.',
        email: email,
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

  // الخطوة 2: التحقق من رمز OTP
  Future<bool> verifyOtp({required String email, required String otp}) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final res = await _repository.verifyOtp(VerifyOtpRequestModel(email: email, otp: otp));
      emit(state.copyWith(
        isLoading: false,
        successMessage: res.message.isNotEmpty ? res.message : 'تم التحقق من الرمز بنجاح.',
        isOtpVerified: true,
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

  // الخطوة 3: تغيير كلمة المرور (Reset Password)
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final res = await _repository.resetPassword(
        ResetPasswordRequestModel(
          email: email,
          otp: otp,
          password: newPassword,
          passwordConfirmation: confirmPassword,
        ),
      );
      emit(state.copyWith(
        isLoading: false,
        successMessage: res.message.isNotEmpty
            ? res.message
            : 'تم إعادة تعيين كلمة المرور بنجاح. يمكنك الآن تسجيل الدخول.',
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

  // إعادة إرسال رمز التحقق
  Future<bool> resendOtp({required String email}) {
    return sendOtp(email: email);
  }

  void resetState() {
    emit(const AdminPasswordResetState());
  }
}
