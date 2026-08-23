import 'package:dio/dio.dart';

class ProfileUpdateRequest {
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? currentPassword;
  final String? password;
  final String? passwordConfirmation;
  final List<int>? avatarBytes;
  final String? avatarFileName;

  const ProfileUpdateRequest({
    this.fullName,
    this.email,
    this.phoneNumber,
    this.currentPassword,
    this.password,
    this.passwordConfirmation,
    this.avatarBytes,
    this.avatarFileName,
  });

  bool get isEmpty =>
      (fullName == null || fullName!.trim().isEmpty) &&
      (email == null || email!.trim().isEmpty) &&
      (phoneNumber == null || phoneNumber!.trim().isEmpty) &&
      (password == null || password!.isEmpty) &&
      (avatarBytes == null || avatarBytes!.isEmpty);

  FormData toFormData() {
    final Map<String, dynamic> map = {};

    if (fullName != null && fullName!.trim().isNotEmpty) {
      map['full_name'] = fullName!.trim();
    }
    if (email != null && email!.trim().isNotEmpty) {
      map['email'] = email!.trim();
    }
    if (phoneNumber != null && phoneNumber!.trim().isNotEmpty) {
      map['phone_number'] = phoneNumber!.trim();
    }
    if (currentPassword != null && currentPassword!.isNotEmpty) {
      map['current_password'] = currentPassword;
    }
    if (password != null && password!.isNotEmpty) {
      map['password'] = password;
    }
    if (passwordConfirmation != null && passwordConfirmation!.isNotEmpty) {
      map['password_confirmation'] = passwordConfirmation;
    }

    if (avatarBytes != null && avatarBytes!.isNotEmpty) {
      final fileName = avatarFileName ?? 'avatar.jpg';
      map['avatar'] = MultipartFile.fromBytes(
        avatarBytes!,
        filename: fileName,
      );
    }

    return FormData.fromMap(map);
  }
}
