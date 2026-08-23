import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/admin_profile_model.dart';
import '../../data/models/email_change_status_model.dart';
import '../../data/models/profile_update_request.dart';
import '../../data/repositories/admin_profile_repository.dart';
import '../state/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AdminProfileRepository _repository;

  ProfileCubit(this._repository) : super(const ProfileInitial());

  Future<void> fetchProfile() async {
    emit(const ProfileLoading());
    try {
      final profile = await _repository.getProfile();
      EmailChangeStatusModel? status;

      if (profile.emailChangePending == true) {
        try {
          status = await _repository.getEmailChangeStatus();
        } catch (_) {
          // If status fetch fails, keep profile data as primary
        }
      }

      emit(ProfileLoaded(
        profile: profile,
        emailStatus: status,
      ));
    } catch (e) {
      final msg = e is ApiException
          ? e.detailedMessage
          : e.toString().replaceAll('Exception: ', '');
      emit(ProfileError(msg));
    }
  }

  Future<void> updateProfile({
    required ProfileUpdateRequest request,
    required AdminProfileModel currentProfile,
  }) async {
    if (request.isEmpty) return;

    emit(ProfileUpdating(currentProfile));
    try {
      final result = await _repository.updateProfile(request);
      final String message =
          result['message']?.toString() ?? 'تم تحديث ملفك الشخصي بنجاح.';
      final EmailVerificationInfo? verificationInfo =
          result['email_verification'] as EmailVerificationInfo?;

      AdminProfileModel updatedProfile = currentProfile;
      if (result['profile'] is AdminProfileModel) {
        updatedProfile = result['profile'] as AdminProfileModel;
      } else {
        updatedProfile = currentProfile.copyWith(
          fullName: request.fullName ?? currentProfile.fullName,
          email: request.email ?? currentProfile.email,
          phoneNumber: request.phoneNumber ?? currentProfile.phoneNumber,
          emailChangePending: verificationInfo != null ? true : currentProfile.emailChangePending,
          pendingNewEmail: verificationInfo != null ? request.email : currentProfile.pendingNewEmail,
        );
      }

      emit(ProfileUpdateSuccess(
        profile: updatedProfile,
        message: message,
        emailVerification: verificationInfo,
      ));

      emit(ProfileLoaded(
        profile: updatedProfile,
        emailVerification: verificationInfo,
      ));
    } catch (e) {
      Map<String, List<String>> fieldErrors = {};
      String errorMsg = e.toString().replaceAll('Exception: ', '');

      if (e is ApiException) {
        fieldErrors = e.errors;
        errorMsg = e.detailedMessage;
      }

      emit(ProfileUpdateError(
        currentProfile: currentProfile,
        message: errorMsg,
        fieldErrors: fieldErrors,
      ));

      emit(ProfileLoaded(
        profile: currentProfile,
        fieldErrors: fieldErrors,
      ));
    }
  }

  Future<void> checkEmailChangeStatus(AdminProfileModel currentProfile) async {
    emit(EmailActionLoading(
      currentProfile: currentProfile,
      actionType: 'status',
    ));
    try {
      final status = await _repository.getEmailChangeStatus();
      if (!status.pending) {
        // Status resolved, re-fetch profile
        final freshProfile = await _repository.getProfile();
        emit(ProfileLoaded(profile: freshProfile, emailStatus: status));
      } else {
        emit(ProfileLoaded(profile: currentProfile, emailStatus: status));
      }
    } catch (e) {
      final msg = e is ApiException
          ? e.detailedMessage
          : e.toString().replaceAll('Exception: ', '');
      emit(EmailActionError(
        currentProfile: currentProfile,
        message: msg,
      ));
      emit(ProfileLoaded(profile: currentProfile));
    }
  }

  Future<void> resendEmailVerification(AdminProfileModel currentProfile) async {
    emit(EmailActionLoading(
      currentProfile: currentProfile,
      actionType: 'resend',
    ));
    try {
      final msg = await _repository.resendEmailVerification();
      emit(EmailActionSuccess(
        profile: currentProfile,
        message: msg,
        actionType: 'resend',
      ));
      emit(ProfileLoaded(profile: currentProfile));
    } catch (e) {
      final msg = e is ApiException
          ? e.detailedMessage
          : e.toString().replaceAll('Exception: ', '');
      emit(EmailActionError(
        currentProfile: currentProfile,
        message: msg,
      ));
      emit(ProfileLoaded(profile: currentProfile));
    }
  }

  Future<void> cancelEmailChange(AdminProfileModel currentProfile) async {
    emit(EmailActionLoading(
      currentProfile: currentProfile,
      actionType: 'cancel',
    ));
    try {
      final msg = await _repository.cancelEmailChange();
      final freshProfile = await _repository.getProfile();
      emit(EmailActionSuccess(
        profile: freshProfile,
        message: msg,
        actionType: 'cancel',
      ));
      emit(ProfileLoaded(profile: freshProfile));
    } catch (e) {
      final msg = e is ApiException
          ? e.detailedMessage
          : e.toString().replaceAll('Exception: ', '');
      emit(EmailActionError(
        currentProfile: currentProfile,
        message: msg,
      ));
      emit(ProfileLoaded(profile: currentProfile));
    }
  }
}
