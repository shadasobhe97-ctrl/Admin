import 'package:dio/dio.dart';

class UpdateAdminRequestModel {
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? password;
  final int? roleId;
  final bool? isActive;
  final List<int>? avatarBytes;
  final String? avatarFileName;

  UpdateAdminRequestModel({
    this.fullName,
    this.email,
    this.phoneNumber,
    this.password,
    this.roleId,
    this.isActive,
    this.avatarBytes,
    this.avatarFileName,
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> map = {};

    if (fullName != null && fullName!.isNotEmpty) map['full_name'] = fullName;
    if (email != null && email!.isNotEmpty) map['email'] = email;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) map['phone_number'] = phoneNumber;
    if (password != null && password!.isNotEmpty) map['password'] = password;
    if (roleId != null) map['role_id'] = roleId;
    if (isActive != null) map['is_active'] = isActive! ? 1 : 0;

    if (avatarBytes != null && avatarBytes!.isNotEmpty) {
      map['avatar'] = MultipartFile.fromBytes(
        avatarBytes!,
        filename: avatarFileName ?? 'avatar.jpg',
      );
    }

    return FormData.fromMap(map);
  }
}
