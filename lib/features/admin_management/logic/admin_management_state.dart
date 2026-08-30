import '../data/models/admin_details_model.dart';
import '../data/models/admin_model.dart';
import '../data/models/roles_permissions_model.dart';

class AdminManagementState {
  final List<AdminModel> admins;
  final AdminDetailsModel? selectedAdmin;
  final List<RoleModel> roles;
  final List<PermissionGroupModel> permissionsTree;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isRolesLoading;
  final String? errorMessage;
  final String? successMessage;
  final String? searchQuery;

  const AdminManagementState({
    this.admins = const [],
    this.selectedAdmin,
    this.roles = const [],
    this.permissionsTree = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isRolesLoading = false,
    this.errorMessage,
    this.successMessage,
    this.searchQuery,
  });

  bool get isEmpty => !isLoading && admins.isEmpty;

  AdminManagementState copyWith({
    List<AdminModel>? admins,
    AdminDetailsModel? selectedAdmin,
    bool clearSelectedAdmin = false,
    List<RoleModel>? roles,
    List<PermissionGroupModel>? permissionsTree,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isRolesLoading,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    String? searchQuery,
  }) {
    return AdminManagementState(
      admins: admins ?? this.admins,
      selectedAdmin: clearSelectedAdmin ? null : (selectedAdmin ?? this.selectedAdmin),
      roles: roles ?? this.roles,
      permissionsTree: permissionsTree ?? this.permissionsTree,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isRolesLoading: isRolesLoading ?? this.isRolesLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
