import '../data/models/admin_details_model.dart';
import '../data/models/admin_model.dart';

class AdminManagementState {
  final List<AdminModel> admins;
  final AdminDetailsModel? selectedAdmin;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final String? errorMessage;
  final String? successMessage;
  final String? searchQuery;

  const AdminManagementState({
    this.admins = const [],
    this.selectedAdmin,
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.errorMessage,
    this.successMessage,
    this.searchQuery,
  });

  bool get isEmpty => !isLoading && admins.isEmpty;

  AdminManagementState copyWith({
    List<AdminModel>? admins,
    AdminDetailsModel? selectedAdmin,
    bool clearSelectedAdmin = false,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    String? searchQuery,
  }) {
    return AdminManagementState(
      admins: admins ?? this.admins,
      selectedAdmin: clearSelectedAdmin ? null : (selectedAdmin ?? this.selectedAdmin),
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
