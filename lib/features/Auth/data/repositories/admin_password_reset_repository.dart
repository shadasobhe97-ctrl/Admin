import '../datasources/password_reset_remote_data_source.dart';
import '../models/password_reset_response_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/send_otp_request_model.dart';
import '../models/verify_otp_request_model.dart';

class AdminPasswordResetRepository {
  final PasswordResetRemoteDataSource _dataSource;

  AdminPasswordResetRepository(this._dataSource);

  Future<PasswordResetResponseModel> sendOtp(SendOtpRequestModel request) {
    return _dataSource.sendOtp(request);
  }

  Future<PasswordResetResponseModel> verifyOtp(VerifyOtpRequestModel request) {
    return _dataSource.verifyOtp(request);
  }

  Future<PasswordResetResponseModel> resetPassword(ResetPasswordRequestModel request) {
    return _dataSource.resetPassword(request);
  }
}
