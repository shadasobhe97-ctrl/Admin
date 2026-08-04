import '../data/models/admin_user_model.dart';

class AdminAuthState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final AdminUserModel? currentUser;

  const AdminAuthState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.currentUser,
  });

  bool get isAuthenticated => currentUser != null;

  AdminAuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    AdminUserModel? currentUser,
    bool clearUser = false,
  }) {
    return AdminAuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
      currentUser: clearUser ? null : currentUser ?? this.currentUser,
    );
  }
}
