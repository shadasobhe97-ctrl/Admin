import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/admin_profile_model.dart';
import '../../data/repositories/admin_profile_repository.dart';
import '../state/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AdminProfileRepository _repository;

  ProfileCubit(this._repository) : super(const ProfileInitial());

  Future<void> fetchProfile() async {
    emit(const ProfileLoading());
    try {
      final profile = await _repository.getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateProfile({
    required dynamic adminId,
    required Map<String, dynamic> changedFields,
    required AdminProfileModel currentProfile,
  }) async {
    if (changedFields.isEmpty) {
      return;
    }
    emit(ProfileUpdating(currentProfile));
    try {
      final result = await _repository.updateProfile(adminId, changedFields);
      final String message = result['message']?.toString() ?? 'تم تحديث البيانات بنجاح.';

      AdminProfileModel updatedProfile = currentProfile;
      if (result['profile'] is AdminProfileModel) {
        updatedProfile = result['profile'] as AdminProfileModel;
      } else {
        // Merge changed fields into current profile model
        updatedProfile = currentProfile.copyWith(
          fullName: changedFields['full_name']?.toString() ?? currentProfile.fullName,
          email: changedFields['email']?.toString() ?? currentProfile.email,
          phoneNumber: changedFields['phone_number']?.toString() ?? currentProfile.phoneNumber,
        );
      }

      emit(ProfileUpdateSuccess(profile: updatedProfile, message: message));
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(ProfileUpdateError(currentProfile: currentProfile, message: errorMsg));
      emit(ProfileLoaded(currentProfile));
    }
  }
}
