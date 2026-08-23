import '../../data/models/admin_profile_model.dart';
import '../../data/models/email_change_status_model.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final AdminProfileModel profile;
  final EmailVerificationInfo? emailVerification;
  final EmailChangeStatusModel? emailStatus;
  final Map<String, List<String>>? fieldErrors;

  const ProfileLoaded({
    required this.profile,
    this.emailVerification,
    this.emailStatus,
    this.fieldErrors,
  });

  ProfileLoaded copyWith({
    AdminProfileModel? profile,
    EmailVerificationInfo? emailVerification,
    EmailChangeStatusModel? emailStatus,
    Map<String, List<String>>? fieldErrors,
    bool clearFieldErrors = false,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      emailVerification: emailVerification ?? this.emailVerification,
      emailStatus: emailStatus ?? this.emailStatus,
      fieldErrors: clearFieldErrors ? null : (fieldErrors ?? this.fieldErrors),
    );
  }
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}

class ProfileUpdating extends ProfileState {
  final AdminProfileModel currentProfile;
  const ProfileUpdating(this.currentProfile);
}

class ProfileUpdateSuccess extends ProfileState {
  final AdminProfileModel profile;
  final String message;
  final EmailVerificationInfo? emailVerification;

  const ProfileUpdateSuccess({
    required this.profile,
    required this.message,
    this.emailVerification,
  });
}

class ProfileUpdateError extends ProfileState {
  final AdminProfileModel currentProfile;
  final String message;
  final Map<String, List<String>> fieldErrors;

  const ProfileUpdateError({
    required this.currentProfile,
    required this.message,
    this.fieldErrors = const {},
  });
}

class EmailActionLoading extends ProfileState {
  final AdminProfileModel currentProfile;
  final String actionType; // 'resend', 'cancel', 'status'

  const EmailActionLoading({
    required this.currentProfile,
    required this.actionType,
  });
}

class EmailActionSuccess extends ProfileState {
  final AdminProfileModel profile;
  final String message;
  final String actionType; // 'resend', 'cancel'

  const EmailActionSuccess({
    required this.profile,
    required this.message,
    required this.actionType,
  });
}

class EmailActionError extends ProfileState {
  final AdminProfileModel currentProfile;
  final String message;

  const EmailActionError({
    required this.currentProfile,
    required this.message,
  });
}
