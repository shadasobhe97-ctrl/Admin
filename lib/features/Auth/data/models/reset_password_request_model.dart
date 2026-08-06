class ResetPasswordRequestModel {
  final String email;
  final String otp;
  final String password;
  final String passwordConfirmation;

  ResetPasswordRequestModel({
    required this.email,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}
