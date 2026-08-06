class AdminPasswordResetState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final String? email;
  final bool isOtpVerified;

  const AdminPasswordResetState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.email,
    this.isOtpVerified = false,
  });

  AdminPasswordResetState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    String? email,
    bool clearEmail = false,
    bool? isOtpVerified,
  }) {
    return AdminPasswordResetState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
      email: clearEmail ? null : email ?? this.email,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
    );
  }
}
