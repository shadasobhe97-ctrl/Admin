import '../../data/models/admin_profile_model.dart';

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
  const ProfileLoaded(this.profile);
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
  const ProfileUpdateSuccess({required this.profile, required this.message});
}

class ProfileUpdateError extends ProfileState {
  final AdminProfileModel currentProfile;
  final String message;
  const ProfileUpdateError({required this.currentProfile, required this.message});
}
