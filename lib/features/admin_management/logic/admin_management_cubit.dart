import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/create_admin_request_model.dart';
import '../data/models/update_admin_request_model.dart';
import '../data/repositories/admin_management_repository.dart';
import 'admin_management_state.dart';

class AdminManagementCubit extends Cubit<AdminManagementState> {
  final AdminManagementRepository _repository;
  Timer? _debounceTimer;

  AdminManagementCubit(this._repository) : super(const AdminManagementState());

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  /// 1. GET /api/admin/admins (with optional search)
  Future<void> fetchAdmins({String? search}) async {
    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      searchQuery: search,
    ));

    try {
      final adminsList = await _repository.getAdmins(search: search);
      emit(state.copyWith(
        isLoading: false,
        admins: adminsList,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Search with Debounce (500ms) to avoid spamming the backend API
  void searchAdmins(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchAdmins(search: query);
    });
  }

  /// 2. GET /api/admin/admins/{id}
  Future<void> fetchAdminDetails(int id) async {
    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final details = await _repository.getAdminDetails(id);
      emit(state.copyWith(
        isLoading: false,
        selectedAdmin: details,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// 3. POST /api/admin/admins (Create)
  Future<bool> createAdmin(CreateAdminRequestModel request) async {
    if (state.isCreating) return false;
    emit(state.copyWith(
      isCreating: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final createdAdmin = await _repository.createAdmin(request);
      emit(state.copyWith(
        isCreating: false,
        successMessage: 'تم إضافة المشرف (${createdAdmin.fullName}) بنجاح!',
      ));
      // Re-fetch clean list directly from Backend REST API
      await fetchAdmins(search: state.searchQuery);
      return true;
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  /// 4. POST /api/admin/admins/{id} (Update)
  Future<bool> updateAdmin(int id, UpdateAdminRequestModel request) async {
    if (state.isUpdating) return false;
    emit(state.copyWith(
      isUpdating: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final updatedAdmin = await _repository.updateAdmin(id, request);
      emit(state.copyWith(
        isUpdating: false,
        successMessage: 'تم تحديث بيانات المشرف (${updatedAdmin.fullName}) بنجاح!',
      ));
      // Re-fetch clean list directly from Backend REST API
      await fetchAdmins(search: state.searchQuery);
      return true;
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  /// Toggle Admin Active / Inactive Status
  Future<bool> toggleAdminStatus(int id, bool currentStatus) async {
    return await updateAdmin(
      id,
      UpdateAdminRequestModel(isActive: !currentStatus),
    );
  }

  /// Approve Email Change Token
  Future<bool> approveEmailChange(String token) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final msg = await _repository.approveEmailChange(token);
      emit(state.copyWith(
        isLoading: false,
        successMessage: msg,
      ));
      await fetchAdmins(search: state.searchQuery);
      return true;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  /// Reject Email Change Token
  Future<bool> rejectEmailChange(String token) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final msg = await _repository.rejectEmailChange(token);
      emit(state.copyWith(
        isLoading: false,
        successMessage: msg,
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

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
